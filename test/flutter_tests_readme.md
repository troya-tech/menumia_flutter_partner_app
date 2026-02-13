# Flutter Testing Guide

> [!NOTE]
> This is a quick reference. For the full strategy and roadmap, see [docs/testing/roadmap.md](../../docs/testing/roadmap.md).

This guide explains how to write and run tests for the Menumia Partner App.

## 🧪 Testing Levels

### Level 1: Foundation (Unit Tests)
Focus on business logic, repositories, and facades.
- **Location:** `test/app/services/`, `test/app/providers/`
- **Run command:** `flutter test test/app/services/`

### Level 2: Component (Widget Tests)
Verify individual UI components in isolation.
- **Location:** `test/app/pages/<feature>/widgets/`
- **Run command:** `flutter test test/app/pages/home_page/home_page_test.dart`

### Level 3: Experience (Integration Tests)
Full user flows on a real device/emulator with mocked Firebase.
- **Location:** `integration_test/`
- **Run command:** `flutter test integration_test/app_test.dart --flavor uat --dart-define=ENV=uat -d <device-id>`
- **Find device ID:** `flutter devices`

---

## 🛠️ Tooling & Mocks

We use **Mocktail** for mocking dependencies.

### Mocking a Facade
```dart
class MockHomePageFacade extends Mock implements HomePageFacade {}
```

### Setup in Widget Tests
Always wrap the widget under test in a `MaterialApp` and provide mocked dependencies.

```dart
testWidgets('HomePage renders categories', (tester) async {
  final mockFacade = MockHomePageFacade();
  // ... setup mock responses
  
  await tester.pumpWidget(MaterialApp(
    home: HomePage(facade: mockFacade),
  ));
  
  expect(find.text('Categories'), findsOneWidget);
});
```

## 🚀 Commands

| Task | Command |
| --- | --- |
| Run all tests | `flutter test` |
| Run specific file | `flutter test path/to/test.dart` |
| View coverage | `flutter test --coverage` |
| Update Golden files| `flutter test --update-goldens` |

---

## 💡 Best Practices
- **Avoid Global State:** Inject dependencies via constructors to make widgets testable.
- **Mock Firebase:** Never use real Firebase instances in unit/widget tests.
- **Small Tests:** One concept per test.
- **Descriptive Names:** `testWidgets('Should show error message when login fails', ...)`
