import '../domain/entities/restaurant.dart';
import '../domain/repositories/restaurant_repository.dart';

class RestaurantService {
  final RestaurantRepository _repository;

  RestaurantService(this._repository);

  Future<Restaurant?> getRestaurantById(String id) {
    return _repository.getRestaurantById(id);
  }

  Future<List<Restaurant>> getRestaurantsByIds(List<String> ids) {
    return _repository.getRestaurantsByIds(ids);
  }
}
