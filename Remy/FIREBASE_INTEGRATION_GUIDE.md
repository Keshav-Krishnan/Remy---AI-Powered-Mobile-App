# Firebase Integration Guide for Remy

## Complete Step-by-Step Firebase Setup

### Phase 1: Firebase Console Setup (15 minutes)

#### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `Remy` (or your preferred name)
4. Click "Continue"
5. **Google Analytics**: Toggle OFF (not needed for journaling app)
6. Click "Create project"
7. Wait for Firebase to provision your project
8. Click "Continue" when ready

#### Step 2: Add iOS App to Firebase
1. In Firebase console, click the iOS icon (⊕) to add an iOS app
2. **iOS bundle ID**: Enter `dds.Remy` (must match your Xcode project)
3. **App nickname** (optional): `Remy iOS`
4. **App Store ID**: Leave blank for now
5. Click "Register app"

#### Step 3: Download Configuration File
1. Click "Download GoogleService-Info.plist"
2. **IMPORTANT**: Save this file securely - it contains your Firebase credentials
3. Click "Next" (we'll add the file to Xcode in Phase 2)
4. Click "Next" on SDK setup (we'll do this manually)
5. Click "Continue to console"

#### Step 4: Enable Firestore Database
1. In Firebase Console, click "Firestore Database" in left sidebar
2. Click "Create database"
3. **Secure rules** for now: Select "Start in test mode"
   - ⚠️ Test mode allows read/write for 30 days
   - We'll update security rules later
4. **Cloud Firestore location**: Choose closest to your users
   - US: `us-central1` or `us-east1`
   - Europe: `europe-west1`
   - Asia: `asia-southeast1`
5. Click "Enable"
6. Wait for Firestore to provision (~30 seconds)

#### Step 5: Enable Firebase Storage
1. Click "Storage" in left sidebar
2. Click "Get started"
3. **Security rules**: Start in test mode
4. **Storage location**: Use same location as Firestore
5. Click "Done"

---

### Phase 2: Xcode Project Setup (20 minutes)

#### Step 6: Add GoogleService-Info.plist to Xcode
1. Open your Xcode project: `Remy.xcodeproj`
2. In Xcode, select the `Remy/Remy` folder in Project Navigator
3. Drag and drop `GoogleService-Info.plist` into the `Remy/Remy` folder
4. **IMPORTANT**: In the dialog, ensure:
   - ☑️ "Copy items if needed" is CHECKED
   - ☑️ "Remy" target is SELECTED
   - Click "Finish"
5. Verify: You should see `GoogleService-Info.plist` in your project

#### Step 7: Add Firebase SDK via Swift Package Manager
1. In Xcode, go to **File → Add Package Dependencies**
2. In the search bar, paste:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Click "Add Package"
4. **Dependency Rule**: Select "Up to Next Major Version"
   - Minimum: `11.0.0` (or latest)
5. Click "Add Package"
6. **Select packages to add** - CHECK these packages:
   - ☑️ `FirebaseAuth` (for future user authentication)
   - ☑️ `FirebaseFirestore` (for database)
   - ☑️ `FirebaseStorage` (for images/audio)
7. **Add to target**: Ensure "Remy" is selected
8. Click "Add Package"
9. **Wait**: This may take 2-5 minutes to download and integrate

#### Step 8: Initialize Firebase in App
1. Open `RemyApp.swift`
2. Add import at the top:
   ```swift
   import Firebase
   ```
3. Add initialization in the `init()` method:

```swift
import SwiftUI
import Firebase

@main
struct RemyApp: App {
    @StateObject private var journalViewModel = JournalViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        // Initialize Firebase
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(journalViewModel)
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
    }
}
```

4. **Build the project** (⌘B) to verify Firebase is integrated
5. You should see no errors

---

### Phase 3: Implement Firebase Service (30 minutes)

#### Step 9: Update FirebaseService.swift

Open `/Users/keshavkrishnan/Remy/Remy/Services/FirebaseService.swift` and replace with:

```swift
//
//  FirebaseService.swift
//  Remy
//
//  Created on 10/17/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

/// Service handling all Firebase interactions
class FirebaseService {
    // MARK: - Singleton
    static let shared = FirebaseService()

    // MARK: - Private Properties
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    // MARK: - Initialization
    private init() {
        // Configure Firestore settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true  // Enable offline persistence
        db.settings = settings
    }

    // MARK: - Journal Entries

    /// Save a journal entry to Firestore
    func saveEntry(_ entry: JournalEntry) async throws {
        let entryData: [String: Any] = [
            "id": entry.id.uuidString,
            "content": entry.content,
            "journalType": entry.journalType.rawValue,
            "moodTag": entry.moodTag?.rawValue ?? "",
            "themeTag": entry.themeTag?.rawValue ?? "",
            "imageUri": entry.imageUri ?? "",
            "audioUri": entry.audioUri ?? "",
            "timestamp": Timestamp(date: entry.timestamp),
            "createdAt": Timestamp(date: Date())
        ]

        try await db.collection("journal_entries").document(entry.id.uuidString).setData(entryData)
        print("[FirebaseService] ✅ Entry saved: \(entry.id)")
    }

    /// Load all journal entries
    func loadEntries() async throws -> [JournalEntry] {
        let snapshot = try await db.collection("journal_entries")
            .order(by: "timestamp", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { doc -> JournalEntry? in
            let data = doc.data()

            guard
                let idString = data["id"] as? String,
                let id = UUID(uuidString: idString),
                let content = data["content"] as? String,
                let journalTypeRaw = data["journalType"] as? String,
                let journalType = JournalType(rawValue: journalTypeRaw),
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue()
            else {
                print("[FirebaseService] ⚠️ Failed to parse entry: \(doc.documentID)")
                return nil
            }

            let moodTag = (data["moodTag"] as? String).flatMap { MoodTag(rawValue: $0) }
            let themeTag = (data["themeTag"] as? String).flatMap { ThemeTag(rawValue: $0) }
            let imageUri = data["imageUri"] as? String
            let audioUri = data["audioUri"] as? String

            return JournalEntry(
                id: id,
                content: content,
                journalType: journalType,
                moodTag: moodTag,
                themeTag: themeTag,
                imageUri: imageUri,
                audioUri: audioUri,
                timestamp: timestamp
            )
        }
    }

    /// Update an existing entry
    func updateEntry(_ entry: JournalEntry) async throws {
        let entryData: [String: Any] = [
            "content": entry.content,
            "moodTag": entry.moodTag?.rawValue ?? "",
            "themeTag": entry.themeTag?.rawValue ?? ""
        ]

        try await db.collection("journal_entries")
            .document(entry.id.uuidString)
            .updateData(entryData)
        print("[FirebaseService] ✅ Entry updated: \(entry.id)")
    }

    /// Delete an entry
    func deleteEntry(id: UUID) async throws {
        try await db.collection("journal_entries").document(id.uuidString).delete()
        print("[FirebaseService] ✅ Entry deleted: \(id)")
    }

    // MARK: - File Upload

    /// Upload image to Firebase Storage
    func uploadImage(_ imageData: Data, for entryId: UUID) async throws -> String {
        let storageRef = storage.reference().child("images/\(entryId.uuidString).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        print("[FirebaseService] ✅ Image uploaded: \(downloadURL.absoluteString)")
        return downloadURL.absoluteString
    }

    /// Upload audio to Firebase Storage
    func uploadAudio(_ audioData: Data, for entryId: UUID) async throws -> String {
        let storageRef = storage.reference().child("audio/\(entryId.uuidString).m4a")

        let metadata = StorageMetadata()
        metadata.contentType = "audio/m4a"

        _ = try await storageRef.putDataAsync(audioData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()

        print("[FirebaseService] ✅ Audio uploaded: \(downloadURL.absoluteString)")
        return downloadURL.absoluteString
    }

    // MARK: - Streak Data

    /// Save streak data
    func saveStreak(_ streakData: StreakData) async throws {
        let data: [String: Any] = [
            "currentStreak": streakData.currentStreak,
            "longestStreak": streakData.longestStreak,
            "lastEntryDate": streakData.lastEntryDate.map { Timestamp(date: $0) } ?? NSNull()
        ]

        try await db.collection("user_data").document("streak").setData(data)
        print("[FirebaseService] ✅ Streak saved")
    }

    /// Load streak data
    func loadStreak() async throws -> StreakData {
        let doc = try await db.collection("user_data").document("streak").getDocument()

        guard doc.exists, let data = doc.data() else {
            return StreakData()  // Return default if no data
        }

        let currentStreak = data["currentStreak"] as? Int ?? 0
        let longestStreak = data["longestStreak"] as? Int ?? 0
        let lastEntryDate = (data["lastEntryDate"] as? Timestamp)?.dateValue()

        return StreakData(
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastEntryDate: lastEntryDate
        )
    }
}
```

#### Step 10: Make JournalEntry Identifiable
Ensure `JournalEntry` has an `id` property. Open the JournalEntry model file and verify it has:

```swift
struct JournalEntry: Identifiable {
    let id: UUID
    var content: String
    var journalType: JournalType
    // ... other properties

    init(id: UUID = UUID(), content: String, journalType: JournalType, ...) {
        self.id = id
        // ...
    }
}
```

#### Step 11: Update JournalViewModel to Use Firebase

Update your `JournalViewModel.swift`:

```swift
import Foundation
import SwiftUI

@MainActor
class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var streakData = StreakData()

    private let firebaseService = FirebaseService.shared

    func loadEntries() async {
        isLoading = true
        errorMessage = nil

        do {
            entries = try await firebaseService.loadEntries()
            print("[JournalViewModel] ✅ Loaded \(entries.count) entries from Firebase")
        } catch {
            errorMessage = "Failed to load entries: \(error.localizedDescription)"
            print("[JournalViewModel] ❌ Error loading entries: \(error)")
            // Fallback to local mock data if Firebase fails
            loadMockData()
        }

        isLoading = false
    }

    func createEntry(_ entry: JournalEntry) async {
        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.saveEntry(entry)
            entries.insert(entry, at: 0)
            updateStreak()
            print("[JournalViewModel] ✅ Entry created")
        } catch {
            errorMessage = "Failed to save entry: \(error.localizedDescription)"
            print("[JournalViewModel] ❌ Error creating entry: \(error)")
        }

        isLoading = false
    }

    func updateEntry(_ entry: JournalEntry) async {
        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.updateEntry(entry)
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries[index] = entry
            }
            print("[JournalViewModel] ✅ Entry updated")
        } catch {
            errorMessage = "Failed to update entry: \(error.localizedDescription)"
            print("[JournalViewModel] ❌ Error updating entry: \(error)")
        }

        isLoading = false
    }

    func deleteEntry(id: UUID) async {
        isLoading = true
        errorMessage = nil

        do {
            try await firebaseService.deleteEntry(id: id)
            entries.removeAll { $0.id == id }
            print("[JournalViewModel] ✅ Entry deleted")
        } catch {
            errorMessage = "Failed to delete entry: \(error.localizedDescription)"
            print("[JournalViewModel] ❌ Error deleting entry: \(error)")
        }

        isLoading = false
    }

    private func updateStreak() {
        guard let lastEntry = entries.first else {
            streakData.currentStreak = 0
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastStreakDate = streakData.lastEntryDate {
            let lastStreakDay = calendar.startOfDay(for: lastStreakDate)
            let daysDifference = calendar.dateComponents([.day], from: lastStreakDay, to: today).day ?? 0

            if daysDifference == 0 {
                return  // Same day
            } else if daysDifference == 1 {
                streakData.currentStreak += 1  // Consecutive day
            } else {
                streakData.currentStreak = 1  // Streak broken
            }
        } else {
            streakData.currentStreak = 1  // First entry
        }

        streakData.lastEntryDate = today

        if streakData.currentStreak > streakData.longestStreak {
            streakData.longestStreak = streakData.currentStreak
        }

        // Save streak to Firebase
        Task {
            do {
                try await firebaseService.saveStreak(streakData)
            } catch {
                print("[JournalViewModel] ❌ Error saving streak: \(error)")
            }
        }
    }

    func entriesForType(_ type: JournalType) -> [JournalEntry] {
        entries.filter { $0.journalType == type }
    }

    func entriesForDate(_ date: Date) -> [JournalEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDate($0.timestamp, inSameDayAs: date) }
    }

    // Mock data for testing/offline
    private func loadMockData() {
        let mockEntries = [
            JournalEntry(
                content: "Today was a great day! I finished my project.",
                journalType: .quick,
                moodTag: .happy,
                themeTag: .work,
                timestamp: Date()
            ),
            JournalEntry(
                content: "Feeling grateful for my family and friends.",
                journalType: .gratitude,
                moodTag: .grateful,
                themeTag: .family,
                timestamp: Date().addingTimeInterval(-86400)
            )
        ]

        self.entries = mockEntries
        self.streakData = StreakData(currentStreak: 3, longestStreak: 7)
    }
}
```

---

### Phase 4: Update Firestore Security Rules (10 minutes)

#### Step 12: Secure Your Database
⚠️ **IMPORTANT**: Test mode expires in 30 days. Update rules before deploying.

1. Go to Firebase Console → Firestore Database → Rules
2. Replace with these rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Journal entries - read/write for all users (update when auth is added)
    match /journal_entries/{entryId} {
      allow read, write: if true;  // ⚠️ Update to: if request.auth != null;
    }

    // User data (streaks, settings)
    match /user_data/{document=**} {
      allow read, write: if true;  // ⚠️ Update to: if request.auth != null;
    }
  }
}
```

3. Click "Publish"

**For production (after adding Firebase Auth):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /journal_entries/{entryId} {
      allow read, write: if request.auth != null;
    }

    match /user_data/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Step 13: Update Storage Security Rules

1. Go to Firebase Console → Storage → Rules
2. Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /images/{imageId} {
      allow read, write: if true;  // ⚠️ Update to: if request.auth != null;
    }

    match /audio/{audioId} {
      allow read, write: if true;  // ⚠️ Update to: if request.auth != null;
    }
  }
}
```

