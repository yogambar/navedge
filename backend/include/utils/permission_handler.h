#ifndef PERMISSION_HANDLER_H
#define PERMISSION_HANDLER_H

#include <string>

class PermissionHandler {
public:
    // Request location access permission
    static bool requestLocationPermission();

    // Check if location permission is granted
    static bool isLocationPermissionGranted();

    // Request storage access permission
    static bool requestStoragePermission();

    // Check if storage permission is granted
    static bool isStoragePermissionGranted();

private:
    PermissionHandler() = default; // Prevent instantiation
};

#endif // PERMISSION_HANDLER_H

