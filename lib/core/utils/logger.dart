import 'dart:developer' as developer;
import 'dart:io';

class Logger {
  static bool enableLogging = true; // Set to false to disable all logs
  static final String logFilePath = "logs/app.log"; // Change as needed

  static void info(String message, {String tag = 'INFO'}) {
    _log(tag, message, colorCode: '\x1B[34m'); // Blue
  }

  static void warning(String message, {String tag = 'WARNING'}) {
    _log(tag, message, colorCode: '\x1B[33m'); // Yellow
  }

  static void error(String message, {String tag = 'ERROR'}) {
    _log(tag, message, colorCode: '\x1B[31m'); // Red
  }

  static void debug(String message, {String tag = 'DEBUG'}) {
    _log(tag, message, colorCode: '\x1B[32m'); // Green
  }

  static void _log(String tag, String message, {String colorCode = '\x1B[37m'}) {
    if (!enableLogging) return; // Skip logging if disabled

    final timestamp = DateTime.now().toLocal().toString();
    final logMessage = '[$timestamp] [$tag] $message';

    // Print log to console with color
    print('$colorCode$logMessage\x1B[0m'); 

    // Log using developer.log
    developer.log(logMessage, name: tag);

    // Save log to file (optional)
    _writeLogToFile(logMessage);
  }

  static void _writeLogToFile(String message) {
    try {
      final file = File(logFilePath);
      file.createSync(recursive: true); // Ensure directory exists
      file.writeAsStringSync('$message\n', mode: FileMode.append);
    } catch (e) {
      developer.log('Failed to write log: $e', name: 'Logger');
    }
  }
}

