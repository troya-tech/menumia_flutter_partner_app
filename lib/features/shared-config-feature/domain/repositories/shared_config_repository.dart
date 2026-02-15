import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

abstract class SharedConfigRepository {
  Stream<SharedConfig> watchSharedConfig(String menuKey, [LogContext? context]);
}

