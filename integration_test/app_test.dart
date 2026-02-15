

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/profile_page.dart';
import 'package:menumia_flutter_partner_app/app/routing/routing.dart';
import 'package:menumia_flutter_partner_app/app/theme/theme.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';
import 'package:menumia_flutter_partner_app/app/services/profile_page_facade.dart';

// Fake Repositories
import 'package:menumia_flutter_partner_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/repositories/fake_menu_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/infrastructure/repositories/fake_restaurant_user_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/infrastructure/repositories/fake_restaurant_repository.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/infrastructure/repositories/fake_shared_config_repository.dart';

// Application Services & Fixtures
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_user.dart';
import 'package:menumia_flutter_partner_app/testing/auth_fixtures.dart';
import 'package:menumia_flutter_partner_app/testing/restaurant_users_fixtures.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/services/menu_service.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/application/restaurant_user_service.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/application/restaurant_service.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/application/shared_config_service.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';

// ─── Testable Auth Repository ────────────────────────────────────────────────

/// Extends FakeAuthRepository to allow configurable error behavior for tests.
/// - By default, signInWithGoogle works normally (delegates to super).
/// - Set [signInError] to make signInWithGoogle throw that exception.
/// - Set [onSignIn] to inject custom sign-in behavior (e.g. emit a specific user).
class TestableAuthRepository extends FakeAuthRepository {
  Exception? signInError;
  Future<AuthUser> Function()? onSignIn;

  TestableAuthRepository();

  @override
  Future<AuthUser> signInWithGoogle() async {
    if (signInError != null) {
      throw signInError!;
    }
    if (onSignIn != null) {
      return onSignIn!();
    }
    return super.signInWithGoogle();
  }
}

// ─── Fake User Data ──────────────────────────────────────────────────────────

/// Primary test user — reuses [AuthFixtures.testUser] for consistency
/// with FakeAuthRepository.signInWithGoogle().
const fakeAuthUser = AuthFixtures.testUser;

const fakeAuthUser2 = AuthUser(
  uid: 'test-uid-456',
  email: 'other@menumia.com',
  displayName: 'Other User',
);

/// Primary test restaurant user — reuses [RestaurantUsersFixtures.fake_foorcun]
/// which corresponds to [AuthFixtures.testUser] (same email).
final fakeRestaurantUser = RestaurantUsersFixtures.fake_foorcun;

// ─── Test App ────────────────────────────────────────────────────────────────

