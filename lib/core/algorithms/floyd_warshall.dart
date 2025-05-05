import 'package:latlong2/latlong.dart';

class FloydWarshall {
  static Map<LatLng, Map<LatLng, double>> findShortestPaths(
    Map<LatLng, Map<LatLng, double>> graph,
  ) {
    final numVertices = graph.length;
    final vertices = graph.keys.toList();
    final distances = <LatLng, Map<LatLng, double>>{};
    final next = <LatLng, Map<LatLng, LatLng?>>{};

    // Initialize distances and next matrices
    for (final u in vertices) {
      distances[u] = <LatLng, double>{};
      next[u] = <LatLng, LatLng?>{};
      for (final v in vertices) {
        if (u == v) {
          distances[u]![v] = 0;
        } else if (graph[u]?.containsKey(v) == true) {
          distances[u]![v] = graph[u]![v]!;
          next[u]![v] = v;
        } else {
          distances[u]![v] = double.infinity;
          next[u]![v] = null;
        }
      }
    }

    // Compute shortest paths
    for (final k in vertices) {
      for (final i in vertices) {
        for (final j in vertices) {
          if (distances[i]![k] != double.infinity &&
              distances[k]![j] != double.infinity &&
              distances[i]![k]! + distances[k]![j]! < distances[i]![j]!) {
            distances[i]![j] = distances[i]![k]! + distances[k]![j]!;
            next[i]![j] = next[i]![k];
          }
        }
      }
    }

    return distances;
  }

  static List<LatLng> getPath(
    Map<LatLng, Map<LatLng, LatLng?>> next,
    LatLng start,
    LatLng end,
  ) {
    if (!next.containsKey(start) || !next.containsKey(end) || next[start]![end] == null) {
      return []; // No path exists
    }
    final path = <LatLng>[start];
    LatLng? current = start;
    while (current != end) {
      current = next[current]![end];
      if (current == null) break; // Should not happen if a path exists
      path.add(current);
    }
    return path;
  }

  static List<LatLng> findPath(
    Map<LatLng, Map<LatLng, double>> graph,
    LatLng start,
    LatLng end,
  ) {
    final shortestDistances = findShortestPaths(graph);
    if (!shortestDistances.containsKey(start) ||
        !shortestDistances[start]!.containsKey(end) ||
        shortestDistances[start]![end] == double.infinity) {
      return []; // No path found
    }

    final next = <LatLng, Map<LatLng, LatLng?>>{};
    final vertices = graph.keys.toList();

    // Initialize the 'next' matrix again based on the final distances
    for (final u in vertices) {
      next[u] = <LatLng, LatLng?>{};
      for (final v in vertices) {
        if (u == v) {
          next[u]![v] = v;
        } else if (graph[u]?.containsKey(v) == true && shortestDistances[u]![v] == graph[u]![v]!) {
          next[u]![v] = v;
        } else {
          next[u]![v] = null;
        }
      }
    }

    // Populate the 'next' matrix by considering intermediate nodes
    for (final k in vertices) {
      for (final i in vertices) {
        for (final j in vertices) {
          if (next[i]![k] != null && next[k]![j] != null &&
              shortestDistances[i]![j] == shortestDistances[i]![k]! + shortestDistances[k]![j]!) {
            next[i]![j] ??= next[i]![k];
          }
        }
      }
    }

    return getPath(next, start, end);
  }
}
