#ifndef LOGGER_H
#define LOGGER_H

#include <string>
#include <iostream>
#include <fstream>
#include <mutex>
#include <ctime>
#include <iomanip>
#include <sstream>
#include <memory>  // For std::unique_ptr

// Enum for log levels
enum class LogLevel {
    INFO,
    WARNING,
    ERROR
};

// Logger class to handle logging at various levels
class Logger {
public:
    // Get the singleton instance of Logger
    static Logger& getInstance();

    // Logs a message at a specified log level
    void log(LogLevel level, const std::string& message);

    // Set the log file where logs will be saved
    void setLogFile(const std::string& filePath);

    // Enable or disable logging to the console
    void enableConsoleLogging(bool enable);

private:
    // Private constructor for singleton pattern
    Logger();

    // Destructor to close log file
    ~Logger();

    // File stream to write logs to a file
    std::ofstream logFile;

    // Mutex to ensure thread safety while logging
    std::mutex logMutex;

    // Flag to determine if logging to the console is enabled
    bool consoleLoggingEnabled;

    // Get the current timestamp for log entries
    std::string getTimestamp();

    // Convert LogLevel enum to a string for display
    std::string logLevelToString(LogLevel level);

    // Private function to log to console if enabled
    void logToConsole(const std::string& message);
};

// Macros to log messages at different levels
#define LOG_INFO(message) Logger::getInstance().log(LogLevel::INFO, message)
#define LOG_WARNING(message) Logger::getInstance().log(LogLevel::WARNING, message)
#define LOG_ERROR(message) Logger::getInstance().log(LogLevel::ERROR, message)

#endif // LOGGER_H

