#ifndef CLERK_AUTH_H
#define CLERK_AUTH_H

#include <string>

class ClerkAuth {
public:
    // Constructor to initialize ClerkAuth (loads API keys)
    ClerkAuth();

    // Authenticate user using Clerk API (sign-in or token verification)
    bool authenticateUser(const std::string& token);

    // Register a new user
    bool registerUser(const std::string& email, const std::string& password);

    // Fetch user details
    std::string getUserDetails(const std::string& userId);

    // Logout user (invalidate session)
    bool logoutUser(const std::string& token);

    // Refresh authentication token
    std::string refreshAuthToken(const std::string& refreshToken);

private:
    std::string publishableKey; // Clerk Publishable API Key
    std::string secretKey;      // Clerk Secret API Key

    // Load API keys from configuration file
    void loadApiKeys();

    // Send a request to Clerk API
    std::string sendRequest(const std::string& endpoint, const std::string& method = "GET", const std::string& requestData = "") const;
};

#endif // CLERK_AUTH_H

