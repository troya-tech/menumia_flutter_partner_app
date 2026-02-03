import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import '../../features/restaurant-user-feature/application/restaurant_user_service.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant.dart';
import '../../features/restaurant-user-feature/infrastructure/repositories/firebase_restaurant_user_repository.dart';
import '../../utils/app_logger.dart';

class ProfilePageFacade {
  final RestaurantUserService _userService;
  
  // Logger
  static final _logger = AppLogger('ProfilePageFacade');
  
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
    _logger.debug('Loading user data...');
    
    // Get the currently authenticated user's UID
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      _logger.warning('No authenticated user found');
      return;
    }
    
    final userId = currentUser.uid;
    _logger.data('User UID', userId);

    final user = await _userService.getUserById(userId);
    if (user != null) {
      _logger.success('User data loaded successfully');
      _logger.data('User display name', user.displayName);
      _logger.data('Related restaurants', user.relatedRestaurantsIds.length);
      
      _currentUserController.add(user);
      _loadRestaurants(user.relatedRestaurantsIds);
    } else {
      _logger.error('User not found in database for UID: $userId');
    }
  }

  Future<void> _loadRestaurants(List<String> restaurantIds) async {
    _logger.debug('Loading ${restaurantIds.length} restaurant(s)...');
    
    final db = FirebaseDatabase.instance.ref('restaurants');
    final List<Restaurant> loadedRestaurants = [];

    for (var id in restaurantIds) {
      try {
        final snapshot = await db.child(id).get();
        if (snapshot.exists && snapshot.value != null) {
            final jsonMap = jsonDecode(jsonEncode(snapshot.value)) as Map<String, dynamic>;
            final restaurant = Restaurant(
                id: id,
                restaurantName: jsonMap['restaurantName'] ?? 'Unknown',
                menuKey: jsonMap['menuKey'] ?? '',
                openHour: jsonMap['openHour'] ?? '',
                closeHour: jsonMap['closeHour'] ?? '',
            );
            loadedRestaurants.add(restaurant);
            _logger.data('Loaded restaurant', restaurant.restaurantName);
        }
      } catch (e) {
        _logger.error('Error loading restaurant $id', e);
      }
    }
    
    _logger.success('Loaded ${loadedRestaurants.length} restaurant(s)');
    _relatedRestaurantsController.add(loadedRestaurants);
  }

  void setActiveRestaurant(String restaurantId) {
    _logger.info('Setting active restaurant: $restaurantId');
    _activeRestaurantIdController.add(restaurantId);
  }

  void dispose() {
    _currentUserController.close();
    _relatedRestaurantsController.close();
    _activeRestaurantIdController.close();
  }
}
