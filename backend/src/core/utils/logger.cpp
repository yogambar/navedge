#include "utils/logger.h"
#include <ctime>
#include <iomanip>
#include <sstream>
#include <iostream>
#include <mutex>
#include <fstream>

// Singleton instance of Logger
Logger& Logger::getInstance() {
    static Logger instance;  // Ensures only one instance of Logger exists
    return instance;
}

// Constructor - Initializes the default log file
Logger::Logger() : consoleLoggingEnabled(true) {
    setLogFile("backend/logs/navedge.log");  // Default log file path
}

// Destructor - Ensures the log file is closed when the Logger instance is destroyed
Logger::~Logger() {
    if (logFile.is_open()) {
        logFile.close();  // Close log file if it's open
    }
}

// Set the log file path where logs will be saved
void Logger::setLogFile(const std::string& filePath) {
    std::lock_guard<std::mutex> lock(logMutex);  // Ensure thread-safety when setting the log file

    // Close existing log file if open
    if (logFile.is_open()) {
        logFile.close();
    }

    // Open the log file for appending (create if not exists)
    logFile.open(filePath, std::ios::app);
    if (!logFile) {
        std::cerr << "Failed to open log file: " << filePath << std::endl;  // Print error to console if file can't be opened
    }
}

// Log a message with the specified log level (INFO, WARNING, ERROR)
void Logger::log(LogLevel level, const std::string& message) {
    std::lock_guard<std::mutex> lock(logMutex);  // Ensure thread-safety when logging

    // Get the current timestamp
    std::string timestamp = getTimestamp();
    
    // Format the log message
    std::string logMessage = "[" + timestamp + "] [" + logLevelToString(level) + "] " + message;

    // Log message to console if enabled
    if (consoleLoggingEnabled) {
        logToConsole(logMessage);
    }

    // Write log message to the log file if it's open
    if (logFile.is_open()) {
        logFile << logMessage << std::endl;
    }
}

// Enable or disable console logging
void Logger::enableConsoleLogging(bool enable) {
    consoleLoggingEnabled = enable;
}

// Private method to log message to the console
void Logger::logToConsole(const std::string& message) {
    std::cout << message << std::endl;  // Output log message to console
}

// Get the current timestamp in "YYYY-MM-DD HH:MM:SS" format
std::string Logger::getTimestamp() {
    auto now = std::time(nullptr);  // Get current time
    std::tm localTime;
    localtime_r(&now, &localTime);  // Thread-safe version of localtime
    std::ostringstream oss;
    oss << std::put_time(&localTime, "%Y-%m-%d %H:%M:%S");  // Format the timestamp
    return oss.str();  // Return the formatted timestamp
}

// Convert LogLevel enum to string for easier display
std::string Logger::logLevelToString(LogLevel level) {
    switch (level) {
        case LogLevel::INFO: return "INFO";     // Return "INFO" string for INFO log level
        case LogLevel::WARNING: return "WARNING"; // Return "WARNING" string for WARNING log level
        case LogLevel::ERROR: return "ERROR";   // Return "ERROR" string for ERROR log level
        default: return "UNKNOWN";               // Default case for unknown log levels
    }
}

