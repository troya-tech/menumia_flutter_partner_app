import 'category.dart';

class Menu {
  final String menuKey;
  final List<Category> categories;

  const Menu({
    required this.menuKey,
    required this.categories,
  });

  Menu copyWith({
    String? menuKey,
    List<Category>? categories,
  }) {
    return Menu(
      menuKey: menuKey ?? this.menuKey,
      categories: categories ?? this.categories,
    );
  }
}
