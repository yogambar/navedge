#include "map/location_service.h"
#include <iostream>

// Constructor: initializes location permission as false
LocationService::LocationService() : locationPermissionGranted(false) {}

// Request location permission from the user
bool LocationService::requestLocationPermission() {
    char userResponse;
    std::cout << "Allow location access? (y/n): ";
    std::cin >> userResponse;

    if (userResponse == 'y' || userResponse == 'Y') {
        locationPermissionGranted = true;
        std::cout << "Location access granted.\n";
    } else {
        std::cout << "Location access denied.\n";
    }
    return locationPermissionGranted;
}

// Get the current location if permission is granted
std::optional<Coordinate> LocationService::getCurrentLocation() const {
    if (locationPermissionGranted) {
        // Simulated location; replace with actual location retrieval logic
        return Coordinate{28.6139, 77.2090}; // Example: New Delhi, India
    }
    return std::nullopt;
}

