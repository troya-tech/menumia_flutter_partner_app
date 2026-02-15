import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_repository.dart';
import 'package:menumia_flutter_partner_app/features/auth-feature/domain/auth_user.dart';
import 'package:rxdart/rxdart.dart';
import '../../../testing/auth_fixtures.dart';

/// A fake implementation of [AuthRepository] for testing purposes.
/// 
/// Following Vladimir Khorikov's definition of a **Fake**:
/// It provides a functional, stateful, but simplified implementation of the 
/// repository without external dependencies (Firebase/Google).
/// 
/// It maintains internal state and updates the [authStateChanges] stream accordingly.
class FakeAuthRepository implements AuthRepository {
  AuthUser? _currentUser;
  
  // Using BehaviorSubject to ensure new listeners get the latest state immediately
  final _authStateController = BehaviorSubject<AuthUser?>();

  /// Creates a [FakeAuthRepository] with an optional [initialUser].
  FakeAuthRepository({AuthUser? initialUser}) : _currentUser = initialUser {
    // Seed initial state
    _authStateController.add(_currentUser);
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() => _authStateController.stream;

  @override
  Future<AuthUser> signInWithGoogle() async {
    // Simplified functional logic: transition state to logged in
    // using the standard test fixture user.
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate minimal latency
    
    _currentUser = AuthFixtures.testUser;
    _authStateController.add(_currentUser);
    
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    // Simplified functional logic: transition state to logged out.
    await Future.delayed(const Duration(milliseconds: 50));
    
    _currentUser = null;
    _authStateController.add(_currentUser);
  }

  /// Clean up the stream controller when the repository is no longer needed.
  void dispose() {
    _authStateController.close();
  }
  
  /// Helper method for tests to manually inject a specific user state
  /// or reset the repository.
  void emitUser(AuthUser? user) {
    _currentUser = user;
    _authStateController.add(_currentUser);
  }
}
