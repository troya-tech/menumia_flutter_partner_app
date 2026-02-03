import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/domain/repositories/shared_config_repository.dart';
import 'package:menumia_flutter_partner_app/features/shared-config-feature/infrastructure/dtos/shared_config_dto.dart';

class FirebaseSharedConfigRepository implements SharedConfigRepository {
  final FirebaseDatabase _database;

  FirebaseSharedConfigRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Stream<SharedConfig> watchSharedConfig(String menuKey) {
    print('🔥 Firebase: Watching shared_config/$menuKey');
    return _database.ref('shared_config/$menuKey').onValue.map((event) {
      final value = event.snapshot.value;
      print('🔥 Firebase: Received value: $value');
      
      if (value == null) {
        print('⚠️ Firebase: Value is null, returning empty config');
        return SharedConfig.empty();
      }

      try {
        final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
        print('🔥 Firebase: Parsed JSON: $jsonMap');
        final config = SharedConfigDto.fromJson(jsonMap).toDomain();
        print('🔥 Firebase: Converted to domain - orderingEnabled: ${config.planTiersPlanner.orderingEnabled}');
        return config;
      } catch (e) {
        // In a real app, use a proper logger
        print('❌ Error parsing shared config stream: $e');
        return SharedConfig.empty();
      }
    });
  }
}
