Plan: Integrating FakeAuthRepository (Dual-Track)
This plan covers using 
FakeAuthRepository
 for rapid development on devices and maintaining a dual-track testing strategy (switching between Fake and Actual implementations).

Proposed Strategy
1. On-Device Testing: main_fake.dart
We will create a dedicated entry point that allows you to run the app on your phone without Firebase Auth.

[NEW] 
main_fake.dart
This file will:

Skip Firebase initialization (if possible, or use dummy values).
Override authRepositoryProvider with 
FakeAuthRepository
.
Usage: flutter run -t lib/main_fake.dart
2. Dual-Track Testing
To support testing against both Fake and Actual (UAT/Prod) implementations, we will categorize tests:

Test Category	Target	Implementation	Tool
Unit/Widget	Logic & UI	
FakeAuthRepository
flutter test
Smoke/Integration	End-to-End	Actual (UAT/Prod)	flutter test integration_test/
How and where to toggle?
In your test suite, we can use a helper to define the scope:

dart
// test/helpers/test_setup.dart
ProviderScope createTestProviderScope({bool useFake = true, Widget? child}) {
  return ProviderScope(
    overrides: [
      if (useFake) authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      // if false, it uses the default (Actual) provider
    ],
    child: child ?? const MyApp(),
  );
}
Proposed Changes
[Component Name] Shared Application
[NEW] 
main_fake.dart
Minimal entry point for "Device Testing".

[MODIFY] 
main.dart
We might need to export 
MyApp
 or move initialization logic to a sharable function if 
main.dart
 gets too complex, but for now, we can simply import it.

Verification Plan
Automated Tests
Run `flutter test` to verify unit tests pass with the Fake.
Run `flutter test integration_test/` (with a fake account or real test account) to verify the actual flow.

# Manual Verification
Run `flutter run -t lib/main_fake.dart` on a phone.

Confirm you can "log in" and navigate the app without a real internet connection or Firebase setup.