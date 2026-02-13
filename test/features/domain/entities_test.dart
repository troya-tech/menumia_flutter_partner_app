import 'package:flutter_test/flutter_test.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/category.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/product.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';

void main() {
  group('Category Entity', () {
    test('creates with required fields', () {
      const category = Category(id: '1', name: 'Drinks');

      expect(category.id, '1');
      expect(category.name, 'Drinks');
      expect(category.displayOrder, 0);
      expect(category.isActive, true);
      expect(category.items, isEmpty);
    });

    test('copyWith overrides only specified fields', () {
      const original = Category(
        id: '1',
        name: 'Drinks',
        displayOrder: 1,
        isActive: true,
      );

      final copy = original.copyWith(name: 'Beverages', isActive: false);

      expect(copy.id, '1'); // unchanged
      expect(copy.name, 'Beverages'); // changed
      expect(copy.displayOrder, 1); // unchanged
      expect(copy.isActive, false); // changed
    });

    test('copyWith preserves items when not overridden', () {
      const product = Product(
        id: 'p1',
        name: 'Tea',
        description: '',
        price: 5.0,
        imageUrl: '',
        displayOrder: 0,
      );
      const category = Category(
        id: '1',
        name: 'Drinks',
        items: [product],
      );

      final copy = category.copyWith(name: 'Hot Drinks');
      expect(copy.items.length, 1);
      expect(copy.items.first.name, 'Tea');
    });
  });

  group('Product Entity', () {
    test('creates with all required fields', () {
      const product = Product(
        id: 'p1',
        name: 'Kebab',
        description: 'Grilled meat',
        price: 80.0,
        imageUrl: 'https://img.com/kebab.png',
        displayOrder: 1,
      );

      expect(product.id, 'p1');
      expect(product.name, 'Kebab');
      expect(product.price, 80.0);
    });

    test('copyWith overrides price correctly', () {
      const original = Product(
        id: 'p1',
        name: 'Kebab',
        description: 'Grilled meat',
        price: 80.0,
        imageUrl: '',
        displayOrder: 0,
      );

      final updated = original.copyWith(price: 95.0);
      expect(updated.price, 95.0);
      expect(updated.name, 'Kebab'); // unchanged
    });
  });

  group('Restaurant Entity', () {
    test('creates with required fields', () {
      const r = Restaurant(
        id: 'r1',
        menuKey: 'mk1',
        restaurantName: 'Alpha',
        openHour: '09:00',
        closeHour: '22:00',
      );

      expect(r.id, 'r1');
      expect(r.menuKey, 'mk1');
      expect(r.restaurantName, 'Alpha');
    });

    test('empty factory produces blank values', () {
      final r = Restaurant.empty();
      expect(r.id, '');
      expect(r.menuKey, '');
      expect(r.restaurantName, '');
    });

    test('copyWith overrides restaurantName', () {
      const r = Restaurant(
        id: 'r1',
        menuKey: 'mk1',
        restaurantName: 'Alpha',
        openHour: '09:00',
        closeHour: '22:00',
      );

      final copy = r.copyWith(restaurantName: 'Beta');
      expect(copy.restaurantName, 'Beta');
      expect(copy.menuKey, 'mk1'); // unchanged
    });
  });

  group('RestaurantUser Entity', () {
    test('creates with required fields', () {
      final user = RestaurantUser(
        id: 'u1',
        email: 'user@test.com',
        relatedRestaurantsIds: ['r1', 'r2'],
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 6, 1),
        isActive: true,
      );

      expect(user.email, 'user@test.com');
      expect(user.relatedRestaurantsIds.length, 2);
      expect(user.displayName, isNull);
      expect(user.role, isNull);
    });

    test('empty factory produces inactive user', () {
      final user = RestaurantUser.empty();
      expect(user.isActive, false);
      expect(user.email, '');
      expect(user.relatedRestaurantsIds, isEmpty);
    });
  });

  group('SharedConfig Entity', () {
    test('creates with ordering enabled', () {
      const config = SharedConfig(
        planTiersPlanner: PlanTiersPlanner(orderingEnabled: true),
        themeSettingsPlanner: ThemeSettingsPlanner(
          logoUrlLink: 'https://logo.png',
          primaryColor: '#FF0000',
          secondaryColor: '#00FF00',
          titleColor: '#000000',
          cardLogoBackgroundColor: '#FFFFFF',
        ),
      );

      expect(config.planTiersPlanner.orderingEnabled, true);
      expect(config.themeSettingsPlanner.logoUrlLink, 'https://logo.png');
    });

    test('empty factory produces safe defaults', () {
      final config = SharedConfig.empty();
      expect(config.planTiersPlanner.orderingEnabled, false);
      expect(config.themeSettingsPlanner.primaryColor, '#D3D3D3');
    });
  });
}
