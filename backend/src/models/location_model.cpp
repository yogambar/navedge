#include "models/location_model.h"
#include <cmath>
#include <iostream>
#include <sstream>

// Constructor implementation
Location::Location(double latitude, double longitude, const std::string& name)
    : latitude(latitude), longitude(longitude), name(name) {}

// Getters
double Location::getLatitude() const {
    return latitude;
}

double Location::getLongitude() const {
    return longitude;
}

std::string Location::getName() const {
    return name;
}

// Setters
void Location::setLatitude(double newLatitude) {
    latitude = newLatitude;
}

void Location::setLongitude(double newLongitude) {
    longitude = newLongitude;
}

void Location::setName(const std::string& newName) {
    name = newName;
}

// Equality comparison operators
bool Location::operator==(const Location& other) const {
    return latitude == other.latitude && longitude == other.longitude;
}

bool Location::operator!=(const Location& other) const {
    return !(*this == other);  // Calls operator== and negates the result
}

// Method to calculate distance to another location (Haversine formula)
double Location::distanceTo(const Location& other) const {
    const double R = 6371.0; // Radius of Earth in kilometers
    double lat1 = latitude * M_PI / 180.0;  // Convert latitude from degrees to radians
    double lon1 = longitude * M_PI / 180.0; // Convert longitude from degrees to radians
    double lat2 = other.latitude * M_PI / 180.0;
    double lon2 = other.longitude * M_PI / 180.0;

    // Haversine formula
    double dlat = lat2 - lat1;
    double dlon = lon2 - lon1;
    double a = sin(dlat / 2) * sin(dlat / 2) +
               cos(lat1) * cos(lat2) *
               sin(dlon / 2) * sin(dlon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in kilometers
}

// Convert location to string (for easier logging/debugging)
std::string Location::toString() const {
    std::ostringstream oss;
    oss << "Location(" << latitude << ", " << longitude << ", " << name << ")";
    return oss.str();
}

