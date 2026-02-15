import '../../domain/entities/restaurant_user.dart';
import '../../domain/repositories/restaurant_user_repository.dart';
import '../../../../testing/restaurant_users_fixtures.dart';

class FakeRestaurantUserRepository implements RestaurantUserRepository {
  @override
  Future<RestaurantUser?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return RestaurantUsersFixtures.all.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RestaurantUser?> getUserByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return RestaurantUsersFixtures.all.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return RestaurantUsersFixtures.all
        .where((u) => u.relatedRestaurantsIds.contains(restaurantId))
        .toList();
  }

  @override
  Future<String> createUser(RestaurantUser user) async {
    return 'fake-new-user-id';
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {}

  @override
  Future<void> deleteUser(String id) async {}

  @override
  Future<List<RestaurantUser>> getAllUsers() async {
    return RestaurantUsersFixtures.all;
  }
}
