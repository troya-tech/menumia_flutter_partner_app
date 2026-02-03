import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/repositories/restaurant_user_repository.dart';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/infrastructure/dtos/restaurant_user_dto.dart';

class FirebaseRestaurantUserRepository implements RestaurantUserRepository {
  final FirebaseDatabase _database;
  final String _basePath = 'restaurantUsers';

  FirebaseRestaurantUserRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Future<RestaurantUser?> getUserById(String id) async {
    final snapshot = await _database.ref('$_basePath/$id').get();
    if (!snapshot.exists || snapshot.value == null) return null;

    try {
      final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
      return RestaurantUserDto.fromJson(jsonMap, id).toDomain();
    } catch (e) {
      print('Error parsing restaurant user $id: $e');
      return null;
    }
  }

  @override
  Future<RestaurantUser?> getUserByEmail(String email) async {
    // Query by email - requires indexing in Firebase rules for performance
    final snapshot = await _database
        .ref(_basePath)
        .orderByChild('email')
        .equalTo(email)
        .limitToFirst(1)
        .get();

    if (!snapshot.exists || snapshot.value == null) return null;

    try {
      final data = snapshot.value as Map<dynamic, dynamic>;
      final key = data.keys.first.toString();
      final jsonMap = jsonDecode(jsonEncode(data[key])) as Map<String, dynamic>;
      return RestaurantUserDto.fromJson(jsonMap, key).toDomain();
    } catch (e) {
      print('Error querying restaurant user by email $email: $e');
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
}
