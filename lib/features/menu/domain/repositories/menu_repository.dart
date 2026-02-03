import '../entities/menu.dart';
import '../entities/category.dart';
import '../entities/product.dart';

abstract class MenuRepository {
  /// Watches the menu structure for the given [menuKey]
  Stream<Menu> watchMenu(String menuKey);

  /// Updates or creates a category
  Future<void> updateCategory(String menuKey, Category category);
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories);
  
  /// Deletes a category
  Future<void> deleteCategory(String menuKey, String categoryId);
  
  /// Updates or creates a product within a category
  Future<void> updateProduct(String menuKey, String categoryId, Product product);

  /// Updates order for multiple products in a category
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products);
  
  /// Deletes a product
  Future<void> deleteProduct(String menuKey, String categoryId, String productId);
}
