cmake_minimum_required(VERSION 3.16)
project(navedge_backend)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Define directories
set(SOURCE_DIR ${CMAKE_SOURCE_DIR}/src)
set(INCLUDE_DIR ${CMAKE_SOURCE_DIR}/include)
set(LIBRARY_DIR ${CMAKE_SOURCE_DIR}/library)

# Add executable
add_executable(navedge_backend
    ${SOURCE_DIR}/main.cpp

    # Algorithms
    ${SOURCE_DIR}/core/algorithms/dijkstra.cpp
    ${SOURCE_DIR}/core/algorithms/bellman_ford.cpp
    ${SOURCE_DIR}/core/algorithms/floyd_warshall.cpp
    ${SOURCE_DIR}/core/algorithms/knapsack.cpp

    # Authentication
    ${SOURCE_DIR}/core/authentication/clerk_auth.cpp

    # Chatbot
    ${SOURCE_DIR}/core/chatbot/chatbot.cpp

    # Map processing
    ${SOURCE_DIR}/core/map/map_processor.cpp
    ${SOURCE_DIR}/core/map/location_service.cpp

    # Utilities
    ${SOURCE_DIR}/core/utils/file_handler.cpp
    ${SOURCE_DIR}/core/utils/logger.cpp
    ${SOURCE_DIR}/core/utils/permission_handler.cpp
    ${SOURCE_DIR}/core/utils/storage_handler.cpp
    ${SOURCE_DIR}/core/utils/sound_service.cpp
    ${SOURCE_DIR}/core/utils/config.cpp

    # Models
    ${SOURCE_DIR}/models/user_model.cpp
    ${SOURCE_DIR}/models/map_model.cpp
    ${SOURCE_DIR}/models/location_model.cpp
    ${SOURCE_DIR}/models/chatbot_model.cpp

    # Routes
    ${SOURCE_DIR}/routes/router.cpp
    ${SOURCE_DIR}/routes/route_manager.cpp
)

# Include directories
target_include_directories(navedge_backend PRIVATE 
    ${INCLUDE_DIR} 
    ${LIBRARY_DIR}/json/include 
    ${LIBRARY_DIR}/curl/include 
    ${LIBRARY_DIR}/libosmium/include 
    ${LIBRARY_DIR}/boost
)

# Find and link required external libraries

# Threads (Multithreading support)
find_package(Threads REQUIRED)
target_link_libraries(navedge_backend PRIVATE Threads::Threads)

# cURL (HTTP Requests)
find_package(CURL REQUIRED)
if (CURL_FOUND)
    target_include_directories(navedge_backend PRIVATE ${CURL_INCLUDE_DIRS})
    target_link_libraries(navedge_backend PRIVATE ${CURL_LIBRARIES})
else()
    message(FATAL_ERROR "cURL library not found!")
endif()

# Boost (Header-only mode, no linking required)
target_compile_definitions(navedge_backend PRIVATE BOOST_ALL_NO_LIB)

# Libosmium (Header-only, for OpenStreetMap processing)
target_compile_definitions(navedge_backend PRIVATE LIBOSMIUM)

# Optimize build output
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/build)

# Enable compiler warnings for better debugging
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    target_compile_options(navedge_backend PRIVATE -Wall -Wextra -Wpedantic)
elseif (MSVC)
    target_compile_options(navedge_backend PRIVATE /W4)
endif()

