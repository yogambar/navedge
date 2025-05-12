#include "models/user_model.h"
#include "utils/file_handler.h"
#include <iostream>
#include <fstream>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// Constructor to initialize a user object with id, name, email, and hashed password
UserModel::UserModel(int id, const std::string& name, const std::string& email, const std::string& passwordHash)
    : id(id), name(name), email(email), passwordHash(passwordHash) {}

// Getter for the user id
int UserModel::getId() const {
    return id;
}

// Getter for the user's name
std::string UserModel::getName() const {
    return name;
}

// Getter for the user's email
std::string UserModel::getEmail() const {
    return email;
}

// Getter for the user's password hash
std::string UserModel::getPasswordHash() const {
    return passwordHash;
}

// Setter for the user's name
void UserModel::setName(const std::string& name) {
    this->name = name;
}

// Setter for the user's email
void UserModel::setEmail(const std::string& email) {
    this->email = email;
}

// Setter for the user's password hash
void UserModel::setPasswordHash(const std::string& passwordHash) {
    this->passwordHash = passwordHash;
}

// Verifies the input password by comparing it with the stored password hash
bool UserModel::verifyPassword(const std::string& inputPassword) const {
    return passwordHash == inputPassword; // This comparison is for demonstration; in a real system, you should use hashing comparison
}

// Loads user data from a JSON file into a vector of UserModel objects
bool UserModel::loadUsersFromFile(const std::string& filePath, std::vector<UserModel>& users) {
    std::ifstream file(filePath);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to open users database file: " << filePath << std::endl;
        return false;
    }

    json userData;
    file >> userData; // Parse JSON data
    file.close();

    // Loop through the parsed JSON and create UserModel objects
    for (const auto& user : userData) {
        // Assuming the user data in JSON file contains fields: id, name, email, password
        users.emplace_back(user["id"], user["name"], user["email"], user["password"]);
    }

    return true;
}

// Saves a vector of UserModel objects to a JSON file
bool UserModel::saveUsersToFile(const std::string& filePath, const std::vector<UserModel>& users) {
    json userData;
    // Loop through each UserModel and convert to JSON format
    for (const auto& user : users) {
        userData.push_back({
            {"id", user.getId()},
            {"name", user.getName()},
            {"email", user.getEmail()},
            {"password", user.getPasswordHash()} // Store the password hash (not plain text)
        });
    }

    std::ofstream file(filePath);
    if (!file.is_open()) {
        std::cerr << "Error: Unable to write to users database file: " << filePath << std::endl;
        return false;
    }

    // Write the JSON object to the file with a pretty print format (4 spaces for indentation)
    file << userData.dump(4);
    file.close();
    return true;
}

