# AppLogger Usage Guide

## Overview

The `AppLogger` utility provides consistent, formatted logging throughout the application with the format:
```
[ServiceName] [breadcrumb-id] "message"
```

### Breadcrumb IDs (Correlation IDs)

Breadcrumb IDs are unique identifiers that help trace a single operation across multiple services. They allow you to:
- Track a user action from start to finish
- Correlate logs across different services
- Debug complex flows involving multiple components
- Identify which logs belong to the same request/operation

Example output with breadcrumb IDs:
```
[AuthService] [2345-1234] ℹ️ "Starting Google Sign-In flow"
[AuthService] [2345-1234] "Authenticating with Google..."
[AuthService] [2345-1234] ✅ "Firebase sign-in successful"
[ProfilePageFacade] [2345-1234] "Loading user data..."
[ProfilePageFacade] [2345-1234] ✅ "User data loaded successfully"
```

All logs with `[2345-1234]` belong to the same sign-in operation.

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

## Using Breadcrumb IDs

### Creating a Log Context

Create a `LogContext` at the start of an operation to track it across services:

```dart
// Create a new context with a unique breadcrumb ID
final context = _logger.createContext();

// Use it in all log calls for this operation
_logger.info('Starting operation', context);
_logger.debug('Processing step 1...', context);
_logger.success('Operation completed', context);

// Output:
// [MyService] [2345-1234] ℹ️ "Starting operation"
// [MyService] [2345-1234] "Processing step 1..."
// [MyService] [2345-1234] ✅ "Operation completed"
```

### Passing Context Between Services

Pass the `LogContext` to other services to maintain the same breadcrumb ID:

```dart
class AuthService {
  static final _logger = AppLogger('AuthService');
  
  Future<User> signIn() async {
    final context = _logger.createContext();
    _logger.info('Starting sign-in', context);
    
    // ... authentication logic ...
    
    // Pass context to another service
    await _userService.loadUserData(userId, context);
    
    return user;
  }
}

class UserService {
  static final _logger = AppLogger('UserService');
  
  Future<void> loadUserData(String userId, LogContext context) async {
    _logger.debug('Loading user data', context);
    // ... load data ...
    _logger.success('User data loaded', context);
  }
}

// Output:
// [AuthService] [2345-1234] ℹ️ "Starting sign-in"
// [UserService] [2345-1234] "Loading user data"
// [UserService] [2345-1234] ✅ "User data loaded"
```

### When to Use Breadcrumb IDs

**Use breadcrumb IDs when:**
- Starting a user-initiated action (button click, form submit)
- Making API calls or database queries
- Operations that span multiple services
- Complex flows you need to debug

**Don't use breadcrumb IDs for:**
- Simple, isolated operations
- Internal helper methods that don't cross service boundaries
- Logs that don't need correlation

### Example: Complete Flow with Breadcrumbs

```dart
class OrderService {
  static final _logger = AppLogger('OrderService');
  final PaymentService _paymentService;
  final NotificationService _notificationService;
  
  Future<void> createOrder(Order order) async {
    // Create context for this entire order creation flow
    final context = _logger.createContext();
    
    _logger.info('Creating order', context);
    _logger.data('Order ID', order.id, context);
    
    try {
      // Process payment - pass context
      _logger.debug('Processing payment...', context);
      await _paymentService.processPayment(order.total, context);
      
      // Send notification - pass context
      _logger.debug('Sending confirmation...', context);
      await _notificationService.sendOrderConfirmation(order, context);
      
      _logger.success('Order created successfully', context);
    } catch (e, stackTrace) {
      _logger.error('Order creation failed', e, stackTrace, context);
      rethrow;
    }
  }
}

// Output:
// [OrderService] [2345-1234] ℹ️ "Creating order"
// [OrderService] [2345-1234] 📦 "Order ID": ORD-123
// [OrderService] [2345-1234] "Processing payment..."
// [PaymentService] [2345-1234] "Charging card..."
// [PaymentService] [2345-1234] ✅ "Payment successful"
// [OrderService] [2345-1234] "Sending confirmation..."
// [NotificationService] [2345-1234] "Sending email..."
// [NotificationService] [2345-1234] ✅ "Email sent"
// [OrderService] [2345-1234] ✅ "Order created successfully"
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