/// Builds the real MyApp widget wrapped with fake providers.
/// Uses real services backed by in-memory fake repositories — no mocks.
Widget buildTestApp({
  required TestableAuthRepository fakeAuth,
  required RestaurantContextService contextService,
  required MenuService menuService,
  required ProfilePageFacade profileFacade,
  required SharedConfigService sharedConfigService,
  Stream<RestaurantUser?>? currentUserStream,
}) {
  return ProviderScope(
    overrides: [
      // Core auth — FakeAuthRepository (in-memory, no Firebase)
      authRepositoryProvider.overrideWithValue(fakeAuth),
      // Restaurant context — real service wired with fakes
      restaurantContextServiceProvider.overrideWithValue(contextService),
      // Menu service — uses FakeMenuRepository
      menuServiceProvider.overrideWithValue(menuService),
      // Profile facade — real facade wired to RestaurantContextService
      profilePageFacadeProvider.overrideWithValue(profileFacade),
      // Shared config — uses FakeSharedConfigRepository
      sharedConfigServiceProvider.overrideWithValue(sharedConfigService),
      // Ordering toggle — derives from shared config
      orderingEnabledProvider.overrideWith((ref) => Stream.value(false)),
      // Stream providers — forward from RestaurantContextService
      currentUserProvider.overrideWith(
          (ref) => currentUserStream ?? contextService.currentUser$),
      relatedRestaurantsProvider
          .overrideWith((ref) => contextService.relatedRestaurants$),
      activeRestaurantIdProvider
          .overrideWith((ref) => contextService.activeRestaurantId$),
      activeMenuKeyProvider
          .overrideWith((ref) => contextService.activeMenuKey$),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menumia Partner (Integration Test)',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.auth,
      onGenerateRoute: AppRouter.generateRoute,
    ),
  );
}

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TestableAuthRepository fakeAuth;
  late RestaurantContextService contextService;
  late MenuService menuService;
  late ProfilePageFacade profileFacade;
  late SharedConfigService sharedConfigService;

  setUp(() {
    // Build the full fake dependency chain:
    // FakeAuthRepository → RestaurantContextService → ProfilePageFacade
    fakeAuth = TestableAuthRepository(); // Starts unauthenticated (null user)
    final userService = RestaurantUserService(FakeRestaurantUserRepository());
    final restaurantService = RestaurantService(FakeRestaurantRepository());
    menuService = MenuService(FakeMenuRepository());
    sharedConfigService = SharedConfigService(FakeSharedConfigRepository());

    contextService = RestaurantContextService(
      authRepository: fakeAuth,
      userService: userService,
      restaurantService: restaurantService,
    );

    profileFacade = ProfilePageFacade(contextService);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 1: Unauthenticated → LoginPage
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Shows LoginPage when user is not authenticated', (tester) async {
    // fakeAuth starts with null user (unauthenticated by default)

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Verify: LoginPage is visible
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Menumia Partner'), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 2: Authenticated → HomePage
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Shows HomePage when user is authenticated', (tester) async {
    // Pre-authenticate the fake auth repository
    fakeAuth.emitUser(fakeAuthUser);

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Verify: HomePage is visible with bottom navigation
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);  // Bottom nav item
    expect(find.text('Profil'), findsOneWidget);     // Bottom nav item
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 3: Tap Login Button → triggers signInWithGoogle
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Tapping Login button calls signInWithGoogle', (tester) async {
    // Start unauthenticated (default)

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Tap the "Login with Google" button
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: FakeAuthRepository signs in → user is now authenticated
    expect(fakeAuth.currentUser, isNotNull);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 4: Internet Not Available → Shows Error UI
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Tapping Login button with no internet shows error message',
      (tester) async {
    // Configure fakeAuth to throw a network error
    const networkErrorMessage = 'Exception: Network error: No internet connection';
    fakeAuth.signInError = Exception('Network error: No internet connection');

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Tap the "Login with Google" button
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: Error message is displayed in the UI
    expect(find.text(networkErrorMessage), findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 5: Login Success → navigates to HomePage
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Successful login navigates to HomePage', (tester) async {
    // Start unauthenticated (default)
    // Configure custom sign-in to emit our specific fake user
    fakeAuth.onSignIn = () async {
      fakeAuth.emitUser(fakeAuthUser);
      return fakeAuthUser;
    };

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Verify: starts on LoginPage
    expect(find.byType(LoginPage), findsOneWidget);

    // Tap login
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: navigated to HomePage
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 6: Login Failure → shows generic error
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Failed login shows error message', (tester) async {
    // Configure fakeAuth to throw authentication error
    fakeAuth.signInError =
        Exception('Authentication failed: Invalid credentials');

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Tap login
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: error is shown, still on LoginPage
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Exception: Authentication failed: Invalid credentials'),
        findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 7: No Internet → shows network error
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('No internet shows network error', (tester) async {
    // Configure fakeAuth to throw network error
    fakeAuth.signInError =
        Exception('Network error: Unable to resolve host');

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Tap login
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: network error is shown
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Exception: Network error: Unable to resolve host'),
        findsOneWidget);
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 8: Login → navigate to Profile page
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Login then navigate to Profile page', (tester) async {
    // Start authenticated
    fakeAuth.emitUser(fakeAuthUser);

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    ));
    await tester.pumpAndSettle();

    // Verify: on HomePage
    expect(find.byType(HomePage), findsOneWidget);

    // Tap "Profil" tab in bottom navigation
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Verify: ProfilePage is visible
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget); // AppBar title
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 9: Login → Profile → Logout
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Login, go to Profile, then Logout', (tester) async {
    // Start authenticated
    fakeAuth.emitUser(fakeAuthUser);

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));
    await tester.pumpAndSettle();

    // Verify: on HomePage
    expect(find.byType(HomePage), findsOneWidget);

    // Navigate to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);

    // Scroll the Logout button into view (it's below the fold on ProfilePage)
    final logoutButton = find.text('Logout');
    await tester.ensureVisible(logoutButton);
    await tester.pumpAndSettle();

    // Tap Logout button (the OutlinedButton in ProfilePage)
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Verify: confirmation dialog appears
    expect(find.text('Are you sure you want to logout?'), findsOneWidget);

    // Tap confirm "Logout" button in the dialog (ElevatedButton)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Verify: user is signed out
    expect(fakeAuth.currentUser, isNull);

    // Verify: navigated back to LoginPage
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 10: Logout → Re-login with same account
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Logout then re-login with same account', (tester) async {
    // Start authenticated
    fakeAuth.emitUser(fakeAuthUser);

    // Configure re-login to emit same user
    fakeAuth.onSignIn = () async {
      fakeAuth.emitUser(fakeAuthUser);
      return fakeAuthUser;
    };

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));
    await tester.pumpAndSettle();

    // ── Phase 1: Logout ──
    // Navigate to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Scroll Logout button into view and tap
    final logoutBtn = find.text('Logout');
    await tester.ensureVisible(logoutBtn);
    await tester.pumpAndSettle();
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    // Confirm logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Verify: on LoginPage
    expect(find.byType(LoginPage), findsOneWidget);

    // ── Phase 2: Re-login with same account ──
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: back on HomePage
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 11: Logout → Re-login with different account
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Logout then re-login with different account', (tester) async {
    // Start authenticated with User 1
    fakeAuth.emitUser(fakeAuthUser);

    // Configure re-login to emit DIFFERENT user
    fakeAuth.onSignIn = () async {
      fakeAuth.emitUser(fakeAuthUser2);
      return fakeAuthUser2;
    };

    await tester.pumpWidget(buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));
    await tester.pumpAndSettle();

    // ── Phase 1: Logout ──
    // Navigate to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Scroll Logout button into view and tap
    final logoutBtn = find.text('Logout');
    await tester.ensureVisible(logoutBtn);
    await tester.pumpAndSettle();
    await tester.tap(logoutBtn);
    await tester.pumpAndSettle();

    // Confirm logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Verify: on LoginPage
    expect(find.byType(LoginPage), findsOneWidget);

    // ── Phase 2: Re-login with different account ──
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: back on HomePage with different user
    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);

    // Verify: signed in as second user
    expect(fakeAuth.currentUser?.uid, equals(fakeAuthUser2.uid));
  });
}
