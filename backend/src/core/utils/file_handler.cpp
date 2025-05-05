#include "utils/file_handler.h"
#include <fstream>
#include <sstream>
#include <iostream>
#include <filesystem>  // For filesystem operations in C++17

namespace fs = std::filesystem;

// Function to read the contents of a file and return it as a string
std::string FileHandler::readFile(const std::string& filePath) {
    std::ifstream file(filePath);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to open file " << filePath << std::endl;
        return "";
    }

    std::stringstream buffer;
    buffer << file.rdbuf();
    file.close();
    return buffer.str();
}

// Function to write a string to a file (overwrites if the file already exists)
bool FileHandler::writeFile(const std::string& filePath, const std::string& content) {
    std::ofstream file(filePath);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to write to file " << filePath << std::endl;
        return false;
    }

    file << content;
    file.close();
    return true;
}

// Function to read a file line by line and return a vector of strings
std::vector<std::string> FileHandler::readLines(const std::string& filePath) {
    std::vector<std::string> lines;
    std::ifstream file(filePath);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to open file " << filePath << std::endl;
        return lines;
    }

    std::string line;
    while (std::getline(file, line)) {
        lines.push_back(line);
    }

    file.close();
    return lines;
}

// Function to append a string to an existing file
bool FileHandler::appendToFile(const std::string& filePath, const std::string& content) {
    std::ofstream file(filePath, std::ios::app);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to append to file " << filePath << std::endl;
        return false;
    }

    file << content;
    file.close();
    return true;
}

// Function to get all files in a directory with a specified extension (e.g., .json)
std::vector<std::string> FileHandler::getFilesInDirectory(const std::string& directoryPath, const std::string& extension) {
    std::vector<std::string> files;
    try {
        // Iterate through the files in the specified directory
        for (const auto& entry : fs::directory_iterator(directoryPath)) {
            if (fs::is_regular_file(entry) && entry.path().extension() == extension) {
                files.push_back(entry.path().string());
            }
        }
    } catch (const fs::filesystem_error& e) {
        std::cerr << "Error: " << e.what() << std::endl;
    }
    return files;
}

