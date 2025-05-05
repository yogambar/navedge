#include "algorithms/floyd_warshall.h"
#include <iostream>

FloydWarshall::FloydWarshall(int vertices) : vertices_(vertices) {
    initialize();
}

void FloydWarshall::initialize() {
    distance_ = std::vector<std::vector<double>>(vertices_, std::vector<double>(vertices_, std::numeric_limits<double>::infinity()));
    next_ = std::vector<std::vector<int>>(vertices_, std::vector<int>(vertices_, -1));

    for (int i = 0; i < vertices_; i++) {
        distance_[i][i] = 0;
        next_[i][i] = i;
    }
}

void FloydWarshall::addEdge(int u, int v, double weight) {
    distance_[u][v] = weight;
    next_[u][v] = v;
}

void FloydWarshall::computeShortestPaths() {
    for (int k = 0; k < vertices_; k++) {
        for (int i = 0; i < vertices_; i++) {
            for (int j = 0; j < vertices_; j++) {
                if (distance_[i][k] != std::numeric_limits<double>::infinity() &&
                    distance_[k][j] != std::numeric_limits<double>::infinity() &&
                    distance_[i][k] + distance_[k][j] < distance_[i][j]) {
                    
                    distance_[i][j] = distance_[i][k] + distance_[k][j];
                    next_[i][j] = next_[i][k];
                }
            }
        }
    }
}

double FloydWarshall::getDistance(int u, int v) const {
    return distance_[u][v];
}

std::vector<int> FloydWarshall::getPath(int u, int v) const {
    if (next_[u][v] == -1) {
        return {}; // No path exists
    }
    
    std::vector<int> path;
    int current = u;
    while (current != v) {
        if (current == -1) {
            return {}; // Path broken
        }
        path.push_back(current);
        current = next_[current][v];
    }
    path.push_back(v);
    return path;
}

