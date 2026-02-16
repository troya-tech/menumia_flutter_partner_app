import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
/// - By default, signInWithGoogle works synchronously (no Future.delayed).
/// - Set [signInError] to make signInWithGoogle throw that exception.
/// - Set [onSignIn] to inject custom sign-in behavior (e.g. emit a specific user).
///
/// Unlike [FakeAuthRepository], this skips artificial delays so widget tests
/// don't fail with "Timer is still pending" under FakeAsync.
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
    // Default: emit testUser immediately (no Future.delayed)
    emitUser(AuthFixtures.testUser);
    return AuthFixtures.testUser;
  }

  @override
  Future<void> signOut() async {
    // Immediate sign-out (no Future.delayed)
    emitUser(null);
  }
}

// ─── Fake User Data ──────────────────────────────────────────────────────────

/// Primary test user — reuses [AuthFixtures.testUser] for consistency
/// with FakeAuthRepository.signInWithGoogle().
const fakeAuthUser = AuthFixtures.testUser;

/// Secondary test user for re-login scenarios.
const fakeAuthUser2 = AuthUser(
  uid: 'test-uid-456',
  email: 'other@menumia.com',
  displayName: 'Other User',
);

/// Primary test restaurant user — reuses [RestaurantUsersFixtures.fake_foorcun]
/// which corresponds to [AuthFixtures.testUser] (same email).
final fakeRestaurantUser = RestaurantUsersFixtures.fake_foorcun;

// ─── Test App Builder ────────────────────────────────────────────────────────

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
      title: 'Menumia Partner (Test)',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.auth,
      onGenerateRoute: AppRouter.generateRoute,
    ),
  );
}

// ─── Test Harness ────────────────────────────────────────────────────────────

/// Container for all shared test dependencies.
/// Created fresh in each test's [setUp] to ensure isolation.
class TestHarness {
  final TestableAuthRepository fakeAuth;
  final RestaurantContextService contextService;
  final MenuService menuService;
  final ProfilePageFacade profileFacade;
  final SharedConfigService sharedConfigService;

  TestHarness._({
    required this.fakeAuth,
    required this.contextService,
    required this.menuService,
    required this.profileFacade,
    required this.sharedConfigService,
  });

  /// Creates a fresh [TestHarness] with the full fake dependency chain:
  /// FakeAuthRepository → RestaurantContextService → ProfilePageFacade
  factory TestHarness.create() {
    final fakeAuth = TestableAuthRepository();
    final userService = RestaurantUserService(FakeRestaurantUserRepository());
    final restaurantService = RestaurantService(FakeRestaurantRepository());
    final menuService = MenuService(FakeMenuRepository());
    final sharedConfigService = SharedConfigService(FakeSharedConfigRepository());

    final contextService = RestaurantContextService(
      authRepository: fakeAuth,
      userService: userService,
      restaurantService: restaurantService,
    );

    final profileFacade = ProfilePageFacade(contextService);

    return TestHarness._(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
    );
  }

  /// Convenience method to build the test app widget.
  Widget buildApp({Stream<RestaurantUser?>? currentUserStream}) {
    return buildTestApp(
      fakeAuth: fakeAuth,
      contextService: contextService,
      menuService: menuService,
      profileFacade: profileFacade,
      sharedConfigService: sharedConfigService,
      currentUserStream: currentUserStream,
    );
  }
}
