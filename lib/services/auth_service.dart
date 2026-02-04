import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menumia_flutter_partner_app/utils/app_logger.dart';

/// Authentication service for managing user authentication
///
/// This service provides a centralized interface for all authentication
/// operations including Google Sign-In, sign-out, and auth state monitoring.
class AuthService {
  // Singleton pattern
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  // Logger
  static final _logger = AppLogger('AuthService');

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign-In instance
  // Note: signIn() automatically requests basic profile and email scopes
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

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
  /// If "[16] Account reauth failed" error occurs, it will disconnect and retry.
  /// Throws an exception if any step fails.
  Future<UserCredential> signInWithGoogle() async {
    final context = _logger.createContext();
    _logger.info('Starting Google Sign-In flow', context);
    
    try {
      return await _performGoogleSignIn(context);
    } on GoogleSignInException catch (e) {
      // Check if this is the "[16] Account reauth failed" error
      if (e.code == GoogleSignInExceptionCode.canceled && 
          e.description?.contains('16') == true) {
        _logger.warning('Credential Manager cache issue detected, clearing and retrying...', context);
        
        // Disconnect to clear cached credentials
        try {
          await _googleSignIn.disconnect();
          _logger.debug('Disconnected successfully, retrying sign-in...', context);
        } catch (disconnectError) {
          _logger.debug('Disconnect failed (continuing anyway): $disconnectError', context);
        }
        
        // Retry the sign-in
        try {
          return await _performGoogleSignIn(context);
        } on GoogleSignInException catch (retryError) {
          _logger.error('Google Sign-In retry failed', retryError, null, context);
          throw Exception('Google Sign-In failed after retry: ${retryError.description ?? retryError.code}');
        }
      }
      
      _logger.error('Google Sign-In failed', e, null, context);
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw Exception('Google Sign-In was canceled by user');
      }
      throw Exception('Google Sign-In failed: ${e.description ?? e.code}');
    } catch (e) {
      _logger.error('Google Sign-In failed', e, null, context);
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Internal method to perform the actual Google Sign-In flow
  Future<UserCredential> _performGoogleSignIn(dynamic context) async {
    // Scopes needed for authorization (email is default, but we may need more)
    const List<String> scopes = ['email'];
    
    // First, try lightweight authentication (silent sign-in)
    _logger.debug('Attempting lightweight authentication...', context);
    GoogleSignInAccount? account = await _googleSignIn.attemptLightweightAuthentication();
    
    // If lightweight auth failed/returned null, use interactive authenticate
    if (account == null) {
      _logger.debug('Lightweight auth unavailable, using interactive sign-in...', context);
      account = await _googleSignIn.authenticate(scopeHint: scopes);
    }
    
    _logger.success('Google authentication successful', context);
    _logger.data('Account email', account.email, context);

    // Get authentication tokens - in v7, authentication only returns idToken
    _logger.debug('Getting authentication tokens...', context);
    final GoogleSignInAuthentication auth = account.authentication;

    // Ensure we have an ID token
    final String? idToken = auth.idToken;
    if (idToken == null) {
      _logger.error('Google ID token is null', null, null, context);
      throw StateError(
        'Google ID token is null. Ensure a Web Client ID (client_type: 3) exists in google-services.json.',
      );
    }
    _logger.debug('ID token obtained successfully', context);

    // Get authorization (access token) via the authorizationClient
    _logger.debug('Getting authorization (access token)...', context);
    String? accessToken;
    try {
      final authorization = await account.authorizationClient.authorizeScopes(scopes);
      accessToken = authorization.accessToken;
      _logger.debug('Access token obtained successfully', context);
    } catch (authzError) {
      // Authorization might fail, but we can still proceed with just idToken
      _logger.warning('Authorization failed (proceeding with idToken only): $authzError', context);
    }

    // Create Firebase credential
    _logger.debug('Creating Firebase credential...', context);
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken, // Can be null, Firebase accepts idToken-only
    );

    // Sign in to Firebase
    _logger.debug('Signing in to Firebase...', context);
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
    
    _logger.success('Firebase sign-in successful', context);
    _logger.data('User UID', userCredential.user?.uid, context);
    _logger.data('User email', userCredential.user?.email, context);

    return userCredential;
  }

  /// Sign out from both Firebase and Google
  ///
  /// This ensures the user is completely signed out from both services.
  Future<void> signOut() async {
    final context = _logger.createContext();
    _logger.info('Starting sign-out process', context);
    
    try {
      _logger.debug('Signing out from Firebase and Google...', context);
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _logger.success('Sign-out successful', context);
    } catch (e) {
      _logger.error('Sign-out failed', e, null, context);
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
