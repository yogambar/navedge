#include "utils/config.h" 
#include "utils/logger.h"
#include "utils/storage_handler.h"
#include <iostream>
#include <nlohmann/json.hpp>

json Config::settings; // Initialize static member

// Load settings from a JSON file
bool Config::loadSettings(const std::string& filePath) {
    // Load the content from the file
    std::string fileContent = StorageHandler::loadFromFile(filePath);
    
    if (fileContent.empty()) {
        LOG_ERROR("Failed to load settings.json: File is empty or missing.");
        return false;
    }

    try {
        // Parse the JSON content
        settings = json::parse(fileContent);
        LOG_INFO("Configuration loaded successfully from settings.json");
        return true;
    } catch (json::parse_error& e) {
        // Handle JSON parsing error
        LOG_ERROR("JSON parsing error in settings.json: " + std::string(e.what()));
        return false;
    }
}

// Retrieve a string value from the config
std::string Config::getValue(const std::string& key, const std::string& defaultValue) {
    try {
        // Check if the key exists and retrieve the value
        json::json_pointer ptr("/" + key);
        return settings.contains(ptr) ? settings[ptr].get<std::string>() : defaultValue;
    } catch (...) {
        // Handle error and return the default value
        LOG_ERROR("Error retrieving string value for key: " + key);
        return defaultValue;
    }
}

// Retrieve an integer value from the config
int Config::getIntValue(const std::string& key, int defaultValue) {
    try {
        // Check if the key exists and retrieve the value
        json::json_pointer ptr("/" + key);
        return settings.contains(ptr) ? settings[ptr].get<int>() : defaultValue;
    } catch (...) {
        // Handle error and return the default value
        LOG_ERROR("Error retrieving integer value for key: " + key);
        return defaultValue;
    }
}

// Retrieve a boolean value from the config
bool Config::getBoolValue(const std::string& key, bool defaultValue) {
    try {
        // Check if the key exists and retrieve the value
        json::json_pointer ptr("/" + key);
        return settings.contains(ptr) ? settings[ptr].get<bool>() : defaultValue;
    } catch (...) {
        // Handle error and return the default value
        LOG_ERROR("Error retrieving boolean value for key: " + key);
        return defaultValue;
    }
}

// Retrieve a float value from the config
double Config::getFloatValue(const std::string& key, double defaultValue) {
    try {
        // Check if the key exists and retrieve the value
        json::json_pointer ptr("/" + key);
        return settings.contains(ptr) ? settings[ptr].get<double>() : defaultValue;
    } catch (...) {
        // Handle error and return the default value
        LOG_ERROR("Error retrieving float value for key: " + key);
        return defaultValue;
    }
}

