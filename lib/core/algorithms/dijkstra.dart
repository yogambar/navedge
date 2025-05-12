import 'dart:convert';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class Dijkstra {
  late List<List<double>> graph;
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
      graph = List.generate(n, (_) => List.filled(n, double.infinity));

      for (int i = 0; i < n - 1; i++) {
        final d = _distance(nodes[i], nodes[i + 1]);
        graph[i][i + 1] = d;
        graph[i + 1][i] = d;
      }

      // Get indices closest to start and end
      int source = _closestIndex(start);
      int target = _closestIndex(end);

      return _dijkstra(source, target);
    } catch (e) {
      print('Dijkstra error: $e');
      return [];
    }
  }

  List<LatLng> _dijkstra(int source, int target) {
    final n = graph.length;
    final dist = List.filled(n, double.infinity);
    final prev = List<int?>.filled(n, null);
    final visited = List.filled(n, false);

    dist[source] = 0;

    for (int i = 0; i < n; i++) {
      int? u;
      double minDist = double.infinity;
      for (int j = 0; j < n; j++) {
        if (!visited[j] && dist[j] < minDist) {
          u = j;
          minDist = dist[j];
        }
      }

      if (u == null || u == target) break;
      visited[u] = true;

      for (int v = 0; v < n; v++) {
        if (graph[u][v] != double.infinity) {
          double alt = dist[u] + graph[u][v];
          if (alt < dist[v]) {
            dist[v] = alt;
            prev[v] = u;
          }
        }
      }
    }

    // Reconstruct path
    List<LatLng> path = [];
    int? u = target;
    while (u != null) {
      path.insert(0, nodes[u]);
      u = prev[u];
    }

    return path;
  }

  int _closestIndex(LatLng point) {
    double minDist = double.infinity;
    int idx = 0;
    for (int i = 0; i < nodes.length; i++) {
      double d = _distance(nodes[i], point);
      if (d < minDist) {
        minDist = d;
        idx = i;
      }
    }
    return idx;
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