3. Click "Publish"

---

### Phase 5: Testing Firebase Integration (15 minutes)

#### Step 14: Test Database Operations

1. **Run the app** in Simulator or device
2. **Create a journal entry**:
   - Open the app
   - Tap "New Entry" → "Quick Journal"
   - Write something: "Testing Firebase integration!"
   - Tap "Save Entry"
3. **Verify in Firebase Console**:
   - Go to Firestore Database
   - You should see `journal_entries` collection
   - Click on it to see your entry

4. **Test offline support**:
   - Turn OFF internet on your device
   - Create another entry
   - Turn internet back ON
   - Entry should sync automatically

#### Step 15: Monitor Firebase Usage

1. Go to Firebase Console → Project Overview
2. Check **Usage** section:
   - Firestore: Reads/Writes
   - Storage: Stored data
3. **Free tier limits** (Spark Plan):
   - Firestore: 50K reads, 20K writes per day
   - Storage: 5GB stored, 1GB downloaded per day

---

### Phase 6: Add Firebase Authentication (Optional - 20 minutes)

#### Step 16: Enable Email/Password Auth

1. Firebase Console → Authentication
2. Click "Get started"
3. Click "Email/Password" → Enable
4. Click "Save"

#### Step 17: Enable Apple Sign In

1. In Authentication → Sign-in method
2. Click "Apple" → Enable
3. You'll need:
   - Apple Developer account
   - App ID with Sign in with Apple capability
   - Service ID
