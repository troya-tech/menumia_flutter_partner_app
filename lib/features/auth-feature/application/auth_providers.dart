import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../infrastructure/google_sign_in_auth_repository.implementation.dart';
import 'auth_service.dart';

/// Provider for the AuthRepository implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return GoogleSignInAuthRepository();
});

/// Provider for the AuthService (Application Layer)
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(authRepositoryProvider));
});

/// StreamProvider for the authentication state
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});
