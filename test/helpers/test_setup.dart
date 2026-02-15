import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/application/auth_providers.dart';
import 'package:menumia_flutter_partner_app/app/providers/providers.dart';
import 'package:menumia_flutter_partner_app/features/menu/application/menu_providers.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/repositories/menu_repository.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/infrastructure/fake_auth_repository.implementation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:menumia_flutter_partner_app/app/services/restaurant_context_service.dart';
import 'package:menumia_flutter_partner_app/features/menu/domain/entities/menu.dart';

class MockRestaurantContextService extends Mock implements RestaurantContextService {}
class MockMenuRepository extends Mock implements MenuRepository {}

/// Helper to create a [ProviderContainer] or [ProviderScope] with toggleable 
/// authentication implementations.
/// 
/// This facilitates Vladimir Khorikov's "Dual-Track" testing strategy where
/// you can run the exact same test against both Fakes and Reality.
class TestSetup {
  /// Returns a list of overrides based on the [useFake] flag.
  static List<Override> authOverrides({bool useFake = true}) {
    if (!useFake) return [];

    final mockContext = MockRestaurantContextService();
    final mockMenuRepo = MockMenuRepository();

    // Stub the Context Service to avoid Firebase calls in tests
    when(() => mockContext.init()).thenAnswer((_) async {});
    when(() => mockContext.currentUser$).thenAnswer((_) => const Stream.empty());
    when(() => mockContext.relatedRestaurants$).thenAnswer((_) => const Stream.empty());
    when(() => mockContext.activeRestaurantId$).thenAnswer((_) => const Stream.empty());
    when(() => mockContext.activeMenuKey$).thenAnswer((_) => const Stream.empty());

    // Stub the Menu Repository to avoid Firebase calls in tests
    when(() => mockMenuRepo.watchMenu(any())).thenAnswer(
      (_) => Stream.value(Menu(menuKey: 'test-menu', categories: [])),
    );

    return [
      authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      restaurantContextServiceProvider.overrideWithValue(mockContext),
      menuRepositoryProvider.overrideWithValue(mockMenuRepo),
    ];
  }
}
