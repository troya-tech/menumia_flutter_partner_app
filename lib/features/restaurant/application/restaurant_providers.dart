import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/restaurant_repository.dart';
import '../infrastructure/repositories/firebase_restaurant_repository.dart';
import 'restaurant_service.dart';

/// Provider for the RestaurantRepository
final restaurantRepositoryProvider = Provider<RestaurantRepository>((ref) {
  return FirebaseRestaurantRepository();
});

/// Provider for the RestaurantService
final restaurantServiceProvider = Provider<RestaurantService>((ref) {
  return RestaurantService(ref.watch(restaurantRepositoryProvider));
});
