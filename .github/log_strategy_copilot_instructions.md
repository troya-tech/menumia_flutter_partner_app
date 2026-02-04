# Flutter Logging Strategy / Copilot Instructions

## Core Principle
All debug logs **MUST** start with the class name in brackets to ensure traceability in the debug console.

## Implementation details

1.  **AppLogger Utility**:
    - Always use the `AppLogger` class located in `lib/utils/app_logger.dart`.
    - **DO NOT** use `print()` or `debugPrint()` directly.

2.  **Initialization**:
    - Instantiate the logger as a `static final` field in your class.
    - Pass the exact Class Name as the constructor argument.

    ```dart
    class MyService {
      static final _logger = AppLogger('MyService');
      // ...
    }
    ```

3.  **Usage**:
    - Use `_logger.debug('message')` for development logs.
    - Use `_logger.info('message')` for important flow events.
    - Use `_logger.error('message', error, stackTrace)` for exceptions.

    ```dart
    void doSomething() {
      _logger.debug('Starting operation...');
      try {
        // ...
      } catch (e, s) {
        _logger.error('Operation failed', e, s);
      }
    }
    ```

4.  **Output Format**:
    - The `AppLogger` automatically prefixes the class name.
    - Expected output: `[MyService] "Starting operation..."`

## Formatting Rules
- Use string interpolation sparingly in high-frequency logs.
- Keep messages concise but descriptive.
- Ensure sensitive data (passwords, tokens) is never logged.