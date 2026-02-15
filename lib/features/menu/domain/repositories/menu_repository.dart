import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

import '../entities/menu.dart';
import '../entities/category.dart';
import '../entities/product.dart';

abstract class MenuRepository {
  /// Watches the menu structure for the given [menuKey]
  Stream<Menu> watchMenu(String menuKey, [LogContext? context]);

  /// Updates or creates a category
  Future<void> updateCategory(String menuKey, Category category, [LogContext? context]);
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories, [LogContext? context]);
  
  /// Deletes a category
  Future<void> deleteCategory(String menuKey, String categoryId, [LogContext? context]);
  
  /// Updates or creates a product within a category
  Future<void> updateProduct(String menuKey, String categoryId, Product product, [LogContext? context]);

  /// Updates order for multiple products in a category
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products, [LogContext? context]);
  
  /// Deletes a product
  Future<void> deleteProduct(String menuKey, String categoryId, String productId, [LogContext? context]);
}

