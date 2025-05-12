#ifndef DIJKSTRA_H
#define DIJKSTRA_H

#include <vector>
#include <unordered_map>
#include <limits>
#include <queue>
#include <utility>

class Dijkstra {
public:
    struct Edge {
        int destination;
        double weight;
    };

    using Graph = std::unordered_map<int, std::vector<Edge>>;

    Dijkstra(const Graph& graph);
    std::vector<int> findShortestPath(int start, int end);
    std::unordered_map<int, double> computeShortestDistances(int start);

private:
    Graph graph_;
};

#endif // DIJKSTRA_H

