# Email-Based User Lookup

## Overview

The application uses **email-based lookup** to match authenticated users with their database profiles. This means users are identified by their email address rather than their Firebase Auth UID.

## How It Works

1. User signs in with Google (or other auth provider)
2. Firebase Auth creates a session with a UID
3. App retrieves the user's email from Firebase Auth
4. App queries the database for a user with that email
5. User profile is loaded and displayed

## Database Structure

Users can be stored with **any ID** in the database. The email field is used for lookup:

```json
{
  "restaurantUsers": {
    "user-001": {
      "email": "john@example.com",
      "displayName": "John Doe",
      "relatedRestaurantsIds": ["restaurant-1", "restaurant-2"],
      "role": "admin",
      "isActive": true,
      "createdAt": "2026-02-03T20:00:00.000Z",
      "updatedAt": "2026-02-03T20:00:00.000Z"
    },
    "user-002": {
      "email": "jane@example.com",
      "displayName": "Jane Smith",
      "relatedRestaurantsIds": ["restaurant-1"],
      "role": "manager",
      "isActive": true,
      "createdAt": "2026-02-03T20:00:00.000Z",
      "updatedAt": "2026-02-03T20:00:00.000Z"
    }
  }
}
```

## Firebase Indexing Requirement

For optimal performance, you **must** add an index on the `email` field in your Firebase Realtime Database rules:

### How to Add the Index

1. Go to Firebase Console
2. Navigate to **Realtime Database** → **Rules**
3. Add the following rule:

```json
{
  "rules": {
    "restaurantUsers": {
      ".indexOn": ["email"],
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

4. Click **Publish**

### Why Indexing is Important

- **Without index**: Queries scan the entire database (slow, may fail on large datasets)
- **With index**: Queries use O(log n) lookup (fast, efficient)
- Firebase will show a warning in the console if the index is missing

## Adding New Users

To add a new user to the database:

### Option 1: Firebase Console (Manual)

1. Go to Firebase Console → Realtime Database
2. Navigate to `restaurantUsers`
3. Click **+** to add a child
4. Use any unique ID (e.g., `user-003`, or use auto-generated push ID)
5. Add the user data:
   ```json
   {
     "email": "newuser@example.com",
     "displayName": "New User",
     "relatedRestaurantsIds": ["restaurant-1"],
     "role": "staff",
     "isActive": true,
     "createdAt": "2026-02-03T20:00:00.000Z",
     "updatedAt": "2026-02-03T20:00:00.000Z"
   }
   ```

### Option 2: Programmatically

Use the `RestaurantUserService.createUser()` method:

```dart
final newUser = RestaurantUser(
  id: '', // Will be auto-generated
  email: 'newuser@example.com',
  displayName: 'New User',
  relatedRestaurantsIds: ['restaurant-1'],
  role: 'staff',
  isActive: true,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final userId = await restaurantUserService.createUser(newUser);
print('Created user with ID: $userId');
```

## Troubleshooting

### User Not Found After Sign-In

**Symptom:** Profile page shows "User Profile Not Found" after successful sign-in.

**Check the logs:**
```
[ProfilePageFacade] 📦 "User email": user@example.com
[FirebaseRestaurantUserRepository] ⚠️ "User not found in database with email: user@example.com"
```

**Solution:**
1. Verify the user exists in `restaurantUsers` node
2. Check that the `email` field matches exactly (case-sensitive)
3. Ensure the email index is set up in Firebase rules

### Slow Queries

**Symptom:** Long delay when loading profile page.

**Check Firebase Console:**
- Look for warning: "Using an unspecified index. Consider adding '.indexOn'"

**Solution:**
- Add the email index as described above

### Multiple Users with Same Email

**Symptom:** Unexpected user data loaded.

**Cause:** Multiple users in the database have the same email address.

**Solution:**
- Ensure email uniqueness in your database
- The query uses `limitToFirst(1)` so it will return the first match
- Consider adding validation to prevent duplicate emails

## Benefits of Email-Based Lookup

1. **Flexible User IDs**: Users don't need to have Firebase Auth UID as their database ID
2. **Easier Management**: Can create users with readable IDs like `user-001`, `user-002`
3. **Migration Friendly**: Easy to import existing user data
4. **Natural Matching**: Email is the natural identifier for users
5. **No Manual UID Matching**: Don't need to know the Auth UID when creating users

## Migration from UID-Based Lookup

If you previously used UID-based lookup:

1. **No immediate action needed** - Both methods work
2. **For new users**: Use any ID structure, just ensure email field is present
3. **For existing users**: They will continue to work if they have an email field
4. **Recommendation**: Gradually migrate to descriptive IDs for better organization

## Security Considerations

- Email queries require authentication (user must be signed in)
- Firebase rules should restrict read/write access appropriately
- Email field should be validated to ensure proper format
- Consider adding email uniqueness validation in your security rules

## Example Firebase Security Rules

```json
{
  "rules": {
    "restaurantUsers": {
      ".indexOn": ["email"],
      ".read": "auth != null",
      "$userId": {
        ".write": "auth != null && (
          root.child('restaurantUsers').child($userId).child('email').val() == auth.token.email ||
          root.child('admins').child(auth.uid).exists()
        )",
        ".validate": "newData.hasChildren(['email', 'displayName', 'relatedRestaurantsIds', 'role', 'isActive'])",
        "email": {
          ".validate": "newData.isString() && newData.val().matches(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,}$/i)"
        }
      }
    }
  }
}
```

This ensures:
- Users can only edit their own profile (or admins can edit any)
- Email format is validated
- Required fields are enforced
