
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth-feature/application/auth_providers.dart';
export '../../features/auth-feature/application/auth_providers.dart';

import '../services/restaurant_context_service.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant-user-feature/application/restaurant_user_providers.dart';
export '../../features/restaurant-user-feature/application/restaurant_user_providers.dart';
import '../../features/restaurant/domain/entities/restaurant.dart';
import '../../features/restaurant/application/restaurant_providers.dart';
export '../../features/restaurant/application/restaurant_providers.dart';
import '../../features/shared-config-feature/application/shared_config_providers.dart';
export '../../features/shared-config-feature/application/shared_config_providers.dart';
export '../../features/menu/application/menu_providers.dart';
import '../services/profile_page_facade.dart';
import '../../utils/app_logger.dart';



/// Note: menuServiceProvider and menuProvider are now imported from menu_providers.dart

/// Provider for the RestaurantContextService
final restaurantContextServiceProvider = Provider<RestaurantContextService>((ref) {
  return RestaurantContextService(
    authRepository: ref.watch(authRepositoryProvider),
    userService: ref.watch(restaurantUserServiceProvider),
    restaurantService: ref.watch(restaurantServiceProvider),
  );
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

/// Shared config providers are now exported from shared_config_providers.dart

/// StreamProvider that evaluates if ordering is enabled based on active menu key
final orderingEnabledProvider = StreamProvider<bool>((ref) {
  final menuKey = ref.watch(activeMenuKeyProvider).valueOrNull;
  if (menuKey == null) return Stream.value(false);
  
  final logger = AppLogger('orderingEnabledProvider');
  final logCtx = logger.createContext();
  logger.debug('Watching shared config for menuKey: $menuKey', logCtx);

  return ref.watch(sharedConfigServiceProvider)
      .watchSharedConfig(menuKey, logCtx)
      .map((config) => config.planTiersPlanner.orderingEnabled);
});


/// Provider for ProfilePageFacade
final profilePageFacadeProvider = Provider<ProfilePageFacade>((ref) {
  return ProfilePageFacade(ref.watch(restaurantContextServiceProvider));
});
