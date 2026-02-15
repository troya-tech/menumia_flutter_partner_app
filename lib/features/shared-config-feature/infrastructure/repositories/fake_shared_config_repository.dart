import 'package:rxdart/rxdart.dart';
import '../../domain/entities/shared_config.dart';
import '../../domain/repositories/shared_config_repository.dart';
import '../../../../testing/shared_config_fixtures.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';


class FakeSharedConfigRepository implements SharedConfigRepository {
  static final _logger = AppLogger('FakeSharedConfigRepository');

  static final Map<String, BehaviorSubject<SharedConfig>> _subjects = {};

  BehaviorSubject<SharedConfig> _getSubject(String menuKey) {
    _logger.debug('Getting subject for menuKey: $menuKey');
    if (!_subjects.containsKey(menuKey)) {
      SharedConfig initial;
      try {
        if (menuKey == 'key_millet-bahcesi-lapseki-sosyal-tesisleri') initial = SharedConfigFixtures.milletBahcesi;
        else if (menuKey == 'key_tesis3') initial = SharedConfigFixtures.tesis3;
        else if (menuKey == 'menuKey_forknife') initial = SharedConfigFixtures.forknife;
        else if (menuKey == 'menuKey_nfc17') initial = SharedConfigFixtures.nfc;
        else if (menuKey == 'key_fake') initial = SharedConfigFixtures.fake;
        else initial = SharedConfigFixtures.fake;
      } catch (e) {
        _logger.error('Error getting shared config for $menuKey', e);
        initial = SharedConfig.empty();
      }
      _subjects[menuKey] = BehaviorSubject<SharedConfig>.seeded(initial);
    }
    return _subjects[menuKey]!;
  }


  @override
  Stream<SharedConfig> watchSharedConfig(String menuKey) {
    _logger.debug('Watching shared config for menu: $menuKey');
    return _getSubject(menuKey).stream;
  }

}
