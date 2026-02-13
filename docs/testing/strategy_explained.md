# Testing Strategy Explained

This document provides a deep dive into the technical implementation of our testing strategy.

## 🏗️ Architectural Alignment

Our Flutter testing strategy mirrors the patterns used in our Angular project (`tests/data_layer/` and `tests/ui_layer/`). This ensures a consistent mental model across the Menumia ecosystem.

---

## 🔹 Level 1: Foundation (Unit & Logic)

**Goal:** Ensure that the data transformation and business logic are correct without any UI dependencies.

### Tooling
- **`flutter_test`**: The core Dart testing framework.
- **`mocktail`**: Used for mocking dependencies (preferred over `mockito` for simplicity and type safety).

### Patterns
- **Facade Testing:** Testing the logic inside `HomePageFacade`, `AuthFacade`, etc.
- **Repository Testing:** Mocking the `firebase_database` responses to ensure data is correctly mapped to our model classes.

---

## 🔹 Level 2: Component (Widget Tests)

**Goal:** Verify that UI components render correctly and respond to state changes in isolation.

### Isolation from Firebase
Widgets in Menumia are designed to be testable by injecting dependencies. 
> [!IMPORTANT]
> Never try to boot the whole app (`MyApp`) in a widget test. It will fail due to missing Firebase configuration.

### Example Setup
```dart
testWidgets('Product item shows price', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: ProductListItem(
        product: testProduct,
        onTap: () {},
      ),
    ),
  ));

  expect(find.text(testProduct.price.toString()), findsOneWidget);
});
```

---

## 🔹 Level 3: Experience (Integration Tests)

**Goal:** Verify the "Happy Path" of the user experience across multiple screens.

### Tooling Options
- **Native (`integration_test`):**
  - Runs on real devices or simulators.
  - Faster execution for Flutter-specific logic.
- **Robot Framework + Appium:**
  - Cross-platform consistency.
  - Shared reporting with the Angular project.

---

## 💡 Best Practices

1. **No Singletons:** Avoid `Service.instance`. Always pass dependencies through the constructor.
2. **Mocking External APIs:** Always mock Firebase and other 3rd party services.
3. **Golden Tests:** Use them sparingly for visual regression on complex custom-painted widgets.
4. **Descriptive Failures:** Write clear test descriptions so failed CI runs are easy to debug.
