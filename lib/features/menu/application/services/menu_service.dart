import '../../domain/entities/menu.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

class MenuService {
  final MenuRepository _menuRepository;

  MenuService(this._menuRepository);

  /// Watches the full menu structure (categories with products)
  Stream<Menu> watchMenu(String menuKey, [LogContext? context]) {
    return _menuRepository.watchMenu(menuKey, context);
  }

  /// Updates a category
  Future<void> updateCategory(String menuKey, Category category, [LogContext? context]) async {
    return _menuRepository.updateCategory(menuKey, category, context);
  }

  /// Updates order for multiple categories
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories, [LogContext? context]) async {
    return _menuRepository.updateCategoriesOrder(menuKey, categories, context);
  }

  /// Deletes a category
  Future<void> deleteCategory(String menuKey, String categoryId, [LogContext? context]) async {
    return _menuRepository.deleteCategory(menuKey, categoryId, context);
  }

  /// Updates a product
  Future<void> updateProduct(String menuKey, String categoryId, Product product, [LogContext? context]) async {
    return _menuRepository.updateProduct(menuKey, categoryId, product, context);
  }

  /// Updates order for multiple products
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products, [LogContext? context]) async {
    return _menuRepository.updateProductsOrder(menuKey, categoryId, products, context);
  }

  /// Deletes a product
  Future<void> deleteProduct(String menuKey, String categoryId, String productId, [LogContext? context]) async {
    return _menuRepository.deleteProduct(menuKey, categoryId, productId, context);
  }
}
