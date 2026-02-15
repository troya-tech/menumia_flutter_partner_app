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

  void _logMenuDetails(String menuKey, Menu menu, [LogContext? context]) {
    final catCount = menu.categories.length;
    final prodCount = menu.categories.fold<int>(0, (sum, cat) => sum + cat.items.length);
    _logger.info('Menu State [$menuKey]: $catCount categories, $prodCount products total', context);
  }

  Menu _getOrCreateMenu(String menuKey, [LogContext? context]) {
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
        _logger.error('Error creating menu for key: $menuKey', e, null, context);
        _menuCache[menuKey] = MenuFixtures.fake;
      }
    }
    return _menuCache[menuKey]!;
  }

  BehaviorSubject<Menu> _getSubject(String menuKey, [LogContext? context]) {
    _logger.debug('Getting subject for menuKey: $menuKey', context);
    if (!_menuSubjects.containsKey(menuKey)) {
      final initialMenu = _getOrCreateMenu(menuKey, context);
      _menuSubjects[menuKey] = BehaviorSubject<Menu>.seeded(initialMenu);
    }
    return _menuSubjects[menuKey]!;
  }

  @override
  Stream<Menu> watchMenu(String menuKey, [LogContext? context]) {
    _logger.debug('Watching menu: $menuKey', context);
    final menu = _getOrCreateMenu(menuKey, context);
    _logMenuDetails(menuKey, menu, context);
    return _getSubject(menuKey, context).stream.map((m) => m.copyWith(context: context));
  }




  @override
  Future<void> updateCategory(String menuKey, Category category, [LogContext? context]) async {
    final menu = _getOrCreateMenu(menuKey, context);
    final categories = List<Category>.from(menu.categories);
    
    final index = categories.indexWhere((c) => c.id == category.id);
    if (index >= 0) {
      categories[index] = category;
    } else {
      categories.add(category);
    }
    
    final updatedMenu = menu.copyWith(categories: categories);
    _menuCache[menuKey] = updatedMenu;
    _getSubject(menuKey, context).add(updatedMenu);
    _logger.success('Category ${category.name} (${category.id}) updated in menu $menuKey', context);
    _logMenuDetails(menuKey, updatedMenu, context);
  }



  @override
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories, [LogContext? context]) async {
    final menu = _getOrCreateMenu(menuKey, context);
    final updatedMenu = menu.copyWith(categories: categories);
    _menuCache[menuKey] = updatedMenu;
    _getSubject(menuKey, context).add(updatedMenu);
    _logger.success('Categories order updated for ${categories.length} items in $menuKey', context);
    _logMenuDetails(menuKey, updatedMenu, context);
  }



  @override
  Future<void> deleteCategory(String menuKey, String categoryId, [LogContext? context]) async {
    final menu = _getOrCreateMenu(menuKey, context);
    final categories = menu.categories.where((c) => c.id != categoryId).toList();
    
    final updatedMenu = menu.copyWith(categories: categories);
    _menuCache[menuKey] = updatedMenu;
    _getSubject(menuKey, context).add(updatedMenu);
    _logger.warning('Category $categoryId deleted from menu $menuKey', context);
    _logMenuDetails(menuKey, updatedMenu, context);
  }



  @override
  Future<void> updateProduct(String menuKey, String categoryId, Product product, [LogContext? context]) async {
    final menu = _getOrCreateMenu(menuKey, context);
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
      _getSubject(menuKey, context).add(updatedMenu);
      _logger.success('Product ${product.name} (${product.id}) updated in category $categoryId (Menu: $menuKey)', context);
      _logMenuDetails(menuKey, updatedMenu, context);
    } else {
      _logger.warning('Failed to update product: Category $categoryId not found in menu $menuKey', context);
    }
  }



  @override
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products, [LogContext? context]) async {
    final menu = _getOrCreateMenu(menuKey, context);
    final categories = List<Category>.from(menu.categories);
    
    final catIndex = categories.indexWhere((c) => c.id == categoryId);
    if (catIndex >= 0) {
      categories[catIndex] = categories[catIndex].copyWith(items: products);
      final updatedMenu = menu.copyWith(categories: categories);
      _menuCache[menuKey] = updatedMenu;
      _getSubject(menuKey, context).add(updatedMenu);
      _logger.success('Products order updated for category $categoryId in $menuKey', context);
      _logMenuDetails(menuKey, updatedMenu, context);
    } else {
      _logger.warning('Failed to update products order: Category $categoryId not found in menu $menuKey', context);
    }
  }


  @override
  Future<void> deleteProduct(String menuKey, String categoryId, String productId, [LogContext? context]) async {
    final menu = _getOrCreateMenu(menuKey, context);
    final categories = List<Category>.from(menu.categories);
    
    final catIndex = categories.indexWhere((c) => c.id == categoryId);
    if (catIndex >= 0) {
      final category = categories[catIndex];
      final items = category.items.where((p) => p.id != productId).toList();
      
      categories[catIndex] = category.copyWith(items: items);
      final updatedMenu = menu.copyWith(categories: categories);
      _menuCache[menuKey] = updatedMenu;
      _getSubject(menuKey, context).add(updatedMenu);
      _logger.warning('Product $productId deleted from category $categoryId in $menuKey', context);
      _logMenuDetails(menuKey, updatedMenu, context);
    } else {
      _logger.warning('Failed to delete product: Category $categoryId not found in menu $menuKey', context);
    }
  }

}
