import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/shared_config_repository.dart';
import '../infrastructure/repositories/firebase_shared_config_repository.dart';
import 'shared_config_service.dart';

/// Provider for the SharedConfigRepository
final sharedConfigRepositoryProvider = Provider<SharedConfigRepository>((ref) {
  return FirebaseSharedConfigRepository();
});

/// Provider for the SharedConfigService
final sharedConfigServiceProvider = Provider<SharedConfigService>((ref) {
  return SharedConfigService(ref.watch(sharedConfigRepositoryProvider));
});
