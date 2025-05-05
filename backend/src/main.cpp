#include <iostream>
#include <fstream>
#include <vector>
#include <string>
#include <nlohmann/json.hpp>
#include "authentication/clerk_auth.h"
#include "routes/route_manager.h"
#include "map/map_processor.h"
#include "chatbot/chatbot.h"
#include "utils/config.h"
#include "utils/logger.h"

using json = nlohmann::json;

void displayWelcomeMessage() {
    std::cout << "=====================================\n";
    std::cout << "       Navedge Backend Service\n";
    std::cout << "=====================================\n";
}

int main() {
    // Display welcome message
    displayWelcomeMessage();

    // Log initialization message
    LOG_INFO("Initializing backend...");

    // Load configuration settings
    if (!Config::loadSettings("backend/data/settings.json")) {
        LOG_ERROR("Failed to load settings. Exiting...");
        return 1;
    }

    // Retrieve Clerk API keys from config
    std::string clerkSecretKey = Config::getValue("authentication.clerk_secret_key");
    if (clerkSecretKey.empty()) {
        LOG_ERROR("Clerk Secret API Key is missing from settings.json.");
        return 1;
    }

    // Initialize Clerk authentication
    ClerkAuth clerkAuth;

    // Test user credentials for registration and authentication
    std::string email = "tester@gmail.com";
    std::string password = "Tester@0248";

    // Register the test user
    bool authSuccess = clerkAuth.registerUser(email, password);
    if (authSuccess) {
        LOG_INFO("User registered successfully.");
    } else {
        LOG_WARNING("User registration failed or user already exists.");
    }

    // Authenticate test user
    std::string testToken = "test-user-token";  // Replace with actual token retrieval logic
    if (clerkAuth.authenticateUser(testToken)) {
        LOG_INFO("User authenticated successfully.");
    } else {
        LOG_ERROR("Authentication failed for user.");
        return 1;  // Stop execution if authentication fails
    }

    // Load available routes
    RouteManager routeManager;
    if (!routeManager.loadRoutes("backend/data/routes")) {
        LOG_ERROR("Failed to load routes.");
        return 1;  // Fail if routes cannot be loaded
    } else {
        LOG_INFO("Routes loaded successfully.");
    }

    // Process map data
    MapProcessor mapProcessor("backend/map"); // Assuming map data path is passed as a parameter
    if (!mapProcessor.loadMapData()) {
        LOG_ERROR("Failed to load map data.");
        return 1;  // Fail if map data cannot be loaded
    } else {
        LOG_INFO("Map data loaded successfully.");
    }

    // Start chatbot interaction
    Chatbot chatbot("backend/data/chatbot_responses.json"); // Path to chatbot responses file
    std::string userInput;

    std::cout << "Chatbot is ready! Type 'exit' to quit.\n";
    while (true) {
        std::cout << "You: ";
        std::getline(std::cin, userInput);

        if (userInput == "exit") {
            break;
        }

        std::string botResponse = chatbot.getResponse(userInput);
        std::cout << "Bot: " << botResponse << std::endl;
    }

    // Log shutdown message
    LOG_INFO("Backend shutting down...");
    return 0;
}

