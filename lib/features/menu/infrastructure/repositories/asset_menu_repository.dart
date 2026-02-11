import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' hide Category;
import '../../domain/entities/category.dart';
import '../../domain/entities/menu.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../dtos/category_dto.dart';

class AssetMenuRepository implements MenuRepository {
  @override
  Stream<Menu> watchMenu(String menuKey) async* {
    try {
      // Load string from assets
      final jsonString = await rootBundle.loadString('assets/data/menumia-f10d8-default-rtdb-export.json');
      
      // Decode JSON
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      // Navigate to the menuKey
      final menuRoot = jsonMap['menu'] as Map<String, dynamic>?;
      if (menuRoot == null) {
        throw Exception('Menu root not found in JSON');
      }
      
      final specificMenu = menuRoot[menuKey] as Map<String, dynamic>?;
      if (specificMenu == null) {
        throw Exception('Menu key $menuKey not found in JSON');
      }
      
      final categoriesMap = specificMenu['category'] as Map<String, dynamic>?;
      final categories = <Category>[];

      if (categoriesMap != null) {
        // Parse Categories
        final parsedCategories = categoriesMap.entries
            .map((e) => CategoryDto.fromJson(e.value as Map<String, dynamic>, e.key))
            .map((dto) => dto.toDomain())
            .toList();
            
        // Sort Categories by displayOrder
        parsedCategories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
        categories.addAll(parsedCategories);
      }
      
      yield Menu(menuKey: menuKey, categories: categories);
      
    } catch (e) {
      debugPrint('Error loading menu: $e');
      yield Menu(menuKey: menuKey, categories: []);
    }
  }


  @override
  Future<void> updateCategory(String menuKey, Category category) async {
    debugPrint('AssetMenuRepository: updateCategory not supported for assets');
  }

  @override
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories) async {
    debugPrint('AssetMenuRepository: updateCategoriesOrder not supported for assets');
  }

  @override
  Future<void> deleteCategory(String menuKey, String categoryId) async {
    debugPrint('AssetMenuRepository: deleteCategory not supported for assets');
  }

  @override
  Future<void> updateProduct(String menuKey, String categoryId, Product product) async {
    debugPrint('AssetMenuRepository: updateProduct not supported for assets');
  }

  @override
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products) async {
    debugPrint('AssetMenuRepository: updateProductsOrder not supported for assets');
  }

  @override
  Future<void> deleteProduct(String menuKey, String categoryId, String productId) async {
    debugPrint('AssetMenuRepository: deleteProduct not supported for assets');
  }
}
