import 'package:menumia_flutter_partner_app/utils/app_logger.dart';
import '../domain/entities/restaurant.dart';
import '../domain/repositories/restaurant_repository.dart';

class RestaurantService {
  final RestaurantRepository _repository;

  RestaurantService(this._repository);

  Future<Restaurant?> getRestaurantById(String id, [LogContext? context]) {
    return _repository.getRestaurantById(id, context);
  }

  Future<List<Restaurant>> getRestaurantsByIds(List<String> ids, [LogContext? context]) {
    return _repository.getRestaurantsByIds(ids, context);
  }

  Stream<Restaurant?> watchRestaurant(String id, [LogContext? context]) {
    return _repository.watchRestaurant(id, context);
  }

  Stream<List<Restaurant>> watchRestaurantsByIds(List<String> ids, [LogContext? context]) {
    return _repository.watchRestaurantsByIds(ids, context);
  }
}

