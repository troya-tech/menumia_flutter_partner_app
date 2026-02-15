import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/profile_page.dart';
import 'package:menumia_flutter_partner_app/app/routing/routing.dart';
import 'package:menumia_flutter_partner_app/app/theme/theme.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_repository.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_user.dart';
import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';
import 'package:menumia_flutter_partner_app/app/services/profile_page_facade.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/services/menu_service.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';

// ─── Mocks ───────────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

class MockRestaurantContextService extends Mock
    implements RestaurantContextService {}

class MockMenuService extends Mock implements MenuService {}

class MockProfilePageFacade extends Mock implements ProfilePageFacade {}

// ─── Fake User Data ──────────────────────────────────────────────────────────

const fakeAuthUser = AuthUser(
  uid: 'test-uid-123',
  email: 'test@menumia.com',
  displayName: 'Test User',
);

const fakeAuthUser2 = AuthUser(
  uid: 'test-uid-456',
  email: 'other@menumia.com',
  displayName: 'Other User',
);

final fakeRestaurantUser = RestaurantUser(
  id: 'test-uid-123',
  email: 'test@menumia.com',
  displayName: 'Test User',
  relatedRestaurantsIds: const ['restaurant-1'],
  role: 'owner',
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
  isActive: true,
);

// ─── Test App ────────────────────────────────────────────────────────────────

