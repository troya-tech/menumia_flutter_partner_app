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
    final categoriesData = json['categories'];
    final List<CategoryDto> categories = [];

    if (categoriesData is Map) {
      categories.addAll(
        categoriesData.entries.map(
          (e) => CategoryDto.fromJson(Map<String, dynamic>.from(e.value), e.key),
        ),
      );
    } else if (categoriesData is List) {
      for (var i = 0; i < categoriesData.length; i++) {
        final item = categoriesData[i];
        if (item != null) {
          categories.add(
            CategoryDto.fromJson(Map<String, dynamic>.from(item), i.toString()),
          );
        }
      }
    }
    
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
