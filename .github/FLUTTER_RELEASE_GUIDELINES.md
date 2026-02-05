# Flutter Release & Firebase Configuration Guidelines

This document serves as a "Copilot" guide to prevent common issues in Release builds, specifically regarding Firebase initialization, Google Sign-In, and "Black Screen" startup crashes.

## 1. Prevent "Duplicate App" Crashes (Flavors & Firebase)

**Issue:** 
When using flavors (e.g., `prod`, `uat`) with `google-services.json`, the Android native layer often initializes a default Firebase app automatically. If your Dart code also calls `Firebase.initializeApp()`, the app crashes with:
`[core/duplicate-app] A Firebase App named "[DEFAULT]" already exists`

**Solution:**

1.  **Disable Native Auto-Initialization** in `android/app/src/main/AndroidManifest.xml`:
    ```xml
    <manifest ... xmlns:tools="http://schemas.android.com/tools">
      <application ...>
        <!-- Disable Firebase Build-In Auto-Initialization -->
        <provider
            android:name="com.google.firebase.provider.FirebaseInitProvider"
            android:authorities="${applicationId}.firebaseinitprovider"
            android:exported="false"
            tools:node="remove" />
      </application>
    </manifest>
    ```

2.  **Safe Initialization in Dart** (`lib/main.dart`):
    Always check if Firebase is already initialized before calling `initializeApp`.
    ```dart
    // Initialize Firebase (Check if already initialized to prevent 'duplicate-app' crash)
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: firebaseOptions,
      );
    }
    ```

## 2. Prevent "Black Screen" in Release Mode

**Issue:**
The app runs fine in Debug mode but shows a blank black screen in Release mode. This is usually due to missing permissions, code shrinking (R8) stripping essential classes, or unhandled async exceptions at startup.

**Solution:**

1.  **Add Internet Permission** to `android/app/src/main/AndroidManifest.xml`:
    (Debug builds add this automatically; Release builds do not).
    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    ```

2.  **Configure ProGuard / R8 Rules** (`android/app/proguard-rules.pro`):
    Ensure that Google Sign-In and Firebase classes are not stripped.
    ```properties
    # Flutter Wrapper
    -keep class io.flutter.app.** { *; }
    -keep class io.flutter.plugin.**  { *; }
    
    # Firebase
    -keep class com.google.firebase.** { *; }
    -keep class com.google.android.gms.** { *; }
    
    # Google Sign In (CRITICAL for Auth)
    -keep class com.google.android.gms.auth.api.signin.** { *; }
    -keep class com.google.android.gms.auth.api.signin.internal.** { *; }
    
    # Prevent warnings
    -dontwarn io.flutter.embedding.**
    -dontwarn com.google.errorprone.annotations.**
    ```

3.  **Global Error Handling in `main()`**:
    Wrap initialization in a `try-catch` block to render an error screen instead of failing silently (Black Screen).
    ```dart
    void main() async {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        // ... init logic ...
        runApp(const MyApp());
      } catch (e, stackTrace) {
        runApp(MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Init Error:\n$e')),
          ),
        ));
      }
    }
    ```

## 3. Google Sign-In "Invalid Credential" (SHA-1)

**Issue:**
Google Sign-In fails with `[firebase_auth/invalid-credential]` in Release builds, even if it works in Debug.

**Solution:**
You must add **ALL 3** types of SHA-1 fingerprints to the Firebase Console:

1.  **Debug Key**: For `flutter run` (default `debug.keystore`).
2.  **Local Release Key**: For `flutter run --release` (your local `.jks` file).
    *   Get SHA-1 via: `./gradlew signingReport`
3.  **Play Store App Signing Key**: For the version downloaded from the Play Store.
    *   Get SHA-1 via: **Google Play Console** -> **Release** -> **App Integrity**.
