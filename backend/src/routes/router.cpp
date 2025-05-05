#include "routes/router.h"
#include <iostream>
#include <vector>
#include <cmath> // For distance calculations (Haversine formula or Euclidean)

// Helper function to calculate distance between two locations
double calculateDistance(const Location& loc1, const Location& loc2) {
    // Example using Euclidean distance, can be replaced with a more accurate method like Haversine formula for geographic data
    double latDiff = loc2.getLatitude() - loc1.getLatitude();
    double lonDiff = loc2.getLongitude() - loc1.getLongitude();
    return std::sqrt(latDiff * latDiff + lonDiff * lonDiff);
}

/**
 * @brief Registers a new route with a corresponding request handler.
 * @param route The route path (e.g., "/auth/login").
 * @param handler The function that processes requests for this route.
 */
void Router::registerRoute(const std::string& route, RouteHandler handler) {
    routes[route] = handler;
}

/**
 * @brief Handles an incoming request, invokes the corresponding route handler, and returns the response.
 * @param route The requested route.
 * @param request The request data in string format.
 * @return The response from the route handler or a "404 Not Found" message if the route is unregistered.
 */
std::string Router::handleRequest(const std::string& route, const std::string& request) const {
    auto it = routes.find(route);
    if (it != routes.end()) {
        return it->second(request); // Execute the registered handler function
    } else {
        return "404 Not Found: The requested route does not exist.";
    }
}

/**
 * @brief Calculates the optimal route between two locations.
 * @param source The starting location.
 * @param destination The destination location.
 * @return A vector of Location objects representing the optimal route.
 */
std::vector<Location> Router::calculateOptimalRoute(const Location& source, const Location& destination) {
    // Example method for calculating the optimal route. This can be replaced with a proper algorithm like Dijkstra or A*.

    // Assuming for now that the optimal route is just a straight line from the source to the destination.
    // More complex algorithms should be implemented based on the project's needs (like distance or traffic-based algorithms).

    std::vector<Location> route;

    // Add source and destination as part of the route
    route.push_back(source);
    route.push_back(destination);

    // Log the calculated route (for debugging purposes)
    std::cout << "Optimal route calculated:" << std::endl;
    std::cout << "Source: (" << source.getLatitude() << ", " << source.getLongitude() << ")" << std::endl;
    std::cout << "Destination: (" << destination.getLatitude() << ", " << destination.getLongitude() << ")" << std::endl;

    return route;
}

