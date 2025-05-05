#include "map/map_processor.h"
#include <iostream>
#include <fstream>
#include <cmath>
#include <limits>

// Constructor: Initializes the map file path
MapProcessor::MapProcessor(const std::string& mapFilePath) : mapFilePath(mapFilePath) {}

// Load map data from the OSM file
bool MapProcessor::loadMapData() {
    return parseOSMFile();
}

// Get the closest node to a given coordinate
int MapProcessor::getClosestNode(const Coordinate& coord) const {
    int closestNodeId = -1;
    double minDistance = std::numeric_limits<double>::max(); // Initialize with a large value

    // Iterate through all nodes to find the one closest to the given coordinates
    for (const auto& [id, node] : nodes) {
        double distance = std::sqrt(std::pow(coord.latitude - node.coord.latitude, 2) +
                                    std::pow(coord.longitude - node.coord.longitude, 2));
        if (distance < minDistance) {
            minDistance = distance;
            closestNodeId = id;
        }
    }

    return closestNodeId;
}

// Retrieve the road network nodes
std::vector<Node> MapProcessor::getNodes() const {
    std::vector<Node> nodeList;
    for (const auto& [id, node] : nodes) {
        nodeList.push_back(node);
    }
    return nodeList;
}

// Retrieve the road network edges
std::vector<Edge> MapProcessor::getEdges() const {
    return edges;
}

// Helper function to simulate parsing OSM file
bool MapProcessor::parseOSMFile() {
    std::ifstream file(mapFilePath, std::ios::binary);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to open map file: " << mapFilePath << std::endl;
        return false;
    }

    // Simulated parsing logic (actual parsing requires an OSM library)
    std::cout << "Parsing map data from " << mapFilePath << "..." << std::endl;

    // Dummy data for demonstration
    nodes[1] = {1, {28.6139, 77.2090}}; // Example: Delhi
    nodes[2] = {2, {34.0837, 74.7973}}; // Example: Srinagar
    edges.push_back({1, 2, 10.5});      // Example edge: Delhi to Srinagar with a distance of 10.5

    std::cout << "Map data loaded successfully!" << std::endl;
    file.close();
    return true;
}

