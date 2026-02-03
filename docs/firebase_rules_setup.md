# Firebase Database Rules - Quick Setup

## Required Index for Email-Based Lookup

Add this to your Firebase Realtime Database rules:

```json
{
  "rules": {
    "restaurantUsers": {
      ".indexOn": ["email"]
    }
  }
}
```

## Complete Rules Example (Recommended)

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

## How to Apply

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Realtime Database** → **Rules**
4. Paste the rules above
5. Click **Publish**

## Verify It's Working

After publishing, you should NOT see this warning in the console:
```
Using an unspecified index. Consider adding ".indexOn": "email" at /restaurantUsers
```

If you still see the warning, wait a few seconds and refresh the page.
