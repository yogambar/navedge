import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../core/constants/api_constants.dart';
import '../core/models/prediction_model.dart';
import '../core/services/directions_service.dart';
import '../core/services/location_service.dart';
import '../core/services/street_view_service.dart';
import '../core/utils/permission_handler.dart';
import '../widgets/route_info_widget.dart';
import '../widgets/street_view_button.dart';
import '../widgets/street_view_dialog.dart';
import '../user_data_provider.dart'; // Ensure this import is correct

class MapScreen extends StatefulWidget {
  final Map<gmaps.LatLng, Map<gmaps.LatLng, double>>? initialGraph;

  const MapScreen({
    Key? key,
    this.initialGraph,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final Set<gmaps.Marker> _markers = {};
  final Set<gmaps.Polyline> _polylines = {};
  gmaps.GoogleMapController? _mapController;
  final Completer<gmaps.GoogleMapController> _mapCompleter =
      Completer<gmaps.GoogleMapController>();
  gmaps.LatLng? _currentLocation;
  gmaps.LatLng? _sourceLatLng;
  gmaps.LatLng? _destinationLatLng;
  gmaps.LatLng _defaultLocation = const gmaps.LatLng(30.3165, 78.0322); // Dehradun
  final Map<String, String> _vehicleIcons = {
    'driving': 'assets/images/icons/car.png',
    'walking': 'assets/images/icons/walk.png',
    'bicycling': 'assets/images/icons/bike.png',
  };
  double _currentZoom = 12.0;
  bool _isLoading = true;
  double? _routeDistanceKm;
  String? _routeDuration;
  StreamSubscription<Position>? _positionStream;
  gmaps.LatLng? _lastPosition;
  double _currentRouteBearing = 0.0; // Initial bearing
  gmaps.MapType _currentMapType = gmaps.MapType.normal; // For toggling map type
  bool _isFetchingRoutes = false; // To prevent multiple route fetches
  bool _isChangeModeExpanded = false;
  bool _areModeButtonsLoading = true; // For loading animation

  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();
  final StreetViewService _streetViewService = StreetViewService();

  bool _useDirectApi = true; // To control API usage

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndGetCurrentLocation();
    // Simulate loading delay for mode buttons
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _areModeButtonsLoading = false;
        });
      }
    });
    // Set default vehicle mode to driving
    Provider.of<UserData>(context, listen: false).updateSelectedVehicle('driving');
  }

  Future<void> _checkLocationPermissionAndGetCurrentLocation() async {
    final isGranted = await PermissionHandlerService.requestLocationPermission();
    if (isGranted) {
      await _getCurrentLocation();
    } else {
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        _currentLocation = gmaps.LatLng(position.latitude, position.longitude);
        _currentZoom = 15.0;
        _mapCompleter.future.then((controller) {
          controller.animateCamera(
            gmaps.CameraUpdate.newLatLngZoom(_currentLocation!, _currentZoom),
          );
        });
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
      if (mounted) {
        _isLoading = false;
        setState(() {});
      }
    } finally {
      if (_isLoading && mounted) {
        _isLoading = false;
        setState(() {});
      }
    }
  }

  Future<gmaps.LatLng?> _getLatLngFromPlaceId(String placeId) async {
    if (_useDirectApi) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=${ApiConstants.googleApiKey}'); // Assuming you have this in ApiConstants
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final location = data['results'][0]['geometry']['location'];
            return gmaps.LatLng(location['lat'], location['lng']);
          } else {
            debugPrint('Geocoding API returned no results.');
            if (mounted) {
              setState(() => _useDirectApi = false);
            }
            return _getLatLngFromPlaceIdViaProxy(placeId);
          }
        } else {
          debugPrint('Geocoding API failed: ${response.statusCode}');
          debugPrint('Body: ${response.body}');
          if (mounted) {
            setState(() => _useDirectApi = false);
          }
          return _getLatLngFromPlaceIdViaProxy(placeId);
        }
      } catch (e) {
        debugPrint('Geocoding API error: $e');
        if (mounted) {
          setState(() => _useDirectApi = false);
        }
        return _getLatLngFromPlaceIdViaProxy(placeId);
      }
    } else {
      return _getLatLngFromPlaceIdViaProxy(placeId);
    }
  }

  Future<gmaps.LatLng?> _getLatLngFromPlaceIdViaProxy(String placeId) async {
    final url = Uri.parse('${ApiConstants.proxyBaseUrl}/geocode/json?place_id=$placeId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return gmaps.LatLng(location['lat'], location['lng']);
        }
      } else {
        debugPrint('Geocoding via proxy failed: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Geocoding via proxy error: $e');
    }
    return null;
  }

  Future<List<Prediction>> _getPlacePredictions(String input) async {
    if (input.isEmpty) return [];
    if (_useDirectApi) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=${ApiConstants.googleApiKey}'); // Assuming you have this in ApiConstants
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['predictions'] != null) {
            return (data['predictions'] as List)
                .map((json) => Prediction.fromJson(json))
                .toList();
          } else {
            debugPrint('Places Autocomplete API returned no predictions.');
            if (mounted) {
              setState(() => _useDirectApi = false);
            }
            return _getPlacePredictionsViaProxy(input);
          }
        } else {
          debugPrint('Places Autocomplete API failed: ${response.statusCode}');
          debugPrint('Body: ${response.body}');
          if (mounted) {
            setState(() => _useDirectApi = false);
          }
          return _getPlacePredictionsViaProxy(input);
        }
      } catch (e) {
        debugPrint('Places Autocomplete API error: $e');
        if (mounted) {
          setState(() => _useDirectApi = false);
        }
        return _getPlacePredictionsViaProxy(input);
      }
    } else {
      return _getPlacePredictionsViaProxy(input);
    }
  }

  Future<List<Prediction>> _getPlacePredictionsViaProxy(String input) async {
    if (input.isEmpty) return [];
    final url = Uri.parse(
        '${ApiConstants.proxyBaseUrl}/places/autocomplete/json?input=${Uri.encodeComponent(input)}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['predictions'] != null) {
          return (data['predictions'] as List)
              .map((json) => Prediction.fromJson(json))
              .toList();
        }
      } else {
        debugPrint('Autocomplete via proxy failed: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Autocomplete via proxy error: $e');
    }
    return [];
  }

  void _updateSourceLocation(Prediction prediction) async {
    _sourceController.text = prediction.description ?? '';
    final sourceLatLng = await _getLatLngFromPlaceId(prediction.placeId!);
    if (sourceLatLng != null) {
      if (mounted) {
        setState(() {
          _sourceLatLng = sourceLatLng;
          _addMarker('source', _sourceLatLng!, prediction.description ?? '');
          _moveCamera(_sourceLatLng!);
          _updatePolyline(context); // Pass context here
        });
      }
    }
  }

  void _updateDestinationLocation(Prediction prediction) async {
    _destinationController.text = prediction.description ?? '';
    final destinationLatLng = await _getLatLngFromPlaceId(prediction.placeId!);
    if (destinationLatLng != null) {
      if (mounted) {
        setState(() {
          _destinationLatLng = destinationLatLng;
          _addMarker('destination', _destinationLatLng!, prediction.description ?? '');
          if (_sourceLatLng == null) {
            _moveCamera(_destinationLatLng!);
          }
          _updatePolyline(context); // Pass context here
        });
      }
    }
  }

  void _addMarker(String id, gmaps.LatLng position, String title) async {
    if (mounted) {
      final icon = _vehicleIcons[Provider.of<UserData>(context, listen: false).selectedVehicle];
      gmaps.BitmapDescriptor? bitmapDescriptor;
      if (id == 'source' || id == 'destination') {
        // Use default markers for source and destination
        bitmapDescriptor = gmaps.BitmapDescriptor.defaultMarkerWithHue(
          id == 'source' ? gmaps.BitmapDescriptor.hueGreen : gmaps.BitmapDescriptor.hueRed,
        );
      } else if (icon != null) {
        bitmapDescriptor = await gmaps.BitmapDescriptor.fromAssetImage(
          const ImageConfiguration(size: Size(48.0, 48.0)), // Adjust size if needed
          icon,
        );
      } else {
        bitmapDescriptor = gmaps.BitmapDescriptor.defaultMarker;
      }

      setState(() {
        _markers.removeWhere((m) => m.markerId.value == id);
        _markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId(id),
            position: position,
            infoWindow: gmaps.InfoWindow(title: title),
            icon: bitmapDescriptor!,
          ),
        );
      });
    }
  }

  void _moveCamera(gmaps.LatLng position) {
    _mapController?.animateCamera(gmaps.CameraUpdate.newLatLngZoom(position, 15));
  }

  Future<http.Response> fetchDirections() async {
    if (_sourceLatLng == null || _destinationLatLng == null) {
      return http.Response('Source or destination not set', 400);
    }
    if (_useDirectApi) {
      final selectedVehicle = Provider.of<UserData>(context, listen: false).selectedVehicle;
      final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
      final destination = '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';
      final url =
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&mode=$selectedVehicle&alternatives=true&key=${ApiConstants.googleApiKey}';
      print('Direct Directions API URL: $url'); // ADDED
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200 &&
            jsonDecode(response.body)['routes'] != null) {
          print('Direct Directions API Success! Body: ${response.body}'); // ADDED
          return response;
        } else {
          debugPrint(
              'Directions API failed or returned no routes: ${response.statusCode}');
          print('Direct Directions API Failure Body: ${response.body}'); // ADDED
          if (mounted) {
            setState(() => _useDirectApi = false);
          }
          return _fetchDirectionsViaProxy();
        }
      } catch (e) {
        debugPrint('Directions API error: $e');
        print('Direct Directions API Error: $e'); // ADDED
        if (mounted) {
          setState(() => _useDirectApi = false);
        }
        return _fetchDirectionsViaProxy();
      }
    } else {
      return _fetchDirectionsViaProxy();
    }
  }

  Future<http.Response> _fetchDirectionsViaProxy() async {
    if (_sourceLatLng == null || _destinationLatLng == null) {
      return http.Response('Source or destination not set', 400);
    }
    final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
    final destination =
        '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';
    final selectedVehicle = Provider.of<UserData>(context, listen: false).selectedVehicle;
    final proxyUrl =
        '${ApiConstants.proxyBaseUrl}/directions/json?origin=$origin&destination=$destination&mode=$selectedVehicle';
    print('Proxy Directions API URL: $proxyUrl'); // ADDED
    try {
      final response = await http.get(Uri.parse(proxyUrl));
      print('Proxy Directions API Response Status: ${response.statusCode}'); // ADDED
      print('Proxy Directions API Response Body: ${response.body}'); // ADDED
      return response;
    } catch (e) {
      debugPrint('Directions via proxy error: $e');
      print('Directions via proxy error: $e'); // ADDED
      throw e;
    }
  }

  Future<void> _updatePolyline([BuildContext? context]) async {
    if (_sourceLatLng == null || _destinationLatLng == null || _isFetchingRoutes) {
      return;
    }
    setState(() {
      _isFetchingRoutes = true;
      _polylines.clear();
      _routeDistanceKm = null;
      _routeDuration = null;
    });
    final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
    final destination =
        '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';

    print('Selected vehicle mode before fetching directions: ${Provider.of<UserData>(context!, listen: false).selectedVehicle}'); // ALREADY PRESENT
    try {
      http.Response response = await fetchDirections();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Directions API (via direct or proxy) Success! Decoded Body: $data'); // ADDED
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final routes = data['routes'] as List;
          final newPolylines = <gmaps.Polyline>{};
          for (int i = 0; i < routes.length; i++) {
            if (routes[i]['overview_polyline'] != null && routes[i]['overview_polyline']['points'] != null) {
              final points = routes[i]['overview_polyline']['points'];
              final result = PolylinePoints().decodePolyline(points);
              final coords =
                  result.map((p) => gmaps.LatLng(p.latitude, p.longitude)).toList();

              newPolylines.add(
                gmaps.Polyline(
                  polylineId: gmaps.PolylineId('route_$i'),
                  points: coords,
                  color: i == 0 ? Colors.deepPurple : Colors.grey,
                  width: i == 0 ? 5 : 3,
                ),
              );

              if (i == 0 && routes[0]['legs'] != null && routes[0]['legs'].isNotEmpty) {
                _routeDistanceKm = routes[0]['legs'][0]['distance']['value'] / 1000;
                _routeDuration = routes[0]['legs'][0]['duration']['text'];
              }
            } else {
              debugPrint('Error: overview_polyline or points are null for route $i');
            }
          }

          if (mounted) {
            setState(() {
              _polylines.clear();
              _polylines.addAll(newPolylines);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _polylines.clear();
              _routeDistanceKm = null;
              _routeDuration = null;
            });
          }
          debugPrint('No routes found in the directions API response.');
        }
      } else {
        if (mounted) {
          setState(() {
            _polylines.clear();
            _routeDistanceKm = null;
            _routeDuration = null;
          });
        }
        debugPrint('Directions request failed: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context!).showSnackBar(
          const SnackBar(content: Text('Failed to fetch directions')),
        );
        setState(() {
          _polylines.clear();
          _routeDistanceKm = null;
          _routeDuration = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingRoutes = false;
        });
      }
    }

    try {
      http.Response response = await fetchDirections();
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Directions API (via direct or proxy) Success! Decoded Body: $data'); // ADDED
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final routes = data['routes'] as List;
          final newPolylines = <gmaps.Polyline>{};
          for (int i = 0; i < routes.length; i++) {
            if (routes[i]['overview_polyline'] != null && routes[i]['overview_polyline']['points'] != null) {
              final points = routes[i]['overview_polyline']['points'];
              final result = PolylinePoints().decodePolyline(points);
              final coords =
                  result.map((p) => gmaps.LatLng(p.latitude, p.longitude)).toList();

              newPolylines.add(
                gmaps.Polyline(
                  polylineId: gmaps.PolylineId('route_$i'),
                  points: coords,
                  color: i == 0 ? Colors.deepPurple : Colors.grey,
                  width: i == 0 ? 5 : 3,
                ),
              );

              if (i == 0 && routes[0]['legs'] != null && routes[0]['legs'].isNotEmpty) {
                _routeDistanceKm = routes[0]['legs'][0]['distance']['value'] / 1000;
                _routeDuration = routes[0]['legs'][0]['duration']['text'];
              }
            } else {
              debugPrint('Error: overview_polyline or points are null for route $i');
            }
          }

          if (mounted) {
            setState(() {
              _polylines.clear();
              _polylines.addAll(newPolylines);
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _polylines.clear();
              _routeDistanceKm = null;
              _routeDuration = null;
            });
          }
          debugPrint('No routes found in the directions API response.');
        }
      } else {
        if (mounted) {
          setState(() {
            _polylines.clear();
            _routeDistanceKm = null;
            _routeDuration = null;
          });
        }
        debugPrint('Directions request failed: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
      if (mounted) {
        ScaffoldMessenger.of(context!).showSnackBar(
          const SnackBar(content: Text('Failed to fetch directions')),
        );
        setState(() {
          _polylines.clear();
          _routeDistanceKm = null;
          _routeDuration = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingRoutes = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Icon icon,
    required ValueChanged<Prediction> onSelected,
    VoidCallback? onUseCurrentLocation,
  }) {
    return TypeAheadField<Prediction>(
      suggestionsCallback: _getPlacePredictions,
      itemBuilder: (context, suggestion) {
        return ListTile(
          leading: icon,
          title: Text(suggestion.description ?? ''),
          subtitle: Text(suggestion.structuredFormatting?.secondaryText ?? ''),
        );
      },
      onSelected: onSelected, // Changed from onSuggestionSelected
      builder: (context, fieldController, focusNode) {
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: icon,
            suffixIcon: label == "📍 Source Location" && onUseCurrentLocation != null
                ? IconButton(
                    icon: const Icon(Icons.gps_fixed),
                    onPressed: onUseCurrentLocation,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.white,
          ),
        );
      },
      controller: controller,
    );
  }

  void _useCurrentLocationAsSource(BuildContext context) async {
    final userData = Provider.of<UserData>(context, listen: false);
    if (userData.currentLocation != null) {
      final currentLocationLatLng =
          gmaps.LatLng(userData.currentLocation!.latitude, userData.currentLocation!.longitude);
      try {
        final response = await http.get(ApiConstants.proxyReverseGeocodingUrl(
            currentLocationLatLng.latitude, currentLocationLatLng.longitude));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final formattedAddress = data['results'][0]['formatted_address'];
            if (mounted) {
              setState(() {
                _sourceController.text = formattedAddress ?? 'Current Location';
                _sourceLatLng = currentLocationLatLng;
                _addMarker('source', _sourceLatLng!, _sourceController.text);
                _moveCamera(_sourceLatLng!);
                _updatePolyline(context);
              });
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not determine address from current location.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error fetching address from current location.')),
          );
        }
      } catch (e) {
        debugPrint('Error reverse geocoding current location: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error getting address from current location.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location not yet available.')),
      );
    }
  }

  void _openStreetView() async {
    print('MapScreen: _openStreetView called. Current location: $_currentLocation');
    if (_currentLocation != null) {
      try {
        final streetViewUrl = _streetViewService.getStreetViewUrl( // Or getProxyStreetViewUrl depending on your setup
          latitude: _currentLocation!.latitude,
          longitude: _currentLocation!.longitude,
        );
        debugPrint('MapScreen: Street View URL generated: $streetViewUrl');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StreetViewDialog(
              latitude: _currentLocation?.latitude ?? 0.0,
              longitude: _currentLocation?.longitude ?? 0.0,
            );
          },
        );
      } catch (e) {
        debugPrint('Error generating Street View URL: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Street View.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location not available.')),
      );
    }
  }

  Widget _modeButton(BuildContext context, String iconPath, String mode) {
    final selectedVehicle = Provider.of<UserData>(context).selectedVehicle;
    final isSelected = selectedVehicle == mode;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * (isPanelOpen(screenWidth) ? 0.2 : 0.15);
    final borderRadius = BorderRadius.circular(16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: buttonSize,
      height: buttonSize * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected ? Colors.deepPurple : Colors.white,
        borderRadius: borderRadius,
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Provider.of<UserData>(context, listen: false).updateSelectedVehicle(mode);
            _updatePolyline(context);
            Navigator.pop(context);
          },
          borderRadius: borderRadius,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icons/$iconPath',
                fit: BoxFit.contain,
                width: buttonSize * 0.5,
                height: buttonSize * 0.5,
              ),
              const SizedBox(height: 8),
              Text(
                mode.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: buttonSize * 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isPanelOpen(double screenWidth) {
    return screenWidth < 600;
  }

  void _showModeSelectionPopup(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final popupWidth = screenWidth * 0.7;
    final popupHeight = screenHeight * 0.6;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(scale: Tween<double>(begin: 0.5, end: 1.0).animate(anim1), child: FadeTransition(opacity: anim1, child: child));
      },
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Center(
          child: Container(
            width: popupWidth,
            height: popupHeight,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text(
                  "Choose Travel Mode",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_areModeButtonsLoading)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildModeButtonSkeleton(sizeFactor: 0.7),
                      _buildModeButtonSkeleton(sizeFactor: 0.7),
                      _buildModeButtonSkeleton(sizeFactor: 0.7),
                    ],
                  )
                else
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      _modeButton(buildContext, 'car.png', 'driving'),
                      _modeButton(buildContext, 'bike.png', 'bicycling'),
                      _modeButton(buildContext, 'walk.png', 'walking'),
                    ],
                  ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(buildContext),
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _changeModeButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final mainButtonSize = screenWidth * 0.15; // Increased size
    final iconSize = mainButtonSize * 0.6;

    return Positioned(
      left: 16,
      top: 16,
      child: FloatingActionButton(
        heroTag: 'expand_modes_popup',
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          _showModeSelectionPopup(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(mainButtonSize / 2),
        ),
        child: Icon(Icons.directions, size: iconSize),
        mini: false,
        elevation: 4,
      ),
    );
  }

  Widget _buildModeButtonSkeleton({double sizeFactor = 1.0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.2 * sizeFactor; // Adjust size based on screen width

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: buttonSize,
        height: buttonSize * 0.8,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Map Route"),
        backgroundColor: isDark ? Colors.black : Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(
              _currentMapType == gmaps.MapType.normal ? Icons.satellite_alt : Icons.map_outlined,
            ),
            onPressed: () {
              setState(() {
                _currentMapType = _currentMapType == gmaps.MapType.normal
                    ? gmaps.MapType.satellite
                    : gmaps.MapType.normal;
              });
            },
            tooltip: 'Toggle Map Type',
          ),
          StreetViewButton(
            latitude: _currentLocation?.latitude ?? 0.0,
            longitude: _currentLocation?.longitude ?? 0.0,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              print('MapScreen: Settings button pressed!');
              // Open settings or other options
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Positioned.fill(
              child: Container(
                color: Colors.grey[200], // Adjust as needed
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/loading_map.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          if (!_isLoading)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _sourceController,
                        label: "📍 Source Location",
                        icon: const Icon(Icons.my_location),
                        onSelected: _updateSourceLocation,
                        onUseCurrentLocation: () => _useCurrentLocationAsSource(context),
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _destinationController,
                        label: "🏁 Destination",
                        icon: const Icon(Icons.flag),
                        onSelected: _updateDestinationLocation,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _updatePolyline(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.alt_route),
                        label: const Text("Show Route"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      gmaps.GoogleMap(
                        onMapCreated: (controller) {
                          _mapController = controller;
                          _mapCompleter.complete(controller);
                        },
                        initialCameraPosition: gmaps.CameraPosition(
                          target: _currentLocation ?? _defaultLocation,
                          zoom: _currentZoom,
                        ),
                        markers: _markers,
                        polylines: _polylines,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: false,
                        mapType: _currentMapType,
                        padding: const EdgeInsets.only(bottom: 100),
                        onTap: (gmaps.LatLng point) {
                          setState(() {
                            if (_sourceLatLng == null || (_sourceLatLng != null && _destinationLatLng != null)) {
                              _sourceLatLng = point;
                              _destinationLatLng = null;
                              _markers.removeWhere((m) => m.markerId.value == 'source' || m.markerId.value == 'destination');
                              _addMarker('source', _sourceLatLng!, 'Origin');
                              _polylines.clear();
                              _routeDistanceKm = null;
                              _routeDuration = null;
                            } else {
                              _destinationLatLng = point;
                              _addMarker('destination', _destinationLatLng!, 'Destination');
                              _updatePolyline(context);
                            }
                            _sourceController.clear();
                            _destinationController.clear();
                            if (_sourceLatLng != null) _sourceController.text = '(${_sourceLatLng!.latitude.toStringAsFixed(6)}, ${_sourceLatLng!.longitude.toStringAsFixed(6)})';
                            if (_destinationLatLng != null) _destinationController.text = '(${_destinationLatLng!.latitude.toStringAsFixed(6)}, ${_destinationLatLng!.longitude.toStringAsFixed(6)})';
                          });
                        },
                      ),
                      _changeModeButton(context),
                    ],
                  ),
                ),
                if (_routeDistanceKm != null && _routeDuration != null)
                  RouteInfoWidget(
                    distanceKm: _routeDistanceKm!,
                    duration: _routeDuration!,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
