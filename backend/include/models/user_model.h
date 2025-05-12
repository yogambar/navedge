#ifndef USER_MODEL_H
#define USER_MODEL_H

#include <string>
#include <vector>

class UserModel {
public:
    // Constructor
    UserModel(int id, const std::string& name, const std::string& email, const std::string& passwordHash);

    // Getters
    int getId() const;
    std::string getName() const;
    std::string getEmail() const;
    std::string getPasswordHash() const;

    // Setters
    void setName(const std::string& name);
    void setEmail(const std::string& email);
    void setPasswordHash(const std::string& passwordHash);

    // Utility
    bool verifyPassword(const std::string& password) const;

    // Static methods for file handling
    static bool loadUsersFromFile(const std::string& filePath, std::vector<UserModel>& users);
    static bool saveUsersToFile(const std::string& filePath, const std::vector<UserModel>& users);

private:
    int id;
    std::string name;
    std::string email;
    std::string passwordHash; // Store hashed password
};

#endif // USER_MODEL_H

