# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Remy is an AI-powered journaling app built with SwiftUI. The app supports multiple journal types (quick, personal, photo, gratitude), voice recording with transcription, mood and theme tracking, and AI-powered reflections using OpenAI. The backend is Firebase (without authentication initially), and the app is designed for iOS 18.5+, macOS 15.5+, and visionOS 2.5+.

## Build Commands

### Building the App
```bash
# Build for all platforms
xcodebuild -project Remy.xcodeproj -scheme Remy -configuration Debug build

# Build for specific destination (iOS Simulator)
xcodebuild -project Remy.xcodeproj -scheme Remy -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for macOS
xcodebuild -project Remy.xcodeproj -scheme Remy -destination 'platform=macOS' build
```

### Running Tests
```bash
# Run all tests (unit + UI tests)
xcodebuild test -project Remy.xcodeproj -scheme Remy -destination 'platform=iOS Simulator,name=iPhone 16'

# Run only unit tests
xcodebuild test -project Remy.xcodeproj -scheme Remy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RemyTests

# Run only UI tests
xcodebuild test -project Remy.xcodeproj -scheme Remy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RemyUITests

# Run a specific test
xcodebuild test -project Remy.xcodeproj -scheme Remy -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:RemyTests/RemyTests/example
```

### Cleaning Build Artifacts
```bash
xcodebuild clean -project Remy.xcodeproj -scheme Remy
```

## Architecture

### Project Structure (MVVM)
```
Remy/
├── Models/              # Data models
│   ├── JournalEntry.swift
│   ├── MoodTag.swift
│   ├── ThemeTag.swift
│   ├── JournalType.swift
│   ├── AIReflection.swift
│   └── StreakData.swift
├── Views/
│   ├── Screens/         # Full screen views
│   │   ├── MainTabView.swift
│   │   ├── HomeScreen.swift
│   │   ├── JournalScreen.swift
│   │   ├── DashboardScreen.swift
│   │   └── QuickJournalScreen.swift
│   └── Components/      # Reusable UI components
│       ├── MoodSelector.swift
│       ├── ThemeSelector.swift
│       └── StreakProgress.swift
├── ViewModels/          # Business logic (to be implemented)
├── Services/            # Firebase, OpenAI, Audio services (to be implemented)
├── Utils/               # Helper functions
├── Extensions/          # Swift extensions
│   ├── Color+Hex.swift
│   └── Font+Remy.swift
├── RemyApp.swift        # App entry point
├── ContentView.swift    # Root view
├── Info.plist           # Permissions and configuration
└── Assets.xcassets/     # Images and colors
```

### Data Models
- **JournalEntry**: Core model for all journal entries with content, type, mood, theme, and AI reflection
- **MoodTag**: 8 moods (happy, grateful, excited, neutral, sad, anxious, stressed, angry) with colors and scores
- **ThemeTag**: 8 themes (personal, work, relationships, family, health, goals, hobbies, school) with colors
- **JournalType**: Types of journals (quick, personal, photo, gratitude, goals, reflection, dreams, travel)
- **AIReflection**: AI-generated insights with summary, dominant emotion, follow-up questions, and suggestions
- **StreakData**: Tracking current and longest journaling streaks

### Design System
**Colors**: Defined in `Color+Hex.swift`
- Brand: remyBrown (#8B5A3C), remyCream (#FDF8F6), remyBeige (#E8DCD1), remyDarkBrown (#5D3A1A)
- Mood colors: Each mood has a unique color (see MoodTag.swift)
- Theme colors: Each theme has a unique color (see ThemeTag.swift)

**Typography**: Defined in `Font+Remy.swift`
- remyTitle, remyHeadline, remyBody, remyCaption

**Spacing**: CGFloat extensions (.xxs to .xxl)

**Shadows**: `remyCardShadow()` view modifier

### Navigation Flow
1. **MainTabView**: 3-tab layout (Home, Journal, Insights)
2. **HomeScreen**: Quick actions, streak progress, gratitude widget
3. **JournalScreen**: List of entries with filters by type
4. **DashboardScreen**: Analytics and insights (charts to be implemented)
5. **Modal screens**: QuickJournalScreen (sheet presentation)

### Key Features to Implement
1. **Firebase Integration**: Firestore for storing entries, no auth initially
2. **OpenAI Integration**: GPT-3.5 for AI reflections, Whisper for transcription
3. **Audio Recording**: AVFoundation for voice journals
4. **Photo Capture**: Camera and photo library integration
5. **Streak Tracking**: Calculate and update streaks based on entry dates
6. **Analytics**: Charts for mood trends, theme distribution, calendar heatmap

### Testing Frameworks
- **Unit Tests**: Swift Testing framework (imported as `Testing`)
  - Test functions are marked with `@Test` attribute
  - Use `#expect(...)` for assertions
- **UI Tests**: XCTest with XCUIApplication
  - Standard XCTest class-based approach
  - Launch performance tests included

### Permissions (Info.plist)
The app requests the following permissions:
- **NSMicrophoneUsageDescription**: For voice journal entries
- **NSCameraUsageDescription**: For photo journals
- **NSPhotoLibraryUsageDescription**: To select photos from library
- **NSPhotoLibraryAddUsageDescription**: To save photos to library
- **NSSpeechRecognitionUsageDescription**: For voice transcription

### Platform Support
The app is configured as a universal binary supporting:
- iPhone and iPad (iOS 18.5+)
- Mac (macOS 15.5+)
- Apple Vision Pro (visionOS 2.5+)

Build settings automatically select the appropriate SDK based on the destination platform.

## Firebase Setup (To Do)

### Installation via SPM
1. Add Firebase package: `https://github.com/firebase/firebase-ios-sdk`
2. Select packages: FirebaseFirestore, FirebaseStorage (for photos/audio)

### Configuration
1. Download `GoogleService-Info.plist` from Firebase Console
2. Add to Remy/ directory in Xcode
3. Initialize Firebase in `RemyApp.swift`:
```swift
import Firebase

@main
struct RemyApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### Firestore Schema
**Collection: `journal_entries`**
```
{
  id: UUID,
  content: String,
  journalType: String,
  moodTag: String?,
  themeTag: String?,
  imageUri: String?,
  audioUri: String?,
  aiReflection: {
    summary: String,
    dominantEmotion: String,
    followUp: String,
    ...
  },
  timestamp: Timestamp,
  createdAt: Timestamp
}
```

**Collection: `streaks`**
```
{
  currentStreak: Int,
  longestStreak: Int,
  lastEntryDate: Timestamp
}
```

## OpenAI Setup (To Do)

### API Key Storage
Store API key securely in Keychain, not in code or Info.plist.

### Services to Implement
1. **AIService**: Chat completions for journal analysis
2. **TranscriptionService**: Whisper API for voice-to-text

## Development Notes

### Xcode Project Management
- The project uses Xcode's file system synchronized groups
- Files are automatically discovered from the filesystem
- When adding new Swift files, place them in the appropriate directory

### SwiftUI Previews
SwiftUI previews are enabled. Use `#Preview` macro for live previews in Xcode.

### Code Signing
Currently set to Automatic code signing. The bundle identifier is `dds.Remy`.
