#include "utils/storage_handler.h"
#include <fstream>
#include <iostream>

bool StorageHandler::saveToFile(const std::string& filePath, const std::string& data) {
    std::ofstream outFile(filePath, std::ios::out | std::ios::trunc);
    if (!outFile) {
        std::cerr << "Error: Unable to open file for writing: " << filePath << std::endl;
        return false;
    }
    outFile << data;
    outFile.close();
    return true;
}

std::string StorageHandler::loadFromFile(const std::string& filePath) {
    std::ifstream inFile(filePath, std::ios::in);
    if (!inFile) {
        std::cerr << "Error: Unable to open file for reading: " << filePath << std::endl;
        return "";
    }
    
    std::string content((std::istreambuf_iterator<char>(inFile)), std::istreambuf_iterator<char>());
    inFile.close();
    return content;
}

bool StorageHandler::fileExists(const std::string& filePath) {
    std::ifstream file(filePath);
    return file.good();
}

