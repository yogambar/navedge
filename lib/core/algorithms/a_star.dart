import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class AStar {
  /// Heuristic function to estimate the distance between two LatLng points (Haversine formula).
  static double _calculateHeuristic(LatLng start, LatLng end) {
    const R = 6371e3; // metres
    final lat1 = start.latitude * math.pi / 180; // φ1, λ1 in radians
    final lon1 = start.longitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;
    final lon2 = end.longitude * math.pi / 180;

    final deltaLat = lat2 - lat1;
    final deltaLon = lon2 - lon1;

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1) * math.cos(lat2) *
            math.sin(deltaLon / 2) * math.sin(deltaLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return R * c; // in metres
  }

  static List<LatLng> findPath(
    Map<LatLng, Map<LatLng, double>> graph,
    LatLng start,
    LatLng end,
  ) {
    if (!graph.containsKey(start) || !graph.containsKey(end)) {
      return []; // Start or end node not in graph
    }

    final openSet = <LatLng>{start};
    final cameFrom = <LatLng, LatLng>{};
    final gScore = <LatLng, double>{start: 0};
    final fScore = <LatLng, double>{start: _calculateHeuristic(start, end)};

    while (openSet.isNotEmpty) {
      LatLng current = openSet.reduce((a, b) =>
          fScore[a]! < fScore[b]! ? a : b); // Node in openSet with lowest fScore

      if (current == end) {
        return _reconstructPath(cameFrom, current);
      }

      openSet.remove(current);

      final neighbors = graph[current]?.keys ?? <LatLng>[];
      for (final neighbor in neighbors) {
        final tentativeGScore = gScore[current]! + (graph[current]?[neighbor] ?? double.infinity);
        if (!gScore.containsKey(neighbor) || tentativeGScore < gScore[neighbor]!) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;
          fScore[neighbor] = gScore[neighbor]! + _calculateHeuristic(neighbor, end);
          if (!openSet.contains(neighbor)) {
            openSet.add(neighbor);
          }
        }
      }
    }

    return []; // No path found
  }

  static List<LatLng> _reconstructPath(
    Map<LatLng, LatLng> cameFrom,
    LatLng current,
  ) {
    final path = <LatLng>[current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      path.add(current);
    }
    return path.reversed.toList();
  }
}
