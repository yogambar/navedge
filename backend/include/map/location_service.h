#ifndef LOCATION_SERVICE_H
#define LOCATION_SERVICE_H

#include <iostream>
#include <optional>

// Structure to represent geographic coordinates
struct Coordinate {
    double latitude;
    double longitude;
};

// Class to handle location services
class LocationService {
public:
    // Constructor
    LocationService();

    // Request location permission from the user
    bool requestLocationPermission();

    // Get the current location of the user (if permission is granted)
    std::optional<Coordinate> getCurrentLocation() const;

private:
    bool locationPermissionGranted;
};

#endif // LOCATION_SERVICE_H

