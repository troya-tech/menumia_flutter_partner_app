import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:menumia_flutter_partner_app/app/pages/login-page/login_page.dart';
import 'package:menumia_flutter_partner_app/app/pages/home_page/home_page.dart';
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

// ─── Test App ────────────────────────────────────────────────────────────────

/// Builds the real MyApp widget wrapped with mocked providers.
/// This is the closest to how the real app runs — real routing, real widgets,
/// but with Firebase/Google removed from the equation.
Widget buildTestApp({
  required MockAuthRepository mockAuth,
  required MockRestaurantContextService mockContext,
  required MockMenuService mockMenuService,
  required MockProfilePageFacade mockProfileFacade,
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
      currentUserProvider.overrideWith((ref) => Stream.value(null)),
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
}
