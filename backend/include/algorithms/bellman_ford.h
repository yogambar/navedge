#ifndef BELLMAN_FORD_H
#define BELLMAN_FORD_H

#include <vector>
#include <unordered_map>
#include <limits>

struct Edge {
    int source;
    int destination;
    double weight;
};

class BellmanFord {
public:
    BellmanFord(int vertices, const std::vector<Edge>& edges);
    
    // Finds the shortest path from the start node to all others
    bool findShortestPath(int start, std::unordered_map<int, double>& distances, std::unordered_map<int, int>& predecessors);

private:
    int vertices_;
    std::vector<Edge> edges_;
};

#endif // BELLMAN_FORD_H

