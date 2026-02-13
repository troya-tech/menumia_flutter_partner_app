# How to Run Tests

This guide explains how to execute tests for the Menumia Partner App.

## Prerequisites

1. **Flutter SDK** installed and on your PATH.
2. Run `flutter pub get` in the project root to fetch dependencies (including `mocktail`).

---

## Running All Tests

```bash
cd menumia_flutter_partner_app
flutter test
```

This runs every `*_test.dart` file in the `test/` directory.

---

## Running by Level

### Level 1: Unit & Logic Tests

| Component | Command |
| --- | --- |
| All services (facades) | `flutter test test/app/services/` |
| RestaurantContextService | `flutter test test/app/services/restaurant_context_service_test.dart` |
| HomePageFacade | `flutter test test/app/services/home_page_facade_test.dart` |
| ProfilePageFacade | `flutter test test/app/services/profile_page_facade_test.dart` |
| Entity Models | `flutter test test/features/domain/entities_test.dart` |
| CategoryDto | `flutter test test/features/menu/infrastructure/dtos/category_dto_test.dart` |
| ProductDto | `flutter test test/features/menu/infrastructure/dtos/product_dto_test.dart` |

### Level 2: Widget Tests

| Component | Command |
| --- | --- |
| EditProductDialog | `flutter test test/app/pages/home_page/widgets/edit_product_dialog_test.dart` |
| CategoryReorderPage | `flutter test test/app/pages/home_page/widgets/category_reorder_page_test.dart` |
| LoginPage | `flutter test test/app/pages/login-page/login_page_test.dart` |
| App Router | `flutter test test/app/routing/app_router_test.dart` |

### Level 3: Smoke Tests

| Component | Command |
| --- | --- |
| Login Smoke | `flutter test test/smoke/login_page_smoke_test.dart` |

---

## Coverage Report

Generate a coverage report:

```bash
flutter test --coverage
```

The output will be in `coverage/lcov.info`. You can visualize it with tools like `lcov` or VS Code extensions.

---

## Tips

- **Run a single file:** `flutter test path/to/file_test.dart`
- **Run with verbose output:** `flutter test --reporter=expanded`
- **Filter by test name:** `flutter test --name "your test description"`
- **Watch mode (auto-rerun):** Not natively supported; use a file watcher like `nodemon` or IDE test runner.

---

## Test File Structure

```
test/
├── app/
│   ├── pages/
│   │   ├── home_page/widgets/
│   │   │   ├── category_reorder_page_test.dart  (Level 2)
│   │   │   └── edit_product_dialog_test.dart     (Level 2)
│   │   └── login-page/
│   │       └── login_page_test.dart              (Level 2)
│   ├── routing/
│   │   └── app_router_test.dart                  (Level 1)
│   └── services/
│       ├── home_page_facade_test.dart            (Level 1)
│       ├── profile_page_facade_test.dart         (Level 1)
│       └── restaurant_context_service_test.dart  (Level 1)
├── features/
│   ├── domain/
│   │   └── entities_test.dart                    (Level 1)
│   └── menu/infrastructure/dtos/
│       ├── category_dto_test.dart                (Level 1)
│       └── product_dto_test.dart                 (Level 1)
└── smoke/
    ├── login_page_smoke_test.dart                (Level 3)
    └── screen_rendering_draft.dart               (Draft)
```
