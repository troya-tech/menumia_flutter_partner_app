import 'dart:async';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_repository.dart';
import '../../features/restaurant-user-feature/application/restaurant_user_service.dart';
import '../../features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import '../../features/restaurant/application/restaurant_service.dart';
import '../../features/restaurant/domain/entities/restaurant.dart';
import '../../utils/app_logger.dart';

class RestaurantContextService {
  final RestaurantUserService _userService;
  final RestaurantService _restaurantService;
  final AuthRepository _authRepository;
  static final _logger = AppLogger('RestaurantContextService');

  // State Controllers
  final _currentUserController = BehaviorSubject<RestaurantUser?>.seeded(null);
  final _relatedRestaurantsController = BehaviorSubject<List<Restaurant>>.seeded([]);
  final _activeRestaurantIdController = BehaviorSubject<String?>.seeded(null);
  final _activeMenuKeyController = BehaviorSubject<String?>.seeded(null);


  // Streams
  Stream<RestaurantUser?> get currentUser$ => _currentUserController.stream;
  Stream<List<Restaurant>> get relatedRestaurants$ => _relatedRestaurantsController.stream;
  Stream<String?> get activeRestaurantId$ => _activeRestaurantIdController.stream;
  Stream<String?> get activeMenuKey$ => _activeMenuKeyController.stream;

  // Subscriptions
  StreamSubscription? _userSub;
  StreamSubscription? _restaurantsSub;

  RestaurantContextService({
    required AuthRepository authRepository,
    required RestaurantUserService userService,
    required RestaurantService restaurantService,
  })  : _authRepository = authRepository,
        _userService = userService,
        _restaurantService = restaurantService {
    _initAuthListener();
  }

  void _initAuthListener() {
    _authRepository.authStateChanges().listen((authUser) {
      _userSub?.cancel();
      _restaurantsSub?.cancel();

      if (authUser == null) {
        _clearState();
      } else {
        final email = authUser.email;
        if (email != null) {
          final logCtx = _logger.createContext();
          _logger.info('User signed in: $email. Starting trace.', logCtx);
          _userSub = _userService.watchUserByEmail(email, logCtx).listen((user) {
            _currentUserController.add(user);
            if (user != null) {
              _syncRestaurants(user.relatedRestaurantsIds, logCtx);
            }
          });
        }
      }
    });
  }

  void _syncRestaurants(List<String> restaurantIds, [LogContext? context]) {
    _restaurantsSub?.cancel();
    _restaurantsSub = _restaurantService.watchRestaurantsByIds(restaurantIds, context).listen((restaurants) {
      _relatedRestaurantsController.add(restaurants);
      
      // Update active restaurant if needed
      final currentActiveId = _activeRestaurantIdController.value;
      if (currentActiveId == null && restaurants.isNotEmpty) {
        setActiveRestaurant(restaurants.first.id, context);
      } else if (currentActiveId != null) {
        // Update menu key if restaurant data changed
        final r = restaurants.firstWhereOrNull((r) => r.id == currentActiveId);
        if (r != null) {
          _activeMenuKeyController.add(r.menuKey);
        }
      }
    });
  }

  void _clearState() {
    _logger.info('Clearing state');
    _currentUserController.add(null);
    _relatedRestaurantsController.add([]);
    _activeRestaurantIdController.add(null);
    _activeMenuKeyController.add(null);
  }

  /// Compatibility method for existing calls
  Future<void> init() async {
    // With BehaviorSubject and reactive listeners, explicit init is less critical
    // but we can wait for the first user emission if needed.
    if (_currentUserController.value != null) return;
    
    // Pulse the auth stream if needed? No, it should be automatic.
    await _currentUserController.firstWhere((u) => u != null).timeout(
      const Duration(seconds: 5),
      onTimeout: () => null,
    );
  }

  void setActiveRestaurant(String restaurantId, [LogContext? context]) {
    if (_activeRestaurantIdController.value == restaurantId) return;

    final restaurant = _relatedRestaurantsController.value.firstWhereOrNull((r) => r.id == restaurantId);
    if (restaurant != null) {
      _activeRestaurantIdController.add(restaurantId);
      _activeMenuKeyController.add(restaurant.menuKey);
      _logger.info('Set active restaurant: ${restaurant.restaurantName}', context);
    }
  }

  void dispose() {
    _userSub?.cancel();
    _restaurantsSub?.cancel();
    _currentUserController.close();
    _relatedRestaurantsController.close();
    _activeRestaurantIdController.close();
    _activeMenuKeyController.close();
  }
}
