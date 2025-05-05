#include "algorithms/dijkstra.h"
#include <queue>
#include <unordered_map>
#include <vector>
#include <limits>
#include <algorithm>

Dijkstra::Dijkstra(const Graph& graph) : graph_(graph) {}

std::vector<int> Dijkstra::findShortestPath(int start, int end) {
    std::unordered_map<int, double> distances;
    std::unordered_map<int, int> predecessors;
    std::priority_queue<std::pair<double, int>, std::vector<std::pair<double, int>>, std::greater<>> minHeap;

    for (const auto& node : graph_) {
        distances[node.first] = std::numeric_limits<double>::infinity();
    }
    distances[start] = 0;
    minHeap.push({0, start});

    while (!minHeap.empty()) {
        int current = minHeap.top().second;
        double currentDist = minHeap.top().first;
        minHeap.pop();

        if (current == end) break;

        for (const auto& edge : graph_.at(current)) {
            int neighbor = edge.destination;
            double newDist = currentDist + edge.weight;

            if (newDist < distances[neighbor]) {
                distances[neighbor] = newDist;
                predecessors[neighbor] = current;
                minHeap.push({newDist, neighbor});
            }
        }
    }

    std::vector<int> path;
    for (int at = end; at != start; at = predecessors[at]) {
        if (predecessors.find(at) == predecessors.end()) return {}; // No path found
        path.push_back(at);
    }
    path.push_back(start);
    std::reverse(path.begin(), path.end());
    return path;
}

std::unordered_map<int, double> Dijkstra::computeShortestDistances(int start) {
    std::unordered_map<int, double> distances;
    std::priority_queue<std::pair<double, int>, std::vector<std::pair<double, int>>, std::greater<>> minHeap;

    for (const auto& node : graph_) {
        distances[node.first] = std::numeric_limits<double>::infinity();
    }
    distances[start] = 0;
    minHeap.push({0, start});

    while (!minHeap.empty()) {
        int current = minHeap.top().second;
        double currentDist = minHeap.top().first;
        minHeap.pop();

        for (const auto& edge : graph_.at(current)) {
            int neighbor = edge.destination;
            double newDist = currentDist + edge.weight;

            if (newDist < distances[neighbor]) {
                distances[neighbor] = newDist;
                minHeap.push({newDist, neighbor});
            }
        }
    }

    return distances;
}

