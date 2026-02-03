import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:menumia_partner_app/features/shared-config-feature/domain/entities/shared_config.dart';
import 'package:menumia_partner_app/features/shared-config-feature/domain/repositories/shared_config_repository.dart';
import 'package:menumia_partner_app/features/shared-config-feature/infrastructure/dtos/shared_config_dto.dart';

class FirebaseSharedConfigRepository implements SharedConfigRepository {
  final FirebaseDatabase _database;

  FirebaseSharedConfigRepository({FirebaseDatabase? database})
      : _database = database ?? FirebaseDatabase.instance;

  @override
  Stream<SharedConfig> watchSharedConfig(String menuKey) {
    return _database.ref('shared_config/$menuKey').onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return SharedConfig.empty();
      }

      try {
        final jsonMap = jsonDecode(jsonEncode(value)) as Map<String, dynamic>;
        return SharedConfigDto.fromJson(jsonMap).toDomain();
      } catch (e) {
        // In a real app, use a proper logger
        print('Error parsing shared config stream: $e');
        return SharedConfig.empty();
      }
    });
  }
}
