import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/menu.dart';
import '../domain/repositories/menu_repository.dart';
import '../infrastructure/repositories/firebase_menu_repository.dart';
import 'services/menu_service.dart';

/// Provider for the MenuRepository
final menuRepositoryProvider = Provider<MenuRepository>((ref) {
  return FirebaseMenuRepository();
});

/// Provider for the MenuService
final menuServiceProvider = Provider<MenuService>((ref) {
  return MenuService(ref.watch(menuRepositoryProvider));
});

/// StreamProvider for a specific menu
final menuProvider = StreamProvider.family<Menu, String>((ref, menuKey) {
  return ref.watch(menuServiceProvider).watchMenu(menuKey);
});
