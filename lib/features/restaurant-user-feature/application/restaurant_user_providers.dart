import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/restaurant_user_repository.dart';
import '../infrastructure/repositories/firebase_restaurant_user_repository.dart';
import 'restaurant_user_service.dart';

/// Provider for the RestaurantUserRepository
final restaurantUserRepositoryProvider = Provider<RestaurantUserRepository>((ref) {
  return FirebaseRestaurantUserRepository();
});

/// Provider for the RestaurantUserService
final restaurantUserServiceProvider = Provider<RestaurantUserService>((ref) {
  return RestaurantUserService(ref.watch(restaurantUserRepositoryProvider));
});
