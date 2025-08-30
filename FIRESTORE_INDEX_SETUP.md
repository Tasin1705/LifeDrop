# Firestore Index Setup Guide

## Problem: "Query requires index" Error

When you see this error, it means Firestore needs a composite index for your query. This happens when you use multiple fields in queries (like `where` + `orderBy`).

## Immediate Fix Applied

I've updated the notification service to use a simpler query that doesn't require an index:

- ✅ **Before**: `where('userId') + orderBy('createdAt')` (required index)
- ✅ **After**: `where('userId')` only (no index needed)
- ✅ **Sorting**: Done manually in the app code

## Method 1: Automatic Index Creation (Recommended)

1. **Run your app** and try to view notifications
2. **Check the console/debug output** - you should see a URL like:
   ```
   https://console.firebase.google.com/project/your-project/firestore/indexes?create_composite=...
   ```
3. **Click the URL** - it will automatically create the required index
4. **Wait 5-10 minutes** for the index to build
5. **Try again** - the error should be gone

## Method 2: Manual Index Creation

1. Go to Firebase Console: https://console.firebase.google.com
2. Select your LifeDrop project
3. Go to **Firestore Database** → **Indexes** tab
4. Click **Create Index**
5. Set up the composite index:

### For Notifications Collection:
```
Collection ID: notifications
Fields:
  - userId (Ascending)
  - createdAt (Descending)
Query Scope: Collection
```

### For Blood Requests Collection (if needed):
```
Collection ID: blood_requests
Fields:
  - requesterId (Ascending)
  - createdAt (Descending)
Query Scope: Collection
```

## Method 3: Firebase CLI (Advanced)

Create `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "createdAt",
          "order": "DESCENDING"
        }
      ]
    },
    {
      "collectionGroup": "notifications",
      "queryScope": "COLLECTION",
      "fields": [
        {
          "fieldPath": "userId",
          "order": "ASCENDING"
        },
        {
          "fieldPath": "isRead",
          "order": "ASCENDING"
        }
      ]
    }
  ]
}
```

Then run:
```bash
firebase deploy --only firestore:indexes
```

## Current Status

✅ **Quick Fix Applied**: The app now works without requiring indexes
✅ **Manual Sorting**: Notifications are sorted by date in the app
✅ **No Index Required**: The main query only uses `where('userId')`

## Optional: Enable Ordered Queries

If you want to use the ordered query (faster performance), create the index and then update the notification service:

```dart
// In notification_service.dart, replace getUserNotifications with:
static Stream<QuerySnapshot> getUserNotifications(String userId) {
  return _firestore
      .collection('notifications')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots();
}
```

## Verification

After applying any fix:
1. ✅ Open the app
2. ✅ Go to notifications screen
3. ✅ Should load without "requires index" error
4. ✅ Notifications should be sorted by date (newest first)

The notification system should now work properly!
