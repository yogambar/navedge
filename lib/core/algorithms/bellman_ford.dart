import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/api_constants.dart';

class Edge {
  final LatLng from;
  final LatLng to;
  final double weight;

  Edge(this.from, this.to, this.weight);
}

class BellmanFord {
  Future<List<LatLng>> findPath(LatLng start, LatLng end) async {
    try {
      final uri = ApiConstants.proxyDirectionsUrl(
        '${start.latitude},${start.longitude}',
        '${end.latitude},${end.longitude}',
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch route data');
      }

      final data = jsonDecode(response.body);
      final steps = data['routes'][0]['legs'][0]['steps'] as List;

      List<LatLng> points = [];
      for (final step in steps) {
        final polyline = step['polyline']['points'];
        points.addAll(_decodePolyline(polyline));
      }

      if (points.length < 2) return [];

      // Build graph edges
      final edges = <Edge>[];
      for (int i = 0; i < points.length - 1; i++) {
        final from = points[i];
        final to = points[i + 1];
        final weight = _distance(from, to);
        edges.add(Edge(from, to, weight));
      }

      return _bellmanFord(points, start, end, edges);
    } catch (e) {
      print('Bellman-Ford error: $e');
      return [];
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int shift = 0, result = 0, b;

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

  List<LatLng> _bellmanFord(
    List<LatLng> nodes,
    LatLng source,
    LatLng destination,
    List<Edge> edges,
  ) {
    Map<String, double> dist = {};
    Map<String, LatLng?> parent = {};

    for (var node in nodes) {
      dist[_key(node)] = double.infinity;
      parent[_key(node)] = null;
    }

    dist[_key(source)] = 0;

    for (int i = 1; i < nodes.length; i++) {
      for (var edge in edges) {
        final u = edge.from;
        final v = edge.to;
        final weight = edge.weight;

        if (dist[_key(u)]! + weight < dist[_key(v)]!) {
          dist[_key(v)] = dist[_key(u)]! + weight;
          parent[_key(v)] = u;
        }
      }
    }

    // Optional: check for negative weight cycles
    for (var edge in edges) {
      if (dist[_key(edge.from)]! + edge.weight < dist[_key(edge.to)]!) {
        throw Exception('Graph contains a negative-weight cycle');
      }
    }

    // Reconstruct path
    List<LatLng> path = [];
    LatLng? current = destination;

    while (current != null) {
      path.insert(0, current);
      current = parent[_key(current)];
    }

    if (path.first != source) {
      print('No path found');
      return [];
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

  String _key(LatLng point) => '${point.latitude},${point.longitude}';
}

