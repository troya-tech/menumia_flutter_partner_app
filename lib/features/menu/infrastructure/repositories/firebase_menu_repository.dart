import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../dtos/menu_dto.dart';

import '../../../../utils/app_logger.dart';

class FirebaseMenuRepository implements MenuRepository {
  final FirebaseDatabase _database;
  static final _logger = AppLogger('FirebaseMenuRepository');

  FirebaseMenuRepository({FirebaseDatabase? database}) 
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Stream<Menu> watchMenu(String menuKey) {
    _logger.debug('Watching menu: $menuKey');
    return _database.ref('menu/$menuKey').onValue.map((event) {
      final value = event.snapshot.value;
      _logger.debug('Received event for $menuKey. Value is null: ${value == null}');
      
      if (value == null) {
        _logger.debug('Menu $menuKey is null/empty');
        return Menu(menuKey: menuKey, categories: []);
      }

      try {
        _logger.debug('Parsing menu data for $menuKey...');
        // Robust conversion using json codec to handle RTDB LinkedHashMap types
        final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
        final menu = MenuDto.fromJson(jsonMap, menuKey).toDomain();
        _logger.success('Successfully parsed menu $menuKey with ${menu.categories.length} categories');
        return menu;
      } catch (e, stack) {
        _logger.error('Error parsing menu stream for key $menuKey', e, stack);
        return Menu(menuKey: menuKey, categories: []);
      }
    });
  }

  @override
  Future<void> updateCategory(String menuKey, Category category) async {
    _logger.debug('Updating category: ${category.id} in menu: $menuKey');
    final ref = _database.ref('menu/$menuKey/categories/${category.id}');
    await ref.update({
      'name': category.name,
      'displayOrder': category.displayOrder,
      'isActive': category.isActive,
      // We don't update items here as they are managed separately
    });
    _logger.success('Category ${category.id} updated');
  }

  @override
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories) async {
    _logger.debug('Updating order for ${categories.length} categories in menu: $menuKey');
    final updates = <String, Object?>{};
    for (var category in categories) {
      updates['menu/$menuKey/categories/${category.id}/displayOrder'] = category.displayOrder;
    }
    await _database.ref().update(updates);
    _logger.success('Categories order updated');
  }

  @override
  Future<void> deleteCategory(String menuKey, String categoryId) async {
    _logger.warning('Deleting category: $categoryId from menu: $menuKey');
    await _database.ref('menu/$menuKey/categories/$categoryId').remove();
    _logger.success('Category $categoryId deleted');
  }

  @override
  Future<void> updateProduct(String menuKey, String categoryId, Product product) async {
    _logger.debug('Updating product: ${product.id} in category: $categoryId');
    final ref = _database.ref('menu/$menuKey/categories/$categoryId/menuItem/${product.id}');
    await ref.update({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'displayOrder': product.displayOrder,
    });
    _logger.success('Product ${product.id} updated');
  }

  @override
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products) async {
    _logger.debug('Updating order for ${products.length} products in category: $categoryId');
    final updates = <String, Object?>{};
    for (var product in products) {
      updates['menu/$menuKey/categories/$categoryId/menuItem/${product.id}/displayOrder'] = product.displayOrder;
    }
    await _database.ref().update(updates);
    _logger.success('Products order updated');
  }

  @override
  Future<void> deleteProduct(String menuKey, String categoryId, String productId) async {
    _logger.warning('Deleting product: $productId from category: $categoryId');
    await _database.ref('menu/$menuKey/categories/$categoryId/menuItem/$productId').remove();
    _logger.success('Product $productId deleted');
  }
}
