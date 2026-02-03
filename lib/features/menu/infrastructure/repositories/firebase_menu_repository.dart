import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../dtos/menu_dto.dart';

class FirebaseMenuRepository implements MenuRepository {
  final FirebaseDatabase _database;

  FirebaseMenuRepository({FirebaseDatabase? database}) 
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Stream<Menu> watchMenu(String menuKey) {
    return _database.ref('menu/$menuKey').onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return Menu(menuKey: menuKey, categories: []);
      }

      try {
        // Robust conversion using json codec to handle RTDB LinkedHashMap types
        final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
        return MenuDto.fromJson(jsonMap, menuKey).toDomain();
      } catch (e) {
        // In a real app, use a proper logger
        print('Error parsing menu stream: $e');
        return Menu(menuKey: menuKey, categories: []);
      }
    });
  }

  @override
  Future<void> updateCategory(String menuKey, Category category) async {
    final ref = _database.ref('menu/$menuKey/categories/${category.id}');
    await ref.update({
      'name': category.name,
      'displayOrder': category.displayOrder,
      'isActive': category.isActive,
      // We don't update items here as they are managed separately
    });
  }

  @override
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories) async {
    final updates = <String, Object?>{};
    for (var category in categories) {
      updates['menu/$menuKey/categories/${category.id}/displayOrder'] = category.displayOrder;
    }
    await _database.ref().update(updates);
  }

  @override
  Future<void> deleteCategory(String menuKey, String categoryId) async {
    await _database.ref('menu/$menuKey/categories/$categoryId').remove();
  }

  @override
  Future<void> updateProduct(String menuKey, String categoryId, Product product) async {
    final ref = _database.ref('menu/$menuKey/categories/$categoryId/menuItem/${product.id}');
    await ref.update({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
      'displayOrder': product.displayOrder,
    });
  }

  @override
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products) async {
    final updates = <String, Object?>{};
    for (var product in products) {
      updates['menu/$menuKey/categories/$categoryId/menuItem/${product.id}/displayOrder'] = product.displayOrder;
    }
    await _database.ref().update(updates);
  }

  @override
  Future<void> deleteProduct(String menuKey, String categoryId, String productId) async {
    await _database.ref('menu/$menuKey/categories/$categoryId/menuItem/$productId').remove();
  }
}
