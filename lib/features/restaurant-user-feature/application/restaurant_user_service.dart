import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/repositories/restaurant_user_repository.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

class RestaurantUserService {
  final RestaurantUserRepository _repository;

  RestaurantUserService(this._repository);

  Future<RestaurantUser?> getUserById(String id, [LogContext? context]) => _repository.getUserById(id, context);

  Future<RestaurantUser?> getUserByEmail(String email, [LogContext? context]) => _repository.getUserByEmail(email, context);

  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId, [LogContext? context]) => 
      _repository.getUsersByRestaurantId(restaurantId, context);

  Future<String> createUser(RestaurantUser user, [LogContext? context]) => _repository.createUser(user, context);

  Future<void> updateUser(String id, RestaurantUser user, [LogContext? context]) => 
      _repository.updateUser(id, {
        'displayName': user.displayName,
        'relatedRestaurantsIds': user.relatedRestaurantsIds,
        'role': user.role,
        'isActive': user.isActive,
        'updatedAt': DateTime.now().toIso8601String(),
         // Email is typically not updated here or requires separate auth flow handling
      }, context);

  Future<void> deleteUser(String id, [LogContext? context]) => _repository.deleteUser(id, context);

  Future<List<RestaurantUser>> getAllUsers([LogContext? context]) => _repository.getAllUsers(context);

  Stream<RestaurantUser?> watchUserById(String id, [LogContext? context]) => _repository.watchUserById(id, context);
  Stream<RestaurantUser?> watchUserByEmail(String email, [LogContext? context]) => _repository.watchUserByEmail(email, context);
  Stream<List<RestaurantUser>> watchUsersByRestaurantId(String restaurantId, [LogContext? context]) => 
      _repository.watchUsersByRestaurantId(restaurantId, context);
  Stream<List<RestaurantUser>> watchAllUsers([LogContext? context]) => _repository.watchAllUsers(context);
}

