#ifndef FLOYD_WARSHALL_H
#define FLOYD_WARSHALL_H

#include <vector>
#include <limits>

class FloydWarshall {
public:
    FloydWarshall(int vertices);
    
    void addEdge(int u, int v, double weight);
    void computeShortestPaths();
    double getDistance(int u, int v) const;
    std::vector<int> getPath(int u, int v) const;

private:
    int vertices_;
    std::vector<std::vector<double>> distance_;
    std::vector<std::vector<int>> next_;

    void initialize();
};

#endif // FLOYD_WARSHALL_H

