# Test Catalog

> **11 tests** across 4 files — all headless, ~3 seconds total.

---

## `auth_gate_test.dart` — Auth Gate Routing (2 tests)

Tests the initial routing decision based on authentication state.

| # | Test Name | Pre-condition | Action | Expected |
|---|-----------|--------------|--------|----------|
| 1 | Shows LoginPage when user is not authenticated | `fakeAuth` has no user | Pump widget | `LoginPage` visible with "Menumia Partner" title and "Login with Google" button |
| 2 | Shows HomePage when user is authenticated | `fakeAuth.emitUser(fakeAuthUser)` | Pump widget | `HomePage` visible with "Kategori" and "Profil" tabs |

---

## `login_flow_test.dart` — Login Flows (5 tests)

Tests login button behavior, success navigation, and error handling.

### Success (2 tests)

| # | Test Name | Pre-condition | Action | Expected |
|---|-----------|--------------|--------|----------|
| 3 | Tapping Login button calls signInWithGoogle | Unauthenticated (default) | Tap "Login with Google" | `fakeAuth.currentUser` is not null |
| 4 | Successful login navigates to HomePage | `onSignIn` configured to emit `fakeAuthUser` | Tap "Login with Google" | `HomePage` visible with bottom nav |

### Error Handling (3 tests)

| # | Test Name | Pre-condition | Action | Expected |
|---|-----------|--------------|--------|----------|
| 5 | No internet shows network error | `signInError = Exception('Network error: No internet connection')` | Tap "Login with Google" | Error message + `Icons.error_outline` visible |
| 6 | Failed login shows authentication error | `signInError = Exception('Authentication failed: Invalid credentials')` | Tap "Login with Google" | Error message visible, still on `LoginPage` |
| 7 | DNS resolution failure shows network error | `signInError = Exception('Network error: Unable to resolve host')` | Tap "Login with Google" | Error message visible, still on `LoginPage` |

---

## `navigation_test.dart` — Tab Navigation (1 test)

Tests authenticated tab navigation.

| # | Test Name | Pre-condition | Action | Expected |
|---|-----------|--------------|--------|----------|
| 8 | Navigate from Categories to Profile tab | Authenticated (`fakeAuth.emitUser`) | Tap "Profil" tab | `ProfilePage` visible with "Profile" AppBar title |

---

## `logout_flow_test.dart` — Logout & Re-login (3 tests)

Tests the full logout journey and re-login scenarios.

### Logout (1 test)

| # | Test Name | Pre-condition | Action | Expected |
|---|-----------|--------------|--------|----------|
| 9 | Login, go to Profile, then Logout | Authenticated + `currentUserStream` | Navigate to Profile → Scroll to Logout → Tap Logout → Confirm dialog | `fakeAuth.currentUser` is null, `LoginPage` visible |

### Re-login (2 tests)

| # | Test Name | Pre-condition | Action | Expected |
|---|-----------|--------------|--------|----------|
| 10 | Logout then re-login with same account | Authenticated + `onSignIn` returns same user | Full logout flow → Tap "Login with Google" | Back on `HomePage` with "Kategori" tab |
| 11 | Logout then re-login with different account | Authenticated + `onSignIn` returns `fakeAuthUser2` | Full logout flow → Tap "Login with Google" | Back on `HomePage`, `currentUser.uid == fakeAuthUser2.uid` |

---

## Adding New Tests

1. **New flow?** Create a new file in `test/flows/` (e.g., `menu_flow_test.dart`)
2. **New scenario in existing flow?** Add a `testWidgets` to the appropriate file
3. **New error case?** Add to the `Error Handling` group in `login_flow_test.dart`
4. **New fixture data?** Add to the appropriate file in `lib/testing/`

### Template for a new flow test:

```dart
import 'package:flutter_test/flutter_test.dart';
// ... page imports ...

import '../helpers/test_app.dart';
import '../helpers/pump_helpers.dart';

void main() {
  late TestHarness harness;

  setUp(() {
    harness = TestHarness.create();
  });

  group('My New Flow', () {
    testWidgets('description', (tester) async {
      // 1. Configure initial state
      harness.fakeAuth.emitUser(fakeAuthUser);

      // 2. Build the app
      await tester.pumpWidget(harness.buildApp());
      await pumpAndFlush(tester);

      // 3. Interact
      await tester.tap(find.text('Some Button'));
      await pumpAndFlush(tester);

      // 4. Assert
      expect(find.byType(SomePage), findsOneWidget);
    });
  });
}
```
