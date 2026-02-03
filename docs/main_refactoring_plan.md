# Main.dart Refactoring Plan

## Overview

This document outlines the refactoring plan for `lib/main.dart` to adopt a clean, scalable architecture following Flutter best practices. The goal is to transform the current monolithic main.dart (152 lines with embedded widgets) into a minimal entry point that leverages proper separation of concerns.

## Current State Analysis

### Current main.dart Structure (152 lines)
- ✅ Firebase initialization
- ✅ GoogleSignIn initialization
- ❌ `MyApp` widget embedded in main.dart
- ❌ `AuthGate` widget embedded in main.dart
- ❌ `SignInPage` widget embedded in main.dart
- ❌ `HomePage` widget embedded in main.dart
- ❌ Authentication logic mixed with UI

### Existing Architecture
The project already has a good foundation:
- **`lib/app/`** - Application-level configuration
  - `routing/` - AppRouter, AppRoutes (✅ already exists)
  - `theme/` - AppTheme, AppColors, AppTypography (✅ already exists)
  - `pages/` - UI pages organized by feature
  - `services/` - App-level facade services
  - `config/` - Environment configuration

- **`lib/features/`** - Feature modules
  - `menu/` - Menu management feature
  - `restaurant-user-feature/` - Restaurant user management
  - `shared-config-feature/` - Shared configuration

- **`lib/services/`** - Core business services
  - `auth_service.dart` (currently empty - needs implementation)

## Target Architecture

### Final main.dart (Minimal Entry Point)
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options_uat.dart';
import 'app/routing/routing.dart';
import 'app/theme/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Google Sign-In (v7+)
  await GoogleSignIn.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Menumia Partner',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.auth,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
