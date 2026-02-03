import '../../domain/entities/menu.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';

class MenuService {
  final MenuRepository _menuRepository;

  MenuService(this._menuRepository);

  /// Watches the full menu structure (categories with products)
  Stream<Menu> watchMenu(String menuKey) {
    return _menuRepository.watchMenu(menuKey);
  }

  /// Updates a category
  Future<void> updateCategory(String menuKey, Category category) async {
    return _menuRepository.updateCategory(menuKey, category);
  }

  /// Updates order for multiple categories
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories) async {
    return _menuRepository.updateCategoriesOrder(menuKey, categories);
  }

  /// Deletes a category
  Future<void> deleteCategory(String menuKey, String categoryId) async {
    return _menuRepository.deleteCategory(menuKey, categoryId);
  }

  /// Updates a product
  Future<void> updateProduct(String menuKey, String categoryId, Product product) async {
    return _menuRepository.updateProduct(menuKey, categoryId, product);
  }

  /// Updates order for multiple products
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products) async {
    return _menuRepository.updateProductsOrder(menuKey, categoryId, products);
  }

  /// Deletes a product
  Future<void> deleteProduct(String menuKey, String categoryId, String productId) async {
    return _menuRepository.deleteProduct(menuKey, categoryId, productId);
  }
}
