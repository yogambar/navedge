#ifndef CONFIG_H
#define CONFIG_H

#include <string>
#include <unordered_map>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

class Config {
public:
    // Load settings from a JSON file
    static bool loadSettings(const std::string& filePath);

    // Retrieve a string value from the config
    static std::string getValue(const std::string& key, const std::string& defaultValue = "");

    // Retrieve an integer value from the config
    static int getIntValue(const std::string& key, int defaultValue = 0);

    // Retrieve a boolean value from the config
    static bool getBoolValue(const std::string& key, bool defaultValue = false);

    // Retrieve a float value from the config
    static double getFloatValue(const std::string& key, double defaultValue = 0.0);

private:
    static json settings; // Holds the parsed JSON config
    static std::unordered_map<std::string, std::string> flattenJson(const json& jsonObj, const std::string& prefix = "");
};

#endif // CONFIG_H

