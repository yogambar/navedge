#include "algorithms/bellman_ford.h"
#include <iostream>

BellmanFord::BellmanFord(int vertices, const std::vector<Edge>& edges)
    : vertices_(vertices), edges_(edges) {}

bool BellmanFord::findShortestPath(int start, std::unordered_map<int, double>& distances, std::unordered_map<int, int>& predecessors) {
    // Initialize distances
    for (int i = 0; i < vertices_; i++) {
        distances[i] = std::numeric_limits<double>::infinity();
        predecessors[i] = -1;
    }
    distances[start] = 0;

    // Relax all edges (V - 1) times
    for (int i = 0; i < vertices_ - 1; i++) {
        for (const auto& edge : edges_) {
            if (distances[edge.source] != std::numeric_limits<double>::infinity() &&
                distances[edge.source] + edge.weight < distances[edge.destination]) {
                distances[edge.destination] = distances[edge.source] + edge.weight;
                predecessors[edge.destination] = edge.source;
            }
        }
    }

    // Check for negative-weight cycles
    for (const auto& edge : edges_) {
        if (distances[edge.source] != std::numeric_limits<double>::infinity() &&
            distances[edge.source] + edge.weight < distances[edge.destination]) {
            std::cerr << "Graph contains a negative-weight cycle!" << std::endl;
            return false;
        }
    }

    return true;
}

