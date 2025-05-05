#ifndef CHATBOT_MODEL_H
#define CHATBOT_MODEL_H

#include <string>
#include <vector>
#include <unordered_map>

class ChatbotModel {
public:
    // Constructor
    ChatbotModel();

    // Load predefined responses from a JSON file
    bool loadResponses(const std::string& filePath);

    // Get response based on user input
    std::string getResponse(const std::string& userInput) const;

    // Add custom response to chatbot (optional for learning behavior)
    void addResponse(const std::string& input, const std::string& response);

private:
    std::unordered_map<std::string, std::string> responses; // Maps user inputs to responses
    std::vector<std::string> defaultResponses; // Used if input doesn't match any known phrase

    // Normalize user input for better matching
    std::string normalizeInput(const std::string& input) const;
};

#endif // CHATBOT_MODEL_H

