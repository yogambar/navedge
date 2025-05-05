#ifndef MAP_PROCESSOR_H 
#define MAP_PROCESSOR_H

#include <string>
#include <vector>
#include <unordered_map>
#include <limits>

// Structure to represent a geographical coordinate (latitude and longitude)
struct Coordinate {
    double latitude;  // Latitude of the coordinate
    double longitude; // Longitude of the coordinate
};

// Structure to represent a road network node (intersection or location)
struct Node {
    int id;          // Unique identifier for the node
    Coordinate coord; // Geographical coordinates (latitude, longitude)
};

// Structure to represent a road segment or edge in the graph (connecting two nodes)
struct Edge {
    int source;     // Source node ID
    int destination; // Destination node ID
    double weight;   // Weight (distance or time cost) of the road segment
};

// MapProcessor class for handling map data (simulated OSM data)
class MapProcessor {
public:
    // Constructor that accepts the path to an OpenStreetMap (OSM) file
    MapProcessor(const std::string& mapFilePath);

    // Load map data from an OSM file (in this case, simulate the loading)
    bool loadMapData();

    // Get the closest node to a given coordinate (returning the node ID)
    int getClosestNode(const Coordinate& coord) const;

    // Retrieve all the road network nodes as a vector
    std::vector<Node> getNodes() const;

    // Retrieve all the road network edges as a vector
    std::vector<Edge> getEdges() const;

private:
    std::string mapFilePath; // Path to the OSM file
    std::unordered_map<int, Node> nodes; // Map of nodes by ID
    std::vector<Edge> edges; // Vector of edges representing road segments

    // Helper function to parse OSM file (currently simulated)
    bool parseOSMFile();
};

#endif // MAP_PROCESSOR_H

