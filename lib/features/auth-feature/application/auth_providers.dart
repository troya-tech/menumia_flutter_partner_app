
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';
import '../infrastructure/auth_service.dart';

/// Provider for the AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthService.instance;
});

/// StreamProvider for the authentication state
final authStateProvider = StreamProvider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Provider for the current user (synchronous access if needed, but stream is preferred)
final currentUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});
