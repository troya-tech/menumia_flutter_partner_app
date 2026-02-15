import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

abstract class RestaurantUserRepository {
  Future<RestaurantUser?> getUserById(String id, [LogContext? context]);
  Future<RestaurantUser?> getUserByEmail(String email, [LogContext? context]);
  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId, [LogContext? context]);
  Future<String> createUser(RestaurantUser user, [LogContext? context]);
  Future<void> updateUser(String id, Map<String, dynamic> data, [LogContext? context]);
  Future<void> deleteUser(String id, [LogContext? context]);
  Future<List<RestaurantUser>> getAllUsers([LogContext? context]);

  Stream<RestaurantUser?> watchUserById(String id, [LogContext? context]);
  Stream<RestaurantUser?> watchUserByEmail(String email, [LogContext? context]);
  Stream<List<RestaurantUser>> watchUsersByRestaurantId(String restaurantId, [LogContext? context]);
  Stream<List<RestaurantUser>> watchAllUsers([LogContext? context]);
}

