import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import 'package:rxdart/rxdart.dart';
import '../dtos/restaurant_dto.dart';
import '../../../../utils/app_logger.dart';

class FirebaseRestaurantRepository implements RestaurantRepository {
  final FirebaseDatabase _database;
  static final _logger = AppLogger('FirebaseRestaurantRepository');

  FirebaseRestaurantRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Future<Restaurant?> getRestaurantById(String id) async {
    try {
      final snapshot = await _database.ref('restaurants/$id').get();
      if (snapshot.exists && snapshot.value != null) {
        final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
        return RestaurantDto.fromJson(jsonMap, id).toDomain();
      }
    } catch (e, stack) {
      _logger.error('Error fetching restaurant $id', e, stack);
    }
    return null;
  }

  @override
  Future<List<Restaurant>> getRestaurantsByIds(List<String> ids) async {
    final List<Restaurant> restaurants = [];
    for (var id in ids) {
      final restaurant = await getRestaurantById(id);
      if (restaurant != null) {
        restaurants.add(restaurant);
      }
    }
    return restaurants;
  }

  @override
  Stream<Restaurant?> watchRestaurant(String id) {
    return _database.ref('restaurants/$id').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return null;
      try {
        final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
        return RestaurantDto.fromJson(jsonMap, id).toDomain();
      } catch (e) {
        _logger.error('Error parsing restaurant $id from stream', e);
        return null;
      }
    });
  }

  @override
  Stream<List<Restaurant>> watchRestaurantsByIds(List<String> ids) {
    // This combines multiple streams into one.
    // If any restaurant updates, the entire list emits.
    final streams = ids.map((id) => watchRestaurant(id)).toList();
    
    // Use Rx.combineLatestList (need rxdart)
    // Actually, simple StreamGroup or rxdart's CombineLatestStream
    return CombineLatestStream.list<Restaurant?>(streams)
        .map((list) => list.whereType<Restaurant>().toList());
  }
}
