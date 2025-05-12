import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;

class ApiConstants {
  static const String googleApiKey = 'AIzaSyBIMt3sCM79onF6F0pV2QxVbVM8dc1XxrY';
  //static const String proxyBaseUrl = 'http://127.0.0.1:3000/api';
  static const String proxyBaseUrl = 'http://10.0.2.15:3000/api';
  //static const String proxyBaseUrl = 'https://navedge-api.onrender.com/api';

  // === Places API ===
  static Uri placesAutocompleteUrl(String input) => Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$googleApiKey',
      );
  static Uri proxyPlacesAutocompleteUrl(String input) => Uri.parse(
        '$proxyBaseUrl/places/autocomplete/json?input=${Uri.encodeComponent(input)}',
      );

  // === Geocoding API ===
  static Uri geocodingUrl(String placeId) => Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?place_id=$placeId&key=$googleApiKey',
      );
  static Uri proxyGeocodingUrl(String placeId) => Uri.parse(
        '$proxyBaseUrl/geocode/json?place_id=$placeId',
      );

  // === Directions API ===
  static Uri directionsUrl(String origin, String destination) => Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$googleApiKey',
      );
  static Uri proxyDirectionsUrl(String origin, String destination) => Uri.parse(
        '$proxyBaseUrl/directions/json?origin=$origin&destination=$destination',
      );

  // === Distance Matrix API ===
  static Uri distanceMatrixUrl(List<String> origins, List<String> destinations) => Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origins.join('|')}&destinations=${destinations.join('|')}&key=$googleApiKey',
      );
  static Uri proxyDistanceMatrixUrl(List<String> origins, List<String> destinations) => Uri.parse(
        '$proxyBaseUrl/distancematrix/json?origins=${origins.join('|')}&destinations=${destinations.join('|')}',
      );

  // === Reverse Geocoding API ===
  static Uri reverseGeocodingUrl(double latitude, double longitude) => Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleApiKey',
      );
  static Uri proxyReverseGeocodingUrl(double latitude, double longitude) => Uri.parse(
        '$proxyBaseUrl/geocode/json?latlng=$latitude,$longitude',
      );

  // === Street View Static API ===
  static Uri streetViewStaticUrl({
    required double latitude,
    required double longitude,
    int? sizeX,
    int? sizeY,
    num? heading,
    num? pitch,
    int? fov,
  }) {
    final queryParameters = <String, dynamic>{
      'location': '$latitude,$longitude',
      'key': googleApiKey,
    };
    if (sizeX != null && sizeY != null) queryParameters['size'] = '${sizeX}x${sizeY}';
    if (heading != null) queryParameters['heading'] = heading;
    if (pitch != null) queryParameters['pitch'] = pitch;
    if (fov != null) queryParameters['fov'] = fov;
    return Uri.parse('https://maps.googleapis.com/maps/api/streetview')
        .replace(queryParameters: queryParameters);
  }

  static Uri proxyStreetViewStaticUrl({
    required double latitude,
    required double longitude,
    int? sizeX,
    int? sizeY,
    num? heading,
    num? pitch,
    int? fov,
  }) {
    final queryParameters = <String, dynamic>{
      'location': '$latitude,$longitude',
    };
    if (sizeX != null && sizeY != null) queryParameters['size'] = '${sizeX}x${sizeY}';
    if (heading != null) queryParameters['heading'] = heading;
    if (pitch != null) queryParameters['pitch'] = pitch;
    if (fov != null) queryParameters['fov'] = fov;
    return Uri.parse('$proxyBaseUrl/streetview').replace(queryParameters: queryParameters);
  }

  // === Roads API (Snap to Roads) ===
  static Uri snapToRoadsUrl(List<List<double>> points) {
    final path = points.map((p) => '${p[0]},${p[1]}').join('|');
    return Uri.parse(
      'https://roads.googleapis.com/v1/snapToRoads?path=$path&interpolate=true&key=$googleApiKey',
    );
  }

  static Uri proxySnapToRoadsUrl(List<List<double>> points) {
    final path = points.map((p) => '${p[0]},${p[1]}').join('|');
    return Uri.parse(
      '$proxyBaseUrl/roads/v1/snapToRoads?path=$path&interpolate=true',
    );
  }

  // === Maps Static API ===
  static Uri mapsStaticUrl({
    required gmaps.LatLng center,
    required int zoom,
    required int sizeX,
    required int sizeY,
    List<String>? markers,
    List<String>? paths,
  }) {
    final queryParameters = <String, dynamic>{
      'center': '${center.latitude},${center.longitude}',
      'zoom': zoom.toString(),
      'size': '${sizeX}x${sizeY}',
      'key': googleApiKey,
    };
    if (markers != null && markers.isNotEmpty) queryParameters['markers'] = markers.join('|');
    if (paths != null && paths.isNotEmpty) queryParameters['paths'] = paths.join('|');
    return Uri.parse('https://maps.googleapis.com/maps/api/staticmap')
        .replace(queryParameters: queryParameters);
  }

  static Uri proxyMapsStaticUrl({
    required gmaps.LatLng center,
    required int zoom,
    required int sizeX,
    required int sizeY,
    List<String>? markers,
    List<String>? paths,
  }) {
    final queryParameters = <String, dynamic>{
      'center': '${center.latitude},${center.longitude}',
      'zoom': zoom.toString(),
      'size': '${sizeX}x${sizeY}',
    };
    if (markers != null && markers.isNotEmpty) queryParameters['markers'] = markers.join('|');
    if (paths != null && paths.isNotEmpty) queryParameters['paths'] = paths.join('|');
    return Uri.parse('$proxyBaseUrl/staticmap').replace(queryParameters: queryParameters);
  }

  // === Elevation API ===
  static Uri elevationUrl(List<gmaps.LatLng> locations) {
    final locationsParam = locations.map((loc) => '${loc.latitude},${loc.longitude}').join('|');
    return Uri.parse(
      'https://maps.googleapis.com/maps/api/elevation/json?locations=$locationsParam&key=$googleApiKey',
    );
  }

  static Uri proxyElevationUrl(List<gmaps.LatLng> locations) {
    final locationsParam = locations.map((loc) => '${loc.latitude},${loc.longitude}').join('|');
    return Uri.parse(
      '$proxyBaseUrl/elevation/json?locations=$locationsParam',
    );
  }

  // === Time Zone API ===
  static Uri timeZoneUrl(gmaps.LatLng location, DateTime timestamp) => Uri.parse(
        'https://maps.googleapis.com/maps/api/timezone/json?location=${location.latitude},${location.longitude}&timestamp=${timestamp.millisecondsSinceEpoch ~/ 1000}&key=$googleApiKey',
      );

  static Uri proxyTimeZoneUrl(gmaps.LatLng location, DateTime timestamp) => Uri.parse(
        '$proxyBaseUrl/timezone/json?location=${location.latitude},${location.longitude}&timestamp=${timestamp.millisecondsSinceEpoch ~/ 1000}',
      );

  // === Geolocation API ===
  static Uri geolocationUrl() => Uri.parse(
        'https://www.googleapis.com/geolocation/v1/geolocate?key=$googleApiKey',
      );

  static Uri proxyGeolocationUrl() => Uri.parse(
        '$proxyBaseUrl/geolocation/v1/geolocate',
      );

  // === Routes API (Advanced Routing) ===
  static Uri routesDirectionsUrl({
    required gmaps.LatLng origin,
    required gmaps.LatLng destination,
    String travelMode = 'DRIVING',
  }) =>
      Uri.parse(
        'https://routes.googleapis.com/directions/v2:computeRoutes?key=$googleApiKey',
      );

  static Uri proxyRoutesDirectionsUrl({
    required gmaps.LatLng origin,
    required gmaps.LatLng destination,
    String travelMode = 'DRIVING',
  }) =>
      Uri.parse(
        '$proxyBaseUrl/routes/v2:computeRoutes',
      );

  // === Roads API (Speed Limits) ===
  static Uri speedLimitsUrl(List<String> placeIds) => Uri.parse(
        'https://roads.googleapis.com/v1/speedLimits?placeIds=${placeIds.join(',')}&key=$googleApiKey',
      );

  static Uri proxySpeedLimitsUrl(List<String> placeIds) => Uri.parse(
        '$proxyBaseUrl/roads/v1/speedLimits?placeIds=${placeIds.join(',')}',
      );
}

