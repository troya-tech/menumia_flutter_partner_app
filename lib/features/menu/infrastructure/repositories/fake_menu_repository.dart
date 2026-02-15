import '../../domain/entities/menu.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../../../testing/menu_fixtures.dart';

class FakeMenuRepository implements MenuRepository {
  @override
  Stream<Menu> watchMenu(String menuKey) {
    // Return menu from fixtures based on key
    try {
      if (menuKey == 'menuKey_forknife') return Stream.value(MenuFixtures.forknife);
      if (menuKey == 'menuKey_nfc17') return Stream.value(MenuFixtures.nfc17);
      if (menuKey == 'key_millet-bahcesi-lapseki-sosyal-tesisleri') return Stream.value(MenuFixtures.milletBahcesi);
      if (menuKey == 'key_tesis3') return Stream.value(MenuFixtures.tesis3);
      if (menuKey == 'key_fake') return Stream.value(MenuFixtures.fake);
      
      // Default to fake if not found
      return Stream.value(MenuFixtures.fake);
    } catch (_) {
      return Stream.value(MenuFixtures.fake);
    }
  }

  @override
  Future<void> updateCategory(String menuKey, Category category) async {}

  @override
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories) async {}

  @override
  Future<void> deleteCategory(String menuKey, String categoryId) async {}

  @override
  Future<void> updateProduct(String menuKey, String categoryId, Product product) async {}

  @override
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products) async {}

  @override
  Future<void> deleteProduct(String menuKey, String categoryId, String productId) async {}
}
