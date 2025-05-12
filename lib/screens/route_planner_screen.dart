import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
import '../user_data_provider.dart';
import '../core/algorithms/a_star.dart';
import '../core/algorithms/bellman_ford.dart';
import '../core/algorithms/dijkstra.dart';
import '../core/algorithms/floyd_warshall.dart';

class RoutePlannerScreen extends StatefulWidget {
  final Map<gmaps.LatLng, Map<gmaps.LatLng, double>>? initialGraph;

  const RoutePlannerScreen({
    Key? key,
    this.initialGraph,
  }) : super(key: key);

  @override
  State<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends State<RoutePlannerScreen>
    with TickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String? _selectedAlgorithm;
  gmaps.MapType _currentMapType = gmaps.MapType.normal;

  final Set<gmaps.Marker> _markers = {};
  final Set<gmaps.Polyline> _polylines = {};
  gmaps.GoogleMapController? _mapController;
  final Completer<gmaps.GoogleMapController> _mapCompleter =
      Completer<gmaps.GoogleMapController>();
  gmaps.LatLng? _currentLocation;
  gmaps.LatLng? _sourceLatLng;
  gmaps.LatLng? _destinationLatLng;
  gmaps.LatLng _defaultLocation = const gmaps.LatLng(30.3165, 78.0322); // Dehradun (Fallback)
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

  bool _useDirectApi = true; // Flag to control API usage
  bool _isCalculatingRoute = false;
  bool _areModeButtonsLoading = false;

  final Map<String, Color> _algorithmColors = {
    'Dijkstra': Colors.red,
    'A*': Colors.green,
    'Bellman-Ford': Colors.purple,
    'Floyd-Warshall': Colors.pink,
  };

  final Map<String, String> _algorithmAnimations = {
    'Dijkstra': 'assets/animations/dijkstra.json',
    'Bellman-Ford': 'assets/animations/bellman_ford.json',
    'Floyd-Warshall': 'assets/animations/floyd_warshall.json',
    'A*': 'assets/animations/a_star.json',
  };

  final Map<String, String> _algorithmNames = {
    'Dijkstra': 'Dijkstra\'s Algorithm',
    'Bellman-Ford': 'Bellman-Ford Algorithm',
    'Floyd-Warshall': 'Floyd-Warshall Algorithm',
    'A*': 'A* Search Algorithm',
  };

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissionAndGetCurrentLocation();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _checkLocationPermissionAndGetCurrentLocation() async {
    final isGranted = await PermissionHandlerService.requestLocationPermission();
    if (isGranted) {
      await _getCurrentLocation();
    } else {
      _isLoading = false;
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLocation = gmaps.LatLng(position.latitude, position.longitude);
      Provider.of<UserData>(context, listen: false).updateCurrentLocation(position);
      _currentZoom = 15.0;
      _mapCompleter.future.then((controller) {
        controller.animateCamera(
          gmaps.CameraUpdate.newLatLngZoom(_currentLocation!, _currentZoom),
        );
      });
    } catch (e) {
      debugPrint("Error fetching location: $e");
      _isLoading = false;
      setState(() {});
    } finally {
      if (_isLoading) {
        _isLoading = false;
        setState(() {});
      }
    }
  }

