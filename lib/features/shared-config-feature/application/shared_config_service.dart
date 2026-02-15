import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/repositories/shared_config_repository.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

class SharedConfigService {
  final SharedConfigRepository _repository;

  SharedConfigService(this._repository);

  /// Watches the shared configuration for a specific menu key
  Stream<SharedConfig> watchSharedConfig(String menuKey, [LogContext? context]) {
    return _repository.watchSharedConfig(menuKey, context);
  }
}

