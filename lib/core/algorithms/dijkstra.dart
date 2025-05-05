import 'package:latlong2/latlong.dart';
import 'package:collection/collection.dart'; // Import the PriorityQueue

class Dijkstra {
  static List<LatLng> findPath(
    Map<LatLng, Map<LatLng, double>> graph,
    LatLng start,
    LatLng end,
  ) {
    if (!graph.containsKey(start) || !graph.containsKey(end)) {
      return []; // Start or end node not in graph
    }

    final distances = <LatLng, double>{};
    final predecessors = <LatLng, LatLng?>{};
    final priorityQueue = PriorityQueue<_PriorityNode>((a, b) => a.priority.compareTo(b.priority));

    // Initialize distances to infinity for all nodes except the start node
    for (final node in graph.keys) {
      distances[node] = double.infinity;
    }
    distances[start] = 0;
    priorityQueue.add(_PriorityNode(start, 0));

    while (priorityQueue.isNotEmpty) {
      final current = priorityQueue.removeFirst().node;

      if (current == end) {
        return _reconstructPath(predecessors, current);
      }

      final neighbors = graph[current]?.keys ?? <LatLng>[];
      for (final neighbor in neighbors) {
        final weight = graph[current]![neighbor]!;
        final newDistance = distances[current]! + weight;
        if (newDistance < distances[neighbor]!) {
          distances[neighbor] = newDistance;
          predecessors[neighbor] = current;
          priorityQueue.add(_PriorityNode(neighbor, newDistance));
        }
      }
    }

    return []; // No path found
  }

  static List<LatLng> _reconstructPath(
    Map<LatLng, LatLng?> predecessors,
    LatLng current,
  ) {
    final path = <LatLng>[current];
    while (predecessors.containsKey(current) && predecessors[current] != null) {
      current = predecessors[current]!;
      path.add(current);
    }
    return path.reversed.toList();
  }
}

class _PriorityNode {
  final LatLng node;
  final double priority;

  _PriorityNode(this.node, this.priority);
}
