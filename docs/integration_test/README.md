# Integration Test Suite

## Overview

The Menumia Partner App uses **headless widget tests** with fake repositories to validate user flows without requiring a physical device or emulator. All tests run in ~3 seconds via `make test-ui`.

## Quick Start

```bash
# Run all flow tests (headless, no device needed)
make test-ui

# Run native smoke test on device (Espresso)
make test-ui-native
```

## Directory Structure

```
test/
├── helpers/
│   ├── test_app.dart           # TestHarness, TestableAuthRepository, fixtures, buildTestApp
│   └── pump_helpers.dart       # pumpAndFlush utility for FakeAsync timer handling
│
└── flows/
    ├── auth_gate_test.dart     # Auth routing       (2 tests)
    ├── login_flow_test.dart    # Login + errors      (5 tests)
    ├── navigation_test.dart    # Tab navigation      (1 test)
    └── logout_flow_test.dart   # Logout + re-login   (3 tests)

integration_test/
└── ui_integration_test.dart    # Native device smoke test (Espresso entry point)

lib/testing/                    # Shared fixture data (single source of truth)
├── auth_fixtures.dart
├── menu_fixtures.dart
├── restaurant_users_fixtures.dart
├── restaurants_fixtures.dart
└── shared_config_fixtures.dart
```

## Design Philosophy

### Fakes Over Mocks

We do **not** use `mocktail` or any mocking library. Instead, every repository has a corresponding **Fake** implementation (in-memory, stateful) that lives in `lib/features/*/infrastructure/`:

| Real Repository | Fake Implementation |
|----------------|---------------------|
| `FirebaseAuthRepository` | `FakeAuthRepository` |
| `FirebaseMenuRepository` | `FakeMenuRepository` |
| `FirebaseRestaurantRepository` | `FakeRestaurantRepository` |
| `FirebaseRestaurantUserRepository` | `FakeRestaurantUserRepository` |
| `FirebaseSharedConfigRepository` | `FakeSharedConfigRepository` |

This means tests exercise the **real service logic** — only the data layer is swapped out.

### Headless Execution

Tests use standard `flutter_test` (not `IntegrationTestWidgetsFlutterBinding`), so they run in the Dart VM without building an APK or deploying to a device. This gives:

- **~3 second** total execution time (vs 50+ seconds on device)
- **No install prompts** on the phone
- **CI/CD friendly** — no emulator required

### Flow-Based Organization

Tests are grouped by **user flow**, not by page or feature. This reflects how users actually interact with the app:

- `auth_gate_test.dart` — "What does the user see when they open the app?"
- `login_flow_test.dart` — "What happens when the user taps Login?"
- `logout_flow_test.dart` — "What happens when the user logs out and back in?"
- `navigation_test.dart` — "Can the user navigate between tabs?"

## Further Reading

- [Architecture](./architecture.md) — TestHarness, dependency chain, pumpAndFlush
- [Test Catalog](./test_catalog.md) — Complete list of all tests with descriptions
