#include "models/chatbot_model.h"
#include "utils/file_handler.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <random>
#include <nlohmann/json.hpp> // JSON library

using json = nlohmann::json;

// Constructor
ChatbotModel::ChatbotModel() {
    // Default fallback responses
    defaultResponses = {
        "I'm not sure I understand.",
        "Can you rephrase that?",
        "Interesting! Tell me more.",
        "I see. What else can I help with?"
    };
}

// Load predefined responses from a JSON file
bool ChatbotModel::loadResponses(const std::string& filePath) {
    std::ifstream file(filePath);
    if (!file.is_open()) {
        return false;
    }

    json responseJson;
    file >> responseJson;
    file.close();

    for (auto& [key, value] : responseJson.items()) {
        responses[key] = value;
    }

    return true;
}

// Get response based on user input
std::string ChatbotModel::getResponse(const std::string& userInput) const {
    std::string normalizedInput = normalizeInput(userInput);

    auto it = responses.find(normalizedInput);
    if (it != responses.end()) {
        return it->second;
    }

    // If no matching response is found, return a default fallback response
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<size_t> dist(0, defaultResponses.size() - 1);
    
    return defaultResponses[dist(gen)];
}

// Add custom response to chatbot (optional for learning behavior)
void ChatbotModel::addResponse(const std::string& input, const std::string& response) {
    responses[normalizeInput(input)] = response;
}

// Normalize user input for better matching
std::string ChatbotModel::normalizeInput(const std::string& input) const {
    std::string result = input;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    result.erase(std::remove_if(result.begin(), result.end(), ::ispunct), result.end());
    return result;
}

