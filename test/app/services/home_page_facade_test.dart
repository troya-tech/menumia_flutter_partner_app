import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:menumia_flutter_partner_app/app/services/home_page_facade.dart';
import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/application/shared_config_service.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';

// --- Mocks ---
class MockRestaurantContextService extends Mock
    implements RestaurantContextService {}

class MockSharedConfigService extends Mock implements SharedConfigService {}

void main() {
  late MockRestaurantContextService mockContextService;
  late MockSharedConfigService mockConfigService;
  late StreamController<String?> menuKeyController;

  setUp(() {
    mockContextService = MockRestaurantContextService();
    mockConfigService = MockSharedConfigService();
    menuKeyController = StreamController<String?>.broadcast();

    when(() => mockContextService.activeMenuKey$)
        .thenAnswer((_) => menuKeyController.stream);
  });

  tearDown(() {
    menuKeyController.close();
  });

  HomePageFacade createFacade() {
    return HomePageFacade(
      contextService: mockContextService,
      sharedConfigService: mockConfigService,
    );
  }

  group('HomePageFacade', () {
    test('emits ordering enabled when shared config says so', () async {
      final configController = StreamController<SharedConfig>.broadcast();

      when(() => mockConfigService.watchSharedConfig('menu_key_1'))
          .thenAnswer((_) => configController.stream);

      final facade = createFacade();

      // Collect emissions
      final emissions = <bool>[];
      final sub = facade.orderingEnabled$.listen(emissions.add);

      // Emit a menu key
      menuKeyController.add('menu_key_1');
      await Future.delayed(const Duration(milliseconds: 50));

      // Emit config with ordering enabled
      configController.add(const SharedConfig(
        planTiersPlanner: PlanTiersPlanner(orderingEnabled: true),
        themeSettingsPlanner: ThemeSettingsPlanner(
          logoUrlLink: '',
          primaryColor: '',
          secondaryColor: '',
          titleColor: '',
          cardLogoBackgroundColor: '',
        ),
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emissions, contains(true));

      await sub.cancel();
      await configController.close();
      facade.dispose();
    });

    test('emits false when menu key is null', () async {
      final facade = createFacade();

      final emissions = <bool>[];
      final sub = facade.orderingEnabled$.listen(emissions.add);

      menuKeyController.add(null);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emissions, contains(false));

      await sub.cancel();
      facade.dispose();
    });

    test('emits false when shared config stream errors', () async {
      final errorController = StreamController<SharedConfig>.broadcast();

      when(() => mockConfigService.watchSharedConfig('menu_error'))
          .thenAnswer((_) => errorController.stream);

      final facade = createFacade();

      final emissions = <bool>[];
      final sub = facade.orderingEnabled$.listen(emissions.add);

      menuKeyController.add('menu_error');
      await Future.delayed(const Duration(milliseconds: 50));

      errorController.addError(Exception('Firebase error'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emissions, contains(false));

      await sub.cancel();
      await errorController.close();
      facade.dispose();
    });

    test('cancels previous config subscription on menu key change', () async {
      final config1Controller = StreamController<SharedConfig>.broadcast();
      final config2Controller = StreamController<SharedConfig>.broadcast();

      when(() => mockConfigService.watchSharedConfig('key_1'))
          .thenAnswer((_) => config1Controller.stream);
      when(() => mockConfigService.watchSharedConfig('key_2'))
          .thenAnswer((_) => config2Controller.stream);

      final facade = createFacade();

      final emissions = <bool>[];
      final sub = facade.orderingEnabled$.listen(emissions.add);

      // Emit first key
      menuKeyController.add('key_1');
      await Future.delayed(const Duration(milliseconds: 50));

      // Switch to second key — should cancel key_1 subscription
      menuKeyController.add('key_2');
      await Future.delayed(const Duration(milliseconds: 50));

      // Emit on second key's config
      config2Controller.add(const SharedConfig(
        planTiersPlanner: PlanTiersPlanner(orderingEnabled: true),
        themeSettingsPlanner: ThemeSettingsPlanner(
          logoUrlLink: '',
          primaryColor: '',
          secondaryColor: '',
          titleColor: '',
          cardLogoBackgroundColor: '',
        ),
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(emissions, contains(true));

      await sub.cancel();
      await config1Controller.close();
      await config2Controller.close();
      facade.dispose();
    });

    test('dispose cancels all subscriptions', () {
      final facade = createFacade();
      // Should not throw
      expect(() => facade.dispose(), returnsNormally);
    });
  });
}
