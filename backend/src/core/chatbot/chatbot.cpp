#include "chatbot/chatbot.h"
#include <fstream>
#include <sstream>
#include <iostream>
#include <nlohmann/json.hpp> // JSON parsing library
#include <algorithm> // For transforming user input to lowercase

using json = nlohmann::json;

Chatbot::Chatbot(const std::string& responsesFile) {
    loadResponses(responsesFile);
}

void Chatbot::loadResponses(const std::string& filePath) {
    std::ifstream file(filePath);
    if (!file) {
        std::cerr << "Error: Could not open chatbot responses file: " << filePath << std::endl;
        return;
    }

    // Parse the JSON file
    json responseJson;
    file >> responseJson;

    // Load key-value pairs from the JSON object into the responses map
    for (auto& [key, value] : responseJson.items()) {
        responses[key] = value.get<std::string>();
    }
}

std::string Chatbot::getResponse(const std::string& userInput) {
    std::string lowerInput = userInput;
    // Convert user input to lowercase for case-insensitive matching
    std::transform(lowerInput.begin(), lowerInput.end(), lowerInput.begin(), ::tolower);

    // Iterate over the predefined responses and check for keyword matches
    for (const auto& [key, response] : responses) {
        // Check if the keyword exists in the lowercased user input
        if (lowerInput.find(key) != std::string::npos) {
            return response;
        }
    }

    // If no match found, return a default message
    return "I'm not sure how to respond to that.";
}

