import 'package:latlong2/latlong.dart';

class BellmanFord {
  static Map<LatLng, double> findShortestPaths(
    Map<LatLng, Map<LatLng, double>> graph,
    LatLng startNode,
  ) {
    final distances = <LatLng, double>{};
    final predecessors = <LatLng, LatLng?>{};

    // Initialize distances to infinity for all nodes except the start node
    for (final node in graph.keys) {
      distances[node] = double.infinity;
      predecessors[node] = null;
    }
    distances[startNode] = 0;

    // Relax edges repeatedly
    for (int i = 0; i < graph.length - 1; i++) {
      for (final u in graph.keys) {
        final neighbors = graph[u];
        if (neighbors != null) {
          for (final v in neighbors.keys) {
            final weight = neighbors[v]!;
            if (distances[u] != double.infinity && distances[u]! + weight < distances[v]!) {
              distances[v] = distances[u]! + weight;
              predecessors[v] = u;
            }
          }
        }
      }
    }

    // Check for negative cycles
    for (final u in graph.keys) {
      final neighbors = graph[u];
      if (neighbors != null) {
        for (final v in neighbors.keys) {
          final weight = neighbors[v]!;
          if (distances[u] != double.infinity && distances[u]! + weight < distances[v]!) {
            throw Exception("Graph contains a negative cycle");
          }
        }
      }
    }

    return distances;
  }

  static List<LatLng> getPath(
    Map<LatLng, LatLng?> predecessors,
    LatLng targetNode,
  ) {
    final path = <LatLng>[];
    LatLng? currentNode = targetNode;
    while (currentNode != null) {
      path.add(currentNode);
      currentNode = predecessors[currentNode];
    }
    return path.reversed.toList();
  }

  static List<LatLng> findPath(
    Map<LatLng, Map<LatLng, double>> graph,
    LatLng start,
    LatLng end,
  ) {
    try {
      final distances = findShortestPaths(graph, start);
      if (!distances.containsKey(end) || distances[end] == double.infinity) {
        return []; // No path found
      }
      final predecessors = <LatLng, LatLng?>{};
      for (final u in graph.keys) {
        final neighbors = graph[u];
        if (neighbors != null) {
          for (final v in neighbors.keys) {
            final weight = neighbors[v]!;
            if (distances[u] != double.infinity && distances[u]! + weight == distances[v]! && (predecessors[v] == null || predecessors[v] == u)) {
              predecessors[v] = u;
            }
          }
        }
      }
      return getPath(predecessors, end);
    } catch (e) {
      print("Error running Bellman-Ford: $e");
      return [];
    }
  }
}
