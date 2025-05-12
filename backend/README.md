# Navedge Backend

## Overview
This is the backend for **Navedge**, a high-performance route optimization and mapping application. The backend is built in **C++** and provides advanced algorithms for navigation, authentication using **Clerk**, chatbot functionalities, and direct map processing using **OpenStreetMap (.osm.pbf) files**.

## Features
- **Routing Algorithms**: Implements **Dijkstra, Bellman-Ford, Floyd-Warshall, and Knapsack** algorithms for optimized navigation.
- **Authentication**: Uses **Clerk API** for user authentication.
- **Chatbot**: Simple, fast-response chatbot without external APIs.
- **Map Processing**: Works **entirely offline** with pre-downloaded OpenStreetMap data.
- **User Location Handling**: Uses direct location input and pin-based selection.
- **Storage & Permissions**: Handles storage and permission checks efficiently.
- **High-Performance Execution**: Optimized for speed and low resource usage.

## Project Structure
backend/ 
│── build/ # Compiled binary output 
│── include/ # Header files 
│ ├── core/algorithms/ # Algorithms for navigation 
│ ├── core/authentication/ # Clerk authentication │ ├── core/chatbot/ # Chatbot logic 
│ ├── core/map/ # Map processing │ ├── core/utils/ # Utility services (storage, sound, logging) 
│ ├── models/ # Data models 
│ ├── routes/ # Request routing 
│── src/ # Source files 
│── library/ # Manually stored external C++ libraries 
│── maps/ # Pre-downloaded OpenStreetMap files 
│── CMakeLists.txt # CMake build configuration 
│── README.md # Documentation

## Installation & Setup

### Prerequisites
- **C++ Compiler** (GCC or Clang)
- **CMake**
- **Clerk API Key** (for authentication)

### Build Instructions
1. **Navigate to the backend folder**:
   ```sh
   cd backend

