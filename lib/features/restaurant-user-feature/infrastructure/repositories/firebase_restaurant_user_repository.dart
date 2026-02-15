import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/repositories/restaurant_user_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/infrastructure/dtos/restaurant_user_dto.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

class FirebaseRestaurantUserRepository implements RestaurantUserRepository {
  static final _logger = AppLogger('FirebaseRestaurantUserRepository');
  final FirebaseDatabase _database;
  final String _basePath = 'restaurantUsers';

  FirebaseRestaurantUserRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Future<RestaurantUser?> getUserById(String id) async {
    _logger.debug('Fetching user by ID: $id');
    _logger.data('Database path', '$_basePath/$id');
    
    final snapshot = await _database.ref('$_basePath/$id').get();
    
    _logger.data('Snapshot exists', snapshot.exists);
    _logger.data('Snapshot value is null', snapshot.value == null);
    
    if (!snapshot.exists || snapshot.value == null) {
      _logger.warning('User not found in database at path: $_basePath/$id');
      return null;
    }

    try {
      _logger.debug('Parsing user data...');
      final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
      _logger.data('User JSON', jsonMap);
      
      final user = RestaurantUserDto.fromJson(jsonMap, id).toDomain();
      _logger.success('User loaded successfully');
      _logger.data('User display name', user.displayName);
      
      return user;
    } catch (e, stackTrace) {
      _logger.error('Error parsing restaurant user $id', e, stackTrace);
      return null;
    }
  }

  @override
  Future<RestaurantUser?> getUserByEmail(String email) async {
    _logger.debug('Fetching user by email: $email');
    _logger.data('Query path', _basePath);
    
    // Query by email - requires indexing in Firebase rules for performance
    final snapshot = await _database
        .ref(_basePath)
        .orderByChild('email')
        .equalTo(email)
        .limitToFirst(1)
        .get();

    _logger.data('Snapshot exists', snapshot.exists);
    _logger.data('Snapshot value is null', snapshot.value == null);

    if (!snapshot.exists || snapshot.value == null) {
      _logger.warning('User not found in database with email: $email');
      _logger.info('Make sure the user exists in $_basePath with the email field set');
      return null;
    }

    try {
      _logger.debug('Parsing user data from email query...');
      final data = snapshot.value as Map<dynamic, dynamic>;
      final key = data.keys.first.toString();
      _logger.data('User ID (key)', key);
      
      final jsonMap = jsonDecode(jsonEncode(data[key])) as Map<String, dynamic>;
      _logger.data('User JSON', jsonMap);
      
      final user = RestaurantUserDto.fromJson(jsonMap, key).toDomain();
      _logger.success('User loaded successfully by email');
      _logger.data('User display name', user.displayName);
      
      return user;
    } catch (e, stackTrace) {
      _logger.error('Error querying restaurant user by email $email', e, stackTrace);
      return null;
    }
  }

  @override
  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId) async {
    // This is tricky in simple RTDB structure without many-to-many index.
    // We might need to fetch all users and filter locally OR assuming there's an index.
    // Given the small scale likely initially, fetching all might work, but it's not scalable.
    // Alternatively, if there was an index like `restaurantUsersByRestaurant/{restaurantId}/{userId}: true`
    
    // For now, let's implement retrieving all and filtering client-side as a fallback,
    // assuming the dataset isn't huge yet. Ideally we should have a reverse index.
    
    final users = await getAllUsers();
    return users.where((user) => user.relatedRestaurantsIds.contains(restaurantId)).toList();
  }

  @override
  Future<String> createUser(RestaurantUser user) async {
    final ref = _database.ref(_basePath).push();
    final data = RestaurantUserDto.toMap(user);
    // Don't overwrite the ID property if it was empty in the entity, usage implies new ID generation
    await ref.set(data);
    return ref.key!;
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _database.ref('$_basePath/$id').update(data);
  }

  @override
  Future<void> deleteUser(String id) async {
    await _database.ref('$_basePath/$id').remove();
  }

  @override
  Future<List<RestaurantUser>> getAllUsers() async {
    final snapshot = await _database.ref(_basePath).get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final users = <RestaurantUser>[];
    try {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
         final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
         users.add(RestaurantUserDto.fromJson(jsonMap, key.toString()).toDomain());
      });
    } catch (e) {
      print('Error fetching all restaurant users: $e');
    }
    return users;
  }

  @override
  Stream<RestaurantUser?> watchUserById(String id) {
    return _database.ref('$_basePath/$id').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return null;
      try {
        final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
        return RestaurantUserDto.fromJson(jsonMap, id).toDomain();
      } catch (e) {
        _logger.error('Error parsing user $id from stream', e);
        return null;
      }
    });
  }

  @override
  Stream<RestaurantUser?> watchUserByEmail(String email) {
    return _database.ref(_basePath).orderByChild('email').equalTo(email).limitToFirst(1).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return null;
      try {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final key = data.keys.first.toString();
        final jsonMap = jsonDecode(jsonEncode(data[key])) as Map<String, dynamic>;
        return RestaurantUserDto.fromJson(jsonMap, key).toDomain();
      } catch (e) {
        _logger.error('Error parsing user by email $email from stream', e);
        return null;
      }
    });
  }

  @override
  Stream<List<RestaurantUser>> watchUsersByRestaurantId(String restaurantId) {
    // Note: Filtering client-side for now as in the Future implementation
    return watchAllUsers().map((users) =>
        users.where((u) => u.relatedRestaurantsIds.contains(restaurantId)).toList());
  }

  @override
  Stream<List<RestaurantUser>> watchAllUsers() {
    return _database.ref(_basePath).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];
      
      final users = <RestaurantUser>[];
      try {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
          users.add(RestaurantUserDto.fromJson(jsonMap, key.toString()).toDomain());
        });
      } catch (e) {
        _logger.error('Error parsing all users from stream', e);
      }
      return users;
    });
  }
}
