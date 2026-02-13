import 'package:flutter_test/flutter_test.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/dtos/category_dto.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/category.dart';

void main() {
  group('CategoryDto', () {
    group('fromJson', () {
      test('parses a category with Map-based menuItems correctly', () {
        final json = {
          'name': 'Beverages',
          'displayOrder': 2,
          'isActive': true,
          'menuItem': {
            'item_1': {
              'name': 'Latte',
              'description': 'Creamy latte',
              'price': 25.0,
              'imageUrl': 'https://example.com/latte.png',
              'displayOrder': 1,
            },
            'item_2': {
              'name': 'Espresso',
              'description': 'Strong espresso',
              'price': 15.0,
              'imageUrl': 'https://example.com/espresso.png',
              'displayOrder': 0,
            },
          },
        };

        final dto = CategoryDto.fromJson(json, 'cat_1');

        expect(dto.id, 'cat_1');
        expect(dto.name, 'Beverages');
        expect(dto.displayOrder, 2);
        expect(dto.isActive, true);
        expect(dto.items.length, 2);
        // Items should be sorted by displayOrder
        expect(dto.items.first.name, 'Espresso');
        expect(dto.items.last.name, 'Latte');
      });

      test('parses a category with List-based menuItems correctly', () {
        final json = {
          'name': 'Desserts',
          'displayOrder': 3,
          'isActive': false,
          'menuItem': [
            {
              'name': 'Baklava',
              'description': 'Pistachio baklava',
              'price': 30.0,
              'imageUrl': '',
              'displayOrder': 0,
            },
            null, // null entries should be skipped
            {
              'name': 'Künefe',
              'description': 'Hot cheese dessert',
              'price': 45.0,
              'imageUrl': '',
              'displayOrder': 1,
            },
          ],
        };

        final dto = CategoryDto.fromJson(json, 'cat_2');

        expect(dto.id, 'cat_2');
        expect(dto.name, 'Desserts');
        expect(dto.isActive, false);
        expect(dto.items.length, 2); // null entry skipped
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final dto = CategoryDto.fromJson(json, 'cat_empty');

        expect(dto.name, '');
        expect(dto.displayOrder, 0);
        expect(dto.isActive, true);
        expect(dto.items, isEmpty);
      });

      test('handles null menuItem field gracefully', () {
        final json = {
          'name': 'Empty Category',
          'menuItem': null,
        };

        final dto = CategoryDto.fromJson(json, 'cat_null');
        expect(dto.items, isEmpty);
      });
    });

    group('toDomain', () {
      test('converts DTO to Category entity correctly', () {
        final json = {
          'name': 'Main Courses',
          'displayOrder': 1,
          'isActive': true,
          'menuItem': {
            'p1': {
              'name': 'Kebab',
              'description': 'Grilled kebab',
              'price': 80.0,
              'imageUrl': '',
              'displayOrder': 0,
            },
          },
        };

        final dto = CategoryDto.fromJson(json, 'cat_main');
        final entity = dto.toDomain();

        expect(entity, isA<Category>());
        expect(entity.id, 'cat_main');
        expect(entity.name, 'Main Courses');
        expect(entity.items.length, 1);
        expect(entity.items.first.name, 'Kebab');
      });
    });
  });
}
