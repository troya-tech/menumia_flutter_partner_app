import 'dart:async';
import 'package:menumia_flutter_partner_app/features/restaurant-user-feature/domain/entities/restaurant_user.dart';
import 'package:menumia_flutter_partner_app/features/restaurant/domain/entities/restaurant.dart';
import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';

class ProfilePageFacade {
  // Streams forwarded from RestaurantContextService
  Stream<RestaurantUser?> get currentUser$ => RestaurantContextService.instance.currentUser$;
  Stream<List<Restaurant>> get relatedRestaurants$ => RestaurantContextService.instance.relatedRestaurants$;
  Stream<String?> get activeRestaurantId$ => RestaurantContextService.instance.activeRestaurantId$;

  void init() {
    // Service initialization is now handled globally or we can trigger it here to be safe
    RestaurantContextService.instance.init();
  }
  
  void setActiveRestaurant(String restaurantId) {
    RestaurantContextService.instance.setActiveRestaurant(restaurantId);
  }

  void dispose() {
    // Singleton handles its own lifecycle, nothing to dispose here specific to this facade likely
    // unless we had local subscriptions.
  }
}
