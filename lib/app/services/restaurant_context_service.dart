import 'dart:async';
import 'package:collection/collection.dart'; // for firstOrNull

import '../../services/auth_service.dart';
import '../../features/restaurant-user-feature/application/restaurant_user_service.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant-user-feature/infrastructure/repositories/firebase_restaurant_user_repository.dart';
import '../../features/restaurant/application/restaurant_service.dart';
import '../../features/restaurant/domain/entities/restaurant.dart';
import '../../features/restaurant/infrastructure/repositories/firebase_restaurant_repository.dart';

import '../../utils/app_logger.dart';

class RestaurantContextService {
  static final RestaurantContextService _instance = RestaurantContextService._internal();
  static RestaurantContextService get instance => _instance;

  final RestaurantUserService _userService;
  final RestaurantService _restaurantService;
  static final _logger = AppLogger('RestaurantContextService');

  // State Controllers
  final _currentUserController = StreamController<RestaurantUser?>.broadcast();
  final _relatedRestaurantsController = StreamController<List<Restaurant>>.broadcast();
  final _activeRestaurantIdController = StreamController<String?>.broadcast();
  final _activeMenuKeyController = StreamController<String?>.broadcast();

  // Streams
  Stream<RestaurantUser?> get currentUser$ => _currentUserController.stream;
  Stream<List<Restaurant>> get relatedRestaurants$ => _relatedRestaurantsController.stream;
  Stream<String?> get activeRestaurantId$ => _activeRestaurantIdController.stream;
  Stream<String?> get activeMenuKey$ => _activeMenuKeyController.stream;

  // Internal State
  List<Restaurant> _loadedRestaurants = [];
  String? _currentActiveId;
  RestaurantUser? _currentUser;

  RestaurantContextService._internal()
      : _userService = RestaurantUserService(FirebaseRestaurantUserRepository()),
        _restaurantService = RestaurantService(FirebaseRestaurantRepository()) {
    // Listen for auth state changes to automatically clear state on sign-out
    AuthService.instance.authStateChanges().listen((user) {
      if (user == null) {
        _clearState();
      }
    });
  }

  /// Clear all internal state and emit empty/null values to streams
  void _clearState() {
    _logger.info('Clearing state due to user sign-out');
    _currentUser = null;
    _loadedRestaurants = [];
    _currentActiveId = null;
    _initFuture = null; // Important: Clear the init future so next init() runs fresh

    // Emit cleared state to all listeners
    _currentUserController.add(null);
    _relatedRestaurantsController.add([]);
    _activeRestaurantIdController.add(null);
    _activeMenuKeyController.add(null);
  }

  // Completion future for init
  Future<void>? _initFuture;

  /// Initialize and load data
  Future<void> init() async {
    // If already initialized (must have user), just emit current state
    if (_currentUser != null) {
      _emitCurrentState();
      return;
    }

    // If initialization is in progress, wait for it
    if (_initFuture != null) {
      await _initFuture;
      _emitCurrentState();
      return;
    }

    // Start initialization
    _initFuture = _loadUser();
    await _initFuture;
    _initFuture = null; // Clear future when done (optional, but cleaner)
  }

  void _emitCurrentState() {
     // Emit everything current for late subscribers (since we use broadcast)
     
     if (_currentUser != null) {
       _currentUserController.add(_currentUser);
     }
     if (_loadedRestaurants.isNotEmpty) {
       _relatedRestaurantsController.add(_loadedRestaurants);
     }
     if (_currentActiveId != null) {
       _activeRestaurantIdController.add(_currentActiveId);
       final r = _loadedRestaurants.firstWhereOrNull((r) => r.id == _currentActiveId);
       if (r != null) _activeMenuKeyController.add(r.menuKey);
     }
  }

  Future<void> _loadUser() async {
    _logger.debug('Loading user data...');
    final currentUser = AuthService.instance.currentUser;

    if (currentUser == null) {
      _logger.warning('No authenticated user found');
      _currentUserController.add(null);
      return;
    }

    final userEmail = currentUser.email;
    if (userEmail == null) {
      _logger.error('Authenticated user has no email address');
      _currentUserController.add(null);
      return;
    }

    final user = await _userService.getUserByEmail(userEmail);
    if (user != null) {
      _logger.success('User data loaded successfully: ${user.displayName}');
      _currentUser = user; // SAVE STATE
      _currentUserController.add(user);
      await _loadRestaurants(user.relatedRestaurantsIds);
    } else {
      _logger.error('User not found in database with email: $userEmail');
      _currentUserController.add(null);
    }
  }

  Future<void> _loadRestaurants(List<String> restaurantIds) async {
    _logger.debug('Loading ${restaurantIds.length} restaurant(s)...');
    
    _loadedRestaurants = await _restaurantService.getRestaurantsByIds(restaurantIds);

    _logger.success('Loaded ${_loadedRestaurants.length} restaurant(s) via RestaurantService');
    _relatedRestaurantsController.add(_loadedRestaurants);

    // Default to first restaurant if none active
    if (_loadedRestaurants.isNotEmpty && _currentActiveId == null) {
       setActiveRestaurant(_loadedRestaurants.first.id);
    }
  }

  void setActiveRestaurant(String restaurantId) {
    if (_currentActiveId == restaurantId) return;

    final restaurant = _loadedRestaurants.firstWhereOrNull((r) => r.id == restaurantId);
    if (restaurant != null) {
      _currentActiveId = restaurantId;
      _activeRestaurantIdController.add(restaurantId);
      _activeMenuKeyController.add(restaurant.menuKey);
      _logger.info('Set active restaurant: ${restaurant.restaurantName} (${restaurant.menuKey})');
    } else {
      _logger.warning('Attempted to set active restaurant $restaurantId but it was not found in loaded restaurants');
    }
  }
}
