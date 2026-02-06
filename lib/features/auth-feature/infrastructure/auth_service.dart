
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../utils/app_logger.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Authentication service implementation using Firebase and Google Sign-In
class AuthService implements AuthRepository {
  // Singleton pattern
  const AuthService._();
  static const AuthService instance = AuthService._();
  factory AuthService() => instance;

  // Logger
  static final _logger = AppLogger('AuthService');

  // Firebase Auth instance
  FirebaseAuth get _auth => FirebaseAuth.instance;

  // Google Sign-In instance
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  @override
  AuthUser? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  AuthUser? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    final context = _logger.createContext();
    _logger.info('Starting Google Sign-In flow', context);
    
    try {
      final credential = await _performGoogleSignIn(context);
      final user = credential.user;
      if (user == null) {
         throw Exception('Google Sign-In succeeded but user is null');
      }
      return _mapFirebaseUser(user)!;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled && 
          e.description?.contains('16') == true) {
        _logger.warning('Credential Manager cache issue detected, clearing and retrying...', context);
        
        try {
          await _googleSignIn.disconnect();
          _logger.debug('Disconnected successfully, retrying sign-in...', context);
        } catch (disconnectError) {
          _logger.debug('Disconnect failed (continuing anyway): $disconnectError', context);
        }
        
        try {
          final credential = await _performGoogleSignIn(context);
           final user = credential.user;
          if (user == null) {
             throw Exception('Google Sign-In succeeded but user is null');
          }
           return _mapFirebaseUser(user)!;
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

  Future<UserCredential> _performGoogleSignIn(dynamic context) async {
    const List<String> scopes = ['email'];
    
    _logger.debug('Attempting lightweight authentication...', context);
    GoogleSignInAccount? account = await _googleSignIn.attemptLightweightAuthentication();
    
    if (account == null) {
      _logger.debug('Lightweight auth unavailable, using interactive sign-in...', context);
      account = await _googleSignIn.authenticate(scopeHint: scopes);
    }
    
    _logger.success('Google authentication successful', context);
    _logger.data('Account email', account.email, context);

    _logger.debug('Getting authentication tokens...', context);
    final GoogleSignInAuthentication auth = account.authentication;

    final String? idToken = auth.idToken;
    if (idToken == null) {
      _logger.error('Google ID token is null', null, null, context);
      throw StateError(
        'Google ID token is null. Ensure a Web Client ID (client_type: 3) exists in google-services.json.',
      );
    }
    _logger.debug('ID token obtained successfully: ${idToken.substring(0, 10)}...', context);

    _logger.debug('Getting authorization (access token)...', context);
    String? accessToken;
    try {
      final authorization = await account.authorizationClient.authorizeScopes(scopes);
      accessToken = authorization.accessToken;
      if (accessToken != null) {
        _logger.debug('Access token obtained successfully: ${accessToken.substring(0, 10)}...', context);
      } else {
        _logger.debug('Access token is null (valid for idToken-only flows)', context);
      }
    } catch (authzError) {
      _logger.warning('Authorization failed (proceeding with idToken only): $authzError', context);
    }

    _logger.debug('Creating Firebase credential...', context);
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    _logger.debug('Signing in to Firebase...', context);
    try {
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      
      _logger.success('Firebase sign-in successful', context);
      _logger.data('User UID', userCredential.user?.uid, context);
      _logger.data('User email', userCredential.user?.email, context);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      _logger.error('Firebase Auth Error: [${e.code}] ${e.message}', e, null, context);
      _logger.data('Error Credential', e.credential.toString(), context);
      rethrow;
    } catch (e) {
      _logger.error('Unexpected error during Firebase sign-in', e, null, context);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    final context = _logger.createContext();
    _logger.info('Starting sign-out process', context);
    
    try {
      _logger.debug('Signing out from Firebase and Google...', context);
      try {
        await _googleSignIn.disconnect();
      } catch (e) {
        _logger.debug('Google disconnect failed or not applicable: $e', context);
      }

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
}