  Future<gmaps.LatLng?> _getLatLngFromPlaceId(String placeId) async {
    if (_useDirectApi) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=${ApiConstants.googleApiKey}');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['results'] != null && data['results'].isNotEmpty) {
            final location = data['results'][0]['geometry']['location'];
            return gmaps.LatLng(location['lat'], location['lng']);
          } else {
            debugPrint('Geocoding API returned no results.');
            setState(() => _useDirectApi = false);
            return _getLatLngFromPlaceIdViaProxy(placeId);
          }
        } else {
          debugPrint('Geocoding API failed: ${response.statusCode}');
          debugPrint('Body: ${response.body}');
          setState(() => _useDirectApi = false);
          return _getLatLngFromPlaceIdViaProxy(placeId);
        }
      } catch (e) {
        debugPrint('Geocoding API error: $e');
        setState(() => _useDirectApi = false);
        return _getLatLngFromPlaceIdViaProxy(placeId);
      }
    } else {
      return _getLatLngFromPlaceIdViaProxy(placeId);
    }
  }

  Future<gmaps.LatLng?> _getLatLngFromPlaceIdViaProxy(String placeId) async {
    final url =
        Uri.parse('${ApiConstants.proxyBaseUrl}/geocode/json?place_id=$placeId');
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
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=${ApiConstants.googleApiKey}');
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
            setState(() => _useDirectApi = false);
            return _getPlacePredictionsViaProxy(input);
          }
        } else {
          debugPrint('Places Autocomplete API failed: ${response.statusCode}');
          debugPrint('Body: ${response.body}');
          setState(() => _useDirectApi = false);
          return _getPlacePredictionsViaProxy(input);
        }
      } catch (e) {
        debugPrint('Places Autocomplete API error: $e');
        setState(() => _useDirectApi = false);
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
    _sourceLatLng = await _getLatLngFromPlaceId(prediction.placeId!);
    if (_sourceLatLng != null) {
      _addMarker('source', _sourceLatLng!, prediction.description ?? '');
      _moveCamera(_sourceLatLng!);
      _updatePolyline();
    }
  }

  void _updateDestinationLocation(Prediction prediction) async {
    _destinationController.text = prediction.description ?? '';
    _destinationLatLng = await _getLatLngFromPlaceId(prediction.placeId!);
    if (_destinationLatLng != null) {
      _addMarker('destination', _destinationLatLng!, prediction.description ?? '');
      if (_sourceLatLng == null) {
        _moveCamera(_destinationLatLng!);
      }
      _updatePolyline();
    }
  }

  void _addMarker(String id, gmaps.LatLng position, String title) {
    _markers.removeWhere((m) => m.markerId.value == id);
    _markers.add(
      gmaps.Marker(
        markerId: gmaps.MarkerId(id),
        position: position,
        infoWindow: gmaps.InfoWindow(title: title),
        icon: id == 'source'
            ? gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueGreen)
            : gmaps.BitmapDescriptor.defaultMarkerWithHue(gmaps.BitmapDescriptor.hueRed),
      ),
    );
    setState(() {});
  }

  void _moveCamera(gmaps.LatLng position) {
    _mapController?.animateCamera(gmaps.CameraUpdate.newLatLngZoom(position, 15));
  }

  Future<void> _updatePolyline({String? forcedAlgorithm}) async {
    if (_sourceLatLng == null || _destinationLatLng == null) {
      setState(() => _polylines.clear());
      return;
    }

    final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
    final destination = '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';
    Color polylineColor = Colors.blue;
    String travelMode = Provider.of<UserData>(context, listen: false).selectedVehicle;

    if (forcedAlgorithm != null && _algorithmColors.containsKey(forcedAlgorithm)) {
      polylineColor = _algorithmColors[forcedAlgorithm]!;
      // Even though the algorithms aren't implemented, we'll fetch the default route
      // and just color it differently to show the selection.
      final response = await _fetchDirections(travelMode: travelMode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final result = PolylinePoints().decodePolyline(points);
          final coords = result.map((p) => gmaps.LatLng(p.latitude, p.longitude)).toList();
          _drawPolyline(coords, polylineColor, polylineId: forcedAlgorithm.toLowerCase());
          _updateRouteInfo(data);
        } else {
          _clearRouteInfo();
          debugPrint('No routes found for $forcedAlgorithm.');
        }
      } else {
        _clearRouteInfo();
        debugPrint('Directions request failed for $forcedAlgorithm: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }
    } else {
      // Default behavior: Fetch route using the selected travel mode
      final response = await _fetchDirections(travelMode: travelMode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final result = PolylinePoints().decodePolyline(points);
          final coords = result.map((p) => gmaps.LatLng(p.latitude, p.longitude)).toList();
          _drawPolyline(coords, polylineColor, polylineId: 'default_route');
          _updateRouteInfo(data);
        } else {
          _clearRouteInfo();
          debugPrint('No default routes found.');
        }
      } else {
        _clearRouteInfo();
        debugPrint('Default directions request failed: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
      }
    }
  }

  void _updateRouteInfo(Map<String, dynamic> data) {
    setState(() {
      if (data['routes'].isNotEmpty && data['routes'][0]['legs'] != null && data['routes'][0]['legs'].isNotEmpty) {
        _routeDistanceKm = data['routes'][0]['legs'][0]['distance']['value'] / 1000;
        _routeDuration = data['routes'][0]['legs'][0]['duration']['text'];
      } else {
        _routeDistanceKm = null;
        _routeDuration = null;
      }
    });
  }

  void _drawPolyline(List<gmaps.LatLng> points, Color color, {required String polylineId}) {
    setState(() {
      _polylines.removeWhere((p) => p.polylineId == gmaps.PolylineId(polylineId));
      _polylines.add(
        gmaps.Polyline(
          polylineId: gmaps.PolylineId(polylineId),
          points: points,
          color: color,
          width: 5,
        ),
      );
    });
  }

  void _clearRouteInfo() {
    setState(() {
      _polylines.clear();
      _routeDistanceKm = null;
      _routeDuration = null;
    });
  }

  Future<http.Response> _fetchDirections({String? travelMode}) async {
    if (_sourceLatLng == null || _destinationLatLng == null) {
      throw Exception("Source and destination are not set.");
    }
    final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
    final destination =
        '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';
    final mode = travelMode ?? Provider.of<UserData>(context, listen: false).selectedVehicle;
    String apiMode;
    switch (mode) {
      case 'driving':
        apiMode = 'driving';
        break;
      case 'bicycling':
        apiMode = 'bicycling';
        break;
      case 'walking':
        apiMode = 'walking';
        break;
      default:
        apiMode = 'driving'; // Default if no mode is selected
        break;
    }

    if (_useDirectApi) {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=${ApiConstants.googleApiKey}&mode=$apiMode');
      try {
        final response = await http.get(url);
        if (response.statusCode == 200 &&
            jsonDecode(response.body)['routes'] != null) {
          return response;
        } else {
          debugPrint(
              'Directions API failed or returned no routes: ${response.statusCode}');
          setState(() => _useDirectApi = false);
          return _fetchDirectionsViaProxy(apiMode);
        }
      } catch (e) {
        debugPrint('Directions API error: $e');
        setState(() => _useDirectApi = false);
        return _fetchDirectionsViaProxy(apiMode);
      }
    } else {
      return _fetchDirectionsViaProxy(apiMode);
    }
  }

  Future<http.Response> _fetchDirectionsViaProxy(String mode) async {
    if (_sourceLatLng == null || _destinationLatLng == null) {
      throw Exception("Source and destination are not set.");
    }
    final origin = '${_sourceLatLng!.latitude},${_sourceLatLng!.longitude}';
    final destination =
        '${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}';
    final url = Uri.parse(
      '${ApiConstants.proxyBaseUrl}/directions/json?origin=$origin&destination=$destination&mode=$mode',
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
            setState(() {
              _sourceController.text = formattedAddress ?? 'Current Location';
              _sourceLatLng = currentLocationLatLng;
              _addMarker('source', _sourceLatLng!, _sourceController.text);
              _moveCamera(_sourceLatLng!);
              _updatePolyline();
            });
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

  Widget _modeButton(BuildContext context, String iconPath, String mode) {
    final selectedVehicle = Provider.of<UserData>(context).selectedVehicle;
    final isSelected = selectedVehicle == mode;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.2;
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
            _updatePolyline();
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

  Widget _buildModeButtonSkeleton({double sizeFactor = 1.0}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonSize = screenWidth * 0.2 * sizeFactor;
    final borderRadius = BorderRadius.circular(16);
    return Container(
      width: buttonSize,
      height: buttonSize * 0.8,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
    );
  }

  void _showModeSelectionPopup(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final popupWidth = screenWidth * 0.7;
    final popupHeight = screenHeight * 0.4;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.5, end: 1.0).animate(anim1),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
      pageBuilder: (BuildContext dialogContext, Animation<double> animation, Animation<double> secondaryAnimation) {
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Travel Mode",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _areModeButtonsLoading
                      ? Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            _buildModeButtonSkeleton(sizeFactor: 0.6),
                            _buildModeButtonSkeleton(sizeFactor: 0.6),
                            _buildModeButtonSkeleton(sizeFactor: 0.6),
                          ],
                        )
                      : Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            _modeButton(context, 'car.png', 'driving'),
                            _modeButton(context, 'bike.png', 'bicycling'),
                            _modeButton(context, 'walk.png', 'walking'),
                          ],
                        ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openAlgorithmSelectionPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final screenSize = MediaQuery.of(context).size;
            return Center(
              child: SizedBox(
                width: screenSize.width * 0.8,
                height: screenSize.height * 0.75,
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Choose Routing Algorithm (for demonstration)',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _algorithmNames.length,
                            itemBuilder: (context, index) {
                              final algorithmKey = _algorithmNames.keys.toList()[index];
                              final algorithmName = _algorithmNames[algorithmKey]!;
                              final animationPath = _algorithmAnimations[algorithmKey]!;
                              final isSelected = _selectedAlgorithm == algorithmKey;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                color: isSelected
                                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.3)
                                    : null,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedAlgorithm = algorithmKey;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Lottie.asset(
                                            animationPath,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading Lottie asset: $error');
                                              return const Icon(Icons.error_outline, size: 60, color: Colors.red);
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 12.0),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                algorithmName,
                                                style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                                              ),
                                              Text(
                                                algorithmKey,
                                                style: TextStyle(fontSize: 12.0, color: Colors.grey[600]),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(Icons.check_circle, color: Colors.green),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            if (_sourceLatLng != null && _destinationLatLng != null) {
                              _updatePolyline(forcedAlgorithm: _selectedAlgorithm);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select both source and destination.')),
                              );
                            }
                          },
                          child: const Text('Use Selected Algorithm (Demonstration)'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openStreetView() async {
    print('MapScreen: _openStreetView called. Current location: $_currentLocation');
    if (_currentLocation != null) {
      try {
        final streetViewUrl = _streetViewService.getStreetViewUrl(
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
      title: const Text('Route Planner'),
      actions: [
        IconButton(
          icon: const Icon(Icons.map_outlined),
          onPressed: () {
            setState(() {
              _currentMapType = _currentMapType == gmaps.MapType.normal
                  ? gmaps.MapType.hybrid
                  : gmaps.MapType.normal;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openAlgorithmSelectionPopup,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              gmaps.GoogleMap(
                key: ValueKey(_currentMapType),
                mapType: _currentMapType,
                initialCameraPosition: gmaps.CameraPosition(
                  target: _currentLocation ?? _defaultLocation,
                  zoom: _currentZoom,
                ),
                onMapCreated: (gmaps.GoogleMapController controller) {
                  if (!_mapCompleter.isCompleted) {
                    _mapController = controller;
                    _mapCompleter.complete(controller);
                  }
                },
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),

              // Top Input Fields
              Positioned(
                top: 16.0,
                left: 16.0,
                right: 16.0,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _sourceController,
                      label: "📍 Source Location",
                      icon: const Icon(Icons.location_on),
                      onSelected: _updateSourceLocation,
                      onUseCurrentLocation: () => _useCurrentLocationAsSource(context),
                    ),
                    const SizedBox(height: 8.0),
                    _buildTextField(
                      controller: _destinationController,
                      label: "🎯 Destination",
                      icon: const Icon(Icons.flag),
                      onSelected: _updateDestinationLocation,
                    ),
                    const SizedBox(height: 12.0),

                    // Top-Level Buttons Below Input
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _openAlgorithmSelectionPopup,
                          icon: const Icon(Icons.settings),
                          label: const Text('Algorithm'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showModeSelectionPopup(context),
                          icon: const Icon(Icons.directions_car),
                          label: const Text('Change Mode'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigoAccent,
                          ),
                        ),
                        if (_destinationLatLng != null)
                          StreetViewButton(
                            latitude: _destinationLatLng!.latitude,
                            longitude: _destinationLatLng!.longitude,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Route Info Bar at Bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_routeDistanceKm != null && _routeDuration != null)
                        RouteInfoWidget(
                          distanceKm: _routeDistanceKm!,
                          duration: _routeDuration!,
                        ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _sourceLatLng != null && _destinationLatLng != null
                              ? () => _updatePolyline(forcedAlgorithm: _selectedAlgorithm)
                              : null,
                          icon: const Icon(Icons.route),
                          label: const Text('Find Route'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent.shade700,
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
  );
}
}
