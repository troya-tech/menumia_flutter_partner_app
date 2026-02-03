import 'package:menumia_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';

abstract class SharedConfigRepository {
  Stream<SharedConfig> watchSharedConfig(String menuKey);
}
