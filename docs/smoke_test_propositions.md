# Smoke Test Propositions

This document outlines a strategy for re-introducing smoke tests to the Menumia Partner App. The goal is to verify critical application paths without requiring a full backend integration or causing "false negatives" due to missing dependencies.

## Philosophy
A good smoke test for this app should answer: **"Does the app start, authenticate (mocked), and navigate to the home screen?"**

## Proposed Tests

### Level 1: App Launch & Routing (Unit Tests)
These tests verify that the app structure and routing logic are sound, without rendering UI.

**Location:** `test/app/routing/app_router_test.dart`

**What to test:**
-   Verify `AppRouter.generateRoute` returns the correct `MaterialPageRoute` for known routes (`/`, `/home`, `/profile`).
-   Verify it returns the `ErrorPage` for unknown routes.

**Example Code:**
```dart
test('generates home route', () {
  final route = AppRouter.generateRoute(const RouteSettings(name: AppRoutes.home));
  expect(route, isA<MaterialPageRoute>());
  expect((route as MaterialPageRoute).builder(MockBuildContext()), isA<HomePage>());
});
```

### Level 2: Critical Widget Rendering (Widget Tests)
These tests ensure that the main screens can build without crashing. They require mocking dependencies like `FirebaseAuth` or Repositories.

**Location:** `test/smoke/screen_rendering_test.dart`

**What to test:**
-   **AuthGate:** Verify it shows a loading spinner or login button depending on auth state.
-   **HomePage:** Verify the scaffold, app bar, and bottom navigation bar appear.
-   **ProfilePage:** Verify the profile layout renders.

**Dependencies needed:**
-   `mocktail` (already added) to mock `FirebaseAuth` and `RestaurantContextService`.

**Example Code:**
```dart
testWidgets('HomePage renders without crashing', (tester) async {
  // Setup mocks
  when(() => mockRestaurantService.restaurant$).thenAnswer((_) => Stream.value(mockRestaurant));
  
  await tester.pumpWidget(MaterialApp(home: HomePage()));
  expect(find.byType(Scaffold), findsOneWidget);
  expect(find.text('Menumia Partner'), findsOneWidget);
});
```

### Level 3: The "Golden Path" (Integration Widget Test)
This is the ultimate smoke test. It simulates a full user startup flow using a test harness.

**Location:** `test/smoke/app_startup_test.dart`

**What to test:**
1.  Start App (pumping `MyApp`).
2.  Mock `FirebaseAuth` to return a `User` (Simulate "Already Logged In").
3.  Verify the app navigates automatically from `AuthGate` -> `HomePage`.

**Why this is better than the old counter test:**
The old test failed because `Firebase.initializeApp()` wasn't mocked/handled. This test will wrap `MyApp` in a provider scope or use dependency injection to supply mock auth services, ensuring the app "thinks" it's connected.

## Recommendation
Start by implementing **Level 1** (Routing) and **Level 2** (HomePage rendering) to establish a baseline of "The app builds and routes."
