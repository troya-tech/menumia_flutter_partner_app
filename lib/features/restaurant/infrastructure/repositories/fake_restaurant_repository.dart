import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../../../../testing/restaurants_fixtures.dart';

class FakeRestaurantRepository implements RestaurantRepository {
  @override
  Future<Restaurant?> getRestaurantById(String id) async {
    // Artificial delay to simulate network
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return RestaurantsFixtures.all.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Restaurant>> getRestaurantsByIds(List<String> ids) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return RestaurantsFixtures.all.where((r) => ids.contains(r.id)).toList();
  }
}
