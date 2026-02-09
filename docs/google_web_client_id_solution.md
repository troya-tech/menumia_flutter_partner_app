# Solving the "serverClientId" (Web Client ID) Problem

This document explains why Google Sign-In might fail to return an `idToken` on Android and how we solved it in the Menumia project.

## The Problem
When implementing `signInWithGoogle` using `google_sign_in` and `firebase_auth`, you might encounter an error where the `GoogleSignInAuthentication.idToken` is `null`. Since Firebase's `GoogleAuthProvider.credential` requires an `idToken`, the authentication flow breaks.

**Error Message (Custom):**
> `StateError: Google ID token is null. Ensure a Web Client ID (client_type: 3) exists in google-services.json.`

## Root Cause
The `google_sign_in` plugin uses the project's **Web Client ID** (also known as `serverClientId`) to authorize the request and retrieve an ID token on behalf of a server-side application (Firebase in this case).

On Android:
1.  The plugin attempts to find a **Web Application** client ID (OAuth client type `3`) within the `google-services.json` file.
2.  If the Firebase project does not have a Web App configured, or if the downloaded `google-services.json` is outdated and doesn't contain this entry, the plugin fails to retrieve the `idToken`.

## The Solution

### 1. Firebase Console Configuration
Even if your app is Android-only, you **MUST** create a Web App in your Firebase project.
- Go to **Project Settings** > **General**.
- Add a new **Web App** (name it anything, e.g., "Web Auth Client").
- This generates a "Web client ID" in the Google Cloud Console.

### 2. Update `google-services.json`
Download the updated `google-services.json` for your Android app and place it in the appropriate folder (e.g., `android/app/src/prod/`).
Verify it contains an `oauth_client` entry with `"client_type": 3`:

```json
{
  "client": [
    {
      "oauth_client": [
        {
          "client_id": "YOUR_WEB_CLIENT_ID.apps.googleusercontent.com",
          "client_type": 3
        }
      ]
    }
  ]
}
```

### 3. Implementation in `AuthService`
Instead of hardcoding the `serverClientId` in the `GoogleSignIn` constructor (which makes managing multiple flavors difficult), we rely on automatic discovery from `google-services.json` and add a defensive check:

```dart
final GoogleSignInAuthentication auth = await account.authentication;
final String? idToken = auth.idToken;

if (idToken == null) {
  throw StateError(
    'Google ID token is null. Ensure a Web Client ID (client_type: 3) exists in google-services.json.',
  );
}
```

### 4. Flavor Management
In this project, we use separate `google-services.json` files for `uat` and `prod` flavors located in:
- `android/app/src/uat/google-services.json`
- `android/app/src/prod/google-services.json`

Each file contains the specific Web Client ID for its corresponding Firebase project.

---

## AI Prompt: "Web client ID" Problem
Use the following prompt to help an AI assistant implement this solution in a new project:

> "In our Flutter project using Firebase Auth and Google Sign-In, we need to ensure the Google ID token is correctly retrieved on Android. Please implement the Google Sign-In flow following these requirements:
> 1. Do NOT hardcode `serverClientId` in the `GoogleSignIn` constructor.
> 2. Rely on the `google-services.json` file for client ID discovery (ensure `client_type: 3` exists).
> 3. Add a check after `account.authentication`: if `idToken` is null, throw a descriptive `StateError` explaining that the 'Web Client ID (client_type: 3)' is missing from `google-services.json`.
> 4. Explain to the user that they must create a Web App in the Firebase console to generate this ID, even if the app is Android-only."
