import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Authentication service for managing user authentication
///
/// This service provides a centralized interface for all authentication
/// operations including Google Sign-In, sign-out, and auth state monitoring.
class AuthService {
  // Singleton pattern
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Scopes required for Google Sign-In
  static const List<String> _scopes = ['email'];

  /// Get the current authenticated user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  ///
  /// Emits the current user when signed in, or null when signed out.
  /// This stream can be used to automatically navigate users based on auth state.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  /// Sign in with Google using google_sign_in v7+ API
  ///
  /// This method handles the complete Google Sign-In flow:
  /// 1. Authenticates with Google
  /// 2. Gets authentication tokens
  /// 3. Creates Firebase credential
  /// 4. Signs in to Firebase
  ///
  /// Throws an exception if any step fails.
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Authenticate with Google (v7+ API)
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: _scopes,
      );

      // Get authentication details
      final GoogleSignInAuthentication auth = account.authentication;
      
      // Get authorization with access token
      final authorization = await account.authorizationClient.authorizeScopes(_scopes);

      // Ensure we have an ID token
      final String? idToken = auth.idToken;
      if (idToken == null) {
        throw StateError(
          'Google ID token is null. Check Firebase/Google setup.',
        );
      }

      // Create Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      return userCredential;
    } catch (e) {
      // Re-throw with more context
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Sign out from both Firebase and Google
  ///
  /// This ensures the user is completely signed out from both services.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Sign-out failed: $e');
    }
  }

  /// Check if a user is currently signed in
  bool get isSignedIn => currentUser != null;

  /// Get the current user's email
  String? get userEmail => currentUser?.email;

  /// Get the current user's display name
  String? get userDisplayName => currentUser?.displayName;

  /// Get the current user's photo URL
  String? get userPhotoUrl => currentUser?.photoURL;
}
