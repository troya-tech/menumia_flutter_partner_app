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
    final itemsData = json['menuItem'];
    final List<ProductDto> items = [];

    if (itemsData is Map) {
      items.addAll(
        itemsData.entries.map(
          (e) => ProductDto.fromJson(Map<String, dynamic>.from(e.value), e.key),
        ),
      );
    } else if (itemsData is List) {
      for (var i = 0; i < itemsData.length; i++) {
        final item = itemsData[i];
        if (item != null) {
          items.add(
            ProductDto.fromJson(Map<String, dynamic>.from(item), i.toString()),
          );
        }
      }
    }

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
