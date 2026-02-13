import 'package:flutter_test/flutter_test.dart';
import 'package:menumia_flutter_partner_app/features/menu/infrastructure/dtos/product_dto.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/product.dart';

void main() {
  group('ProductDto', () {
    group('fromJson', () {
      test('parses a complete product correctly', () {
        final json = {
          'name': 'Adana Kebab',
          'description': 'Spicy minced meat kebab',
          'price': 120.0,
          'imageUrl': 'https://example.com/adana.png',
          'displayOrder': 3,
        };

        final dto = ProductDto.fromJson(json, 'prod_1');

        expect(dto.id, 'prod_1');
        expect(dto.name, 'Adana Kebab');
        expect(dto.description, 'Spicy minced meat kebab');
        expect(dto.price, 120.0);
        expect(dto.imageUrl, 'https://example.com/adana.png');
        expect(dto.displayOrder, 3);
      });

      test('handles missing fields with defaults', () {
        final json = <String, dynamic>{};
        final dto = ProductDto.fromJson(json, 'prod_empty');

        expect(dto.id, 'prod_empty');
        expect(dto.name, '');
        expect(dto.description, '');
        expect(dto.price, 0.0);
        expect(dto.imageUrl, '');
        expect(dto.displayOrder, 0);
      });

      test('handles integer price as double', () {
        final json = {
          'name': 'Tea',
          'description': 'Turkish tea',
          'price': 10, // integer, not double
          'imageUrl': '',
          'displayOrder': 0,
        };

        final dto = ProductDto.fromJson(json, 'prod_tea');
        expect(dto.price, 10.0);
        expect(dto.price, isA<double>());
      });
    });

    group('toDomain', () {
      test('converts DTO to Product entity', () {
        final json = {
          'name': 'Ayran',
          'description': 'Cold yogurt drink',
          'price': 8.5,
          'imageUrl': 'https://example.com/ayran.png',
          'displayOrder': 1,
        };

        final dto = ProductDto.fromJson(json, 'prod_ayran');
        final entity = dto.toDomain();

        expect(entity, isA<Product>());
        expect(entity.id, 'prod_ayran');
        expect(entity.name, 'Ayran');
        expect(entity.price, 8.5);
      });
    });
  });
}
