#include "authentication/clerk_auth.h"
#include "utils/storage_handler.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <curl/curl.h>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// Helper function to handle cURL response
size_t writeCallback(void* contents, size_t size, size_t nmemb, std::string* output) {
    size_t totalSize = size * nmemb;
    output->append((char*)contents, totalSize);
    return totalSize;
}

// Constructor: Load API keys
ClerkAuth::ClerkAuth() {
    loadApiKeys();
}

// Load API keys from settings.json
void ClerkAuth::loadApiKeys() {
    std::string configData = StorageHandler::loadFromFile("backend/data/settings.json");

    if (!configData.empty()) {
        try {
            json configJson = json::parse(configData);
            if (configJson.contains("authentication")) {
                if (configJson["authentication"].contains("clerk_publishable_key")) {
                    publishableKey = configJson["authentication"]["clerk_publishable_key"];
                }
                if (configJson["authentication"].contains("clerk_secret_key")) {
                    secretKey = configJson["authentication"]["clerk_secret_key"];
                }
            } else {
                std::cerr << "Error: Clerk API keys missing in settings.json" << std::endl;
            }
        } catch (json::parse_error& e) {
            std::cerr << "Error parsing settings.json: " << e.what() << std::endl;
        }
    } else {
        std::cerr << "Error: Unable to load settings.json" << std::endl;
    }
}

// Generic function to send HTTP requests to Clerk API
std::string ClerkAuth::sendRequest(const std::string& endpoint, const std::string& method, const std::string& requestData) const {
    if (secretKey.empty()) {
        std::cerr << "Error: Clerk Secret API key is not set!" << std::endl;
        return "";
    }

    std::string url = "https://api.clerk.dev/v1" + endpoint;
    std::string responseString;

    CURL* curl = curl_easy_init();
    if (curl) {
        struct curl_slist* headers = nullptr;
        headers = curl_slist_append(headers, ("Authorization: Bearer " + secretKey).c_str());
        headers = curl_slist_append(headers, "Content-Type: application/json");

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeCallback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &responseString);

        if (method == "POST") {
            curl_easy_setopt(curl, CURLOPT_POST, 1L);
            curl_easy_setopt(curl, CURLOPT_POSTFIELDS, requestData.c_str());
        } else if (method == "DELETE") {
            curl_easy_setopt(curl, CURLOPT_CUSTOMREQUEST, "DELETE");
        }

        CURLcode res = curl_easy_perform(curl);
        if (res != CURLE_OK) {
            std::cerr << "cURL Error: " << curl_easy_strerror(res) << std::endl;
        }

        curl_easy_cleanup(curl);
        curl_slist_free_all(headers);
    }

    return responseString;
}

// Authenticate user with Clerk token
bool ClerkAuth::authenticateUser(const std::string& token) {
    std::string response = sendRequest("/sessions/" + token, "GET");

    if (!response.empty()) {
        try {
            json jsonResponse = json::parse(response);
            return jsonResponse.contains("id"); // If the response contains an ID, authentication is successful
        } catch (json::parse_error& e) {
            std::cerr << "Error parsing authentication response: " << e.what() << std::endl;
        }
    }

    return false;
}

// Register a new user
bool ClerkAuth::registerUser(const std::string& email, const std::string& password) {
    json requestBody = {
        {"email_address", email},
        {"password", password}
    };

    std::string response = sendRequest("/users", "POST", requestBody.dump());

    if (!response.empty()) {
        try {
            json jsonResponse = json::parse(response);
            return jsonResponse.contains("id"); // User registration is successful if an ID is present
        } catch (json::parse_error& e) {
            std::cerr << "Error parsing registration response: " << e.what() << std::endl;
        }
    }

    return false;
}

// Fetch user details from Clerk
std::string ClerkAuth::getUserDetails(const std::string& userId) {
    return sendRequest("/users/" + userId, "GET");
}

// Logout user by invalidating session
bool ClerkAuth::logoutUser(const std::string& token) {
    std::string response = sendRequest("/sessions/" + token, "DELETE");

    if (!response.empty()) {
        try {
            json jsonResponse = json::parse(response);
            return jsonResponse.contains("success"); // Successful logout returns success
        } catch (json::parse_error& e) {
            std::cerr << "Error parsing logout response: " << e.what() << std::endl;
        }
    }

    return false;
}

// Refresh authentication token
std::string ClerkAuth::refreshAuthToken(const std::string& refreshToken) {
    json requestBody = {
        {"refresh_token", refreshToken}
    };

    std::string response = sendRequest("/sessions/refresh", "POST", requestBody.dump());

    if (!response.empty()) {
        try {
            json jsonResponse = json::parse(response);
            if (jsonResponse.contains("token")) {
                return jsonResponse["token"];
            }
        } catch (json::parse_error& e) {
            std::cerr << "Error parsing token refresh response: " << e.what() << std::endl;
        }
    }

    return "";
}

