import '../../domain/entities/menu.dart';
import 'category_dto.dart';

class MenuDto {
  final String menuKey;
  final List<CategoryDto> categories;

  MenuDto({
    required this.menuKey,
    required this.categories,
  });

  factory MenuDto.fromJson(Map<String, dynamic> json, String menuKey) {
    final categoriesMap = json['categories'] as Map<String, dynamic>? ?? {};
    
    final categories = categoriesMap.entries
        .map((e) => CategoryDto.fromJson(e.value as Map<String, dynamic>, e.key))
        .toList();
    
    // Sort categories by displayOrder
    categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return MenuDto(
      menuKey: menuKey,
      categories: categories,
    );
  }

  Menu toDomain() {
    return Menu(
      menuKey: menuKey,
      categories: categories.map((e) => e.toDomain()).toList(),
    );
  }
}
