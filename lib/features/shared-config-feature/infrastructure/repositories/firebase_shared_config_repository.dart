import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/repositories/shared_config_repository.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/infrastructure/dtos/shared_config_dto.dart';

import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

class FirebaseSharedConfigRepository implements SharedConfigRepository {
  final FirebaseDatabase _database;
  static final _logger = AppLogger('FirebaseSharedConfigRepository');

  FirebaseSharedConfigRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Stream<SharedConfig> watchSharedConfig(String menuKey, [LogContext? context]) {
    _logger.debug('Watching shared_config/$menuKey', context);
    return _database.ref('shared_config/$menuKey').onValue.map((event) {
      final value = event.snapshot.value;
      
      if (value == null) {
        _logger.warning('Shared config value is null for $menuKey', context);
        return SharedConfig.empty();
      }

      try {
        final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
        final config = SharedConfigDto.fromJson(jsonMap).toDomain();
        _logger.success('Shared config loaded for $menuKey', context);
        return config;
      } catch (e, stack) {
        _logger.error('Error parsing shared config stream for $menuKey', e, stack, context);
        return SharedConfig.empty();
      }
    });
  }
}

