#ifndef CHATBOT_H
#define CHATBOT_H

#include <string>
#include <unordered_map>
#include <algorithm>  // for transforming user input to lowercase

class Chatbot {
public:
    // Constructor that loads responses from a file
    Chatbot(const std::string& responsesFile);
    
    // Process user input and return chatbot's response
    std::string getResponse(const std::string& userInput);

private:
    std::unordered_map<std::string, std::string> responses; // Predefined responses
    void loadResponses(const std::string& filePath); // Load responses from a JSON file
};

#endif // CHATBOT_H

