import 'package:menumia_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';
import 'package:menumia_partner_app/features/shared-config-feature/domain/repositories/shared_config_repository.dart';

class SharedConfigService {
  final SharedConfigRepository _repository;

  SharedConfigService(this._repository);

  /// Watches the shared configuration for a specific menu key
  Stream<SharedConfig> watchSharedConfig(String menuKey) {
    return _repository.watchSharedConfig(menuKey);
  }
}
