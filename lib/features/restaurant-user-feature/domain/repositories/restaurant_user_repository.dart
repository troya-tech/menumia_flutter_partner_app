import 'package:menumia_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';

abstract class RestaurantUserRepository {
  Future<RestaurantUser?> getUserById(String id);
  Future<RestaurantUser?> getUserByEmail(String email);
  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId);
  Future<String> createUser(RestaurantUser user);
  Future<void> updateUser(String id, Map<String, dynamic> data);
  Future<void> deleteUser(String id);
  Future<List<RestaurantUser>> getAllUsers();
}
