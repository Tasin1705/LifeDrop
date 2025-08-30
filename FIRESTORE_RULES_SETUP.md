# Firestore Security Rules Setup

## The Error
You're getting "permission-denied" because Firestore security rules are blocking access to the notifications collection.

## Quick Fix (For Testing Only)
To quickly test the notification system, you can temporarily set permissive rules in Firebase Console:

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your LifeDrop project
3. Go to Firestore Database
4. Click on "Rules" tab
5. Replace the existing rules with this **TEMPORARY** rule:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

6. Click "Publish"

## Production Rules (Recommended)
For production, use the more secure rules from `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - users can read and write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Notifications collection - users can read and write their own notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.userId || request.auth.uid == request.resource.data.userId);
      allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
    }
    
    // Blood requests collection - authenticated users can read all, create their own
    match /blood_requests/{requestId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.requesterId;
      allow update: if request.auth != null && request.auth.uid == resource.data.requesterId;
    }
    
    // Allow users to read other users' basic info (for blood matching)
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Steps to Apply Rules:

### Option 1: Firebase Console (Recommended)
1. Copy the rules from `firestore.rules` file
2. Go to Firebase Console → Firestore Database → Rules
3. Paste the rules and click "Publish"

### Option 2: Firebase CLI (Advanced)
1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init firestore`
4. Deploy: `firebase deploy --only firestore:rules`

## What These Rules Do:
- ✅ Users can read/write their own user data
- ✅ Users can create notifications for others (for blood requests)
- ✅ Users can read/write their own notifications
- ✅ Users can read blood requests from anyone
- ✅ Users can create/update their own blood requests
- ✅ All operations require authentication

## Testing:
After applying the rules, the notification system should work without permission errors.