/// Builds the real MyApp widget wrapped with mocked providers.
/// This is the closest to how the real app runs — real routing, real widgets,
/// but with Firebase/Google removed from the equation.
Widget buildTestApp({
  required MockAuthRepository mockAuth,
  required MockRestaurantContextService mockContext,
  required MockMenuService mockMenuService,
  required MockProfilePageFacade mockProfileFacade,
  Stream<RestaurantUser?>? currentUserStream,
}) {
  return ProviderScope(
    overrides: [
      // Core auth — replaces Firebase Auth + Google Sign-In
      authRepositoryProvider.overrideWithValue(mockAuth),
      // Restaurant context — replaces Firebase RTDB user/restaurant loading
      restaurantContextServiceProvider.overrideWithValue(mockContext),
      // Menu service — replaces FirebaseMenuRepository
      menuServiceProvider.overrideWithValue(mockMenuService),
      // Profile facade — replaces RestaurantContextService dependency
      profilePageFacadeProvider.overrideWithValue(mockProfileFacade),
      // Ordering toggle — avoids SharedConfigService → Firebase
      orderingEnabledProvider.overrideWith((ref) => Stream.value(false)),
      // Stream providers from RestaurantContextService — provide test data
      currentUserProvider.overrideWith((ref) => currentUserStream ?? Stream.value(null)),
      relatedRestaurantsProvider.overrideWith((ref) => Stream.value(<Restaurant>[])),
      activeRestaurantIdProvider.overrideWith((ref) => Stream.value(null)),
      activeMenuKeyProvider.overrideWith((ref) => Stream.value(null)),
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

  late MockAuthRepository mockAuth;
  late MockRestaurantContextService mockContext;
  late MockMenuService mockMenuService;
  late MockProfilePageFacade mockProfileFacade;

  setUp(() {
    mockAuth = MockAuthRepository();
    mockContext = MockRestaurantContextService();
    mockMenuService = MockMenuService();
    mockProfileFacade = MockProfilePageFacade();

    // Default: mock context streams return empty/null
    when(() => mockContext.currentUser$)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockContext.relatedRestaurants$)
        .thenAnswer((_) => Stream.value(<Restaurant>[]));
    when(() => mockContext.activeRestaurantId$)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockContext.activeMenuKey$)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockContext.init()).thenAnswer((_) async {});

    // Profile facade defaults
    when(() => mockProfileFacade.currentUser$)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockProfileFacade.relatedRestaurants$)
        .thenAnswer((_) => Stream.value(<Restaurant>[]));
    when(() => mockProfileFacade.activeRestaurantId$)
        .thenAnswer((_) => Stream.value(null));
    when(() => mockProfileFacade.init()).thenReturn(null);
    when(() => mockProfileFacade.dispose()).thenReturn(null);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 1: Unauthenticated → LoginPage
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Shows LoginPage when user is not authenticated', (tester) async {
    // Auth state emits null → no user logged in
    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuth.currentUser).thenReturn(null);

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
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
    // Auth state emits a user → logged in
    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(fakeAuthUser));
    when(() => mockAuth.currentUser).thenReturn(fakeAuthUser);

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
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
    // Start unauthenticated
    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuth.currentUser).thenReturn(null);

    // Mock the sign-in to return our fake user
    when(() => mockAuth.signInWithGoogle())
        .thenAnswer((_) async => fakeAuthUser);

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
    ));
    await tester.pumpAndSettle();

    // Tap the "Login with Google" button
    await tester.tap(find.text('Login with Google'));
    await tester.pumpAndSettle();

    // Verify: signInWithGoogle was called exactly once
    verify(() => mockAuth.signInWithGoogle()).called(1);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 4: Internet Not Available → Shows Error UI
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Tapping Login button with no internet shows error message',
      (tester) async {
    // Start unauthenticated
    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuth.currentUser).thenReturn(null);

    // Mock the sign-in to throw a network error
    const networkErrorMessage = 'Exception: Network error: No internet connection';
    when(() => mockAuth.signInWithGoogle()).thenThrow(
      Exception('Network error: No internet connection'),
    );

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
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
    // Use StreamController so we can change auth state dynamically
    final authController = StreamController<AuthUser?>();
    authController.add(null); // Start unauthenticated

    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => authController.stream);
    when(() => mockAuth.currentUser).thenReturn(null);

    // Mock successful sign-in
    when(() => mockAuth.signInWithGoogle()).thenAnswer((_) async {
      // After sign-in succeeds, emit the user on the auth stream
      authController.add(fakeAuthUser);
      return fakeAuthUser;
    });

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
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

    await authController.close();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 6: Login Failure → shows generic error
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Failed login shows error message', (tester) async {
    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuth.currentUser).thenReturn(null);

    // Mock sign-in to throw a generic error
    when(() => mockAuth.signInWithGoogle()).thenThrow(
      Exception('Authentication failed: Invalid credentials'),
    );

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
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
    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(null));
    when(() => mockAuth.currentUser).thenReturn(null);

    // Mock sign-in to throw a socket/network exception
    when(() => mockAuth.signInWithGoogle()).thenThrow(
      Exception('Network error: Unable to resolve host'),
    );

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
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
    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => Stream.value(fakeAuthUser));
    when(() => mockAuth.currentUser).thenReturn(fakeAuthUser);

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
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
    // Since currentUserProvider returns null, we expect the "not found" state
    expect(find.text('User Profile Not Found'), findsOneWidget);
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 9: Login → Profile → Logout
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Login, go to Profile, then Logout', (tester) async {
    final authController = StreamController<AuthUser?>();
    authController.add(fakeAuthUser); // Start authenticated

    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => authController.stream);
    when(() => mockAuth.currentUser).thenReturn(fakeAuthUser);

    // Provide a RestaurantUser so ProfilePage shows the full UI with Logout button
    when(() => mockProfileFacade.currentUser$)
        .thenAnswer((_) => Stream.value(fakeRestaurantUser));

    // Mock signOut
    when(() => mockAuth.signOut()).thenAnswer((_) async {
      authController.add(null); // Emit null to simulate logout
    });

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));
    await tester.pumpAndSettle();

    // Verify: on HomePage
    expect(find.byType(HomePage), findsOneWidget);

    // Navigate to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);

    // Tap Logout button (the OutlinedButton in ProfilePage)
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Verify: confirmation dialog appears
    expect(find.text('Are you sure you want to logout?'), findsOneWidget);

    // Tap confirm "Logout" button in the dialog (ElevatedButton)
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();

    // Verify: signOut was called
    verify(() => mockAuth.signOut()).called(1);

    // Verify: navigated back to LoginPage
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Login with Google'), findsOneWidget);

    await authController.close();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 10: Logout → Re-login with same account
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Logout then re-login with same account', (tester) async {
    final authController = StreamController<AuthUser?>();
    authController.add(fakeAuthUser); // Start authenticated

    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => authController.stream);
    when(() => mockAuth.currentUser).thenReturn(fakeAuthUser);

    // Provide a RestaurantUser so ProfilePage shows full UI with Logout button
    when(() => mockProfileFacade.currentUser$)
        .thenAnswer((_) => Stream.value(fakeRestaurantUser));

    // Mock signOut
    when(() => mockAuth.signOut()).thenAnswer((_) async {
      authController.add(null);
    });

    // Mock re-login with same account
    when(() => mockAuth.signInWithGoogle()).thenAnswer((_) async {
      authController.add(fakeAuthUser);
      return fakeAuthUser;
    });

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));
    await tester.pumpAndSettle();

    // ── Phase 1: Logout ──
    // Navigate to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Tap Logout
    await tester.tap(find.text('Logout'));
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

    await authController.close();
  });

  // ─────────────────────────────────────────────────────────────────────────
  // TEST 11: Logout → Re-login with different account
  // ─────────────────────────────────────────────────────────────────────────
  testWidgets('Logout then re-login with different account', (tester) async {
    final authController = StreamController<AuthUser?>();
    authController.add(fakeAuthUser); // Start authenticated with User 1

    when(() => mockAuth.authStateChanges())
        .thenAnswer((_) => authController.stream);
    when(() => mockAuth.currentUser).thenReturn(fakeAuthUser);

    // Provide a RestaurantUser so ProfilePage shows full UI with Logout button
    when(() => mockProfileFacade.currentUser$)
        .thenAnswer((_) => Stream.value(fakeRestaurantUser));

    // Mock signOut
    when(() => mockAuth.signOut()).thenAnswer((_) async {
      authController.add(null);
    });

    // Mock re-login with DIFFERENT account
    when(() => mockAuth.signInWithGoogle()).thenAnswer((_) async {
      authController.add(fakeAuthUser2); // Different user!
      return fakeAuthUser2;
    });

    await tester.pumpWidget(buildTestApp(
      mockAuth: mockAuth,
      mockContext: mockContext,
      mockMenuService: mockMenuService,
      mockProfileFacade: mockProfileFacade,
      currentUserStream: Stream.value(fakeRestaurantUser),
    ));
    await tester.pumpAndSettle();

    // ── Phase 1: Logout ──
    // Navigate to Profile tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Tap Logout
    await tester.tap(find.text('Logout'));
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

    // Verify: signInWithGoogle returned the second user
    verify(() => mockAuth.signInWithGoogle()).called(1);

    await authController.close();
  });
}
