#include "models/map_model.h"

// Constructor implementation
MapModel::MapModel(int id, const std::string& name, const std::string& filePath)
    : id(id), name(name), filePath(filePath) {}

// Getters
int MapModel::getId() const {
    return id;
}

std::string MapModel::getName() const {
    return name;
}

std::string MapModel::getFilePath() const {
    return filePath;
}

// Setters
void MapModel::setName(const std::string& newName) {
    name = newName;
}

void MapModel::setFilePath(const std::string& newFilePath) {
    filePath = newFilePath;
}

