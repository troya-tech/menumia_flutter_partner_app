# How to Deploy Firebase Realtime Database Rules

## Quick Method: Firebase Console (Recommended)

### Step 1: Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **adisyon-project**
3. Click on **Realtime Database** in the left menu
4. Click on the **Rules** tab

### Step 2: Copy and Paste Rules
Copy the rules from `database.rules.json` and paste them into the Firebase Console:

```json
{
  "rules": {
    "restaurantUsers": {
      ".indexOn": ["email"],
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "restaurants": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

### Step 3: Publish
Click the **Publish** button at the top right.

### Step 4: Verify
You should see a success message. The rules are now active immediately!

---

## Alternative: Firebase CLI (Optional)

If you want to use the Firebase CLI for deployment:

### Prerequisites
```bash
# Install Firebase CLI globally (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login
```

### Initialize Firebase (One-time setup)
```bash
# Run from project root
firebase init database

# Select:
# - Use an existing project
# - Choose: adisyon-project
# - Database rules file: database.rules.json
```

### Deploy Rules
```bash
# Deploy only database rules
firebase deploy --only database

# Or deploy everything
firebase deploy
```

---

## Verify Rules Are Active

### Method 1: Check Console
1. Go to Firebase Console → Realtime Database → Rules
2. You should see the `.indexOn` for `restaurantUsers`

### Method 2: Check App Logs
After deploying, run your app. You should NOT see this warning:
```
Using an unspecified index. Consider adding ".indexOn": "email"
```

If you still see the warning:
- Wait 30 seconds and try again (rules take a moment to propagate)
- Clear app cache and restart
- Check that you published the rules in the console

---

## Troubleshooting

### "Permission Denied" Error
**Cause:** Rules require authentication but user is not signed in.

**Solution:** Make sure user is authenticated before accessing the database.

### "Index Not Working" Warning
**Cause:** Rules were not published or haven't propagated yet.

**Solution:**
1. Verify rules are published in Firebase Console
2. Wait 30-60 seconds
3. Restart your app

### Rules Not Updating
**Cause:** Browser cache or rules not saved.

**Solution:**
1. Hard refresh the Firebase Console (Ctrl+Shift+R)
2. Re-publish the rules
3. Check the "Rules" tab shows your latest changes

---

## Current Project Configuration

- **Project ID:** adisyon-project
- **Database Rules File:** `database.rules.json`
- **Required Index:** `email` on `restaurantUsers`

---

## Important Notes

⚠️ **Security:** The current rules allow any authenticated user to read/write all data. For production, you should add more restrictive rules.

✅ **Index Performance:** The email index is required for efficient user lookups. Without it, queries will be slow.

🔄 **Deployment:** Rules changes are instant when published via console. No app restart needed.
