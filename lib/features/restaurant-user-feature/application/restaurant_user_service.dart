import 'package:menumia_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_partner_app/features/restaurant-user-feature/domain/repositories/restaurant_user_repository.dart';

class RestaurantUserService {
  final RestaurantUserRepository _repository;

  RestaurantUserService(this._repository);

  Future<RestaurantUser?> getUserById(String id) => _repository.getUserById(id);

  Future<RestaurantUser?> getUserByEmail(String email) => _repository.getUserByEmail(email);

  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId) => 
      _repository.getUsersByRestaurantId(restaurantId);

  Future<String> createUser(RestaurantUser user) => _repository.createUser(user);

  Future<void> updateUser(String id, RestaurantUser user) => 
      _repository.updateUser(id, {
        'displayName': user.displayName,
        'relatedRestaurantsIds': user.relatedRestaurantsIds,
        'role': user.role,
        'isActive': user.isActive,
        'updatedAt': DateTime.now().toIso8601String(),
         // Email is typically not updated here or requires separate auth flow handling
      });

  Future<void> deleteUser(String id) => _repository.deleteUser(id);

  Future<List<RestaurantUser>> getAllUsers() => _repository.getAllUsers();
}
