# Google Sign-In Troubleshooting

## Error: "Developer console is not set up correctly"

If you encounter the error `GoogleSignInException(code GoogleSignInExceptionCode.unknownError, [28444] Developer console is not set up correctly., null)`, it almost always means there is a mismatch between the **SHA-1 certificate fingerprint** of your Android app and what is configured in the **Firebase/Google Cloud Console**.

### Root Cause
Google Sign-In on Android requires the signing certificate's SHA-1 fingerprint to be whitelisted in the Google API Console. If the app is signed with a key (debug or release) that isn't registered, this error occurs.

### Step-by-Step Resolution

#### 1. specific to verify `google-services.json`
Ensure you are using the correct `google-services.json` for your flavor (e.g., `prod`).
- It should be located in `android/app/src/prod/google-services.json` (for flavored apps) or `android/app/google-services.json`.
- Verify the `package_name` inside the JSON matches your `build.gradle` `applicationId`.


#### 2. Get Your Local SHA-1 Fingerprint
You need to verify if your current building key matches the one expected by Firebase.

**Expected SHA-1 (from your current `google-services.json`):**
`d252c1e4e0e85051aed6b99d3148a6255d359e24`

**Action:**
1. Run the helper script created in `android/`:
   ```bash
   cd android
   .\get_sha1.bat
   ```
   (Or run `gradlew signingReport` manually).

2. Look for the **SHA1** fingerprint of the `prodDebug` (or `debug`) variant.
3. **Compare** it with the expected SHA-1 above.
   - If they **MATCH**: The issue is likely unrelated to SHA-1 (check Support Email or OAuth Consent Screen).
   - If they **DIFFER**: You MUST add the *new* SHA-1 from the console output to the Firebase Console.


#### 3. Update Firebase Console
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select your project.
3. Click the gear icon ⚙️ > **Project settings**.
4. Scroll down to the **Your apps** section and select your **Android app**.
5. Look at the **SHA certificate fingerprints** list.
6. **Add** the SHA-1 you copied in Step 2.
7. **Download** the updated `google-services.json` (optional, usually only needed if client IDs changed, but good practice).

#### 4. Additional Checks
- **Support Email**: In Firebase Console > Project settings > General, ensure a **Support email** is selected. This is required for OAuth.
- **Google Cloud Console**: If it still fails, check [Google Cloud Console > credentials](https://console.cloud.google.com/apis/credentials). Ensure the "Android" client ID lists the correct package name and SHA-1.

### Clean and Rebuild
After updating the console, sometimes cached configurations persist.
1. `flutter clean`
2. `flutter pub get`
3. Uninstall the app from the device/emulator.
4. `flutter run`
