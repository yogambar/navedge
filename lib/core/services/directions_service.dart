import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../constants/api_constants.dart';
import '../models/route_model.dart';

class DirectionsService {
  final bool _useDirectApi = true; // Consider making this configurable

  Future<List<RouteModel>?> getDirections({
    required gmaps.LatLng origin,
    required gmaps.LatLng destination,
  }) async {
    if (_useDirectApi) {
      return _fetchDirectionsViaApi(origin, destination);
    } else {
      return _fetchDirectionsViaProxy(origin, destination);
    }
  }

  Future<List<RouteModel>?> _fetchDirectionsViaApi(
    gmaps.LatLng origin,
    gmaps.LatLng destination,
  ) async {
    final originString = '${origin.latitude},${origin.longitude}';
    final destinationString = '${destination.latitude},${destination.longitude}';
    final url = ApiConstants.directionsUrl(originString, destinationString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return (data['routes'] as List)
              .map((json) => RouteModel.fromJson(json))
              .toList();
        } else {
          print('Directions API returned no routes.');
          return null;
        }
      } else {
        print('Directions API failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Directions API error: $e');
      return null;
    }
  }

  Future<List<RouteModel>?> _fetchDirectionsViaProxy(
    gmaps.LatLng origin,
    gmaps.LatLng destination,
  ) async {
    final originString = '${origin.latitude},${origin.longitude}';
    final destinationString = '${destination.latitude},${destination.longitude}';
    final url = ApiConstants.proxyDirectionsUrl(originString, destinationString);

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          return (data['routes'] as List)
              .map((json) => RouteModel.fromJson(json))
              .toList();
        } else {
          print('Directions via proxy returned no routes.');
          return null;
        }
      } else {
        print('Directions via proxy failed with status: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Directions via proxy error: $e');
      return null;
    }
  }
}
