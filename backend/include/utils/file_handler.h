#ifndef FILE_HANDLER_H
#define FILE_HANDLER_H

#include <string>
#include <vector>
#include <filesystem>  // For filesystem operations in C++17

namespace fs = std::filesystem;

class FileHandler {
public:
    // Reads the contents of a file and returns it as a string
    static std::string readFile(const std::string& filePath);

    // Writes a string to a file (overwrites if exists)
    static bool writeFile(const std::string& filePath, const std::string& content);

    // Reads a file line by line and returns a vector of strings
    static std::vector<std::string> readLines(const std::string& filePath);

    // Appends a string to an existing file
    static bool appendToFile(const std::string& filePath, const std::string& content);

    // Get all files in a directory with a specified extension (e.g., .json)
    static std::vector<std::string> getFilesInDirectory(const std::string& directoryPath, const std::string& extension);
};

#endif // FILE_HANDLER_H

