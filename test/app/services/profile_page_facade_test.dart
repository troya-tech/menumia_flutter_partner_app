import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:menumia_flutter_partner_app/app/services/profile_page_facade.dart';
import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';

// --- Mocks ---
class MockRestaurantContextService extends Mock
    implements RestaurantContextService {}

void main() {
  late MockRestaurantContextService mockContextService;

  final testUser = RestaurantUser(
    id: 'user_1',
    email: 'test@menumia.com',
    displayName: 'Test User',
    relatedRestaurantsIds: ['r1'],
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 6, 1),
    isActive: true,
  );

  final testRestaurants = [
    const Restaurant(
      id: 'r1',
      menuKey: 'mk1',
      restaurantName: 'Test Restaurant',
      openHour: '09:00',
      closeHour: '22:00',
    ),
  ];

  setUp(() {
    mockContextService = MockRestaurantContextService();
  });

  group('ProfilePageFacade', () {
    test('forwards currentUser stream from context service', () async {
      final controller = StreamController<RestaurantUser?>.broadcast();
      when(() => mockContextService.currentUser$)
          .thenAnswer((_) => controller.stream);
      when(() => mockContextService.relatedRestaurants$)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockContextService.activeRestaurantId$)
          .thenAnswer((_) => const Stream.empty());

      final facade = ProfilePageFacade(mockContextService);

      final userFuture = facade.currentUser$.first;
      controller.add(testUser);

      final user = await userFuture;
      expect(user?.email, 'test@menumia.com');

      await controller.close();
    });

    test('forwards relatedRestaurants stream from context service', () async {
      final controller = StreamController<List<Restaurant>>.broadcast();
      when(() => mockContextService.currentUser$)
          .thenAnswer((_) => const Stream.empty());
      when(() => mockContextService.relatedRestaurants$)
          .thenAnswer((_) => controller.stream);
      when(() => mockContextService.activeRestaurantId$)
          .thenAnswer((_) => const Stream.empty());

      final facade = ProfilePageFacade(mockContextService);

      final restaurantsFuture = facade.relatedRestaurants$.first;
      controller.add(testRestaurants);

      final restaurants = await restaurantsFuture;
      expect(restaurants.length, 1);
      expect(restaurants.first.restaurantName, 'Test Restaurant');

      await controller.close();
    });

    test('delegates init to context service', () {
      when(() => mockContextService.init()).thenAnswer((_) async {});

      final facade = ProfilePageFacade(mockContextService);
      facade.init();

      verify(() => mockContextService.init()).called(1);
    });

    test('delegates setActiveRestaurant to context service', () {
      when(() => mockContextService.setActiveRestaurant(any())).thenReturn(null);

      final facade = ProfilePageFacade(mockContextService);
      facade.setActiveRestaurant('r1');

      verify(() => mockContextService.setActiveRestaurant('r1')).called(1);
    });
  });
}
