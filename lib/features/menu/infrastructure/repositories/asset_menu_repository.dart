import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/category.dart';

import '../../domain/entities/menu.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/menu_repository.dart';
import '../dtos/category_dto.dart';

import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

class AssetMenuRepository implements MenuRepository {
  static final _logger = AppLogger('AssetMenuRepository');

  @override
  Stream<Menu> watchMenu(String menuKey, [LogContext? context]) async* {
    _logger.debug('Watching menu from assets: $menuKey', context);
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
      
      _logger.success('Menu loaded from assets with ${categories.length} categories', context);
      yield Menu(menuKey: menuKey, categories: categories, context: context);
      
    } catch (e, stack) {
      _logger.error('Error loading menu from assets: $menuKey', e, stack, context);
      yield Menu(menuKey: menuKey, categories: [], context: context);
    }

  }


  @override
  Future<void> updateCategory(String menuKey, Category category, [LogContext? context]) async {
    _logger.warning('updateCategory not supported for assets', context);
  }

  @override
  Future<void> updateCategoriesOrder(String menuKey, List<Category> categories, [LogContext? context]) async {
    _logger.warning('updateCategoriesOrder not supported for assets', context);
  }

  @override
  Future<void> deleteCategory(String menuKey, String categoryId, [LogContext? context]) async {
    _logger.warning('deleteCategory not supported for assets', context);
  }

  @override
  Future<void> updateProduct(String menuKey, String categoryId, Product product, [LogContext? context]) async {
    _logger.warning('updateProduct not supported for assets', context);
  }

  @override
  Future<void> updateProductsOrder(String menuKey, String categoryId, List<Product> products, [LogContext? context]) async {
    _logger.warning('updateProductsOrder not supported for assets', context);
  }

  @override
  Future<void> deleteProduct(String menuKey, String categoryId, String productId, [LogContext? context]) async {
    _logger.warning('deleteProduct not supported for assets', context);
  }

}

