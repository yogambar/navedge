import 'dart:convert';
import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AStar {
  late List<LatLng> nodes;
  late List<List<double>> graph;

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

      final source = _closestIndex(start);
      final target = _closestIndex(end);

      return _aStar(source, target);
    } catch (e) {
      print('A* error: $e');
      return [];
    }
  }

  List<LatLng> _aStar(int source, int target) {
    final n = nodes.length;
    final openSet = <int>{source};
    final cameFrom = List<int?>.filled(n, null);

    final gScore = List.filled(n, double.infinity);
    gScore[source] = 0;

    final fScore = List.filled(n, double.infinity);
    fScore[source] = _distance(nodes[source], nodes[target]);

    while (openSet.isNotEmpty) {
      int current = openSet.reduce((a, b) => fScore[a] < fScore[b] ? a : b);

      if (current == target) {
        return _reconstructPath(cameFrom, current);
      }

      openSet.remove(current);

      for (int neighbor = 0; neighbor < n; neighbor++) {
        if (graph[current][neighbor] == double.infinity) continue;

        double tentativeG = gScore[current] + graph[current][neighbor];

        if (tentativeG < gScore[neighbor]) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeG;
          fScore[neighbor] = tentativeG + _distance(nodes[neighbor], nodes[target]);
          openSet.add(neighbor);
        }
      }
    }

    return []; // No path found
  }

  List<LatLng> _reconstructPath(List<int?> cameFrom, int current) {
    List<LatLng> totalPath = [nodes[current]];
    while (cameFrom[current] != null) {
      current = cameFrom[current]!;
      totalPath.insert(0, nodes[current]);
    }
    return totalPath;
  }

  int _closestIndex(LatLng point) {
    double minDist = double.infinity;
    int index = 0;
    for (int i = 0; i < nodes.length; i++) {
      double dist = _distance(point, nodes[i]);
      if (dist < minDist) {
        minDist = dist;
        index = i;
      }
    }
    return index;
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

  double _toRad(double degree) => degree * pi / 180;

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, lat = 0, lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
      lng += dlng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }
}

