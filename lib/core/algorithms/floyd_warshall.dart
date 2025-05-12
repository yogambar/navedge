import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/api_constants.dart';

class FloydWarshall {
  late List<List<double>> dist;
  late List<List<int?>> next;
  late List<LatLng> nodes;

  Future<List<LatLng>> findPath(LatLng start, LatLng end) async {
    try {
      final uri = ApiConstants.proxyDirectionsUrl(
        '${start.latitude},${start.longitude}',
        '${end.latitude},${end.longitude}',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('Failed to load directions');
      }

      final data = jsonDecode(response.body);
      final steps = data['routes'][0]['legs'][0]['steps'] as List;

      nodes = [];
      for (final step in steps) {
        final polyline = step['polyline']['points'];
        nodes.addAll(_decodePolyline(polyline));
      }

      if (nodes.length < 2) return [];

      final n = nodes.length;
      dist = List.generate(n, (_) => List.filled(n, double.infinity));
      next = List.generate(n, (_) => List.filled(n, null));

      // Build the graph (fully connected with distances)
      for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
          if (i == j) {
            dist[i][j] = 0;
          } else {
            final d = _distance(nodes[i], nodes[j]);
            dist[i][j] = d;
            next[i][j] = j;
          }
        }
      }

      // Floyd-Warshall algorithm
      for (int k = 0; k < n; k++) {
        for (int i = 0; i < n; i++) {
          for (int j = 0; j < n; j++) {
            if (dist[i][k] + dist[k][j] < dist[i][j]) {
              dist[i][j] = dist[i][k] + dist[k][j];
              next[i][j] = next[i][k];
            }
          }
        }
      }

      // Find indices for start and end
      int? startIdx, endIdx;
      for (int i = 0; i < nodes.length; i++) {
        if (_isClose(nodes[i], start)) startIdx = i;
        if (_isClose(nodes[i], end)) endIdx = i;
      }

      if (startIdx == null || endIdx == null) return [];

      return _reconstructPath(startIdx, endIdx);
    } catch (e) {
      print('Floyd-Warshall error: $e');
      return [];
    }
  }

  List<LatLng> _reconstructPath(int u, int v) {
    if (next[u][v] == null) return [];

    List<LatLng> path = [nodes[u]];
    while (u != v) {
      u = next[u][v]!;
      path.add(nodes[u]);
    }
    return path;
  }

  double _distance(LatLng a, LatLng b) {
    const R = 6371e3;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final lat1 = _toRad(a.latitude);
    final lat2 = _toRad(b.latitude);

    final aVal = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(aVal), sqrt(1 - aVal));
    return R * c;
  }

  double _toRad(double deg) => deg * pi / 180;

  bool _isClose(LatLng a, LatLng b, [double threshold = 0.0005]) {
    return (a.latitude - b.latitude).abs() < threshold &&
           (a.longitude - b.longitude).abs() < threshold;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return poly;
  }
}

