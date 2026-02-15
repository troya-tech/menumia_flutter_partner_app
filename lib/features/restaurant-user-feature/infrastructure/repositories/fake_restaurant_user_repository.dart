import 'package:rxdart/rxdart.dart';
import '../../domain/entities/restaurant_user.dart';
import '../../domain/repositories/restaurant_user_repository.dart';
import '../../../../testing/restaurant_users_fixtures.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';


class FakeRestaurantUserRepository implements RestaurantUserRepository {
  static final _logger = AppLogger('FakeRestaurantUserRepository');

  static final Map<String, RestaurantUser> _cache = {
    for (var u in RestaurantUsersFixtures.all) u.id: u
  };

  static final _storeController = BehaviorSubject<Map<String, RestaurantUser>>.seeded(_cache);

  @override
  Future<RestaurantUser?> getUserById(String id, [LogContext? context]) async {
    _logger.debug('Getting user by ID: $id', context);
    await Future.delayed(const Duration(milliseconds: 100));
    return _storeController.value[id]?.copyWith(context: context);
  }



  @override
  Future<RestaurantUser?> getUserByEmail(String email, [LogContext? context]) async {
    _logger.debug('Getting user by email: $email', context);
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _storeController.value.values.firstWhere((u) => u.email == email).copyWith(context: context);
    } catch (_) {
      return null;
    }
  }



  @override
  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId, [LogContext? context]) async {
    _logger.debug('Getting users by restaurant ID: $restaurantId', context);
    await Future.delayed(const Duration(milliseconds: 100));
    return _storeController.value.values
        .where((u) => u.relatedRestaurantsIds.contains(restaurantId))
        .map((u) => u.copyWith(context: context))
        .toList();
  }



  @override
  Future<String> createUser(RestaurantUser user, [LogContext? context]) async {
    _logger.info('Creating new fake user: ${user.email}', context);
    final newId = 'fake-user-${DateTime.now().millisecondsSinceEpoch}';
    final newUser = user.copyWith(id: newId);
    
    final newStore = Map<String, RestaurantUser>.from(_storeController.value);
    newStore[newId] = newUser;
    _storeController.add(newStore);
    
    _logger.success('Fake user created with ID: $newId', context);
    return newId;
  }


  @override
  Future<void> updateUser(String id, Map<String, dynamic> data, [LogContext? context]) async {
    final store = _storeController.value;
    final user = store[id];
    if (user != null) {
      _logger.info('Updating fake user: $id', context);
      final updatedUser = user.copyWith(
        displayName: data['displayName'] as String? ?? user.displayName,
        role: data['role'] as String? ?? user.role,
        isActive: data['isActive'] as bool? ?? user.isActive,
        relatedRestaurantsIds: data['relatedRestaurantsIds'] != null 
          ? List<String>.from(data['relatedRestaurantsIds'] as List) 
          : user.relatedRestaurantsIds,
      );
      
      final newStore = Map<String, RestaurantUser>.from(store);
      newStore[id] = updatedUser;
      _storeController.add(newStore);
      _logger.success('Fake user $id updated', context);
    } else {
      _logger.warning('Failed to update fake user: $id not found', context);
    }
  }


  @override
  Future<void> deleteUser(String id, [LogContext? context]) async {
    _logger.warning('Deleting fake user: $id', context);
    final newStore = Map<String, RestaurantUser>.from(_storeController.value);
    newStore.remove(id);
    _storeController.add(newStore);
    _logger.success('Fake user $id deleted', context);
  }


  @override
  Future<List<RestaurantUser>> getAllUsers([LogContext? context]) async {
    _logger.debug('Getting all fake users', context);
    return _storeController.value.values.map((u) => u.copyWith(context: context)).toList();
  }



  @override
  Stream<RestaurantUser?> watchUserById(String id, [LogContext? context]) {
    _logger.debug('Watching user by ID: $id', context);
    return _storeController.stream.map((store) => store[id]?.copyWith(context: context));
  }


  @override
  Stream<RestaurantUser?> watchUserByEmail(String email, [LogContext? context]) {
    _logger.debug('Watching user by email: $email', context);
    return _storeController.stream.map((store) {
      try {
        return store.values.firstWhere((u) => u.email == email).copyWith(context: context);
      } catch (_) {
        return null;
      }
    });
  }


  @override
  Stream<List<RestaurantUser>> watchUsersByRestaurantId(String restaurantId, [LogContext? context]) {
    _logger.debug('Watching users by restaurant ID: $restaurantId', context);
    return _storeController.stream.map((store) {
      return store.values
          .where((u) => u.relatedRestaurantsIds.contains(restaurantId))
          .map((u) => u.copyWith(context: context))
          .toList();
    });
  }



  @override
  Stream<List<RestaurantUser>> watchAllUsers([LogContext? context]) {
    _logger.debug('Watching all fake users', context);
    return _storeController.stream.map((store) => store.values.map((u) => u.copyWith(context: context)).toList());
  }


}
