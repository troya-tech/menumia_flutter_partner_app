# Edit Category Order Test Documentation

## Overview
This document describes the testing strategy for the **Edit Category Order** feature.

## Test Location
`test/app/pages/home_page/widgets/category_reorder_page_test.dart`

## Key Scenarios Tested
1.  **Rendering**: Verifies that the category list renders correctly with provided data.
2.  **Save Action**: Verifies that tapping "Kaydet" triggers `updateCategoriesOrder` in `MenuService`.
3.  **Dynamic Context**: Crucially, it verifies that the `menuKey` passed to the widget is correctly forwarded to the service call, ensuring multi-restaurant support work as intended.
    -   *Note*: The test data is intentionally set with random `displayOrder` values (e.g., 10, 20) to ensure the client-side re-indexing logic (1, 2) detects a change and triggers the API call.

## Dependencies
-   **mocktail**: Used for mocking the `MenuService`.
-   **flutter_test**: Standard Flutter testing framework.

## Logic Tested
```dart
verify(() => mockMenuService.updateCategoriesOrder(
      testMenuKey, 
      any(),
    )).called(1);

```
This assertion confirms that the fix for hardcoded menu keys is working correctly.

## How to Run the Tests

To execute this specific test file, run the following command in your terminal:

```bash
flutter test test/app/pages/home_page/widgets/category_reorder_page_test.dart
```
