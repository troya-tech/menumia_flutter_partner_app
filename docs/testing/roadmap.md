# Flutter Testing Roadmap

This document outlines the phased approach to testing the Menumia Partner App.

## 🗺️ The Strategy: Three-Layered Pyramid

| Level | Name | Scope | Status | Tooling |
| :--- | :--- | :--- | :--- | :--- |
| **Level 1** | **Foundation** | Repositories, Facades, Models | 🔄 In Progress | `flutter_test`, `mocktail` |
| **Level 2** | **Component** | Individual Widgets (Cards, Dialogs) | 🔄 In Progress | `flutter_test` (Widget Tester) |
| **Level 3** | **Experience** | Full User Flows (Login, Menu Mgmt) | 🔄 In Progress | `integration_test` (Native) |

---

## 📅 Roadmap Phases

### Phase 1: Unit & Logic Isolation (Level 1)
- [x] Identify critical Facades for testing.
- [ ] Implement standard unit tests for `HomePageFacade`.
- [ ] implement standard unit tests for `ProfilePageFacade`.
- [ ] Core repository mapping verification.

### Phase 2: Widget Rendering & Layout (Level 2)
- [x] Verification of `LoginPage` rendering.
- [ ] Create widget tests for `CategoryCard` and `ProductListItem`.
- [ ] Verify form validation logic in `EditProductDialog`.

### Phase 3: Integration & Smoke Tests (Level 3)
- [x] Decide on E2E tooling → `integration_test` (Native, runs on device).
- [x] Implement "Happy Path" smoke test: LoginPage → Login button → HomePage.
- [ ] Automated CI integration for integration tests.
- [ ] Implement integration test with real Google Sign-In (Patrol).

---

## 🧪 Quick Commands

```bash
# Run all tests
flutter test

# Run a specific level
flutter test test/app/services/ # Level 1
flutter test test/app/pages/    # Level 2
```