```

---

## Proposed Changes

### Component 1: Core Services

#### [NEW] `lib/services/auth_service.dart`

**Purpose**: Centralize all authentication logic in a dedicated service class.

**Implementation Details**:
- Create a singleton `AuthService` class
- Move Google Sign-In logic from `SignInPage` to `AuthService`
- Implement methods:
  - `signInWithGoogle()` - Handle Google authentication flow
  - `signOut()` - Handle sign-out from both Firebase and Google
  - `authStateChanges()` - Expose Firebase auth state stream
  - `currentUser` - Get current user getter

**Key Features**:
- Uses google_sign_in v7+ API (`authenticate()`, `authorizationClient`)
- Proper error handling with custom exceptions
- Scopes configuration (`['email']`)
- Credential creation for Firebase

**Benefits**:
- Reusable across the app
- Testable in isolation
- Single source of truth for auth logic
- Easy to mock for testing

---

### Component 2: App Structure

#### [MODIFY] `lib/app/pages/auth/auth_gate.dart`

**Current Status**: ✅ Already exists and properly structured

**No changes needed** - This file is already in the correct location and follows best practices:
- Listens to auth state changes
- Routes to SignInPage or HomePage based on auth state
- Shows loading indicator during auth check

#### [MODIFY] `lib/app/pages/auth/sign_in_page.dart`

**Current Status**: ✅ Already exists and uses `AuthService`

**Verification needed**:
- Ensure it's using the fully implemented `AuthService`
- Confirm error handling is consistent
- Verify UI follows design system

#### [MODIFY] `lib/app/pages/home_page/home_page.dart`

**Current Status**: ✅ Already exists

**Verification needed**:
- Ensure sign-out functionality uses `AuthService.signOut()`
- Confirm it's not duplicating auth logic

---

### Component 3: Main Entry Point

#### [MODIFY] `lib/main.dart`

**Changes**:
1. Remove all embedded widget classes:
   - ❌ Remove `AuthGate` class (lines 35-50)
   - ❌ Remove `SignInPage` class (lines 52-121)
   - ❌ Remove `HomePage` class (lines 123-151)

2. Simplify `MyApp` widget:
   - Update title to 'Menumia Partner' (remove UAT suffix for production-ready code)
   - Use `AppTheme.lightTheme` from `app/theme/theme.dart`
   - Use `AppRoutes.auth` for initial route
   - Use `AppRouter.generateRoute` for routing

3. Add proper imports:
   - `import 'app/routing/routing.dart';` (barrel export)
   - `import 'app/theme/theme.dart';` (barrel export)

4. Keep initialization logic:
   - ✅ Firebase initialization
   - ✅ Google Sign-In initialization
   - ✅ WidgetsFlutterBinding.ensureInitialized()

**Result**: Clean, minimal main.dart (approximately 30 lines)

---

### Component 4: Barrel Exports (Optional but Recommended)

#### [VERIFY] `lib/app/routing/routing.dart`

**Purpose**: Barrel export for routing-related classes

**Expected exports**:
```dart
export 'app_router.dart';
export 'app_routes.dart';
```

#### [VERIFY] `lib/app/theme/theme.dart`

**Purpose**: Barrel export for theme-related classes

**Expected exports**:
```dart
export 'app_theme.dart';
export 'app_colors.dart';
export 'app_typography.dart';
```

---

## Implementation Steps

### Step 1: Implement AuthService
1. Open `lib/services/auth_service.dart`
2. Implement the complete authentication service:
   - Singleton pattern
   - `signInWithGoogle()` method
   - `signOut()` method
   - `authStateChanges()` stream
   - `currentUser` getter
3. Add proper error handling and documentation

### Step 2: Verify Existing Pages
1. Check `lib/app/pages/auth/sign_in_page.dart`:
   - Ensure it uses `AuthService.signInWithGoogle()`
   - Verify error handling
2. Check `lib/app/pages/home_page/home_page.dart`:
   - Ensure it uses `AuthService.signOut()`
   - Verify user display logic

### Step 3: Verify Barrel Exports
1. Check `lib/app/routing/routing.dart` exists and exports routing classes
2. Check `lib/app/theme/theme.dart` exists and exports theme classes
3. Create them if they don't exist

### Step 4: Refactor main.dart
1. Add imports for routing and theme barrel exports
2. Update `MyApp` widget:
   - Change title to 'Menumia Partner'
   - Use `AppTheme.lightTheme`
   - Set `initialRoute: AppRoutes.auth`
   - Set `onGenerateRoute: AppRouter.generateRoute`
3. Remove all embedded widget classes:
   - Remove `AuthGate` (already exists in `app/pages/auth/`)
   - Remove `SignInPage` (already exists in `app/pages/auth/`)
   - Remove `HomePage` (already exists in `app/pages/home_page/`)
4. Keep only initialization logic in `main()`

### Step 5: Clean Up and Verify
1. Remove unused imports from main.dart
2. Ensure no breaking changes
3. Verify app still runs correctly

---

## Verification Plan

### Automated Tests

> [!NOTE]
> Currently, the project doesn't have automated tests set up. This refactoring maintains the same functionality, so manual testing is sufficient for now.

**Future recommendation**: Add integration tests for authentication flow using `flutter_test` and `integration_test` packages.

### Manual Verification

#### Test 1: App Launch and Initial Route
1. Run the app: `flutter run`
2. **Expected**: App launches successfully
3. **Expected**: If not authenticated, user sees the Sign-In page (from `app/pages/auth/sign_in_page.dart`)
4. **Expected**: No errors in console

#### Test 2: Google Sign-In Flow
1. From the Sign-In page, tap "Sign in with Google"
2. **Expected**: Google Sign-In dialog appears
3. Complete the sign-in process
4. **Expected**: User is redirected to Home page
5. **Expected**: User's name/email is displayed on Home page
6. **Expected**: No errors in console

#### Test 3: Sign-Out Flow
1. From the Home page, tap "Sign out" button
2. **Expected**: User is signed out
3. **Expected**: User is redirected to Sign-In page
4. **Expected**: No errors in console

#### Test 4: Auth State Persistence
1. Sign in with Google
2. Close the app completely
3. Reopen the app
4. **Expected**: User is still signed in and sees Home page
5. **Expected**: No re-authentication required

#### Test 5: Hot Reload Compatibility
1. While app is running, make a minor UI change
2. Save the file (trigger hot reload)
3. **Expected**: Changes appear without losing auth state
4. **Expected**: No errors in console

---

## Benefits of This Refactoring

### 1. **Separation of Concerns**
- ✅ Business logic (AuthService) separated from UI
- ✅ Routing logic centralized in AppRouter
- ✅ Theme configuration centralized in AppTheme
- ✅ main.dart is purely an entry point

### 2. **Scalability**
- ✅ Easy to add new authentication methods (email/password, Apple Sign-In, etc.)
- ✅ Easy to add new routes and pages
- ✅ Easy to customize theme without touching main.dart

### 3. **Testability**
- ✅ AuthService can be unit tested in isolation
- ✅ Pages can be tested with mocked AuthService
- ✅ Routing logic can be tested independently

### 4. **Maintainability**
- ✅ Clear file structure following Flutter conventions
- ✅ Each file has a single responsibility
- ✅ Easy to locate and modify specific functionality

### 5. **Reusability**
- ✅ AuthService can be used anywhere in the app
- ✅ Theme can be easily switched (light/dark mode)
- ✅ Routing logic is centralized and consistent

---

## File Structure After Refactoring

```
lib/
├── main.dart (30 lines - minimal entry point)
├── firebase_options_uat.dart
│
├── app/
│   ├── config/
│   │   └── app_environment.dart
│   ├── routing/
│   │   ├── routing.dart (barrel export)
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   ├── theme/
│   │   ├── theme.dart (barrel export)
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── auth_gate.dart
│   │   │   └── sign_in_page.dart
│   │   ├── home_page/
│   │   │   ├── home_page.dart
│   │   │   └── widgets/
│   │   └── profile_page.dart
│   └── services/
│       ├── home_page_facade.dart
│       └── profile_page_facade.dart
│
├── features/
│   ├── menu/
│   ├── restaurant-user-feature/
│   └── shared-config-feature/
│
└── services/
    └── auth_service.dart (NEW - core authentication service)
