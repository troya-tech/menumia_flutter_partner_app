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
  Future<RestaurantUser?> getUserById(String id, [LogContext? context]) async {
    _logger.debug('Fetching user by ID: $id', context);
    _logger.data('Database path', '$_basePath/$id', context);
    
    final snapshot = await _database.ref('$_basePath/$id').get();
    
    _logger.data('Snapshot exists', snapshot.exists, context);
    _logger.data('Snapshot value is null', snapshot.value == null, context);
    
    if (!snapshot.exists || snapshot.value == null) {
      _logger.warning('User not found in database at path: $_basePath/$id', context);
      return null;
    }

    try {
      _logger.debug('Parsing user data...', context);
      final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
      _logger.data('User JSON', jsonMap, context);
      
      final user = RestaurantUserDto.fromJson(jsonMap, id).toDomain(context);
      _logger.success('User loaded successfully', context);
      _logger.data('User display name', user.displayName, context);
      
      return user;

    } catch (e, stackTrace) {
      _logger.error('Error parsing restaurant user $id', e, stackTrace, context);
      return null;
    }
  }

  @override
  Future<RestaurantUser?> getUserByEmail(String email, [LogContext? context]) async {
    _logger.debug('Fetching user by email: $email', context);
    _logger.data('Query path', _basePath, context);
    
    // Query by email - requires indexing in Firebase rules for performance
    final snapshot = await _database
        .ref(_basePath)
        .orderByChild('email')
        .equalTo(email)
        .limitToFirst(1)
        .get();

    _logger.data('Snapshot exists', snapshot.exists, context);
    _logger.data('Snapshot value is null', snapshot.value == null, context);

    if (!snapshot.exists || snapshot.value == null) {
      _logger.warning('User not found in database with email: $email', context);
      _logger.info('Make sure the user exists in $_basePath with the email field set', context);
      return null;
    }

    try {
      _logger.debug('Parsing user data from email query...', context);
      final data = snapshot.value as Map<dynamic, dynamic>;
      final key = data.keys.first.toString();
      _logger.data('User ID (key)', key, context);
      
      final jsonMap = jsonDecode(jsonEncode(data[key])) as Map<String, dynamic>;
      _logger.data('User JSON', jsonMap, context);
      
      final user = RestaurantUserDto.fromJson(jsonMap, key).toDomain(context);
      _logger.success('User loaded successfully by email', context);
      _logger.data('User display name', user.displayName, context);
      
      return user;

    } catch (e, stackTrace) {
      _logger.error('Error querying restaurant user by email $email', e, stackTrace, context);
      return null;
    }
  }

  @override
  Future<List<RestaurantUser>> getUsersByRestaurantId(String restaurantId, [LogContext? context]) async {
    // This is tricky in simple RTDB structure without many-to-many index.
    // We might need to fetch all users and filter locally OR assuming there's an index.
    // Given the small scale likely initially, fetching all might work, but it's not scalable.
    // Alternatively, if there was an index like `restaurantUsersByRestaurant/{restaurantId}/{userId}: true`
    
    // For now, let's implement retrieving all and filtering client-side as a fallback,
    // assuming the dataset isn't huge yet. Ideally we should have a reverse index.
    
    final users = await getAllUsers(context);
    return users.where((user) => user.relatedRestaurantsIds.contains(restaurantId)).toList();
  }

  @override
  Future<String> createUser(RestaurantUser user, [LogContext? context]) async {
    _logger.info('Creating user in Firebase', context);
    final ref = _database.ref(_basePath).push();
    final data = RestaurantUserDto.toMap(user);
    // Don't overwrite the ID property if it was empty in the entity, usage implies new ID generation
    await ref.set(data);
    _logger.success('User created with key: ${ref.key}', context);
    return ref.key!;
  }

  @override
  Future<void> updateUser(String id, Map<String, dynamic> data, [LogContext? context]) async {
    _logger.info('Updating user $id in Firebase', context);
    await _database.ref('$_basePath/$id').update(data);
    _logger.success('User $id updated', context);
  }

  @override
  Future<void> deleteUser(String id, [LogContext? context]) async {
    _logger.warning('Deleting user $id from Firebase', context);
    await _database.ref('$_basePath/$id').remove();
    _logger.success('User $id deleted', context);
  }

  @override
  Future<List<RestaurantUser>> getAllUsers([LogContext? context]) async {
    _logger.debug('Fetching all users from Firebase', context);
    final snapshot = await _database.ref(_basePath).get();
    if (!snapshot.exists || snapshot.value == null) return [];

    final users = <RestaurantUser>[];
    try {
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
         final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
         users.add(RestaurantUserDto.fromJson(jsonMap, key.toString()).toDomain(context));
      });
      _logger.success('Fetched ${users.length} users', context);

    } catch (e, stack) {
      _logger.error('Error fetching all restaurant users', e, stack, context);
    }
    return users;
  }

  @override
  Stream<RestaurantUser?> watchUserById(String id, [LogContext? context]) {
    _logger.debug('Watching user by ID: $id', context);
    return _database.ref('$_basePath/$id').onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return null;
      try {
        final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
        return RestaurantUserDto.fromJson(jsonMap, id).toDomain(context);
      } catch (e) {
        _logger.error('Error parsing user $id from stream', e, null, context);

        return null;
      }
    });
  }

  @override
  Stream<RestaurantUser?> watchUserByEmail(String email, [LogContext? context]) {
    _logger.debug('Watching user by email: $email', context);
    return _database.ref(_basePath).orderByChild('email').equalTo(email).limitToFirst(1).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return null;
      try {
        final data = snapshot.value as Map<dynamic, dynamic>;
        final key = data.keys.first.toString();
        final jsonMap = jsonDecode(jsonEncode(data[key])) as Map<String, dynamic>;
        return RestaurantUserDto.fromJson(jsonMap, key).toDomain(context);
      } catch (e) {
        _logger.error('Error parsing user by email $email from stream', e, null, context);

        return null;
      }
    });
  }

  @override
  Stream<List<RestaurantUser>> watchUsersByRestaurantId(String restaurantId, [LogContext? context]) {
    _logger.debug('Watching users by restaurant ID: $restaurantId', context);
    // Note: Filtering client-side for now as in the Future implementation
    return watchAllUsers(context).map((users) =>
        users.where((u) => u.relatedRestaurantsIds.contains(restaurantId)).toList());
  }

  @override
  Stream<List<RestaurantUser>> watchAllUsers([LogContext? context]) {
    _logger.debug('Watching all users from Firebase', context);
    return _database.ref(_basePath).onValue.map((event) {
      final snapshot = event.snapshot;
      if (!snapshot.exists || snapshot.value == null) return [];
      
      final users = <RestaurantUser>[];
      try {
        final data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
          users.add(RestaurantUserDto.fromJson(jsonMap, key.toString()).toDomain(context));
        });
      } catch (e) {
        _logger.error('Error parsing all users from stream', e, null, context);

      }
      return users;
    });
  }
}
