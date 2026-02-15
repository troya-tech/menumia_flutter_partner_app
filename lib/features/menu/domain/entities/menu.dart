import '../../../../utils/app_logger.dart';
import 'category.dart';

class Menu {
  final String menuKey;
  final List<Category> categories;
  final LogContext? context;

  const Menu({
    required this.menuKey,
    required this.categories,
    this.context,
  });

  Menu copyWith({
    String? menuKey,
    List<Category>? categories,
    LogContext? context,
  }) {
    return Menu(
      menuKey: menuKey ?? this.menuKey,
      categories: categories ?? this.categories,
      context: context ?? this.context,
    );
  }
}

