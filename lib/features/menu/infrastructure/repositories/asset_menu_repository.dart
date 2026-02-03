import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/menu.dart';
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
}
