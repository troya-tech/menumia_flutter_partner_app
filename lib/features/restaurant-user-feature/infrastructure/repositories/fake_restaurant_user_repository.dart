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
  Future<RestaurantUser?> getUserById(String id) async {
    _logger.debug('Getting user by ID: $id');
    await Future.delayed(const Duration(milliseconds: 100));
    return _storeController.value[id];
  }


  @override
  Future<RestaurantUser?> getUserByEmail(String email) async {
    _logger.debug('Getting user by email: $email');
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _storeController.value.values.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }


  @override
  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId) async {
    _logger.debug('Getting users by restaurant ID: $restaurantId');
    await Future.delayed(const Duration(milliseconds: 100));
    return _storeController.value.values
        .where((u) => u.relatedRestaurantsIds.contains(restaurantId))
        .toList();
  }


  @override
  Future<String> createUser(RestaurantUser user) async {
    _logger.info('Creating new fake user: ${user.email}');
    final newId = 'fake-user-${DateTime.now().millisecondsSinceEpoch}';
    final newUser = user.copyWith(id: newId);
    
    final newStore = Map<String, RestaurantUser>.from(_storeController.value);
    newStore[newId] = newUser;
    _storeController.add(newStore);
    
    _logger.success('Fake user created with ID: $newId');
    return newId;
  }


  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    final store = _storeController.value;
    final user = store[id];
    if (user != null) {
      _logger.info('Updating fake user: $id');
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
      _logger.success('Fake user $id updated');
    } else {
      _logger.warning('Failed to update fake user: $id not found');
    }
  }


  @override
  Future<void> deleteUser(String id) async {
    _logger.warning('Deleting fake user: $id');
    final newStore = Map<String, RestaurantUser>.from(_storeController.value);
    newStore.remove(id);
    _storeController.add(newStore);
    _logger.success('Fake user $id deleted');
  }


  @override
  Future<List<RestaurantUser>> getAllUsers() async {
    _logger.debug('Getting all fake users');
    return _storeController.value.values.toList();
  }


  @override
  Stream<RestaurantUser?> watchUserById(String id) {
    _logger.debug('Watching user by ID: $id');
    return _storeController.stream.map((store) => store[id]);
  }

  @override
  Stream<RestaurantUser?> watchUserByEmail(String email) {
    _logger.debug('Watching user by email: $email');
    return _storeController.stream.map((store) {

      try {
        return store.values.firstWhere((u) => u.email == email);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Stream<List<RestaurantUser>> watchUsersByRestaurantId(String restaurantId) {
    _logger.debug('Watching users by restaurant ID: $restaurantId');
    return _storeController.stream.map((store) {
      return store.values
          .where((u) => u.relatedRestaurantsIds.contains(restaurantId))
          .toList();
    });
  }


  @override
  Stream<List<RestaurantUser>> watchAllUsers() {
    _logger.debug('Watching all fake users');
    return _storeController.stream.map((store) => store.values.toList());
  }

}
