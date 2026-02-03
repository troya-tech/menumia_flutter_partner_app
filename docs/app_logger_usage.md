# AppLogger Usage Guide

## Overview

The `AppLogger` utility provides consistent, formatted logging throughout the application with the format:
```
[ServiceName] "message"
```

## Setup

### 1. Import the logger
```dart
import '../../utils/app_logger.dart';
```

### 2. Create a logger instance for your service/class
```dart
class MyService {
  // Create a static logger instance with your service name
  static final _logger = AppLogger('MyService');
  
  // ... rest of your code
}
```

## Usage Examples

### Debug Messages
Use for general debugging information:
```dart
_logger.debug('Fetching data from API...');
// Output: [MyService] "Fetching data from API..."
```

### Info Messages
Use for informational messages (with ℹ️ emoji):
```dart
_logger.info('Starting data sync process');
// Output: [MyService] ℹ️ "Starting data sync process"
```

### Success Messages
Use when operations complete successfully (with ✅ emoji):
```dart
_logger.success('Data sync completed');
// Output: [MyService] ✅ "Data sync completed"
```

### Warning Messages
Use for non-critical issues (with ⚠️ emoji):
```dart
_logger.warning('Cache is empty, fetching fresh data');
// Output: [MyService] ⚠️ "Cache is empty, fetching fresh data"
```

### Error Messages
Use for errors (with ❌ emoji, logs in both debug and release):
```dart
try {
  // some operation
} catch (e, stackTrace) {
  _logger.error('Failed to fetch data', e, stackTrace);
  // Output: [MyService] ❌ "Failed to fetch data"
  //         [MyService] Error details: <error>
  //         [MyService] Stack trace: <stackTrace>
}
```

### Data Logging
Use to log data/objects for debugging (with 📦 emoji):
```dart
_logger.data('User ID', userId);
// Output: [MyService] 📦 "User ID": abc123

_logger.data('Response', responseData);
// Output: [MyService] 📦 "Response": {key: value, ...}
```

## Real-World Example

```dart
import 'package:firebase_database/firebase_database.dart';
import '../../utils/app_logger.dart';

class DataService {
  static final _logger = AppLogger('DataService');
  final _db = FirebaseDatabase.instance;

  Future<Map<String, dynamic>?> fetchData(String id) async {
    _logger.info('Fetching data for ID: $id');
    
    try {
      _logger.debug('Querying Firebase database...');
      final snapshot = await _db.ref('data/$id').get();
      
      if (!snapshot.exists) {
        _logger.warning('No data found for ID: $id');
        return null;
      }
      
      final data = snapshot.value as Map<String, dynamic>;
      _logger.success('Data fetched successfully');
      _logger.data('Record count', data.length);
      
      return data;
    } catch (e, stackTrace) {
      _logger.error('Failed to fetch data', e, stackTrace);
      rethrow;
    }
  }
}
```

## Best Practices

1. **Create one logger per class/service** - Use the class name as the logger name
2. **Use appropriate log levels**:
   - `debug()` - Detailed flow information
   - `info()` - Important milestones
   - `success()` - Successful operations
   - `warning()` - Recoverable issues
   - `error()` - Errors and exceptions
   - `data()` - Variable/object inspection

3. **Be descriptive** - Write clear messages that help with debugging
4. **Log at key points**:
   - Start of operations
   - Before external calls (API, database)
   - After successful operations
   - In error handlers
   - When making decisions (if/else branches)

5. **Don't log sensitive data** - Avoid logging passwords, tokens, or PII

## Production Behavior

- `debug()`, `info()`, `warning()`, `success()`, and `data()` only log in **debug mode**
- `error()` logs in **both debug and release mode** (critical errors should always be visible)
- Stack traces only show in **debug mode**

This ensures minimal performance impact in production while maintaining visibility of critical errors.
