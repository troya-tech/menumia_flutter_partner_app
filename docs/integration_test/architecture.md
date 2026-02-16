# Test Architecture

## Dependency Chain

The test infrastructure mirrors the real app's dependency injection but swaps Firebase repositories with in-memory fakes:

```
┌─────────────────────────────────────────────────────────────┐
│                       ProviderScope                         │
│  (overrides real providers with fake-backed services)       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  TestableAuthRepository ─────────┐                          │
│       (extends FakeAuthRepository)│                          │
│                                  ▼                          │
│  FakeRestaurantUserRepository ──► RestaurantContextService  │
│  FakeRestaurantRepository ──────►      │                    │
│                                        ▼                    │
│                                  ProfilePageFacade          │
│                                                             │
│  FakeMenuRepository ────────────► MenuService               │
│  FakeSharedConfigRepository ────► SharedConfigService        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

All services are **real** — only the repositories (data layer) are fake.

## TestHarness

`TestHarness` (in `test/helpers/test_app.dart`) encapsulates the full dependency chain. Each test creates a fresh instance in `setUp()`:

```dart
late TestHarness harness;

setUp(() {
  harness = TestHarness.create();
});

testWidgets('example test', (tester) async {
  // Configure auth state
  harness.fakeAuth.emitUser(fakeAuthUser);

  // Build the app with all fakes wired
  await tester.pumpWidget(harness.buildApp());
  await pumpAndFlush(tester);

  // Assert
  expect(find.byType(HomePage), findsOneWidget);
});
```

### TestHarness.create()

Factory method that constructs the full fake dependency chain:

```
TestableAuthRepository (starts unauthenticated)
    └─► RestaurantContextService
           └─► ProfilePageFacade
FakeMenuRepository
    └─► MenuService
FakeSharedConfigRepository
    └─► SharedConfigService
```

### TestHarness.buildApp()

Convenience method that calls `buildTestApp()` with all the harness dependencies. Accepts optional `currentUserStream` for tests that need a specific `RestaurantUser`:

```dart
await tester.pumpWidget(harness.buildApp(
  currentUserStream: Stream.value(fakeRestaurantUser),
));
```

## TestableAuthRepository

Extends `FakeAuthRepository` with two key differences:

1. **No `Future.delayed`** — `signInWithGoogle()` and `signOut()` are synchronous (immediate `emitUser`). This prevents "Timer is still pending" errors under `FakeAsync`.

2. **Configurable behavior** via two fields:

| Field | Purpose | Example |
|-------|---------|---------|
| `signInError` | Throw an exception on next sign-in | `harness.fakeAuth.signInError = Exception('Network error')` |
| `onSignIn` | Custom sign-in logic | `harness.fakeAuth.onSignIn = () async { ... }` |

**Default behavior** (no fields set): emits `AuthFixtures.testUser` immediately.

## pumpAndFlush

`RestaurantContextService.init()` calls `.timeout(Duration(seconds: 5))` internally. Under `FakeAsync` (which widget tests use), `pumpAndSettle()` will **loop indefinitely** waiting for this timer to expire.

`pumpAndFlush` solves this by pumping with explicit durations:

```dart
Future<void> pumpAndFlush(WidgetTester tester) async {
  await tester.pump();                          // Initial frame
  await tester.pump(const Duration(seconds: 6)); // Flush the 5s timeout
  await tester.pump();                          // Settle remaining frames
}
```

**Rule:** Always use `pumpAndFlush(tester)` instead of `tester.pumpAndSettle()` in flow tests.

## Fixtures

All fixture data lives in `lib/testing/` (single source of truth):

| File | Key Fixtures |
|------|-------------|
| `auth_fixtures.dart` | `AuthFixtures.testUser` — primary test user (foorcun@gmail.com) |
| `restaurant_users_fixtures.dart` | `RestaurantUsersFixtures.fake_foorcun` — matching restaurant user |
| `menu_fixtures.dart` | Fake menu data |
| `restaurants_fixtures.dart` | Fake restaurant data |
| `shared_config_fixtures.dart` | Fake shared config data |

These live in `lib/` (not `test/`) because `FakeAuthRepository` and other fakes in `lib/` import them. Code in `lib/` cannot import from `test/`.

### Test-Specific Aliases

`test/helpers/test_app.dart` re-exports commonly used fixtures as short aliases:

```dart
const fakeAuthUser = AuthFixtures.testUser;
const fakeAuthUser2 = AuthUser(uid: 'test-uid-456', email: 'other@menumia.com', ...);
final fakeRestaurantUser = RestaurantUsersFixtures.fake_foorcun;
```

## buildTestApp

Wraps the real `MaterialApp` in a `ProviderScope` that overrides all real providers with fake-backed services:

```dart
Widget buildTestApp({
  required TestableAuthRepository fakeAuth,
  required RestaurantContextService contextService,
  required MenuService menuService,
  required ProfilePageFacade profileFacade,
  required SharedConfigService sharedConfigService,
  Stream<RestaurantUser?>? currentUserStream,
})
```

**Provider overrides:**

| Provider | Overridden With |
|----------|----------------|
| `authRepositoryProvider` | `TestableAuthRepository` |
| `restaurantContextServiceProvider` | Real service wired with fakes |
| `menuServiceProvider` | `MenuService(FakeMenuRepository())` |
| `profilePageFacadeProvider` | Real facade wired to context service |
| `sharedConfigServiceProvider` | `SharedConfigService(FakeSharedConfigRepository())` |
| `orderingEnabledProvider` | `Stream.value(false)` |
| `currentUserProvider` | Forwarded from context service (or custom stream) |
| `relatedRestaurantsProvider` | Forwarded from context service |
| `activeRestaurantIdProvider` | Forwarded from context service |
| `activeMenuKeyProvider` | Forwarded from context service |
