import '../../domain/entities/category.dart';
import 'product_dto.dart';

class CategoryDto {
  final String id;
  final String name;
  final int displayOrder;
  final bool isActive;
  final List<ProductDto> items;

  CategoryDto({
    required this.id,
    required this.name,
    required this.displayOrder,
    required this.isActive,
    required this.items,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json, String key) {
    final itemsMap = json['menuItem'] as Map<String, dynamic>? ?? {};
    final items = itemsMap.entries
        .map((e) => ProductDto.fromJson(e.value as Map<String, dynamic>, e.key))
        .toList();

    // Sort items by displayOrder
    items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return CategoryDto(
      id: key,
      name: json['name'] as String? ?? '',
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      items: items,
    );
  }

  Category toDomain() {
    return Category(
      id: id,
      name: name,
      displayOrder: displayOrder,
      isActive: isActive,
      items: items.map((e) => e.toDomain()).toList(),
    );
  }
}
