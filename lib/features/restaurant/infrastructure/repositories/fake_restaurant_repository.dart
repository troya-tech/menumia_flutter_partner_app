import 'package:rxdart/rxdart.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../../../../testing/restaurants_fixtures.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';


class FakeRestaurantRepository implements RestaurantRepository {
  static final _logger = AppLogger('FakeRestaurantRepository');

  static final Map<String, Restaurant> _cache = {
    for (var r in RestaurantsFixtures.all) r.id: r
  };
  
  static final _storeController = BehaviorSubject<Map<String, Restaurant>>.seeded(_cache);

  @override
  Future<Restaurant?> getRestaurantById(String id, [LogContext? context]) async {
    _logger.debug('Getting restaurant by ID: $id', context);
    await Future.delayed(const Duration(milliseconds: 100));
    return _storeController.value[id]?.copyWith(context: context);
  }



  @override
  Future<List<Restaurant>> getRestaurantsByIds(List<String> ids, [LogContext? context]) async {
    _logger.debug('Getting restaurants by IDs: $ids', context);
    await Future.delayed(const Duration(milliseconds: 100));
    final store = _storeController.value;
    return ids.map((id) => store[id]?.copyWith(context: context)).whereType<Restaurant>().toList();
  }



  @override
  Stream<Restaurant?> watchRestaurant(String id, [LogContext? context]) {
    _logger.debug('Watching restaurant: $id', context);
    return _storeController.stream.map((store) => store[id]?.copyWith(context: context));
  }



  @override
  Stream<List<Restaurant>> watchRestaurantsByIds(List<String> ids, [LogContext? context]) {
    _logger.debug('Watching restaurants by IDs: $ids', context);
    return _storeController.stream.map((store) {
      return ids.map((id) => store[id]?.copyWith(context: context)).whereType<Restaurant>().toList();
    });
  }


}
