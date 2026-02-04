import '../entities/restaurant.dart';

abstract class RestaurantRepository {
  Future<Restaurant?> getRestaurantById(String id);
  Future<List<Restaurant>> getRestaurantsByIds(List<String> ids);
}
