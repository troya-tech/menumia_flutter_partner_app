# Logging Best Practices

## Overview

This project uses a centralized `AppLogger` utility that automatically handles debug vs production logging. This ensures logs are helpful during development but don't impact production performance or security.

## ✅ Safe Logging (Recommended)

### Use AppLogger

```dart
import '../../utils/app_logger.dart';

class MyService {
  static final _logger = AppLogger('MyService');
  
  void myMethod() {
    _logger.debug('This only shows in debug mode');
    _logger.info('This only shows in debug mode');
    _logger.warning('This only shows in debug mode');
    _logger.error('This shows in production (errors are important!)');
    _logger.success('This only shows in debug mode');
    _logger.data('Key', 'value'); // This only shows in debug mode
  }
}
```

**Benefits:**
- ✅ Automatically disabled in production (except errors)
- ✅ Consistent format across the app
- ✅ Supports breadcrumb IDs for tracing
- ✅ Color-coded output for easy reading
- ✅ No performance impact in production

## ⚠️ Unsafe Logging (Avoid)

### Don't Use print() Directly

```dart
// ❌ BAD - Runs in production!
print('Debug info: $data');
print('[MyService] Processing...');
```

**Problems:**
- ❌ Runs in production (performance impact)
- ❌ May expose sensitive data
- ❌ Pollutes production logs
- ❌ No automatic filtering
- ❌ Inconsistent format

## 🔧 When to Use Each Log Level

### debug()
Use for detailed debugging information:
```dart
_logger.debug('Fetching user by email: $email');
_logger.debug('StreamBuilder - connectionState: ${snapshot.connectionState}');
```

### info()
Use for general informational messages:
```dart
_logger.info('User logged in successfully');
_logger.info('Configuration loaded');
```

### warning()
Use for potentially problematic situations:
```dart
_logger.warning('User not found in database');
_logger.warning('Retrying connection...');
```

### error()
Use for errors (these WILL show in production):
```dart
_logger.error('Failed to load user data', error, stackTrace);
_logger.error('Authentication failed');
```

### success()
Use for successful operations:
```dart
_logger.success('User data loaded successfully');
_logger.success('Order completed');
```

### data()
Use for key-value data logging:
```dart
_logger.data('User ID', userId);
_logger.data('Email', email);
_logger.data('Order count', orders.length);
```

## 🎯 Breadcrumb IDs

Use breadcrumb IDs to trace operations across services:

```dart
class ServiceA {
  static final _logger = AppLogger('ServiceA');
  
  Future<void> startOperation() async {
    final context = _logger.createContext();
    
    _logger.info('Starting operation', context);
    await serviceB.continueOperation(context);
  }
}

class ServiceB {
  static final _logger = AppLogger('ServiceB');
  
  Future<void> continueOperation(LogContext context) async {
    _logger.debug('Continuing operation', context);
    // Same breadcrumb ID traces the entire flow!
  }
}
```

## 📊 Production Behavior

### Debug Mode (Development)
```
[AuthService] [2345-1234] ℹ️ "Starting Google Sign-In flow"
[AuthService] [2345-1234] "Authenticating with Google..."
[AuthService] [2345-1234] ✅ "Firebase sign-in successful"
```

### Release Mode (Production)
```
(No logs shown except errors)
```

### Release Mode with Error
```
[AuthService] ❌ "Authentication failed" - Error: Network timeout
```

## 🚫 What NOT to Log

### Never Log Sensitive Data

```dart
// ❌ NEVER DO THIS
_logger.debug('Password: $password');
_logger.debug('Credit card: $cardNumber');
_logger.debug('API key: $apiKey');

// ✅ DO THIS INSTEAD
_logger.debug('Password length: ${password.length}');
_logger.debug('Card ending in: ${cardNumber.substring(cardNumber.length - 4)}');
_logger.debug('API key configured: ${apiKey.isNotEmpty}');
```

### Avoid Logging Large Objects

```dart
// ❌ BAD - Too much data
_logger.debug('All users: $allUsers');

// ✅ GOOD - Summary only
_logger.debug('Loaded ${allUsers.length} users');
_logger.data('User count', allUsers.length);
```

## 🔍 Debugging Tips

### Temporary Debug Logs

If you need temporary debug logs, use AppLogger (they'll auto-disable in production):

```dart
// Temporary debugging - safe to commit
_logger.debug('TEMP: Checking value: $value');
_logger.data('TEMP: State', currentState);
```

### Conditional Logging

For very verbose logging, you can add extra conditions:

```dart
if (kDebugMode && someCondition) {
  _logger.debug('Very detailed debug info...');
}
```

## 📝 Migration Guide

### Replacing print() with AppLogger

**Before:**
```dart
print('[MyService] Starting operation');
print('User: $user');
print('Error: $error');
```

**After:**
```dart
class MyService {
  static final _logger = AppLogger('MyService');
  
  void myMethod() {
    _logger.info('Starting operation');
    _logger.data('User', user.displayName);
    _logger.error('Operation failed', error);
  }
}
```

## 🎨 Log Output Format

```
[ServiceName] [breadcrumb-id] 📦 "Key": value
[ServiceName] [breadcrumb-id] ℹ️ "message"
[ServiceName] [breadcrumb-id] ⚠️ "warning"
[ServiceName] [breadcrumb-id] ❌ "error"
[ServiceName] [breadcrumb-id] ✅ "success"
[ServiceName] [breadcrumb-id] "debug message"
```

## ✅ Checklist

Before committing code with logs:

- [ ] Using `AppLogger` instead of `print()`
- [ ] Not logging sensitive data (passwords, tokens, etc.)
- [ ] Not logging large objects (use summaries)
- [ ] Using appropriate log levels
- [ ] Using breadcrumb IDs for multi-service operations
- [ ] Errors include stack traces when available

## 📚 See Also

- `docs/app_logger_usage.md` - Complete AppLogger documentation
- `lib/utils/app_logger.dart` - AppLogger implementation
- `lib/examples/breadcrumb_example.dart` - Breadcrumb ID examples
