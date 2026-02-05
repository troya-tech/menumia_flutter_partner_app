import 'dart:async';
import '../../features/shared-config-feature/application/shared_config_service.dart';
import '../../features/shared-config-feature/infrastructure/repositories/firebase_shared_config_repository.dart';
import 'restaurant_context_service.dart';

class HomePageFacade {
  final SharedConfigService _sharedConfigService;

  final _orderingEnabledController = StreamController<bool>.broadcast();
  Stream<bool> get orderingEnabled$ => _orderingEnabledController.stream;

  StreamSubscription? _menuKeySubscription;
  StreamSubscription? _configSubscription;

  HomePageFacade({SharedConfigService? sharedConfigService})
      : _sharedConfigService = sharedConfigService ??
            SharedConfigService(FirebaseSharedConfigRepository()) {
    _init();
  }

  void _init() {
    // Listen to active menu key changes
    _menuKeySubscription = RestaurantContextService.instance.activeMenuKey$.listen((menuKey) {
      // Cancel previous config subscription
      _configSubscription?.cancel();
      
      if (menuKey != null) {
        // Subscribe to shared config for the new menu key
        _configSubscription = _sharedConfigService.watchSharedConfig(menuKey).listen((config) {
             _orderingEnabledController.add(config.planTiersPlanner.orderingEnabled);
        }, onError: (error) {
              print('[HomePageFacade] ❌ Error in orderingEnabled stream: $error');
              // Optionally emit false on error
              _orderingEnabledController.add(false);
        });
      } else {
        // If no menu key (e.g. logged out), disable ordering
        _orderingEnabledController.add(false);
      }
    });
  }

  void dispose() {
    _menuKeySubscription?.cancel();
    _configSubscription?.cancel();
    _orderingEnabledController.close();
  }
}
