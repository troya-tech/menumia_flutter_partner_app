import 'package:rxdart/rxdart.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../../../../testing/menu_fixtures.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';


class FakeMenuRepository implements MenuRepository {
  static final _logger = AppLogger('FakeMenuRepository');
  static final Map<String, BehaviorSubject<Menu>> _menuSubjects = {};
  static final Map<String, Menu> _menuCache = {};

  FakeMenuRepository() {
    _logger.info('Initialized FakeMenuRepository');
  }

  void _logMenuDetails(String menuKey, Menu menu) {
    final catCount = menu.categories.length;
    final prodCount = menu.categories.fold<int>(0, (sum, cat) => sum + cat.items.length);
    _logger.info('Menu State [$menuKey]: $catCount categories, $prodCount products total');
  }




  Menu _getOrCreateMenu(String menuKey) {
    if (!_menuCache.containsKey(menuKey)) {
      try {
        Menu menu;
        if (menuKey == 'menuKey_forknife') menu = MenuFixtures.forknife;
        else if (menuKey == 'menuKey_nfc17') menu = MenuFixtures.nfc17;
        else if (menuKey == 'key_millet-bahcesi-lapseki-sosyal-tesisleri') menu = MenuFixtures.milletBahcesi;
        else if (menuKey == 'key_tesis3') menu = MenuFixtures.tesis3;
        else if (menuKey == 'key_fake') menu = MenuFixtures.fake;
        else menu = MenuFixtures.fake;
        
        _menuCache[menuKey] = menu;
      } catch (e) {
        _logger.error('Error creating menu for key: $menuKey', e);
        _menuCache[menuKey] = MenuFixtures.fake;
      }
    }
    return _menuCache[menuKey]!;

  }

  BehaviorSubject<Menu> _getSubject(String menuKey) {
    _logger.debug('Getting subject for menuKey: $menuKey');
    if (!_menuSubjects.containsKey(menuKey)) {
      final initialMenu = _getOrCreateMenu(menuKey);
      _menuSubjects[menuKey] = BehaviorSubject<Menu>.seeded(initialMenu);
    }
    return _menuSubjects[menuKey]!;
  }


  @override
  Stream<Menu> watchMenu(String menuKey) {
    _logger.debug('Watching menu: $menuKey');
    final menu = _getOrCreateMenu(menuKey);
    _logMenuDetails(menuKey, menu);
    return _getSubject(menuKey).stream;
  }



  @override
  Future<void> updateCategory(String menuKey, Category category) async {
    final menu = _getOrCreateMenu(menuKey);
    final categories = List<Category>.from(menu.categories);
    
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      categories[index] = category;
    } else {
      categories.add(category);
    }
    
    final updatedMenu = menu.copyWith(categories: categories);
    _menuCache[menuKey] = updatedMenu;
    _getSubject(menuKey).add(updatedMenu);
    _logger.success('Category ${category.name} (${category.id}) updated in menu $menuKey');
    _logMenuDetails(menuKey, updatedMenu);
  }



  @override
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories) async {
    final menu = _getOrCreateMenu(menuKey);
    final updatedMenu = menu.copyWith(categories: categories);
    _menuCache[menuKey] = updatedMenu;
    _getSubject(menuKey).add(updatedMenu);
    _logger.success('Categories order updated for ${categories.length} items in $menuKey');
    _logMenuDetails(menuKey, updatedMenu);
  }



  @override
  Future<void> deleteCategory(String menuKey, String categoryId) async {
    final menu = _getOrCreateMenu(menuKey);
    final categories = menu.categories.where((c) => c.id != categoryId).toList();
    
    final updatedMenu = menu.copyWith(categories: categories);
    _menuCache[menuKey] = updatedMenu;
    _getSubject(menuKey).add(updatedMenu);
    _logger.warning('Category $categoryId deleted from menu $menuKey');
    _logMenuDetails(menuKey, updatedMenu);
  }



  @override
  Future<void> updateProduct(String menuKey, String categoryId, Product product) async {
    final menu = _getOrCreateMenu(menuKey);
    final categories = List<Category>.from(menu.categories);
    
    final catIndex = categories.indexWhere((c) => c.id == categoryId);
    if (catIndex >= 0) {
      final category = categories[catIndex];
      final items = List<Product>.from(category.items);
      
      final prodIndex = items.indexWhere((p) => p.id == product.id);
      if (prodIndex >= 0) {
        items[prodIndex] = product;
      } else {
        items.add(product);
      }
      
      categories[catIndex] = category.copyWith(items: items);
      final updatedMenu = menu.copyWith(categories: categories);
      _menuCache[menuKey] = updatedMenu;
      _getSubject(menuKey).add(updatedMenu);
      _logger.success('Product ${product.name} (${product.id}) updated in category $categoryId (Menu: $menuKey)');
      _logMenuDetails(menuKey, updatedMenu);
    } else {
      _logger.warning('Failed to update product: Category $categoryId not found in menu $menuKey');
    }
  }



  @override
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products) async {
    final menu = _getOrCreateMenu(menuKey);
    final categories = List<Category>.from(menu.categories);
    
    final catIndex = categories.indexWhere((c) => c.id == categoryId);
    if (catIndex >= 0) {
      categories[catIndex] = categories[catIndex].copyWith(items: products);
      final updatedMenu = menu.copyWith(categories: categories);
      _menuCache[menuKey] = updatedMenu;
      _getSubject(menuKey).add(updatedMenu);
      _logger.success('Products order updated for category $categoryId in $menuKey');
      _logMenuDetails(menuKey, updatedMenu);
    } else {

      _logger.warning('Failed to update products order: Category $categoryId not found in menu $menuKey');
    }
  }


  @override
  Future<void> deleteProduct(String menuKey, String categoryId, String productId) async {
    final menu = _getOrCreateMenu(menuKey);
    final categories = List<Category>.from(menu.categories);
    
    final catIndex = categories.indexWhere((c) => c.id == categoryId);
    if (catIndex >= 0) {
      final category = categories[catIndex];
      final items = category.items.where((p) => p.id != productId).toList();
      
      categories[catIndex] = category.copyWith(items: items);
      final updatedMenu = menu.copyWith(categories: categories);
      _menuCache[menuKey] = updatedMenu;
      _getSubject(menuKey).add(updatedMenu);
      _logger.warning('Product $productId deleted from category $categoryId in $menuKey');
      _logMenuDetails(menuKey, updatedMenu);
    } else {

      _logger.warning('Failed to delete product: Category $categoryId not found in menu $menuKey');
    }
  }

}
