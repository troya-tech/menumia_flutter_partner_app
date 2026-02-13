import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_repository.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/application/restaurant_user_service.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/application/restaurant_service.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';

// --- Mocks ---
class MockAuthRepository extends Mock implements AuthRepository {}

class MockRestaurantUserService extends Mock implements RestaurantUserService {}

class MockRestaurantService extends Mock implements RestaurantService {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockRestaurantUserService mockUserService;
  late MockRestaurantService mockRestaurantService;
  late StreamController<AuthUser?> authStateController;

  final testAuthUser = const AuthUser(
    uid: 'uid_123',
    email: 'partner@menumia.com',
    displayName: 'Test Partner',
  );

  final testRestaurantUser = RestaurantUser(
    id: 'ru_1',
    email: 'partner@menumia.com',
    displayName: 'Test Partner',
    relatedRestaurantsIds: ['rest_1', 'rest_2'],
    role: 'owner',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 6, 1),
    isActive: true,
  );

  final testRestaurants = [
    const Restaurant(
      id: 'rest_1',
      menuKey: 'menu_key_1',
      restaurantName: 'Restaurant Alpha',
      openHour: '09:00',
      closeHour: '22:00',
    ),
    const Restaurant(
      id: 'rest_2',
      menuKey: 'menu_key_2',
      restaurantName: 'Restaurant Beta',
      openHour: '10:00',
      closeHour: '23:00',
    ),
  ];

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserService = MockRestaurantUserService();
    mockRestaurantService = MockRestaurantService();
    authStateController = StreamController<AuthUser?>.broadcast();

    when(() => mockAuthRepo.authStateChanges())
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  RestaurantContextService createService() {
    return RestaurantContextService(
      authRepository: mockAuthRepo,
      userService: mockUserService,
      restaurantService: mockRestaurantService,
    );
  }

  group('RestaurantContextService', () {
    group('init()', () {
      test('loads user and restaurants when authenticated', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(testAuthUser);
        when(() => mockUserService.getUserByEmail('partner@menumia.com'))
            .thenAnswer((_) async => testRestaurantUser);
        when(() => mockRestaurantService
                .getRestaurantsByIds(['rest_1', 'rest_2']))
            .thenAnswer((_) async => testRestaurants);

        final service = createService();

        // Listen to streams before calling init
        final userFuture = service.currentUser$.first;
        final restaurantsFuture = service.relatedRestaurants$.first;
        final activeIdFuture = service.activeRestaurantId$.first;
        final menuKeyFuture = service.activeMenuKey$.first;

        await service.init();

        final user = await userFuture;
        expect(user?.email, 'partner@menumia.com');

        final restaurants = await restaurantsFuture;
        expect(restaurants.length, 2);

        final activeId = await activeIdFuture;
        expect(activeId, 'rest_1'); // defaults to first

        final menuKey = await menuKeyFuture;
        expect(menuKey, 'menu_key_1');
      });

      test('emits null user when no authenticated user', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(null);

        final service = createService();

        final userFuture = service.currentUser$.first;
        await service.init();

        final user = await userFuture;
        expect(user, isNull);
      });

      test('emits null user when user has no email', () async {
        const noEmailUser = AuthUser(uid: 'uid_no_email');
        when(() => mockAuthRepo.currentUser).thenReturn(noEmailUser);

        final service = createService();

        final userFuture = service.currentUser$.first;
        await service.init();

        final user = await userFuture;
        expect(user, isNull);
      });

      test('emits null user when user not found in database', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(testAuthUser);
        when(() => mockUserService.getUserByEmail(any()))
            .thenAnswer((_) async => null);

        final service = createService();

        final userFuture = service.currentUser$.first;
        await service.init();

        final user = await userFuture;
        expect(user, isNull);
      });
    });

    group('setActiveRestaurant()', () {
      test('switches active restaurant and emits new menu key', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(testAuthUser);
        when(() => mockUserService.getUserByEmail(any()))
            .thenAnswer((_) async => testRestaurantUser);
        when(() => mockRestaurantService.getRestaurantsByIds(any()))
            .thenAnswer((_) async => testRestaurants);

        final service = createService();
        await service.init();

        // Listen for the switch
        final activeIdFuture = service.activeRestaurantId$.first;
        final menuKeyFuture = service.activeMenuKey$.first;

        service.setActiveRestaurant('rest_2');

        final activeId = await activeIdFuture;
        expect(activeId, 'rest_2');

        final menuKey = await menuKeyFuture;
        expect(menuKey, 'menu_key_2');
      });

      test('does nothing when same restaurant is set', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(testAuthUser);
        when(() => mockUserService.getUserByEmail(any()))
            .thenAnswer((_) async => testRestaurantUser);
        when(() => mockRestaurantService.getRestaurantsByIds(any()))
            .thenAnswer((_) async => testRestaurants);

        final service = createService();
        await service.init();

        // Collect emissions - setting same ID should not emit
        final emissions = <String?>[];
        final sub = service.activeRestaurantId$.listen(emissions.add);

        service.setActiveRestaurant('rest_1'); // same as default
        await Future.delayed(const Duration(milliseconds: 50));

        expect(emissions, isEmpty);
        await sub.cancel();
      });
    });

    group('auth state changes', () {
      test('clears state when user signs out', () async {
        when(() => mockAuthRepo.currentUser).thenReturn(testAuthUser);
        when(() => mockUserService.getUserByEmail(any()))
            .thenAnswer((_) async => testRestaurantUser);
        when(() => mockRestaurantService.getRestaurantsByIds(any()))
            .thenAnswer((_) async => testRestaurants);

        final service = createService();
        await service.init();

        // Listen for cleared state
        final userFuture = service.currentUser$.first;
        final restaurantsFuture = service.relatedRestaurants$.first;

        // Simulate sign-out
        authStateController.add(null);

        final user = await userFuture;
        expect(user, isNull);

        final restaurants = await restaurantsFuture;
        expect(restaurants, isEmpty);
      });
    });
  });
}
