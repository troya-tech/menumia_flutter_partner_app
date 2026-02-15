
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth-feature/application/auth_providers.dart';
export '../../features/auth-feature/application/auth_providers.dart';

import '../services/restaurant_context_service.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant-user-feature/application/restaurant_user_service.dart';
import '../../features/restaurant-user-feature/infrastructure/repositories/firebase_restaurant_user_repository.dart';
import '../../features/restaurant/domain/entities/restaurant.dart';
import '../../features/restaurant/application/restaurant_service.dart';
import '../../features/restaurant/infrastructure/repositories/firebase_restaurant_repository.dart';
import '../../features/shared-config-feature/application/shared_config_service.dart';
import '../../features/shared-config-feature/infrastructure/repositories/firebase_shared_config_repository.dart';
export '../../features/menu/application/menu_providers.dart';
import '../services/profile_page_facade.dart';


/// Note: menuServiceProvider and menuProvider are now imported from menu_providers.dart

/// Provider for the RestaurantContextService
final restaurantContextServiceProvider = Provider<RestaurantContextService>((ref) {
  return RestaurantContextService(
    authRepository: ref.watch(authRepositoryProvider),
    userService: RestaurantUserService(FirebaseRestaurantUserRepository()),
    restaurantService: RestaurantService(FirebaseRestaurantRepository()),
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

/// Provider for the SharedConfigService
final sharedConfigServiceProvider = Provider<SharedConfigService>((ref) {
  return SharedConfigService(FirebaseSharedConfigRepository());
});

/// StreamProvider that evaluates if ordering is enabled based on active menu key
final orderingEnabledProvider = StreamProvider<bool>((ref) {
  final menuKey = ref.watch(activeMenuKeyProvider).valueOrNull;
  if (menuKey == null) return Stream.value(false);
  
  return ref.watch(sharedConfigServiceProvider)
      .watchSharedConfig(menuKey)
      .map((config) => config.planTiersPlanner.orderingEnabled);
});

/// Provider for ProfilePageFacade
final profilePageFacadeProvider = Provider<ProfilePageFacade>((ref) {
  return ProfilePageFacade(ref.watch(restaurantContextServiceProvider));
});
