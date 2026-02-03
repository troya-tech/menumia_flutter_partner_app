import 'dart:async'; // Add this for StreamController
import '../../features/shared-config-feature/application/shared_config_service.dart';
import '../../features/shared-config-feature/infrastructure/repositories/firebase_shared_config_repository.dart';

class HomePageFacade {
  final SharedConfigService _sharedConfigService;

  late final Stream<bool> orderingEnabled$;

  HomePageFacade({SharedConfigService? sharedConfigService})
      : _sharedConfigService = sharedConfigService ??
            SharedConfigService(FirebaseSharedConfigRepository()) {
    _init();
  }

  void _init() {
    // TODO: Get the actual menuKey dynamically (e.g. from Auth service or User context)
    // For now hardcoding 'menuKey_forknife' as seen in the export data for development
    const menuKey = 'menuKey_forknife';

    orderingEnabled$ = _sharedConfigService.watchSharedConfig(menuKey)
        .map((config) => config.planTiersPlanner.orderingEnabled)
        .handleError((container) {
            print("Error stream");
            // emit defaults?
        });
  }

  void dispose() {
    // No dedicated controller to close
  }
}
