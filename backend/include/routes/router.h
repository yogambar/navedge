#ifndef ROUTER_H
#define ROUTER_H

#include <string>
#include <unordered_map>
#include <functional>
#include <vector>
#include "models/location_model.h"  // Include Location model for route calculations

class Router {
public:
    using RouteHandler = std::function<std::string(const std::string& request)>;

    /**
     * @brief Registers a route with its corresponding handler function.
     * @param route The route path as a string (e.g., "/auth/login").
     * @param handler The function that processes requests for this route.
     */
    void registerRoute(const std::string& route, RouteHandler handler);

    /**
     * @brief Handles an incoming request and returns the response.
     * @param route The route being requested.
     * @param request The request data in string format.
     * @return The response from the registered handler or a 404 error message.
     */
    std::string handleRequest(const std::string& route, const std::string& request) const;

    /**
     * @brief Calculates the optimal route between two locations.
     * @param source The starting location.
     * @param destination The destination location.
     * @return A vector of Location objects representing the optimal route.
     */
    std::vector<Location> calculateOptimalRoute(const Location& source, const Location& destination);

private:
    std::unordered_map<std::string, RouteHandler> routes; // Map of routes to their handlers
};

#endif // ROUTER_H

