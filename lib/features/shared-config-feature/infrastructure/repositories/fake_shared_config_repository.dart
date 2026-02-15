import '../../domain/entities/shared_config.dart';
import '../../domain/repositories/shared_config_repository.dart';
import '../../../../testing/shared_config_fixtures.dart';

class FakeSharedConfigRepository implements SharedConfigRepository {
  @override
  Stream<SharedConfig> watchSharedConfig(String menuKey) {
    try {
      if (menuKey == 'key_millet-bahcesi-lapseki-sosyal-tesisleri') return Stream.value(SharedConfigFixtures.milletBahcesi);
      if (menuKey == 'key_tesis3') return Stream.value(SharedConfigFixtures.tesis3);
      if (menuKey == 'menuKey_forknife') return Stream.value(SharedConfigFixtures.forknife);
      if (menuKey == 'menuKey_nfc17') return Stream.value(SharedConfigFixtures.nfc);
      if (menuKey == 'key_fake') return Stream.value(SharedConfigFixtures.fake);
      
      // Default to fake if not found
      return Stream.value(SharedConfigFixtures.fake);
    } catch (_) {
      return Stream.value(SharedConfig.empty());
    }
  }
}
