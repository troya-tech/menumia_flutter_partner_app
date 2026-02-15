import 'package:menumia_flutter_partner_app/utils/app_logger.dart';
import '../entities/restaurant.dart';

abstract class RestaurantRepository {
  Future<Restaurant?> getRestaurantById(String id, [LogContext? context]);
  Future<List<Restaurant>> getRestaurantsByIds(List<String> ids, [LogContext? context]);
  
  Stream<Restaurant?> watchRestaurant(String id, [LogContext? context]);
  Stream<List<Restaurant>> watchRestaurantsByIds(List<String> ids, [LogContext? context]);
}

