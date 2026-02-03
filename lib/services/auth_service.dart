import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    if (kIsWeb) {
      throw UnsupportedError('Google Sign-In is not supported on web in this app');
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const List<String> _scopes = ['email'];

  String? _lastAccessToken;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isSignedIn => currentUser != null;

  Future<void> initialize() async {
    if (kIsWeb) return;
    
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint('GoogleSignIn.initialize() not needed on this platform: $e');
    }
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      throw UnsupportedError('Google Sign-In is not supported on web');
    }

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw StateError('Google idToken is null. Check Firebase/Google Sign-In setup.');
      }

      _lastAccessToken = accessToken;

      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
    _lastAccessToken = null;
  }

  Future<void> disconnect() async {
    await GoogleSignIn.instance.disconnect();
    await _auth.signOut();
    _lastAccessToken = null;
  }

  Future<void> clearAuthorizationToken() async {
    final token = _lastAccessToken;
    if (token != null && token.isNotEmpty) {
      try {
        await GoogleSignIn.instance.authorizationClient.clearAuthorizationToken(
          accessToken: token,
        );
        _lastAccessToken = null;
      } catch (e) {
        debugPrint('Failed to clear authorization token: $e');
      }
    }
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'invalid-credential':
        return 'The credential is malformed or has expired.';
      case 'operation-not-allowed':
        return 'Google Sign-In is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this credential.';
      case 'wrong-password':
        return 'Invalid password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'Authentication failed: ${e.message ?? e.code}';
    }
  }
}
