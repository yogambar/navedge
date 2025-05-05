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

import '../core/constants/api_constants.dart';
import '../core/models/prediction_model.dart';
import '../core/services/directions_service.dart';
import '../core/services/location_service.dart';
import '../core/services/street_view_service.dart';
import '../core/utils/permission_handler.dart';
import '../widgets/route_info_widget.dart';
import '../widgets/street_view_button.dart';
import '../widgets/street_view_dialog.dart';
import '../user_data_provider.dart';

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
  double _currentZoom = 12.0;
  bool _isLoading = true;
  double? _routeDistanceKm;
  String? _routeDuration;
  StreamSubscription<Position>? _positionStream;
  gmaps.LatLng? _lastPosition;
  double _currentRouteBearing = 0.0; // Initial bearing

  final LocationService _locationService = LocationService();
  final DirectionsService _directionsService = DirectionsService();
  final StreetViewService _streetViewService = StreetViewService();

  bool _useDirectApi = true; // Added based on your working code

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndGetCurrentLocation(); // Changed to match working code
  }

  Future<void> _checkLocationPermissionAndGetCurrentLocation() async {
    final isGranted = await PermissionHandlerService.requestLocationPermission();
    if (isGranted) {
      await _getCurrentLocation(); // Changed to match working code
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
          _updatePolyline();
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
          _updatePolyline();
        });
      }
    }
  }

  void _addMarker(String id, gmaps.LatLng position, String title) {
    if (mounted) {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == id);
        _markers.add(
          gmaps.Marker(
            markerId: gmaps.MarkerId(id),
            position: position,
            infoWindow: gmaps.InfoWindow(title: title),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              id == 'source' ? gmaps.BitmapDescriptor.hueGreen : gmaps.BitmapDescriptor.hueRed,
            ),
          ),
        );
      });
    }
  }

  void _moveCamera(gmaps.LatLng position) {
    _mapController?.animateCamera(gmaps.CameraUpdate.newLatLngZoom(position, 15));
  }

  Future<void> _updatePolyline() async {
    if (_sourceLatLng == null || _destinationLatLng == null) {
      if (mounted) {
        setState(() => _polylines.clear());
      }
      return;
    }

    final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
    final destination =
        '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';

    Future<http.Response> fetchDirections() async {
      if (_useDirectApi) {
        final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=${ApiConstants.googleApiKey}', // Assuming you have this in ApiConstants
        );
        try {
          final response = await http.get(url);
          if (response.statusCode == 200 &&
              jsonDecode(response.body)['routes'] != null) {
            return response;
          } else {
            debugPrint(
                'Directions API failed or returned no routes: ${response.statusCode}');
            if (mounted) {
              setState(() => _useDirectApi = false);
            }
            return _fetchDirectionsViaProxy();
          }
        } catch (e) {
          debugPrint('Directions API error: $e');
          if (mounted) {
            setState(() => _useDirectApi = false);
          }
          return _fetchDirectionsViaProxy();
        }
      } else {
        return _fetchDirectionsViaProxy();
      }
    }

    http.Response response = await fetchDirections();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        final result = PolylinePoints().decodePolyline(points);
        final coords =
            result.map((p) => gmaps.LatLng(p.latitude, p.longitude)).toList();

        if (mounted) {
          setState(() {
            _polylines.clear();
            _polylines.add(
              gmaps.Polyline(
                polylineId: const gmaps.PolylineId('route'),
                points: coords,
                color: Colors.deepPurple,
                width: 5,
              ),
            );
            if (data['routes'][0]['legs'] != null &&
                data['routes'][0]['legs'].isNotEmpty) {
              _routeDistanceKm = data['routes'][0]['legs'][0]['distance']['value'] / 1000;
              _routeDuration = data['routes'][0]['legs'][0]['duration']['text'];
            } else {
              _routeDistanceKm = null;
              _routeDuration = null;
            }
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
        debugPrint('No routes found.');
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
  }

  Future<http.Response> _fetchDirectionsViaProxy() async {
    final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
    final destination =
        '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';
    final url = Uri.parse(
      '${ApiConstants.proxyBaseUrl}/directions/json?origin=$origin&destination=$destination',
    );
    try {
      return await http.get(url);
    } catch (e) {
      debugPrint('Directions via proxy error: $e');
      throw e;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required Icon icon,
    required ValueChanged<Prediction> onSelected,
    VoidCallback? onUseCurrentLocation, // Kept this in case you still need it
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
      onSelected: onSelected,
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
                _updatePolyline();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Map Route"),
        backgroundColor: isDark ? Colors.black : Colors.deepPurple,
        actions: [
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
                        onPressed: _updatePolyline,
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
                  child: gmaps.GoogleMap(
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
                    padding: const EdgeInsets.only(bottom: 100),
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

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}