```

---

## Migration Checklist

- [ ] **Step 1**: Implement `AuthService` in `lib/services/auth_service.dart`
- [ ] **Step 2**: Verify `SignInPage` uses `AuthService`
- [ ] **Step 3**: Verify `HomePage` uses `AuthService.signOut()`
- [ ] **Step 4**: Verify barrel exports exist (`routing.dart`, `theme.dart`)
- [ ] **Step 5**: Update `main.dart` to use routing and theme
- [ ] **Step 6**: Remove embedded widgets from `main.dart`
- [ ] **Step 7**: Test app launch and initial route
- [ ] **Step 8**: Test Google Sign-In flow
- [ ] **Step 9**: Test Sign-Out flow
- [ ] **Step 10**: Test auth state persistence
- [ ] **Step 11**: Test hot reload compatibility

---

## Notes and Considerations

### Environment Configuration
- Currently using `firebase_options_uat.dart` for UAT environment
- Consider creating environment-specific configurations:
  - `firebase_options_dev.dart`
  - `firebase_options_uat.dart`
  - `firebase_options_prod.dart`
- Use `app/config/app_environment.dart` to manage environment switching

### Future Enhancements
1. **Dependency Injection**: Consider using `get_it` or `provider` for service injection
2. **State Management**: Consider adding `riverpod` or `bloc` for complex state
3. **Error Handling**: Create custom exception classes for better error handling
4. **Logging**: Add logging service for debugging and monitoring
5. **Analytics**: Integrate Firebase Analytics for user tracking

### Breaking Changes
> [!IMPORTANT]
> This refactoring does NOT introduce breaking changes. All functionality remains the same, just better organized.

---

## Questions for Review

1. **Environment Management**: Should we create separate Firebase configuration files for dev/uat/prod environments?
2. **State Management**: Do you want to introduce a state management solution (Provider, Riverpod, Bloc) as part of this refactoring?
3. **Dependency Injection**: Should we set up a DI container (get_it) for services?
4. **Testing**: Should we add automated tests as part of this refactoring, or in a separate task?
5. **App Title**: Should the title remain "Menumia Partner (UAT)" or change to "Menumia Partner"?

---

## Timeline Estimate

- **Step 1-3** (AuthService & verification): ~30 minutes
- **Step 4** (Barrel exports): ~10 minutes
- **Step 5-6** (Refactor main.dart): ~20 minutes
- **Step 7-11** (Testing): ~30 minutes

**Total estimated time**: ~1.5 hours
