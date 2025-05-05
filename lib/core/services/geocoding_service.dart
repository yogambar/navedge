import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../models/place_model_map.dart'; // Import Place

class GeocodingService {
  final bool _useDirectApi = true; // Consider making this configurable

  Future<gmaps.LatLng?> getLatLngFromPlaceId(String placeId) async {
    if (_useDirectApi) {
      return _getLatLngFromPlaceIdViaApi(placeId);
    } else {
      return _getLatLngFromPlaceIdViaProxy(placeId);
    }
  }

  Future<Place?> getAddressFromLatLng(gmaps.LatLng latLng) async {
    if (_useDirectApi) {
      return _getAddressFromLatLngViaApi(latLng);
    } else {
      return _getAddressFromLatLngViaProxy(latLng);
    }
  }

  Future<gmaps.LatLng?> _getLatLngFromPlaceIdViaApi(String placeId) async {
    final url = ApiConstants.geocodingUrl(placeId);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return gmaps.LatLng(location['lat'], location['lng']);
        } else {
          print('Geocoding API returned no results for place ID: $placeId');
          return null;
        }
      } else {
        print('Geocoding API failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Geocoding API error: $e');
      return null;
    }
  }

  Future<gmaps.LatLng?> _getLatLngFromPlaceIdViaProxy(String placeId) async {
    final url = ApiConstants.proxyGeocodingUrl(placeId);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return gmaps.LatLng(location['lat'], location['lng']);
        } else {
          print('Geocoding via proxy returned no results for place ID: $placeId');
          return null;
        }
      } else {
        print('Geocoding via proxy failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Geocoding via proxy error: $e');
      return null;
    }
  }

  Future<Place?> _getAddressFromLatLngViaApi(gmaps.LatLng latLng) async {
    final url = ApiConstants.reverseGeocodingUrl(latLng.latitude, latLng.longitude);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return Place(formattedAddress: data['results'][0]['formatted_address']);
        } else {
          print('Reverse Geocoding API returned no results for: $latLng');
          return null;
        }
      } else {
        print('Reverse Geocoding API failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Reverse Geocoding API error: $e');
      return null;
    }
  }

  Future<Place?> _getAddressFromLatLngViaProxy(gmaps.LatLng latLng) async {
    final url = ApiConstants.proxyReverseGeocodingUrl(latLng.latitude, latLng.longitude);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return Place(formattedAddress: data['results'][0]['formatted_address']);
        } else {
          print('Reverse Geocoding via proxy returned no results for: $latLng');
          return null;
        }
      } else {
        print('Reverse Geocoding via proxy failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Reverse Geocoding via proxy error: $e');
      return null;
    }
  }
}