4. Follow Firebase instructions to configure

#### Step 18: Implement Auth in App

Create `AuthService.swift`:

```swift
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    private init() {}

    func signInAnonymously() async throws -> User {
        let result = try await Auth.auth().signInAnonymously()
        return result.user
    }

    func signInWithEmail(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        return result.user
    }

    func signUpWithEmail(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    var currentUser: User? {
        Auth.auth().currentUser
    }
}
```

---

## Troubleshooting Common Issues

### Issue 1: "GoogleService-Info.plist not found"
**Solution**: Verify the file is in the correct location and added to target
- Open Xcode → Project Navigator
- Select `GoogleService-Info.plist`
- In File Inspector (right panel), ensure "Remy" target is checked

### Issue 2: Build errors with Firebase SDK
**Solution**: Clean build folder
1. Xcode → Product → Clean Build Folder (⇧⌘K)
2. Close Xcode
3. Delete `~/Library/Developer/Xcode/DerivedData/Remy-*`
4. Reopen Xcode and rebuild

### Issue 3: "Firebase app not initialized"
**Solution**: Ensure `FirebaseApp.configure()` is called before any Firebase usage
- Must be in `RemyApp.init()` before `body` is accessed

### Issue 4: Firestore permission denied
**Solution**: Check security rules
- Ensure rules allow read/write: `if true` for testing
- Add authentication for production

