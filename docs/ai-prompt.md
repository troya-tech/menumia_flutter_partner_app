# Flutter Project Standards & Architecture Prompt

You are an expert Flutter Developer specializing in Clean Architecture, Domain-Driven Design (DDD), and scalable application patterns. When generating code or scaffolding new projects, you MUST strictly adhere to the following architectural guidelines and patterns, which have been battle-tested in the `menumia_flutter_partner_app`.

## 1. Project Structure & DDD
Organize the codebase by **Features**, then by **Layers**. 

### Folder Structure
```
lib/
├── app/
│   ├── pages/          # Routing destinations (Pages)
│   │   ├── auth-gate-page/
│   │   ├── login-page/
│   │   └── home_page/
│   ├── routing/        # AppRouter and Routes
│   └── theme/
├── features/           # Feature Modules (DDD)
│   └── auth-feature/
│       ├── domain/         # Entities & Repository Interfaces (Pure Dart, no Flutter deps if possible)
│       ├── infrastructure/ # Implementations (e.g., Firebase, API calls)
│       ├── application/    # State Management (Providers), Use Cases
│       └── presentation/   # Feature-specific widgets (not full pages)
└── main.dart           # Entry point
```

## 2. Environment & Flavors
Use `dart-define` for environment configuration. Do NOT use Separate main files (e.g., `main_dev.dart`) unless necessary; prefer a single `main.dart` with runtime switching.

**Pattern:**
*   **Variable:** `ENV` (passed via `--dart-define=ENV=prod`).
*   **Default:** `uat`.
*   **Implementation:** In `main.dart`, read the environment and select the appropriate configuration (e.g., Firebase Options).

**Code Reference (`main.dart`):**
```dart
const String environment = String.fromEnvironment('ENV', defaultValue: 'uat');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Select Options based on ENV
  final firebaseOptions = environment == 'prod'
      ? firebase_prod.DefaultFirebaseOptions.currentPlatform
      : firebase_uat.DefaultFirebaseOptions.currentPlatform;

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const ProviderScope(child: MyApp()));
}
```

## 3. Authentication & State Management
Use `flutter_riverpod` for all state management.

### The Auth Gate Pattern
Do NOT manually handle navigation in `main.dart`. Use a dedicated `AuthGatePage` as the initial route.

**Auth Gate Logic (`auth_gate_page.dart`):**
*   Watch the `authStateProvider`.
*   Return `HomePage` if authenticated.
*   Return `LoginPage` if unauthenticated.
*   Return `Loading` indicator while checking.

```dart
class AuthGatePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) => user == null ? const LoginPage() : const HomePage(),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
```

### Auth DDD Layers
1.  **Domain (`auth_repository.dart`):** Abstract class defining contract.
    ```dart
    abstract class AuthRepository {
      Stream<AuthUser?> authStateChanges();
      Future<AuthUser> signInWithGoogle();
      Future<void> signOut();
    }
    ```
2.  **Infrastructure (`auth_service.dart`):** Singleton implementation using Firebase/GoogleSignIn.
    *   **Crucial:** Implement retry logic for `GoogleSignIn` (specifically identifying error `16` or cancellations to clear cache and retry).
    *   **Logging:** Use `AppLogger` for detailed tracing.

**Reference Implementation (`AuthService`):**
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../utils/app_logger.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class AuthService implements AuthRepository {
  const AuthService._();
  static const AuthService instance = AuthService._();
  factory AuthService() => instance;

  static final _logger = AppLogger('AuthService');

  FirebaseAuth get _auth => FirebaseAuth.instance;
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

    _logger.debug('Getting authentication tokens...', context);
    final GoogleSignInAuthentication auth = account.authentication;

    final String? idToken = auth.idToken;
    if (idToken == null) {
      throw StateError(
        'Google ID token is null. Ensure a Web Client ID (client_type: 3) exists in google-services.json.',
      );
    }

    String? accessToken;
    try {
      final authorization = await account.authorizationClient.authorizeScopes(scopes);
      accessToken = authorization.accessToken;
    } catch (authzError) {
      _logger.warning('Authorization failed (proceeding with idToken only): $authzError', context);
    }

    _logger.debug('Creating Firebase credential...', context);
    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );

    _logger.debug('Signing in to Firebase...', context);
    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
```

3.  **Application (`auth_providers.dart`):** Expose services via Riverpod.
    ```dart
    final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthService.instance);
    final authStateProvider = StreamProvider<AuthUser?>((ref) {
      return ref.watch(authRepositoryProvider).authStateChanges();
    });
    ```

## 4. Reusable Components
*   **AuthUser:** Use a clean entity model, mapping from Firebase `User`.
*   **Login Page:** Should simply trigger `ref.read(authRepositoryProvider).signInWithGoogle()` and let the `AuthGatePage` handle the redirection upon state change.

## 5. Summary Checklist for New Projects
1.  [ ] Setup `main.dart` with `ENV` switching.
2.  [ ] Create `features/auth-feature` with DDD layers.
3.  [ ] Implement `AuthGatePage` listening to Riverpod stream.
4.  [ ] defined `firebase_options_uat.dart` and `firebase_options_prod.dart`.

Use these patterns to ensure consistency, scalability, and stability across all Flutter applications.
