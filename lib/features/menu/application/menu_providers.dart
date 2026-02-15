import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/menu.dart';
import '../domain/repositories/menu_repository.dart';
import '../infrastructure/repositories/firebase_menu_repository.dart';
import 'services/menu_service.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';


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
  final logger = AppLogger('menuProvider');
  final context = logger.createContext();
  logger.debug('Initializing menuProvider for key: $menuKey', context);
  return ref.watch(menuServiceProvider).watchMenu(menuKey, context);
});

