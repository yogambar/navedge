#ifndef STORAGE_HANDLER_H
#define STORAGE_HANDLER_H

#include <string>

class StorageHandler {
public:
    // Save data to a file
    static bool saveToFile(const std::string& filePath, const std::string& data);

    // Load data from a file
    static std::string loadFromFile(const std::string& filePath);

    // Check if a file exists
    static bool fileExists(const std::string& filePath);
};

#endif // STORAGE_HANDLER_H

