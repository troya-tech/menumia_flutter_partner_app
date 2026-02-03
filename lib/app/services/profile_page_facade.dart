import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import '../../features/restaurant-user-feature/application/restaurant_user_service.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant.dart';
import '../../features/restaurant-user-feature/infrastructure/repositories/firebase_restaurant_user_repository.dart';

class ProfilePageFacade {
  final RestaurantUserService _userService;
  
  // State
  final _currentUserController = StreamController<RestaurantUser?>.broadcast();
  final _relatedRestaurantsController = StreamController<List<Restaurant>>.broadcast();
  final _activeRestaurantIdController = StreamController<String?>.broadcast();

  // Streams
  Stream<RestaurantUser?> get currentUser$ => _currentUserController.stream;
  Stream<List<Restaurant>> get relatedRestaurants$ => _relatedRestaurantsController.stream;
  Stream<String?> get activeRestaurantId$ => _activeRestaurantIdController.stream;

  ProfilePageFacade({RestaurantUserService? userService})
      : _userService = userService ?? 
            RestaurantUserService(FirebaseRestaurantUserRepository());
  
  ProfilePageFacade.withDeps(this._userService);

  void init() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    const userId = "Kj8hLfo5jkb54HtJVXqpbQOJwuX2"; // 'fff' user from export

    final user = await _userService.getUserById(userId);
    if (user != null) {
      _currentUserController.add(user);
      _loadRestaurants(user.relatedRestaurantsIds);
    }
  }

  Future<void> _loadRestaurants(List<String> restaurantIds) async {
    final db = FirebaseDatabase.instance.ref('restaurants');
    final List<Restaurant> loadedRestaurants = [];

    for (var id in restaurantIds) {
      try {
        final snapshot = await db.child(id).get();
        if (snapshot.exists && snapshot.value != null) {
            final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
            loadedRestaurants.add(Restaurant(
                id: id,
                restaurantName: jsonMap['restaurantName'] ?? 'Unknown',
                menuKey: jsonMap['menuKey'] ?? '',
                openHour: jsonMap['openHour'] ?? '',
                closeHour: jsonMap['closeHour'] ?? '',
            ));
        }
      } catch (e) {
        print('Error loading restaurant $id: $e');
      }
    }
    
    _relatedRestaurantsController.add(loadedRestaurants);
  }

  void setActiveRestaurant(String restaurantId) {
    _activeRestaurantIdController.add(restaurantId);
  }

  void dispose() {
    _currentUserController.close();
    _relatedRestaurantsController.close();
    _activeRestaurantIdController.close();
  }
}
