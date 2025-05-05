#include "route_manager.h"
#include "utils/logger.h"
#include "utils/file_handler.h"
#include <fstream>
#include <nlohmann/json.hpp> // for JSON parsing

using json = nlohmann::json;

// Constructor for RouteManager
RouteManager::RouteManager() {}

// Load routes from a specified directory
bool RouteManager::loadRoutes(const std::string& directoryPath) {
    Logger::getInstance().log(LogLevel::INFO, "Loading routes from: " + directoryPath);

    // Get all .json files in the directory
    std::vector<std::string> routeFiles = FileHandler::getFilesInDirectory(directoryPath, ".json");
    if (routeFiles.empty()) {
        Logger::getInstance().log(LogLevel::ERROR, "No route files found in " + directoryPath);
        return false;
    }

    // Iterate through each file and parse its contents
    for (const std::string& file : routeFiles) {
        std::string fileData = FileHandler::readFile(file);
        if (fileData.empty()) {
            Logger::getInstance().log(LogLevel::ERROR, "Failed to read route file: " + file);
            continue;
        }

        try {
            json routeJson = json::parse(fileData);
            std::vector<Location> route;

            // Parse the JSON and create Location objects
            for (const auto& node : routeJson) {
                if (node.contains("latitude") && node.contains("longitude")) {
                    route.emplace_back(node["latitude"], node["longitude"]);
                }
            }

            // Add the route to the routes vector if it's valid
            if (!route.empty()) {
                routes.push_back(route);
            }
        } catch (json::parse_error& e) {
            Logger::getInstance().log(LogLevel::ERROR, "Error parsing JSON in " + file + ": " + std::string(e.what()));
            continue;
        }
    }

    Logger::getInstance().log(LogLevel::INFO, "Successfully loaded " + std::to_string(routes.size()) + " routes.");
    return !routes.empty();
}

// Find the best route between two locations
std::vector<Location> RouteManager::findBestRoute(const Location& source, const Location& destination) {
    Logger::getInstance().log(LogLevel::INFO, "Finding best route from (" + std::to_string(source.getLatitude()) + ", " + 
                 std::to_string(source.getLongitude()) + ") to (" +
                 std::to_string(destination.getLatitude()) + ", " + 
                 std::to_string(destination.getLongitude()) + ")");

    // Use the Router class to calculate the optimal route
    std::vector<Location> bestRoute = router.calculateOptimalRoute(source, destination);
    
    if (bestRoute.empty()) {
        Logger::getInstance().log(LogLevel::ERROR, "No valid route found between the given locations.");
    } else {
        Logger::getInstance().log(LogLevel::INFO, "Best route found with " + std::to_string(bestRoute.size()) + " points.");
    }

    return bestRoute;
}

// Get all available routes
std::vector<std::vector<Location>> RouteManager::getAllRoutes() const {
    return routes;
}

// Save a route to a file
bool RouteManager::saveRoute(const std::string& filename, const std::vector<Location>& route) {
    if (route.empty()) {
        Logger::getInstance().log(LogLevel::ERROR, "Cannot save an empty route.");
        return false;
    }

    // Convert the route to a JSON format
    json routeJson;
    for (const auto& location : route) {
        routeJson.push_back({
            {"latitude", location.getLatitude()},
            {"longitude", location.getLongitude()}
        });
    }

    // Write the route to the specified file
    if (FileHandler::writeFile(filename, routeJson.dump(4))) {
        Logger::getInstance().log(LogLevel::INFO, "Route successfully saved to " + filename);
        return true;
    } else {
        Logger::getInstance().log(LogLevel::ERROR, "Failed to save route to " + filename);
        return false;
    }
}

