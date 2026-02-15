import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Authentication service that provides high-level auth operations.
/// It uses an [AuthRepository] to perform the actual authentication.
class AuthService {
  final AuthRepository _repository;

  AuthService(this._repository);

  /// Current user getter
  AuthUser? get currentUser => _repository.currentUser;

  /// Auth state changes stream
  Stream<AuthUser?> authStateChanges() => _repository.authStateChanges();

  /// Sign in with Google
  Future<AuthUser> signInWithGoogle() => _repository.signInWithGoogle();

  /// Sign out
  Future<void> signOut() => _repository.signOut();
}
