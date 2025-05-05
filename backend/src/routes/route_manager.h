#ifndef ROUTE_MANAGER_H 
#define ROUTE_MANAGER_H

#include <string>
#include <vector>

// Include the Location class and other required models
#include "models/location_model.h"  // Location class definition
#include "routes/router.h"          // Router class for routing algorithms

// Include necessary headers for FileHandler and Logger
#include "utils/file_handler.h"
#include "utils/logger.h"

class RouteManager {
public:
    // Constructor to initialize RouteManager
    RouteManager();

    // Load routes from a specified directory
    bool loadRoutes(const std::string& directoryPath);

    // Find the best route between two locations
    std::vector<Location> findBestRoute(const Location& source, const Location& destination);

    // Get all available routes
    std::vector<std::vector<Location>> getAllRoutes() const;

    // Save route data to a file
    bool saveRoute(const std::string& filename, const std::vector<Location>& route);

private:
    // Stores all possible routes as vectors of Location objects
    std::vector<std::vector<Location>> routes;

    // Router object to handle the routing algorithm
    Router router;
};

#endif // ROUTE_MANAGER_H

