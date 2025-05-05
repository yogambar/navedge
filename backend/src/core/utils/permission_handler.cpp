#include "utils/permission_handler.h"
#include <iostream>

#ifdef _WIN32
    #include <windows.h>
#elif __linux__
    #include <sys/stat.h>
    #include <unistd.h>
#endif

bool PermissionHandler::requestLocationPermission() {
    std::cout << "Requesting location permission..." << std::endl;
    // Simulate user granting permission
    return true;
}

bool PermissionHandler::isLocationPermissionGranted() {
    // Simulating permission check
    return true; 
}

bool PermissionHandler::requestStoragePermission() {
    std::cout << "Requesting storage permission..." << std::endl;
    // Simulate user granting permission
    return true;
}

bool PermissionHandler::isStoragePermissionGranted() {
    // Simulating permission check
    return true;
}

