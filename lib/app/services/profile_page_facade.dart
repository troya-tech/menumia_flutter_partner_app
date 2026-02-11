import 'dart:async';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';
import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';

class ProfilePageFacade {
  final RestaurantContextService _contextService;

  ProfilePageFacade(this._contextService);

  // Streams forwarded from RestaurantContextService
  Stream<RestaurantUser?> get currentUser$ => _contextService.currentUser$;
  Stream<List<Restaurant>> get relatedRestaurants$ => _contextService.relatedRestaurants$;
  Stream<String?> get activeRestaurantId$ => _contextService.activeRestaurantId$;

  void init() {
    _contextService.init();
  }
  
  void setActiveRestaurant(String restaurantId) {
    _contextService.setActiveRestaurant(restaurantId);
  }

  void dispose() {
    // Context service lifecycle is managed by Riverpod provider
  }
}