### Issue 5: Offline writes not syncing
**Solution**: Enable persistence
```swift
let settings = FirestoreSettings()
settings.isPersistenceEnabled = true
db.settings = settings
```

---

## Performance Optimization

### 1. Enable Persistence (Already Done)
Allows offline access and reduces network usage.

### 2. Use Pagination for Large Lists
```swift
func loadEntriesPaginated(limit: Int = 20) async throws -> [JournalEntry] {
    let snapshot = try await db.collection("journal_entries")
        .order(by: "timestamp", descending: true)
        .limit(to: limit)
        .getDocuments()
    // ...
}
```

### 3. Index Firestore Queries
Firebase will prompt you to create indexes for complex queries via console link.

### 4. Compress Images Before Upload
```swift
let compressedImage = image.jpegData(compressionQuality: 0.7)
```

---

## Cost Management

### Free Tier Limits (Spark Plan)
- **Firestore**: 1 GB storage, 50K reads, 20K writes per day
- **Storage**: 5 GB stored, 1 GB/day downloaded
- **Authentication**: Unlimited

### Upgrade to Blaze Plan (Pay-as-you-go)
- Required for: Cloud Functions, more storage
- **Pricing**:
  - Firestore: $0.06 per 100K reads
  - Storage: $0.026/GB per month
  - Free tier still applies

---

## Next Steps

1. ✅ Firebase is now fully integrated!
2. **Test thoroughly** with different entry types
3. **Add Firebase Auth** when ready for production
4. **Set up Cloud Functions** for AI processing (optional)
5. **Enable Analytics** to track usage
6. **Set up Crashlytics** for error reporting

---

## Additional Resources

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firestore Documentation](https://firebase.google.com/docs/firestore)
- [Firebase Storage Documentation](https://firebase.google.com/docs/storage)
- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)

---

**Questions or Issues?**
Check Firebase Console → Project Settings → Service Accounts for debugging credentials.
