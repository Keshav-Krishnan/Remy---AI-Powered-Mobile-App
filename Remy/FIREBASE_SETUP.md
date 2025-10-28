# Firebase Setup Instructions

## Step 1: Add Firebase Package to Xcode

1. Open `Remy.xcodeproj` in Xcode
2. Select the project in the navigator (blue icon)
3. Select the "Remy" target
4. Go to "Package Dependencies" tab
5. Click the "+" button
6. Enter: `https://github.com/firebase/firebase-ios-sdk`
7. Click "Add Package"
8. Select the following products:
   - **FirebaseFirestore** (for database)
   - **FirebaseStorage** (for photos and audio files)
9. Click "Add Package"

## Step 2: Download GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (or create a new one)
3. Click "Add app" → iOS
4. Register your app with bundle ID: `dds.Remy`
5. Download `GoogleService-Info.plist`
6. Drag it into the `Remy/` folder in Xcode
7. Make sure "Copy items if needed" is checked
8. Ensure it's added to the Remy target

## Step 3: Initialize Firebase in RemyApp.swift

This has been done for you - check `RemyApp.swift`:

```swift
import Firebase

@main
struct RemyApp: App {
    init() {
        FirebaseApp.configure()
    }
    // ...
}
```

## Step 4: Set up Firestore Database

1. Go to Firebase Console → Firestore Database
2. Click "Create Database"
3. Start in **Test Mode** (for development)
4. Choose a location closest to you

### Create Collections

The app will auto-create these, but you can manually create them:

**Collection: `journal_entries`**
- Document ID: Auto-generated
- Fields:
  - `content` (string)
  - `journalType` (string)
  - `moodTag` (string)
  - `themeTag` (string)
  - `imageUri` (string, optional)
  - `audioUri` (string, optional)
  - `aiReflection` (map)
  - `timestamp` (timestamp)
  - `createdAt` (timestamp)

**Collection: `streaks`**
- Document ID: Use a consistent ID (e.g., "user_streak")
- Fields:
  - `currentStreak` (number)
  - `longestStreak` (number)
  - `lastEntryDate` (timestamp)

## Step 5: Set up Firebase Storage

1. Go to Firebase Console → Storage
2. Click "Get Started"
3. Start in **Test Mode**
4. Create these folders:
   - `/photos` - for photo journal images
   - `/audio` - for voice recording files

## Step 6: Configure Security Rules (Optional, for later)

### Firestore Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // Open for now, add auth later
    }
  }
}
```

### Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true; // Open for now, add auth later
    }
  }
}
```

## Step 7: Test Firebase Connection

After adding the package and GoogleService-Info.plist:

1. Build and run the app (⌘R)
2. Check the console for: "Firebase configuration success"
3. Try creating a journal entry
4. Check Firebase Console to see if data appears

## Troubleshooting

**Build errors about Firebase modules?**
- Clean build folder: Product → Clean Build Folder (⌘⇧K)
- Restart Xcode

**GoogleService-Info.plist not found?**
- Make sure it's in the same directory as Info.plist
- Check it's added to the Remy target (File Inspector)

**Firestore permission denied?**
- Make sure you started in Test Mode
- Check your security rules

## Environment Variables (For Later)

When you add authentication, store sensitive data in:
- Xcode build settings (User-Defined)
- Or use a Config.xcconfig file (not checked into git)

Never commit API keys to the repository!

---

**Status**: Package setup pending, service files ready
**Next**: Import Firebase packages in Xcode, then test FirebaseService.swift
