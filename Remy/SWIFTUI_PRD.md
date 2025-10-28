# Remy Journal - SwiftUI Product Requirements Document

## Executive Summary

**App Name:** Remy Journal
**Platform:** iOS (Native SwiftUI)
**Current Stack:** React Native + Expo
**Target Stack:** SwiftUI + UIKit (Hybrid)
**Bundle ID:** com.remy.journal.keshavkrishnan
**Minimum iOS Version:** 15.1

### Purpose
Remy is an AI-powered journaling app that combines voice recording, photo journaling, and text entries with intelligent AI reflections powered by OpenAI. The app provides personalized therapeutic insights, tracks moods and themes, and helps users maintain journaling streaks.

---

## Table of Contents
1. [App Architecture](#app-architecture)
2. [Authentication & User Flow](#authentication--user-flow)
3. [Core Features](#core-features)
4. [Screens Breakdown](#screens-breakdown)
5. [Components Library](#components-library)
6. [Data Models](#data-models)
7. [Third-Party Services](#third-party-services)
8. [Permissions & Capabilities](#permissions--capabilities)
9. [Design System](#design-system)
10. [State Management](#state-management)
11. [API Integration](#api-integration)
12. [Migration Checklist](#migration-checklist)

---

## App Architecture

### Navigation Structure
```
Root Navigator (SwiftUI NavigationStack)
├── SplashScreen (animated intro)
├── Onboarding Flow (first time users)
├── Authentication Screen
└── Main App (authenticated users)
    ├── Tab Navigation (3 tabs)
    │   ├── Home Tab
    │   ├── Journal Tab
    │   └── Insights/Dashboard Tab
    └── Modal Screens (NavigationStack presentations)
        ├── Quick Journal Entry
        ├── Personal Journal Entry
        ├── Photo Journal Entry
        ├── Journal Type Selection
        ├── Folder View
        └── Journal Types Management
```

### Tech Stack Requirements

#### Core Frameworks
- **SwiftUI**: Primary UI framework
- **UIKit**: For advanced features (camera, audio recording)
- **Combine**: Reactive state management
- **Swift Concurrency**: async/await for network calls
- **AVFoundation**: Audio recording and playback
- **Speech**: Speech recognition (built-in iOS)
- **CoreData** or **SwiftData**: Local data persistence
- **Keychain**: Secure credential storage

#### Third-Party Dependencies (SPM)
- **Firebase Swift SDK**: Backend & auth (`supabase-swift`)
- **OpenAI Swift SDK** or URLSession: AI features
- **Lottie for iOS** (optional): Animations
- **SwiftUI Charts**: Dashboard analytics (iOS 16+) or fallback to custom charts

---

## Authentication & User Flow

### Onboarding Flow
1. **SplashScreen**
   - Show app logo (newpen.png) with animation
   - Fade transition to next screen
   - Duration: 2 seconds

2. **OnboardingScreen** (first-time users only)
   - Store completion flag in UserDefaults: `onboardingComplete`
   - Multi-page carousel with features
   - Skip button
   - Final CTA: "Get Started"

3. **AuthScreen**
   - Email/password authentication
   - Sign In / Sign Up toggle
   - Email validation
   - Password requirements (min 6 characters)
   - Loading states
   - Error handling with alerts

### Authentication Service (Supabase)
```swift
class AuthService {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func deleteAccount(userId: String) async throws
    func getSession() async throws -> Session?
}
```

### User Model
```swift
struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    var displayName: String
    var photoURL: String?
    var createdAt: Date
}
```

---

## Core Features

### 1. Journal Entry Types

#### Quick Journal
- **Purpose**: Fast, simple text entries
- **Features**:
  - Text input with character limit display
  - Quick prompts (8 rotating prompts)
  - Mood selection (8 moods)
  - Theme selection (8 themes)
  - AI reflection generation
  - Save and cancel actions
  - Celebration modal on first entry

#### Personal Journal
- **Purpose**: Detailed, long-form entries
- **Features**:
  - Voice recording with live transcription
  - Text editing
  - Mood and theme tagging
  - AI reflection
  - Auto-save functionality
  - Audio playback

#### Photo Journal
- **Purpose**: Visual journaling with images
- **Features**:
  - Camera integration
  - Photo library access
  - Image with caption
  - Mood and theme tagging
  - AI reflection on image + caption
  - Photo grid display

#### Gratitude Journal
- **Purpose**: Daily gratitude practice
- **Features**:
  - Quick widget on Home screen
  - Simple text input
  - Automatic "grateful" mood tag
  - Streak tracking

### 2. AI-Powered Reflections

**Provider**: OpenAI GPT-3.5-turbo

**Capabilities**:
- Personalized therapeutic insights based on user context
- Mood detection and analysis
- Theme extraction
- Follow-up questions for deeper reflection
- Growth suggestions
- Mood trend analysis

**User Context System**:
```swift
struct UserContext {
    let displayName: String
    let totalEntries: Int
    let currentStreak: Int
    let journalingFrequency: String  // daily, weekly, when-needed
    let journalingGoal: String       // self-reflection, stress-relief, personal-growth
    let expressionPreference: String  // writing, voice, both
    let moodHistory: [String]
    let themeHistory: [String]
}
```

**AI Response Structure**:
```swift
struct AIReflection: Codable {
    let summary: String              // 2-3 sentence personalized summary
    let dominantEmotion: String      // Detected primary emotion
    let followUp: String             // Therapeutic question
    let personalizedInsight: String? // Pattern observation
    let moodTrend: String?          // Emotional pattern analysis
    let growthSuggestion: String?   // Actionable advice
}
```

### 3. Streaks & Gamification

**Streak System**:
- Current streak calculation (consecutive days)
- Longest streak tracking
- Streak visualization (calendar heatmap)
- Milestone celebrations:
  - First entry
  - 7-day streak
  - 30-day streak
  - Custom milestones

**Achievement Modals**:
- Animated celebration screen
- Confetti/lottie animations
- Encouraging messages
- Share functionality (optional)

### 4. Dashboard & Insights

**Analytics Displayed**:
1. **Mood Trends**
   - Line chart (last 30 days)
   - Pie chart (mood distribution)
   - Mood scores: happy(5), excited(4), grateful(4), neutral(3), anxious(2), stressed(2), sad(1), angry(1)

2. **Theme Analysis**
   - Most common themes
   - Theme distribution chart
   - Theme-mood correlations

3. **Activity Tracking**
   - Monthly calendar heatmap
   - Entry frequency
   - Consistency score

4. **Entry Statistics**
   - Total entries
   - Entries by type (quick, personal, photo, gratitude)
   - Average entries per week

5. **Emotional Volatility**
   - Standard deviation of mood scores
   - Trend indicators

### 5. Audio Recording & Transcription

#### Recording Implementation
**Framework**: AVFoundation

```swift
class AudioRecorderService: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var recordingDuration: TimeInterval = 0

    func startRecording() async throws -> URL
    func stopRecording() async throws -> URL
    func cleanup() async throws
}
```

**Settings**:
- Audio mode: allow recording
- Play in silent mode: true
- Audio quality: HIGH_QUALITY (44.1kHz)
- Format: `.wav` or `.m4a`

#### Transcription Methods
1. **Primary**: OpenAI Whisper API
   - Endpoint: `https://api.openai.com/v1/audio/transcriptions`
   - Model: `whisper-1`
   - Language: `en`
   - Handles file upload via multipart/form-data

2. **Fallback**: iOS Speech Recognition
   - Framework: `Speech`
   - Requires permission: `NSSpeechRecognitionUsageDescription`
   - Real-time transcription
   - Works offline

---

## Screens Breakdown

### 1. SplashScreen
**Purpose**: App launch animation
**Duration**: 2 seconds
**Design**:
- Background: `#FDF8F6` (cream/beige)
- Center logo: newpen.png
- Fade in → scale animation → fade out
- Transitions to onboarding or auth

**SwiftUI Implementation**:
```swift
struct SplashScreen: View {
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8

    var body: some View {
        ZStack {
            Color(hex: "FDF8F6")
                .ignoresSafeArea()

            Image("newpen")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                opacity = 1
                scale = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                // Navigate to next screen
            }
        }
    }
}
```

### 2. AuthScreen
**Layout**:
- Title: "Welcome to Remy"
- Email text field (with email keyboard)
- Password secure field
- Sign In / Sign Up segmented control or toggle
- Primary action button
- Error message display
- Loading spinner overlay

**Validation**:
- Email format check
- Password minimum 6 characters
- Async error handling from Supabase

### 3. HomeScreen (Main Tab)
**Sections**:
1. **Header**
   - Greeting: "Welcome back, [DisplayName]"
   - Date display
   - Settings icon (top right)

2. **Quick Actions Card**
   - "Quick Entry" button (rounded, gradient)
   - "Voice Entry" button
   - "Photo Entry" button

3. **Streak Progress Widget**
   - Current streak count
   - Longest streak
   - Calendar visualization
   - Tap to view history

4. **Gratitude Widget** (collapsible)
   - "What are you grateful for today?"
   - Quick text input
   - Submit button

5. **Quick Entries Review**
   - Horizontal scrolling list
   - Last 5-10 quick entries
   - Tap to expand
   - Entry cards: date, mood icon, preview text

6. **Photo Journal Grid**
   - 2x2 grid of recent photo entries
   - Tap to view full entry

**Navigation Actions**:
- Quick Entry → QuickJournalScreen (modal)
- Voice Entry → PersonalJournalScreen (modal)
- Photo Entry → PhotoJournalScreen (modal)
- Settings → SettingsModal (sheet)

### 4. JournalScreen (Journal Tab)
**Purpose**: Browse all entries by type

**Layout**:
1. **Filter Bar**
   - Horizontal scrolling buttons
   - Options: All, Personal, Photo, Quick, Gratitude, Goals
   - Active filter highlighted

2. **Entries List**
   - Reverse chronological order
   - Grouped by date (Today, Yesterday, This Week, etc.)
   - Entry cards:
     - Journal type icon
     - Mood icon
     - Theme tag
     - Timestamp
     - Content preview (2-3 lines)
     - AI reflection preview
     - Tap to expand

3. **Empty State**
   - Illustration
   - "No entries yet" message
   - "Create your first entry" CTA

**Features**:
- Pull to refresh
- Infinite scroll / pagination
- Swipe actions: Edit, Delete
- Search functionality (optional)

### 5. DashboardScreen (Insights Tab)
**Sections**:
1. **Summary Stats** (cards)
   - Total entries
   - Current streak
   - Entries this week
   - Consistency score

2. **Mood Trends Graph**
   - Line chart: Mood score over time (30 days)
   - X-axis: Dates
   - Y-axis: Mood score (1-5)
   - Tap data points for details

3. **Mood Distribution**
   - Pie chart or donut chart
   - Color-coded by mood
   - Percentage labels

4. **Theme Insights**
   - Horizontal bar chart
   - Most common themes
   - Count per theme

5. **Monthly Calendar**
   - Heatmap style
   - Color intensity = entry frequency
   - Tap date to view entries

6. **Consistency Score**
   - Circular progress indicator
   - Based on entry frequency vs goal

7. **Settings/Account Section**
   - Edit preferences
   - Delete account option
   - Sign out

### 6. QuickJournalScreen (Modal)
**Layout**:
- Navigation bar:
  - Close button (X)
  - Title: "Quick Entry"
- Quick Prompts:
  - Horizontal scrolling chips
  - 8 prompts rotation
- Text Editor:
  - Multi-line text field
  - Placeholder: "What's on your mind?"
  - Character count (optional limit: 500)
- Mood Selector:
  - Horizontal scrolling mood icons
  - 8 moods with colors
- Theme Selector:
  - Horizontal scrolling theme icons
  - 8 themes with colors
- Action Buttons:
  - Cancel (secondary)
  - Save (primary gradient button)
- Loading state during AI analysis
- Success celebration modal

**Moods** (8):
```swift
enum MoodTag: String, CaseIterable {
    case happy     // #FFD93D (yellow)
    case grateful  // #6BCF7F (green)
    case excited   // #FF6B6B (coral)
    case neutral   // #A8A8A8 (gray)
    case sad       // #74B9FF (blue)
    case anxious   // #FDCB6E (orange)
    case stressed  // #E17055 (red-orange)
    case angry     // #D63031 (red)
}
```

**Themes** (8):
```swift
enum ThemeTag: String, CaseIterable {
    case personal       // #6C5CE7 (purple)
    case work          // #00B894 (teal)
    case relationships // #FD79A8 (pink)
    case family        // #FAB1A0 (peach)
    case health        // #00CEC9 (cyan)
    case goals         // #FF7675 (salmon)
    case hobbies       // #A29BFE (lavender)
    case school        // #55A3FF (light blue)
}
```

### 7. PersonalJournalScreen (Modal)
**Layout**:
- Navigation bar with close button
- Title: journal type name (e.g., "Personal Reflection")
- Recording Controls:
  - Large record button (center)
  - Recording timer
  - Waveform visualizer (audio levels)
  - Stop button
- Transcription Display:
  - Real-time text as user speaks
  - Editable text field after recording
- Audio Playback (after recording):
  - Play/pause button
  - Progress slider
  - Duration display
- Mood & Theme Selectors
- Save button
- AI reflection card (after save)

**Voice Recording Flow**:
1. Request microphone permission
2. Start recording on button press
3. Show live waveform animation
4. Display recording duration timer
5. Stop recording on button press
6. Transcribe audio via Whisper API
7. Display transcription (editable)
8. Save with transcription + audio file reference

### 8. PhotoJournalScreen (Modal)
**Layout**:
- Navigation bar
- Photo Section:
  - Camera/Gallery button
  - Selected photo preview (large)
  - Retake/Change button
- Caption Input:
  - Text field: "Add a caption..."
- Mood & Theme Selectors
- Save button
- AI reflection (analyzes photo context + caption)

**Photo Capture Flow**:
1. Request camera & photo library permissions
2. Show action sheet: Take Photo / Choose from Library
3. Present camera or image picker
4. Display selected photo
5. Allow retake or proceed
6. Add caption
7. Save to journal + photo storage

### 9. JournalTypeSelectionScreen (Modal)
**Purpose**: Choose specific journal type for new entry

**Layout**:
- Grid of journal type cards (2 columns)
- Each card:
  - Icon
  - Title
  - Description
  - Tap to select

**Journal Types**:
- Personal Reflection
- Future Planning
- Goals
- Gratitude
- Dream Journal
- Travel Journal
- Work Notes
- Custom types (user-defined)

### 10. FolderViewScreen (Modal)
**Purpose**: View all entries of a specific type

**Props**:
- `journalType`: String
- `folderTitle`: String
- `folderIcon`: String

**Layout**:
- Navigation bar with back button and title
- Entries list (filtered by type)
- Same card design as main Journal tab
- Empty state if no entries

---

## Components Library

### Reusable SwiftUI Components

#### 1. StreakProgress
**Purpose**: Display current and longest streaks
**Props**:
```swift
struct StreakProgress: View {
    let currentStreak: Int
    let longestStreak: Int
    let onTap: () -> Void
}
```
**Design**:
- Flame icon + current streak number
- Trophy icon + longest streak
- Subtle gradient background
- Tap gesture to view history

#### 2. QuickEntriesReview
**Purpose**: Horizontal scrolling list of recent entries
**Props**:
```swift
struct QuickEntriesReview: View {
    let entries: [JournalEntry]
    let onEntryTap: (JournalEntry) -> Void
}
```
**Design**:
- Horizontal ScrollView
- Entry cards (120px wide)
- Mood icon, date, preview text

#### 3. PhotoJournalCard
**Purpose**: Display photo entry in grid
**Props**:
```swift
struct PhotoJournalCard: View {
    let entry: JournalEntry
    let onTap: () -> Void
}
```
**Design**:
- Image with aspect ratio
- Overlay: date + mood icon
- Tap to expand

#### 4. AIInsightCard
**Purpose**: Display AI reflection
**Props**:
```swift
struct AIInsightCard: View {
    let reflection: AIReflection
    let isExpanded: Bool
}
```
**Design**:
- Gradient border or background
- AI icon
- Summary text
- Expand button for full insights
- Collapsible sections

#### 5. MoodSelector
**Purpose**: Select mood with icons
**Props**:
```swift
struct MoodSelector: View {
    @Binding var selectedMood: MoodTag?
}
```
**Design**:
- Horizontal scrolling
- Circular mood icons
- Selected state (border + scale)
- Haptic feedback on tap

#### 6. ThemeSelector
**Purpose**: Select theme with icons
**Props**:
```swift
struct ThemeSelector: View {
    @Binding var selectedTheme: ThemeTag?
}
```
**Design**: Similar to MoodSelector

#### 7. AudioVisualizer
**Purpose**: Animated waveform during recording
**Props**:
```swift
struct AudioVisualizer: View {
    let audioLevels: [CGFloat]
    let isRecording: Bool
}
```
**Implementation**:
- Animated bars representing audio levels
- Use AVAudioRecorder's `averagePower(forChannel:)`
- SwiftUI Canvas or GeometryReader

#### 8. CelebrationModal
**Purpose**: Show achievement celebrations
**Props**:
```swift
struct CelebrationModal: View {
    let isVisible: Bool
    let type: CelebrationType
    let message: String
    let onDismiss: () -> Void
}

enum CelebrationType {
    case firstEntry
    case weekStreak
    case monthStreak
    case customMilestone(count: Int)
}
```
**Design**:
- Full-screen overlay
- Lottie confetti animation
- Achievement icon
- Congratulatory message
- Dismiss button

#### 9. MonthlyCalendar
**Purpose**: Calendar heatmap for entry activity
**Props**:
```swift
struct MonthlyCalendar: View {
    let entries: [JournalEntry]
    let month: Date
    let onDateTap: (Date) -> Void
}
```
**Design**:
- Grid layout (7 columns)
- Day cells colored by entry count
- Color intensity scale
- Tap to filter entries by date

#### 10. MoodTrendsGraph
**Purpose**: Line chart of mood over time
**Props**:
```swift
struct MoodTrendsGraph: View {
    let entries: [JournalEntry]
    let timeRange: TimeRange // 7days, 30days, 90days
}
```
**Implementation**:
- SwiftUI Charts (iOS 16+) or custom path drawing
- X-axis: Dates
- Y-axis: Mood score
- Interactive points

#### 11. ConsistencyScore
**Purpose**: Circular progress for journaling consistency
**Props**:
```swift
struct ConsistencyScore: View {
    let score: Int // 0-100
    let goal: String // daily, weekly
}
```
**Design**:
- Circular progress ring
- Center: score percentage
- Color: gradient based on score

---

## Data Models

### Core Models

```swift
// User
struct User: Codable, Identifiable {
    let id: UUID
    let email: String
    var displayName: String
    var photoURL: String?
    var createdAt: Date
}

// Journal Entry
struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    var content: String
    let journalType: JournalType
    var moodTag: MoodTag?
    var themeTag: ThemeTag?
    var imageUri: String?
    var location: String?
    var aiReflection: AIReflection?
    let timestamp: Date
    var audioUri: String? // For voice entries
}

// Journal Type
enum JournalType: String, Codable, CaseIterable {
    case quick = "quick"
    case personal = "personal"
    case photo = "photo"
    case gratitude = "gratitude"
    case goals = "goals"
    case reflection = "reflection"
    case dreams = "dreams"
    case travel = "travel"
}

// AI Reflection
struct AIReflection: Codable {
    let summary: String
    let dominantEmotion: String
    let followUp: String
    var personalizedInsight: String?
    var moodTrend: String?
    var growthSuggestion: String?
}

// Mood Tag
enum MoodTag: String, Codable, CaseIterable {
    case happy, grateful, excited, neutral
    case sad, anxious, stressed, angry
}

// Theme Tag
enum ThemeTag: String, Codable, CaseIterable {
    case personal, work, relationships, family
    case health, goals, hobbies, school
}

// Streak Data
struct StreakData: Codable {
    let currentStreak: Int
    let longestStreak: Int
    let lastEntryDate: Date
}
```

### Supabase Database Schema

**Table: `users`**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    photo_url TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Table: `journal_entries`**
```sql
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    journal_type TEXT NOT NULL,
    mood_tag TEXT,
    theme_tag TEXT,
    image_uri TEXT,
    audio_uri TEXT,
    location TEXT,
    ai_reflection JSONB,
    timestamp TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX idx_journal_entries_timestamp ON journal_entries(timestamp);
CREATE INDEX idx_journal_entries_journal_type ON journal_entries(journal_type);
```

**Table: `streaks`**
```sql
CREATE TABLE streaks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    current_streak INT DEFAULT 0,
    longest_streak INT DEFAULT 0,
    last_entry_date DATE,
    updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## Third-Party Services

### 1. Supabase
**Purpose**: Backend-as-a-Service
**Features Used**:
- Authentication (email/password)
- PostgreSQL database
- Real-time subscriptions (optional)
- Row-level security

**SDK**: `supabase-swift`
**Installation**: Swift Package Manager
**Repository**: `https://github.com/supabase-community/supabase-swift`

**Configuration**:
```swift
import Supabase

let supabase = SupabaseClient(
    supabaseURL: URL(string: "https://jsiqliwgumpcjodqlxgb.supabase.co")!,
    supabaseKey: "YOUR_ANON_KEY"
)
```

**Environment Variables**:
- `SUPABASE_URL`: https://jsiqliwgumpcjodqlxgb.supabase.co
- `SUPABASE_ANON_KEY`: (from EAS secrets)

### 2. OpenAI API
**Purpose**: AI reflections & transcription
**Endpoints Used**:
1. Chat Completions: `https://api.openai.com/v1/chat/completions`
   - Model: `gpt-3.5-turbo`
   - For journal entry analysis

2. Whisper Transcription: `https://api.openai.com/v1/audio/transcriptions`
   - Model: `whisper-1`
   - For voice-to-text

**API Key Storage**: Keychain (secure)

**Implementation**:
```swift
class OpenAIService {
    private let apiKey: String

    func analyzeEntry(content: String, userContext: UserContext) async throws -> AIReflection
    func transcribeAudio(fileURL: URL) async throws -> String
}
```

---

## Permissions & Capabilities

### Info.plist Required Keys

```xml
<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>Allow Remy to access your microphone to record voice journal entries.</string>

<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Allow Remy to access your camera for photo journals.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Allow Remy to access your photos for photo journals.</string>

<!-- Photo Library Add Only -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Allow Remy to save photos to your library.</string>

<!-- Speech Recognition -->
<key>NSSpeechRecognitionUsageDescription</key>
<string>Allow Remy to transcribe your voice recordings.</string>
```

### Xcode Capabilities
- **Background Modes**:
  - Audio, AirPlay, and Picture in Picture (for voice recording)

- **App Transport Security**:
  - Allow arbitrary loads: NO (use HTTPS only)

- **Associated Domains** (optional):
  - `applinks:remy.app` (for universal links)

### URL Scheme
- Custom scheme: `remy://`
- For deep linking from OAuth redirects

---

## Design System

### Color Palette

**Primary Colors**:
```swift
extension Color {
    static let remyBrown = Color(hex: "8B5A3C")
    static let remyCream = Color(hex: "FDF8F6")
    static let remyBeige = Color(hex: "E8DCD1")
    static let remyDarkBrown = Color(hex: "5D3A1A")
}
```

**Mood Colors**:
- Happy: `#FFD93D`
- Grateful: `#6BCF7F`
- Excited: `#FF6B6B`
- Neutral: `#A8A8A8`
- Sad: `#74B9FF`
- Anxious: `#FDCB6E`
- Stressed: `#E17055`
- Angry: `#D63031`

**Theme Colors**:
- Personal: `#6C5CE7`
- Work: `#00B894`
- Relationships: `#FD79A8`
- Family: `#FAB1A0`
- Health: `#00CEC9`
- Goals: `#FF7675`
- Hobbies: `#A29BFE`
- School: `#55A3FF`

**Gradients**:
```swift
let primaryGradient = LinearGradient(
    colors: [Color(hex: "8B5A3C"), Color(hex: "5D3A1A")],
    startPoint: .leading,
    endPoint: .trailing
)
```

### Typography

**System Font**: SF Pro (iOS default)

```swift
extension Font {
    static let remyTitle = Font.system(size: 28, weight: .bold)
    static let remyHeadline = Font.system(size: 20, weight: .semibold)
    static let remyBody = Font.system(size: 16, weight: .regular)
    static let remyCaption = Font.system(size: 14, weight: .light)
}
```

### Spacing
```swift
extension CGFloat {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
```

### Corner Radius
```swift
static let buttonRadius: CGFloat = 12
static let cardRadius: CGFloat = 16
static let modalRadius: CGFloat = 20
```

### Shadows
```swift
extension View {
    func remyCardShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
```

---

## State Management

### Recommended Architecture: MVVM + Combine

#### ViewModels

**AuthViewModel**
```swift
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService

    func signIn(email: String, password: String) async
    func signUp(email: String, password: String) async
    func signOut() async
    func checkSession() async
}
```

**JournalViewModel**
```swift
class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var currentEntry: JournalEntry?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let journalService: JournalService
    private let aiService: AIService

    func createEntry(_ entry: JournalEntry) async
    func updateEntry(_ entry: JournalEntry) async
    func deleteEntry(id: UUID) async
    func loadEntries(for userId: UUID) async
    func analyzeWithAI(content: String, context: UserContext) async -> AIReflection
}
```

**DashboardViewModel**
```swift
class DashboardViewModel: ObservableObject {
    @Published var moodTrends: [MoodDataPoint] = []
    @Published var themeDistribution: [ThemeCount] = []
    @Published var streakData: StreakData?
    @Published var consistencyScore: Int = 0

    func loadAnalytics(for userId: UUID) async
    func filterByMood(_ mood: MoodTag)
    func filterByTheme(_ theme: ThemeTag)
    func filterByDate(_ date: Date)
}
```

### Local Storage
- **UserDefaults**: Onboarding completion, user preferences
- **Keychain**: API keys, auth tokens
- **CoreData/SwiftData**: Offline entry drafts, cached data

---

## API Integration

### Supabase Service Layer

```swift
class SupabaseService {
    private let client: SupabaseClient

    // Auth
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws
    func getSession() async throws -> Session?

    // Journal Entries
    func createEntry(userId: UUID, entry: JournalEntry) async throws -> JournalEntry
    func fetchEntries(userId: UUID) async throws -> [JournalEntry]
    func updateEntry(id: UUID, updates: JournalEntry) async throws
    func deleteEntry(id: UUID) async throws

    // Streaks
    func getStreak(userId: UUID) async throws -> StreakData
    func updateStreak(userId: UUID, streak: StreakData) async throws
}
```

### OpenAI Service Layer

```swift
class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1"

    func analyzeJournalEntry(
        content: String,
        userContext: UserContext,
        entryType: JournalType
    ) async throws -> AIReflection {
        let systemPrompt = createContextualPrompt(userContext)
        let userPrompt = createAnalysisPrompt(content, entryType)

        let request = ChatCompletionRequest(
            model: "gpt-3.5-turbo",
            messages: [
                .system(systemPrompt),
                .user(userPrompt)
            ],
            temperature: 0.7,
            maxTokens: 400
        )

        // Make API call, parse JSON response
        // Return AIReflection
    }

    func transcribeAudio(fileURL: URL) async throws -> String {
        let formData = try createMultipartFormData(fileURL)

        // POST to /audio/transcriptions
        // Return transcription text
    }
}
```

---

## Migration Checklist

### Phase 1: Setup & Foundation
- [ ] Create new Xcode project (SwiftUI App)
- [ ] Set bundle ID: `com.remy.journal.keshavkrishnan`
- [ ] Set minimum deployment target: iOS 15.1
- [ ] Add Swift Package dependencies:
  - [ ] supabase-swift
  - [ ] (Optional) Lottie for animations
- [ ] Configure Info.plist permissions
- [ ] Set up URL scheme: `remy://`
- [ ] Add app icon and launch screen assets
- [ ] Create color assets in xcassets
- [ ] Set up Build Configurations (Debug, Release)

### Phase 2: Core Architecture
- [ ] Implement MVVM folder structure
- [ ] Create data models (User, JournalEntry, etc.)
- [ ] Set up Supabase client configuration
- [ ] Implement Keychain wrapper for secure storage
- [ ] Create UserDefaults wrapper for preferences
- [ ] Set up logging/analytics framework

### Phase 3: Authentication
- [ ] Build AuthViewModel
- [ ] Implement AuthService (Supabase integration)
- [ ] Create SplashScreen view
- [ ] Create OnboardingScreen view
- [ ] Create AuthScreen view (Sign In/Sign Up)
- [ ] Implement session management
- [ ] Test authentication flow end-to-end

### Phase 4: Navigation
- [ ] Set up NavigationStack root
- [ ] Create TabView (3 tabs)
- [ ] Implement modal presentation logic
- [ ] Add deep linking support
- [ ] Test navigation flows

### Phase 5: Home Screen
- [ ] Create HomeScreen view
- [ ] Build StreakProgress component
- [ ] Build QuickEntriesReview component
- [ ] Build PhotoJournalCard grid
- [ ] Implement gratitude widget
- [ ] Wire up navigation actions
- [ ] Test data loading and display

### Phase 6: Journal Functionality
- [ ] Create JournalViewModel
- [ ] Implement JournalService (Supabase CRUD)
- [ ] Build QuickJournalScreen
- [ ] Build MoodSelector component
- [ ] Build ThemeSelector component
- [ ] Implement entry creation flow
- [ ] Test saving and loading entries

### Phase 7: Audio Recording
- [ ] Create AudioRecorderService (AVFoundation)
- [ ] Implement microphone permission request
- [ ] Build AudioVisualizer component
- [ ] Create PersonalJournalScreen
- [ ] Integrate Whisper transcription
- [ ] Add fallback iOS Speech Recognition
- [ ] Test voice recording and transcription

### Phase 8: Photo Journaling
- [ ] Implement camera permission request
- [ ] Implement photo library permission
- [ ] Create PhotoJournalScreen
- [ ] Integrate UIImagePickerController or PHPicker
- [ ] Add photo storage (Supabase Storage or local)
- [ ] Test photo capture and upload

### Phase 9: AI Integration
- [ ] Create OpenAIService
- [ ] Implement GPT-3.5 chat completion
- [ ] Build user context system
- [ ] Create AIInsightCard component
- [ ] Integrate AI analysis into entry flow
- [ ] Add loading and error states
- [ ] Test AI reflections

### Phase 10: Dashboard & Analytics
- [ ] Create DashboardViewModel
- [ ] Build MoodTrendsGraph (SwiftUI Charts)
- [ ] Build mood distribution pie chart
- [ ] Build MonthlyCalendar heatmap
- [ ] Build ConsistencyScore component
- [ ] Implement filtering and date selection
- [ ] Test analytics calculations

### Phase 11: Streaks & Gamification
- [ ] Implement streak calculation logic
- [ ] Create StreakService
- [ ] Build CelebrationModal component
- [ ] Add milestone detection
- [ ] Integrate haptic feedback
- [ ] Test streak tracking

### Phase 12: Polish & Optimization
- [ ] Add animations and transitions
- [ ] Implement loading skeletons
- [ ] Add pull-to-refresh
- [ ] Optimize image loading
- [ ] Add offline mode support (optional)
- [ ] Implement error handling UI
- [ ] Add accessibility labels (VoiceOver)
- [ ] Test on multiple device sizes

### Phase 13: Testing
- [ ] Unit tests for services
- [ ] UI tests for critical flows
- [ ] Test on iOS 15, 16, 17
- [ ] Test on various iPhone models
- [ ] Beta testing with TestFlight
- [ ] Fix bugs and issues

### Phase 14: App Store Preparation
- [ ] Create App Store screenshots
- [ ] Write App Store description
- [ ] Set up App Privacy details
- [ ] Configure In-App Purchases (if any)
- [ ] Set up App Store Connect
- [ ] Submit for review
- [ ] Launch! 🚀

---

## Technical Debt Notes

### Improvements over React Native Version
1. **Native Performance**: SwiftUI provides better animations and scroll performance
2. **Type Safety**: Swift's strong typing reduces runtime errors
3. **Better Audio**: AVFoundation is more reliable than Expo AV
4. **Offline Support**: CoreData/SwiftData for robust local storage
5. **Smaller App Size**: No JavaScript bundle overhead
6. **Better Battery**: Native code is more efficient
7. **Easier App Store**: No Expo or React Native build complexities

### Challenges to Address
1. **Learning Curve**: If team is unfamiliar with SwiftUI
2. **Code Reuse**: Can't share code with Android (unlike RN)
3. **Rapid Prototyping**: SwiftUI previews help but RN hot reload is faster
4. **Cross-Platform**: Need separate Android app if desired

---

## Appendix

### Recommended Third-Party Packages
1. **Supabase Swift**: `https://github.com/supabase-community/supabase-swift`
2. **Lottie iOS**: `https://github.com/airbnb/lottie-ios` (animations)
3. **KeychainAccess**: `https://github.com/kishikawakatsumi/KeychainAccess`
4. **Alamofire** (optional): For advanced networking needs

### Resources
- **SwiftUI Documentation**: https://developer.apple.com/documentation/swiftui
- **Supabase Docs**: https://supabase.com/docs
- **OpenAI API**: https://platform.openai.com/docs
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines

---

## Summary

This PRD provides a complete blueprint for rebuilding the Remy Journal app in native SwiftUI. The app architecture mirrors the React Native version but leverages native iOS frameworks for superior performance and integration.

**Key Features**:
- ✅ Multiple journal types (quick, personal, photo, gratitude)
- ✅ Voice recording with AI transcription (Whisper)
- ✅ AI-powered reflections (GPT-3.5)
- ✅ Mood and theme tracking
- ✅ Streak gamification
- ✅ Analytics dashboard
- ✅ Supabase backend
- ✅ Native camera and photo integration
- ✅ Offline support with local storage

**Timeline Estimate**: 8-12 weeks for a single iOS developer

**Next Steps**: Begin with Phase 1 setup and work through each phase systematically.

---

*Generated: October 17, 2025*
*Version: 1.0*
*Source: React Native/Expo v1.0.0*
