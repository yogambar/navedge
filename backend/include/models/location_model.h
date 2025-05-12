#ifndef LOCATION_MODEL_H
#define LOCATION_MODEL_H

#include <string>

class Location {
public:
    // Constructor
    Location(double latitude, double longitude, const std::string& name = "");

    // Getters
    double getLatitude() const;
    double getLongitude() const;
    std::string getName() const;

    // Setters
    void setLatitude(double newLatitude);
    void setLongitude(double newLongitude);
    void setName(const std::string& newName);

    // Equality comparison operators
    bool operator==(const Location& other) const;
    bool operator!=(const Location& other) const;

    // Method to calculate distance to another location (Haversine formula)
    double distanceTo(const Location& other) const;

    // Convert location to string (for easier logging/debugging)
    std::string toString() const;

private:
    double latitude;
    double longitude;
    std::string name; // Optional name of the location
};

#endif // LOCATION_MODEL_H

