import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'services/restaurant_context_service.dart';
import '../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../features/restaurant/domain/entities/restaurant.dart';
import '../features/shared-config-feature/application/shared_config_service.dart';
import '../features/shared-config-feature/infrastructure/repositories/firebase_shared_config_repository.dart';
import '../features/menu/application/services/menu_service.dart';
import '../features/menu/infrastructure/repositories/firebase_menu_repository.dart';
import '../features/menu/domain/entities/menu.dart';
import 'services/profile_page_facade.dart';

/// Provider for the AuthService singleton
final authServiceProvider = Provider<AuthService>((ref) => AuthService.instance);

/// Provider for the MenuService
final menuServiceProvider = Provider<MenuService>((ref) {
  return MenuService(FirebaseMenuRepository());
});

/// StreamProvider for a specific menu
final menuProvider = StreamProvider.family<Menu, String>((ref, menuKey) {
  return ref.watch(menuServiceProvider).watchMenu(menuKey);
});

/// StreamProvider for the authentication state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges();
});

/// Provider for the RestaurantContextService singleton
final restaurantContextServiceProvider = Provider<RestaurantContextService>((ref) {
  return RestaurantContextService.instance;
});

/// StreamProvider for the current restaurant user
final currentUserProvider = StreamProvider<RestaurantUser?>((ref) {
  return ref.watch(restaurantContextServiceProvider).currentUser$;
});

/// StreamProvider for the list of related restaurants
final relatedRestaurantsProvider = StreamProvider<List<Restaurant>>((ref) {
  return ref.watch(restaurantContextServiceProvider).relatedRestaurants$;
});

/// StreamProvider for the active restaurant ID
final activeRestaurantIdProvider = StreamProvider<String?>((ref) {
  return ref.watch(restaurantContextServiceProvider).activeRestaurantId$;
});

/// StreamProvider for the active menu key
final activeMenuKeyProvider = StreamProvider<String?>((ref) {
  return ref.watch(restaurantContextServiceProvider).activeMenuKey$;
});

/// Provider for the SharedConfigService
final sharedConfigServiceProvider = Provider<SharedConfigService>((ref) {
  return SharedConfigService(FirebaseSharedConfigRepository());
});

/// StreamProvider that evaluates if ordering is enabled based on active menu key
final orderingEnabledProvider = StreamProvider<bool>((ref) {
  final menuKey = ref.watch(activeMenuKeyProvider).asData?.value;
  if (menuKey == null) return Stream.value(false);
  
  return ref.watch(sharedConfigServiceProvider)
      .watchSharedConfig(menuKey)
      .map((config) => config.planTiersPlanner.orderingEnabled);
});

/// Provider for ProfilePageFacade (stateless wrapper)
final profilePageFacadeProvider = Provider<ProfilePageFacade>((ref) {
  return ProfilePageFacade();
});
