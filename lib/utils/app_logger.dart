import 'package:flutter/foundation.dart';

/// Centralized logging utility for the application
/// 
/// Provides consistent logging format: [ServiceName] "message"
/// Only logs in debug mode to avoid performance issues in production
class AppLogger {
  final String _serviceName;
  
  /// Create a logger for a specific service/class
  /// 
  /// Example: `final _logger = AppLogger('AuthService');`
  const AppLogger(this._serviceName);
  
  /// Log a debug message
  /// 
  /// Format: [ServiceName] "message"
  /// Only logs in debug mode
  void debug(String message) {
    if (kDebugMode) {
      print('[$_serviceName] "$message"');
    }
  }
  
  /// Log an info message
  /// 
  /// Format: [ServiceName] ℹ️ "message"
  void info(String message) {
    if (kDebugMode) {
      print('[$_serviceName] ℹ️ "$message"');
    }
  }
  
  /// Log a warning message
  /// 
  /// Format: [ServiceName] ⚠️ "message"
  void warning(String message) {
    if (kDebugMode) {
      print('[$_serviceName] ⚠️ "$message"');
    }
  }
  
  /// Log an error message
  /// 
  /// Format: [ServiceName] ❌ "message"
  /// Logs in both debug and release mode for critical errors
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('[$_serviceName] ❌ "$message"');
    if (error != null) {
      print('[$_serviceName] Error details: $error');
    }
    if (stackTrace != null && kDebugMode) {
      print('[$_serviceName] Stack trace:\n$stackTrace');
    }
  }
  
  /// Log a success message
  /// 
  /// Format: [ServiceName] ✅ "message"
  void success(String message) {
    if (kDebugMode) {
      print('[$_serviceName] ✅ "$message"');
    }
  }
  
  /// Log data/object for debugging
  /// 
  /// Format: [ServiceName] 📦 "label": data
  void data(String label, Object? data) {
    if (kDebugMode) {
      print('[$_serviceName] 📦 "$label": $data');
    }
  }
}
