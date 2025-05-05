#ifndef MAP_MODEL_H
#define MAP_MODEL_H

#include <string>
#include <vector>

class MapModel {
public:
    // Constructor
    MapModel(int id, const std::string& name, const std::string& filePath);

    // Getters
    int getId() const;
    std::string getName() const;
    std::string getFilePath() const;

    // Setters
    void setName(const std::string& name);
    void setFilePath(const std::string& filePath);

private:
    int id;
    std::string name;
    std::string filePath; // Path to the OSM file
};

#endif // MAP_MODEL_H

