# Remy - Complete Codebase Documentation

**Version:** 1.0
**Last Updated:** October 23, 2025
**Total Lines of Code:** 10,308
**Language:** Swift (iOS)

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [File-by-File Documentation](#file-by-file-documentation)
   - [App Entry Point](#app-entry-point)
   - [Configuration](#configuration)
   - [Models (Data Structures)](#models-data-structures)
   - [Services (Backend Logic)](#services-backend-logic)
   - [ViewModels (Business Logic)](#viewmodels-business-logic)
   - [Views - Screens](#views---screens)
   - [Views - Components](#views---components)
   - [Extensions (Utilities)](#extensions-utilities)
4. [Data Flow](#data-flow)
5. [Third-Party Dependencies](#third-party-dependencies)

---

## Project Overview

**Remy** is an AI-powered journaling iOS application that helps users:
- Write journal entries in multiple formats (quick notes, detailed entries, photo journals, gratitude logs)
- Track their mood and emotional patterns over time
- Categorize entries by life themes (work, family, health, etc.)
- Get AI-powered insights and reflections on their journal entries
- Maintain journaling streaks to build consistent habits
- Visualize their journaling patterns through analytics and charts

**Core Technologies:**
- **SwiftUI**: Modern iOS UI framework
- **Supabase**: Cloud backend for authentication and data storage
- **OpenAI API**: AI-powered journal analysis and insights
- **Combine Framework**: Reactive programming for data flow

---

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

```
┌─────────────────────────────────────────┐
│           Views (SwiftUI)               │  ← What the user sees and interacts with
├─────────────────────────────────────────┤
│        ViewModels (Logic)               │  ← Processes user actions, manages state
├─────────────────────────────────────────┤
│       Services (Backend)                │  ← Talks to cloud servers
├─────────────────────────────────────────┤
│      Models (Data Structures)           │  ← Defines what data looks like
└─────────────────────────────────────────┘
```

**Benefits of this architecture:**
- **Separation of Concerns**: Each layer has a specific job
- **Testability**: Business logic can be tested independently
- **Maintainability**: Easy to find and fix bugs
- **Scalability**: Easy to add new features

---

## File-by-File Documentation

### App Entry Point

#### `RemyApp.swift` (157 lines)

**Purpose:** This is the starting point of the entire application. Like the front door to a building.

**What it does in plain English:**
- When you tap the Remy app icon, this file runs first
- It decides which screen to show you:
  - If the app is starting up → Show a loading screen with the Remy logo
  - If something's broken with the setup → Show an error message with instructions
  - If you're a brand new user → Show the welcome tutorial (onboarding)
  - If you haven't signed in → Show the login screen
  - If you're already logged in → Show the main journal app
- Creates the main "managers" that control the app (like hiring the staff for a hotel)

**Key Components:**
1. **SplashLoadingView** (lines 44-115): The pretty animated logo screen you see when starting the app
2. **ConfigurationErrorView** (lines 117-157): Error screen if the app isn't set up correctly

**Important Variables:**
- `supabaseService`: Manages user login and cloud storage
- `journalViewModel`: Manages all journal entries and data
- `hasCompletedOnboarding`: Remembers if you've seen the welcome tutorial

---

#### `ContentView.swift` (18 lines)

**Purpose:** A simple wrapper that displays the main tab interface.

**What it does in plain English:**
- This is like a picture frame that holds the main app interface
- It just shows the `MainTabView` (the screen with tabs at the bottom)
- It's kept separate so it's easy to swap out the main interface if needed

**Why it exists:**
- Separates the app's entry point from the main interface
- Makes the code cleaner and easier to maintain

---

### Configuration

#### `Config/SupabaseConfig.swift` (103 lines)

**Purpose:** Stores the "address" and "key" needed to connect to your cloud database (Supabase).

**What it does in plain English:**
- Think of Supabase as a storage locker in the cloud where all user data is kept
- This file stores:
  - The **address** of that storage locker (URL)
  - The **access key** to get in (API key)
- It reads these from a configuration file (Config.xcconfig)
- If the configuration is missing, it uses placeholder values instead of crashing

**Key Functions:**
1. **projectURL** (lines 15-37): Gets the cloud storage address
2. **anonKey** (lines 41-64): Gets the access key for the storage
3. **photoBucketName** (line 68): Name of the folder where journal photos are stored

**Security Notes:**
- The "anon key" is safe to include in the app - it's meant to be public
- Real security happens on the server side
- Each user can only access their own data (enforced by server rules)

**Error Handling:**
- If credentials are missing → Returns placeholder values and prints warnings
- If credentials are invalid → Logs warnings but doesn't crash the app

---

### Models (Data Structures)

Models define what data looks like in the app. Think of them as blueprints or templates.

#### `Models/JournalEntry.swift` (~120 lines)

**Purpose:** Defines what a journal entry looks like.

**What it does in plain English:**
- This is like a form template for a journal entry
- It defines all the fields a journal entry can have:
  - **id**: Unique identifier (like a serial number)
  - **content**: The actual text you write
  - **journalType**: What kind of entry (quick note, dream, goal, etc.)
  - **moodTag**: How you were feeling (happy, sad, anxious, etc.)
  - **themeTag**: What category (work, family, health, etc.)
  - **imageUri**: Link to a photo (if it's a photo journal)
  - **audioUri**: Link to an audio recording (if voice journal)
  - **aiReflection**: AI-generated insights about your entry
  - **timestamp**: When you wrote it

**Example:**
```swift
JournalEntry(
    content: "Had a great day at work!",
    journalType: .quick,
    moodTag: .happy,
    themeTag: .work,
    timestamp: Date()
)
```

**Why it's important:**
- Ensures all entries have consistent structure
- Makes it easy to save/load from the database
- Type-safe (prevents errors from wrong data types)

---

#### `Models/JournalType.swift` (~40 lines)

**Purpose:** Defines the different types of journal entries available.

**What it does in plain English:**
- Lists all the different kinds of journals you can write:
  - **quick**: Fast, short notes
  - **personal**: Detailed personal reflections
  - **photo**: Entries with photos
  - **gratitude**: Things you're grateful for
  - **goals**: Your goals and aspirations
  - **reflection**: Deep thoughts and reflections
  - **dreams**: Dream journals
  - **travel**: Travel logs

**Each type has:**
- **displayName**: User-friendly name
- **icon**: Symbol to show in the UI
- **color**: Unique color for visual distinction

**Why it exists:**
- Helps users organize different kinds of entries
- Makes the UI more intuitive with icons and colors
- Allows filtering entries by type

---

#### `Models/MoodTag.swift` (~80 lines)

**Purpose:** Defines the different moods users can tag their entries with.

**What it does in plain English:**
- Lists 8 different mood options:
  - **happy**: Feeling good 😊
  - **grateful**: Feeling thankful 🙏
  - **excited**: Feeling energized ⚡
  - **neutral**: Feeling normal 😐
  - **sad**: Feeling down 😢
  - **anxious**: Feeling worried 😰
  - **stressed**: Feeling pressured 😫
  - **angry**: Feeling frustrated 😠

**Each mood has:**
- **displayName**: What it's called
- **icon**: Emoji or symbol
- **color**: Unique color (e.g., yellow for happy, blue for sad)
- **moodScore**: Numerical value (-2 to +2) for analytics

**Why mood tracking matters:**
- Helps users identify emotional patterns
- Powers the mood analytics charts
- Can help spot triggers for negative moods
- Useful for mental health awareness

---

#### `Models/ThemeTag.swift` (~70 lines)

**Purpose:** Defines life categories users can tag their entries with.

**What it does in plain English:**
- Lists 8 different life areas:
  - **personal**: Personal growth and self-care
  - **work**: Career and professional life
  - **relationships**: Friendships and romance
  - **family**: Family matters
  - **health**: Physical and mental health
  - **goals**: Achievements and aspirations
  - **hobbies**: Interests and activities
  - **school**: Education and learning

**Each theme has:**
- **displayName**: User-friendly name
- **icon**: Symbol representing the category
- **color**: Unique color for visual distinction

**Why theme tagging is useful:**
- Helps organize entries by life area
- Allows filtering (e.g., "show all work-related entries")
- Powers analytics (e.g., "What do I journal most about?")
- Helps identify which areas of life need attention

---

#### `Models/AIReflection.swift` (~50 lines)

**Purpose:** Defines the structure of AI-generated insights.

**What it does in plain English:**
- When you write a journal entry, AI can analyze it and provide insights
- This model defines what those insights look like:
  - **summary**: Brief summary of your entry
  - **dominantEmotion**: Main emotion detected
  - **insights**: Key observations from your writing
  - **followUpQuestions**: Questions to help you reflect deeper
  - **encouragement**: Positive, supportive message
  - **suggestedActions**: Helpful suggestions based on your entry

**Example AI Response:**
```
Summary: "You had a productive day at work but feel stressed about deadlines."
Dominant Emotion: Stressed
Insight: "You value achievement but may be putting too much pressure on yourself."
Follow-up: "What would help you feel less overwhelmed about your work?"
Encouragement: "You're doing great! Remember to take breaks."
Suggested Action: "Try a 10-minute meditation before bed tonight."
```

**Why AI reflection is valuable:**
- Provides perspective on your thoughts
- Helps you understand patterns you might miss
- Encourages deeper self-reflection
- Offers actionable suggestions

---

#### `Models/StreakData.swift` (~30 lines)

**Purpose:** Tracks how many days in a row you've been journaling.

**What it does in plain English:**
- Keeps track of your journaling habit:
  - **currentStreak**: How many days in a row you've journaled (e.g., 5 days)
  - **longestStreak**: Your personal record (e.g., 21 days)
  - **lastEntryDate**: When you last wrote an entry

**How streaks work:**
- Write an entry today → Streak continues
- Skip a day → Streak resets to 0
- Beat your record → New longest streak!

**Why streaks matter:**
- Gamifies journaling to build a consistent habit
- Provides motivation to keep going
- Visual feedback on your progress
- Proven psychological technique for habit formation

---

### Services (Backend Logic)

Services handle communication with external systems (cloud database, AI, etc.).

#### `Services/SupabaseService.swift` (657 lines)

**Purpose:** This is the "messenger" between your app and the cloud storage. Handles all backend operations.

**What it does in plain English:**
- **Think of it like a post office:** Your app writes a letter (data), and this service delivers it to the cloud and brings responses back.

**Main Responsibilities:**

**1. User Authentication (Login/Signup)** (lines 76-129)
- `signUp()`: Creates a new user account
- `signIn()`: Logs user in
- `signOut()`: Logs user out
- `checkAuthStatus()`: Checks if you're already logged in
- `resetPassword()`: Sends password reset email
- `deleteAccount()`: Permanently deletes user and all their data

**2. Journal Entry Management** (lines 197-265)
- `createJournalEntry()`: Saves a new entry to the cloud
- `fetchJournalEntries()`: Gets all your entries from the cloud
- `updateJournalEntry()`: Updates an existing entry
- `deleteJournalEntry()`: Deletes an entry permanently

**3. Photo Management** (lines 268-302)
- `uploadPhoto()`: Uploads journal photos to cloud storage
- `deletePhoto()`: Removes photos from cloud storage
- Stores photos in organized folders by user

**4. Streak Tracking** (lines 305-414)
- `getStreakData()`: Gets your current streak info
- `updateStreak()`: Updates streak when you create an entry
- Calculates if streak continues or breaks based on dates

**5. Chat History** (lines 417-472) - For AI conversations
- `saveChatMessage()`: Saves messages from AI chat
- `fetchChatMessages()`: Retrieves chat history
- `clearChatHistory()`: Deletes all chat messages

**Security Features:**
- All operations require authentication
- Users can only access their own data
- Passwords are encrypted (handled by Supabase)
- API keys are kept secure

**Error Handling:**
- Network errors → Caught and reported to user
- Invalid data → Prevented with validation
- Timeouts → 2-second limit to prevent hanging
- Graceful degradation if cloud is unavailable

**Performance Optimizations:**
- Singleton pattern (only one instance exists)
- Async/await for smooth UI (doesn't freeze the app)
- Caching session state for faster startup
- Timeout protection for slow networks

---

#### `Services/AIService.swift` (366 lines)

**Purpose:** Connects to OpenAI (ChatGPT) to analyze journal entries and provide insights.

**What it does in plain English:**
- **Think of it as having a therapist or life coach built into the app**
- Sends your journal entry to OpenAI's AI
- Gets back thoughtful analysis and suggestions
- Can also have ongoing conversations (chat feature)

**Main Functions:**

**1. Journal Analysis** (~100 lines)
- `analyzeJournalEntry()`: Sends entry to AI for analysis
- AI reads your entry and provides:
  - Summary of what you wrote
  - Detected emotions
  - Patterns it notices
  - Thoughtful questions to help you reflect
  - Encouraging messages
  - Suggested actions

**2. AI Chat Feature** (~150 lines)
- `sendChatMessage()`: Sends a message to AI
- AI responds conversationally
- Maintains context from previous messages
- Can discuss journal entries, ask for advice, etc.

**3. Safety & Privacy**
- Your entries are sent over encrypted connections (HTTPS)
- OpenAI's privacy policy applies
- No data is stored permanently by OpenAI (per their API terms)
- API key is stored securely

**How the AI Analysis Works:**
1. You write a journal entry
2. App sends entry text to OpenAI
3. AI analyzes the content (mood, themes, patterns)
4. AI generates personalized insights
5. App receives and displays insights to you

**Example Prompt Sent to AI:**
```
"Analyze this journal entry and provide insights:
Entry: 'I had a stressful day at work but felt better after talking to my friend.'
Please provide: summary, emotion, insights, questions, encouragement."
```

**Rate Limits & Costs:**
- Uses OpenAI API (paid service)
- Limited number of requests per minute
- Error handling for rate limits
- Graceful fallback if API unavailable

---

### ViewModels (Business Logic)

ViewModels sit between the UI (Views) and the backend (Services). They handle all the business logic.

#### `ViewModels/JournalViewModel.swift` (210 lines)

**Purpose:** This is the "brain" that manages all journal-related operations. The Views ask it for data, and it talks to the Services.

**What it does in plain English:**
- **Think of it as a manager at a library:**
  - The Views (customers) ask for books (journal entries)
  - The ViewModel (librarian) fetches them from Services (the shelves)
  - Keeps track of what's checked out (current entries)
  - Handles requests to add/remove/update entries

**Main Responsibilities:**

**1. Data Storage** (lines 13-16)
- `entries`: Array of all journal entries
- `isLoading`: True when fetching data (shows loading spinner)
- `errorMessage`: Stores any error messages to show user
- `streakData`: Current streak information

**2. Loading Data** (lines 31-67)
- `loadInitialData()`: Loads entries when app starts
- `loadEntries()`: Fetches all entries from cloud
- `loadStreak()`: Gets current streak data
- `loadMockData()`: Provides sample data for testing

**3. Creating Entries** (lines 72-120)
- `createEntry()`: Saves a new text entry
- `createEntryWithPhoto()`: Saves entry with photo attachment
- Automatically updates streak after creating entry

**4. Managing Entries** (lines 123-166)
- `updateEntry()`: Modifies an existing entry
- `deleteEntry()`: Removes an entry permanently
- Updates local array and cloud database

**5. Filtering & Organization** (lines 170-177)
- `entriesForType()`: Gets all entries of a specific type (e.g., all gratitude entries)
- `entriesForDate()`: Gets all entries written on a specific date

**Data Flow Example:**
1. User writes journal entry in UI
2. UI calls `viewModel.createEntry(entry)`
3. ViewModel calls `supabaseService.createJournalEntry(entry)`
4. Service saves to cloud and returns success
5. ViewModel adds entry to local `entries` array
6. ViewModel updates streak
7. UI automatically updates to show new entry

**Error Handling:**
- Network errors → Shows user-friendly error message
- Invalid data → Validates before sending to service
- Loading states → Shows spinner while processing

---

### Views - Screens

Views are the visual interface users interact with. Written in SwiftUI (Apple's modern UI framework).

#### `Views/Screens/MainTabView.swift` (~100 lines)

**Purpose:** The main navigation hub with tabs at the bottom.

**What it does in plain English:**
- **Like the main menu of a restaurant with different sections**
- Creates the tab bar at the bottom with 3 tabs:
  1. **Home** (house icon): Dashboard with quick actions
  2. **Journal** (book icon): View all journal entries
  3. **Insights** (chart icon): Analytics and statistics
- Switches between screens when you tap tabs
- Shows selected tab with highlighting

**Technical Details:**
- Uses SwiftUI's `TabView` component
- Each tab contains a different screen
- Maintains state across tab switches
- Custom colors matching app theme

---

#### `Views/Screens/HomeScreen.swift` (1,148 lines)

**Purpose:** The main dashboard - first screen you see after login.

**What it does in plain English:**
- **Like the homepage of a website - gives you quick access to everything**

**Main Sections:**

**1. Header** (lines ~50-100)
- Greeting message ("Good morning, [name]!")
- Current date
- Profile/settings button

**2. Quick Actions** (lines ~100-250)
- Large buttons to start journaling:
  - Quick note button
  - Voice journal button
  - Photo journal button
  - More options button
- Each button has an icon, label, and color
- Tapping opens the respective journal screen

**3. Streak Widget** (lines ~250-350)
- Shows current journaling streak
- Visual progress indicator
- Motivational message
- "Keep it going!" encouragement

**4. Today's Mood Check** (lines ~350-450)
- Quick mood selector
- Shows mood history for the week
- Colored circles for each day
- Tap to log today's mood

**5. Gratitude Widget** (lines ~450-550)
- Quick prompt: "What are you grateful for today?"
- Shows recent gratitude entries
- One-tap to add gratitude note

**6. Recent Entries Preview** (lines ~550-750)
- Shows 3 most recent journal entries
- Card-based design
- Tap to view full entry
- Swipe to delete

**7. AI Chat Shortcut** (lines ~750-850)
- Button to start conversation with AI
- Shows last chat message preview
- Quick access to AI insights

**8. Decorative Elements** (lines ~850-1148)
- Background gradients
- Floating circles/shapes for visual appeal
- Smooth animations
- Responsive to scrolling

**Design Philosophy:**
- Everything accessible within 1-2 taps
- Visual hierarchy guides attention
- Delightful animations and transitions
- Warm, calming color scheme

---

#### `Views/Screens/JournalScreen.swift` (668 lines)

**Purpose:** Shows all your journal entries in a scrollable list.

**What it does in plain English:**
- **Like a filing cabinet showing all your diary entries**

**Main Features:**

**1. Filter Bar** (lines ~50-150)
- Filter by journal type (quick, photo, gratitude, etc.)
- Filter by mood (happy, sad, stressed, etc.)
- Filter by theme (work, family, health, etc.)
- Search by text
- Date range picker

**2. Entry List** (lines ~150-500)
- Scrollable list of all entries
- Each card shows:
  - Entry preview (first few lines)
  - Date and time
  - Mood emoji
  - Theme tag
  - Photo thumbnail (if applicable)
- Tap entry to view full details

**3. Sorting Options** (lines ~500-550)
- Sort by newest first (default)
- Sort by oldest first
- Sort by mood
- Group by month

**4. Empty State** (lines ~550-600)
- Shown when no entries exist
- Friendly illustration
- "Start your first journal entry!" message
- Big button to create entry

**5. Swipe Actions** (lines ~600-668)
- Swipe left to delete
- Swipe right to favorite/pin
- Confirmation dialog before deleting

**Performance Optimizations:**
- Lazy loading (only loads visible entries)
- Efficient scrolling with `LazyVStack`
- Image caching for photos
- Smooth animations

---

#### `Views/Screens/JournalDetailView.swift` (373 lines)

**Purpose:** Shows the full details of a single journal entry when tapped.

**What it does in plain English:**
- **Like opening a diary to read one specific page in detail**

**Components:**

**1. Header** (lines ~30-80)
- Back button to return to list
- Entry date and time
- Edit button (pencil icon)
- Share button
- Delete button (trash icon)

**2. Entry Content** (lines ~80-180)
- Full entry text (scrollable)
- Formatted with proper spacing
- Readable font size
- Supports long entries

**3. Media Display** (lines ~180-250)
- Shows photo if it's a photo journal
- Zoomable image viewer
- Audio player if voice journal
- Play/pause controls

**4. Tags Section** (lines ~250-300)
- Mood tag with colored badge
- Theme tag with colored badge
- Journal type indicator

**5. AI Insights Panel** (lines ~300-373)
- Expandable section
- Shows AI-generated insights
- Summary, emotions, suggestions
- Thoughtful questions for reflection
- Encouragement message
- Can be hidden/shown with toggle

**Interactive Features:**
- Edit mode: Tap edit to modify entry
- Delete confirmation: "Are you sure?" dialog
- Share: Export entry as text or PDF
- Photo zoom: Pinch to zoom on photos

---

#### `Views/Screens/QuickJournalScreen.swift` (321 lines)

**Purpose:** Fast entry screen for quick thoughts and notes.

**What it does in plain English:**
- **Like sticky notes - for quick thoughts you want to jot down fast**

**Interface Elements:**

**1. Text Entry** (lines ~30-100)
- Large text field
- Placeholder: "What's on your mind?"
- Auto-focuses keyboard when screen opens
- Character count indicator
- Supports emoji keyboard

**2. Quick Mood Selector** (lines ~100-150)
- Row of emoji faces
- Tap to select mood
- Highlighted selection
- Optional (can skip)

**3. Quick Theme Selector** (lines ~150-200)
- Row of category icons
- Tap to select theme
- Optional (can skip)

**4. Save Button** (lines ~200-250)
- Big "Save" button at bottom
- Disabled if empty
- Shows loading spinner while saving
- Haptic feedback on tap

**5. Success Animation** (lines ~250-321)
- Checkmark animation when saved
- "Entry saved!" message
- Automatically dismisses after 1 second
- Returns to home screen

**User Experience:**
- Designed for speed (< 30 seconds to create entry)
- Minimal friction
- No required fields
- Keyboard shortcuts
- Swipe down to dismiss

---

#### `Views/Screens/PhotoJournalScreen.swift` (440 lines)

**Purpose:** Create journal entries with photos.

**What it does in plain English:**
- **Like a photo album where you can add captions and thoughts to pictures**

**Features:**

**1. Photo Picker** (lines ~30-150)
- Button to take new photo (camera)
- Button to choose from library
- Photo preview after selection
- Crop/edit options
- Remove photo button

**2. Caption Field** (lines ~150-220)
- Text area to describe the photo
- Placeholder: "Write about this moment..."
- Optional but encouraged
- Emoji support

**3. Context Selectors** (lines ~220-320)
- Mood selector (how you felt)
- Theme selector (what category)
- Location tag (optional)
- Date/time picker

**4. Photo Display** (lines ~320-400)
- Large photo preview
- Pinch to zoom
- Swipe between multiple photos (future feature)
- Filters/effects (future feature)

**5. Save Flow** (lines ~400-440)
- Uploads photo to cloud storage
- Creates journal entry with photo URL
- Shows upload progress
- Error handling if upload fails
- Success confirmation

**Privacy & Storage:**
- Photos stored securely in cloud
- Only you can see your photos
- Original quality preserved
- Can be deleted anytime

---

#### `Views/Screens/DreamsJournalScreen.swift` (367 lines)

**Purpose:** Specialized screen for recording dreams.

**What it does in plain English:**
- **Like a dream diary with prompts to help you remember details**

**Unique Features:**

**1. Dream Entry Field** (lines ~30-120)
- Large text area for dream description
- Prompts: "What did you dream about?"
- "Who was in your dream?"
- "How did you feel?"
- Voice-to-text option (useful when half-asleep!)

**2. Dream Categorization** (lines ~120-200)
- Dream type: nightmare, lucid, recurring, normal
- Vividness scale (1-5 stars)
- How well you remember it
- Color tags for visual organization

**3. Symbols & Themes** (lines ~200-280)
- Common dream symbols (flying, falling, water, etc.)
- Select multiple symbols present in dream
- Helps identify patterns over time

**4. Emotional Impact** (lines ~280-340)
- How dream made you feel
- Intensity scale
- Physical reactions (heart racing, sweating, etc.)

**5. Time Tracking** (lines ~340-367)
- When you went to sleep
- When you woke up
- Total sleep duration
- Can help correlate dreams with sleep quality

**Why Dreams Matter:**
- Track recurring dreams
- Identify patterns
- Useful for lucid dreaming practice
- Interesting to look back on

---

#### `Views/Screens/GoalsJournalScreen.swift` (448 lines)

**Purpose:** Set and track personal goals.

**What it does in plain English:**
- **Like a goal planner combined with a journal - set goals and track progress**

**Main Sections:**

**1. Goal Creation** (lines ~30-150)
- Goal title (e.g., "Run a marathon")
- Goal description (detailed plan)
- Goal category (health, career, personal, etc.)
- Target date (deadline)
- Priority level (high, medium, low)

**2. Progress Tracking** (lines ~150-250)
- Visual progress bar (0-100%)
- Milestones/checkpoints
- Update progress button
- Completion percentage

**3. Action Steps** (lines ~250-340)
- Break goal into smaller tasks
- Check off completed tasks
- Add new tasks
- Reorder tasks (drag and drop)

**4. Journal Updates** (lines ~340-420)
- Regular check-ins on goal
- "How's it going?" prompt
- Obstacles encountered
- Wins and achievements
- Motivation notes

**5. Goal Review** (lines ~420-448)
- View all goals (active, completed, abandoned)
- Filter by status
- Archive completed goals
- Celebrate achievements

**Goal Psychology:**
- Writing goals makes them more real
- Regular check-ins increase success rate
- Breaking into tasks reduces overwhelm
- Progress tracking provides motivation

---

#### `Views/Screens/DashboardScreen.swift` (599 lines)

**Purpose:** Analytics and insights dashboard - visualize your journaling patterns.

**What it does in plain English:**
- **Like a personal analytics report showing your journaling habits and patterns**

**Widgets & Charts:**

**1. Streak Overview** (lines ~30-100)
- Current streak (big number)
- Longest streak
- Total entries
- Entries this month
- Visual calendar heatmap

**2. Mood Chart** (lines ~100-220)
- Line graph of mood over time
- Color-coded by mood type
- Shows trends (getting happier/sadder)
- Time range selector (week, month, year)
- Average mood score

**3. Theme Distribution** (lines ~220-320)
- Pie chart of journal categories
- Shows what you journal about most
- Percentage breakdown
- "You journal most about: Work (35%)"
- Tap to filter entries by theme

**4. Activity Chart** (lines ~320-420)
- Bar graph of entries per day/week
- Shows journaling consistency
- Identifies best/worst days
- Time of day patterns

**5. Word Cloud** (lines ~420-500)
- Common words from your entries
- Bigger = used more frequently
- Interactive (tap word to find entries)
- Excludes common words (the, and, etc.)

**6. Insights Summary** (lines ~500-599)
- AI-generated monthly summary
- Key observations
- Patterns detected
- Suggested areas to explore
- Positive reinforcement

**Why Analytics Matter:**
- Self-awareness through data
- Identify patterns you might miss
- Motivation to maintain streaks
- Celebration of progress

---

#### `Views/Screens/DetailedAnalyticsScreen.swift` (363 lines)

**Purpose:** Deep dive into specific analytics (accessed from Dashboard).

**What it does in plain English:**
- **Like clicking "See more details" on analytics - provides deeper insights**

**Advanced Analytics:**

**1. Mood Patterns** (lines ~30-130)
- Mood by time of day (morning moods vs. evening)
- Mood by day of week (Monday blues?)
- Correlation with themes (stressed at work?)
- Mood triggers analysis

**2. Writing Patterns** (lines ~130-230)
- Average entry length
- Most productive time of day
- Longest entry
- Shortest entry
- Writing speed trends

**3. Topic Analysis** (lines ~230-320)
- What you write about most
- Topics trending up/down
- Relationships between topics
- Suggested new topics to explore

**4. Comparison Views** (lines ~320-363)
- This month vs. last month
- This year vs. last year
- Personal bests
- Improvement areas

---

#### `Views/Screens/AuthenticationView.swift` (271 lines)

**Purpose:** Unified login/signup screen.

**What it does in plain English:**
- **The gate to the app - where you sign in or create an account**

**Components:**

**1. Logo & Branding** (lines ~30-83)
- App logo (animated book icon)
- App name "Remy"
- Tagline: "Your AI-Powered Journal"
- Decorative background elements

**2. Email Field** (lines ~88-98)
- Text input for email
- Validates email format
- Auto-lowercase
- Email keyboard type

**3. Password Field** (lines ~100-109)
- Secure text input (dots instead of letters)
- "Show/hide password" toggle
- Minimum 6 characters required

**4. Sign In Button** (lines ~126-158)
- Big button to log in
- Disabled if form invalid
- Shows loading spinner while processing
- Gradient background

**5. Error Display** (lines ~112-123)
- Shows error messages (red banner)
- "Invalid email or password"
- "Network error" etc.
- Dismissible

**6. Toggle Sign Up Mode** (lines ~168-185)
- "Don't have an account? Sign Up"
- Switches between login and registration
- Smooth transition

**7. Privacy Policy Link** (lines ~188-199)
- Link to privacy policy page
- Required for App Store compliance

**Security Features:**
- Passwords never stored locally
- Encrypted transmission (HTTPS)
- Email verification (can be enabled)
- Password reset option

---

#### `Views/Screens/JournalTypeSelectionScreen.swift` (246 lines)

**Purpose:** Choose what type of journal entry to create.

**What it does in plain English:**
- **Like a menu asking "What kind of entry do you want to write today?"**

**Layout:**

**1. Header** (lines ~30-60)
- Title: "New Journal Entry"
- Subtitle: "Choose a type"
- Close button (X)

**2. Journal Type Grid** (lines ~60-220)
- 8 cards, one for each type:
  - Quick Note (lightning icon)
  - Personal (heart icon)
  - Photo (camera icon)
  - Gratitude (sparkles icon)
  - Goals (target icon)
  - Reflection (thought bubble icon)
  - Dreams (moon icon)
  - Travel (airplane icon)
- Each card has:
  - Icon
  - Name
  - Brief description
  - Color theme
  - Tap to select

**3. Selection Action** (lines ~220-246)
- Tap card → Opens corresponding journal screen
- Smooth transition animation
- Dismisses selection screen
- Passes journal type to next screen

**User Experience:**
- Visual and intuitive
- Quick to scan options
- Beautiful card design
- Responsive to taps

---

#### `Views/Screens/ReflectionJournalScreen.swift` (~350 lines)

**Purpose:** Guided deep reflection with prompts.

**What it does in plain English:**
- **Like a conversation with yourself, with thought-provoking questions to guide you**

**Features:**

**1. Reflection Prompts**
- Rotating daily prompts
- Categories: self-discovery, values, growth, relationships
- Examples:
  - "What would you do if you weren't afraid?"
  - "What are you most proud of this year?"
  - "What relationship needs attention?"

**2. Guided Questions**
- Multi-step reflection process
- Each question builds on the last
- "Why?" prompts to go deeper
- Optional - can skip questions

**3. Free-form Section**
- Open text area for additional thoughts
- No character limit
- Can be as long or short as needed

**4. Reflection Review**
- Summary of your answers
- Ability to edit before saving
- AI can provide insights on your reflection

---

#### `Views/Onboarding/OnboardingView.swift` (471 lines)

**Purpose:** Welcome tutorial for new users (shown once on first launch).

**What it does in plain English:**
- **Like a tour guide showing you around the app for the first time**

**3-Page Tutorial:**

**Page 1: Welcome** (lines ~86-174)
- Large Remy logo with animation
- App name with elegant typography
- Tagline: "Your personal space for reflection"
- Floating decorative elements
- Pulsing glow effect

**Page 2: Features** (lines ~176-264)
- Shows key features with pills:
  - Voice journaling (mic icon)
  - Photo journaling (camera icon)
  - AI insights (sparkles icon)
  - Mood tracking (heart icon)
  - Analytics (chart icon)
- Title: "Everything you need"
- Description of capabilities
- Animated entrance of pills

**Page 3: Get Started** (lines ~266-393)
- Checkmark icon with animation
- "Ready to begin?" message
- Big "Get Started" button
- Note: "No account needed to start"
- Tap button → Marks onboarding complete → Shows app

**Design Details:**
- Page indicators (dots) at bottom
- Swipe between pages
- Smooth animations and transitions
- Background gradient changes per page
- Beautiful, calming aesthetic

**Technical:**
- Uses SwiftUI `TabView` with page style
- Binding to `isOnboardingComplete` flag
- Stored in UserDefaults (remember completion)
- Can't be shown again once completed

---

### Views - Components

Reusable UI components used across multiple screens.

#### `Views/Components/MoodSelector.swift` (~120 lines)

**Purpose:** Reusable mood picker component.

**What it does in plain English:**
- **A row of emoji faces you tap to select your mood**

**Features:**
- 8 mood options (happy, sad, stressed, etc.)
- Each mood has:
  - Emoji icon
  - Color
  - Name (shown on tap)
- Visual feedback on selection
- Can be used in any screen
- Optional (can skip mood selection)

**Usage:**
```swift
MoodSelector(selectedMood: $mood)
// User taps happy face → $mood becomes .happy
```

**Design:**
- Horizontal scrollable row
- Large, tappable targets
- Selected mood highlighted
- Smooth spring animation on tap

---

#### `Views/Components/ThemeSelector.swift` (~110 lines)

**Purpose:** Reusable theme/category picker.

**What it does in plain English:**
- **Icons representing life categories (work, family, health, etc.) you tap to categorize entries**

**Features:**
- 8 theme options
- Each theme has:
  - Icon (briefcase, heart, dumbbell, etc.)
  - Color
  - Name
- Grid or horizontal layout
- Multiple selection possible (future feature)

**Usage:**
```swift
ThemeSelector(selectedTheme: $theme)
// User taps work icon → $theme becomes .work
```

---

#### `Views/Components/StreakProgress.swift` (~90 lines)

**Purpose:** Visual display of journaling streak.

**What it does in plain English:**
- **A widget showing your current streak with a circular progress indicator**

**Elements:**
- Circular progress ring
- Current streak number in center
- "days in a row" label
- Percentage filled based on progress toward goal
- Color changes based on streak length:
  - 0-7 days: Bronze
  - 8-30 days: Silver
  - 31+ days: Gold

**Animation:**
- Animates when streak increases
- Confetti effect on milestones (7, 30, 100 days)
- Haptic feedback

---

#### `Views/Components/DecorativeElements.swift` (305 lines)

**Purpose:** Reusable decorative background elements.

**What it does in plain English:**
- **Pretty shapes and gradients that make the app look polished and not boring**

**Includes:**

**1. FloatingCircles** (lines ~30-120)
- Animated circles that float in background
- Different sizes and colors
- Subtle movement (floating up/down)
- Low opacity (doesn't distract from content)

**2. GradientBackground** (lines ~120-180)
- Smooth color gradients
- Matches app color scheme
- Different variations for different screens

**3. ParticleEffect** (lines ~180-240)
- Sparkle effects for celebrations
- Used when completing streaks, saving entries
- Customizable color and intensity

**4. WaveAnimation** (lines ~240-305)
- Subtle wave motion in backgrounds
- Calming effect
- Used in meditation/reflection screens

**Why Decorations Matter:**
- Makes app feel premium
- Creates emotional connection
- Guides user attention
- Delightful micro-interactions

---

### Extensions (Utilities)

Extensions add new capabilities to existing Swift types.

#### `Extensions/Color+Hex.swift` (57 lines)

**Purpose:** Allows creating colors from hex codes (like in web design).

**What it does in plain English:**
- **Lets designers specify colors exactly like in design tools (Figma, Sketch)**

**Without this extension:**
```swift
Color(red: 0.545, green: 0.353, blue: 0.102) // confusing!
```

**With this extension:**
```swift
Color(hex: "#8B5A3C") // clear and matches design specs!
```

**Predefined App Colors** (lines 36-56):
- `remyBrown`: Main brand color #4A2C1A
- `remyCream`: Background color #FDF8F6
- `remyBeige`: Secondary color #E8DCD1
- `remyDarkBrown`: Dark accent #3D1F0F
- Plus accent colors for highlights

**Benefits:**
- Designer gives hex code → Developer uses exact color
- Consistent branding across app
- Easy to update color scheme
- Matches web version colors

---

#### `Extensions/Font+Remy.swift` (~70 lines)

**Purpose:** Defines custom font styles used throughout the app.

**What it does in plain English:**
- **Like a style guide for text - ensures all text looks consistent**

**Custom Font Styles:**
- `remyTitle`: Large, bold headlines (32pt)
- `remyHeadline`: Section headers (24pt)
- `remyBody`: Regular text (16pt)
- `remyCaption`: Small text (12pt)
- `remyButton`: Button text (18pt, semibold)

**Usage:**
```swift
Text("Welcome to Remy")
    .font(.remyTitle) // Instead of manually setting size/weight
```

**Benefits:**
- Consistent typography across app
- Easy to update all titles at once
- Accessibility support (scales with device settings)
- Professional appearance

---

## Data Flow

### How data moves through the app:

```
1. User Action (View)
   ↓
2. ViewModel receives action
   ↓
3. ViewModel calls Service
   ↓
4. Service makes API call to cloud
   ↓
5. Cloud processes and responds
   ↓
6. Service receives response
   ↓
7. ViewModel updates published properties
   ↓
8. View automatically refreshes (SwiftUI magic)
   ↓
9. User sees updated UI
```

### Example: Creating a Journal Entry

1. **User types entry** in QuickJournalScreen
2. **User taps Save** button
3. **QuickJournalScreen** calls `journalViewModel.createEntry(entry)`
4. **JournalViewModel** shows loading state (`isLoading = true`)
5. **JournalViewModel** calls `supabaseService.createJournalEntry(entry)`
6. **SupabaseService** sends entry to Supabase cloud database
7. **Supabase** saves entry and returns success
8. **SupabaseService** returns saved entry to ViewModel
9. **JournalViewModel** adds entry to local `entries` array
10. **JournalViewModel** calls `supabaseService.updateStreak()`
11. **SupabaseService** updates streak data
12. **JournalViewModel** sets `isLoading = false`
13. **QuickJournalScreen** automatically updates to show success
14. **QuickJournalScreen** dismisses and returns to home
15. **HomeScreen** automatically shows new entry (because of published properties)

---

## Third-Party Dependencies

### Supabase SDK
- **What it is:** Cloud database and authentication platform
- **Why we use it:** Store user data securely, handle user login
- **Files that use it:** SupabaseService.swift
- **License:** MIT (open source)
- **Privacy:** User data stored on Supabase servers (encrypted)

### OpenAI API
- **What it is:** AI service for analyzing text and generating insights
- **Why we use it:** Provide AI-powered journal analysis
- **Files that use it:** AIService.swift
- **Cost:** Pay-per-use API (charges based on usage)
- **Privacy:** Entries sent to OpenAI for processing (see OpenAI privacy policy)

### SwiftUI
- **What it is:** Apple's modern UI framework
- **Why we use it:** Build beautiful, reactive interfaces
- **Files that use it:** All View files
- **License:** Apple (built into iOS)

### Combine
- **What it is:** Apple's reactive programming framework
- **Why we use it:** Handle async data flow and updates
- **Files that use it:** ViewModels, Services
- **License:** Apple (built into iOS)

---

## Privacy & Security

### Data Storage
- **Journal entries:** Stored in Supabase (cloud database)
- **Photos:** Stored in Supabase Storage (separate from database)
- **User credentials:** Managed by Supabase Auth (encrypted)
- **Local cache:** Some data cached on device for offline access

### Encryption
- **In transit:** All API calls use HTTPS (encrypted)
- **At rest:** Database encrypted on Supabase servers
- **Passwords:** Hashed and salted (never stored as plain text)

### Data Access
- **Row Level Security:** Users can only access their own data
- **API Keys:** Stored in Config.xcconfig (not committed to git)
- **Authentication required:** All data operations require valid login

### Third-Party Access
- **Supabase:** Has access to database (hosting provider)
- **OpenAI:** Receives journal text for analysis (temporary, not stored)
- **Apple:** Standard iOS analytics (can be disabled by user)

### User Rights
- **View data:** Access all your data anytime
- **Export data:** Can export all entries as JSON
- **Delete data:** Delete individual entries or entire account
- **Right to be forgotten:** Account deletion removes all data permanently

---

## Performance Considerations

### Optimizations Implemented

**1. Lazy Loading**
- Journal entries loaded on-demand
- Images loaded only when visible
- Reduces memory usage and initial load time

**2. Caching**
- Recent entries cached locally
- Images cached after first load
- Reduces network requests

**3. Async/Await**
- All network calls non-blocking
- UI remains responsive during operations
- Background processing for heavy tasks

**4. Debouncing**
- Search input debounced (waits for typing to stop)
- Prevents excessive API calls
- Improves performance

**5. Image Compression**
- Photos compressed before upload
- Reduces storage costs
- Faster upload/download

---

## Error Handling Strategy

### Types of Errors Handled

**1. Network Errors**
- No internet connection
- Slow connection timeouts
- Server unavailable
- Graceful degradation to cached data

**2. Authentication Errors**
- Invalid credentials
- Expired session
- Account not found
- Clear error messages to user

**3. Validation Errors**
- Empty required fields
- Invalid email format
- Password too short
- Prevented before submission

**4. Storage Errors**
- Upload failed
- Photo too large
- Storage quota exceeded
- Retry mechanisms

**5. AI Errors**
- API rate limit exceeded
- Invalid response
- Timeout
- Fallback to basic features

---

## Testing & Quality Assurance

### What Gets Tested

**1. Unit Tests**
- Model validation
- Date calculations for streaks
- Data parsing and formatting

**2. Integration Tests**
- API calls to Supabase
- Authentication flow
- Data synchronization

**3. UI Tests**
- Navigation between screens
- Form submissions
- Error displays

**4. Manual Testing Checklist**
- [ ] Can create all journal types
- [ ] Streak updates correctly
- [ ] Photos upload successfully
- [ ] AI insights generate properly
- [ ] Offline mode works
- [ ] Login/logout flow
- [ ] Data persistence
- [ ] Animations smooth

---

## Future Enhancements Planned

### Roadmap

**Phase 1: Core Features** ✅ (Current)
- Basic journaling
- Mood/theme tracking
- AI insights
- Streak tracking
- Analytics

**Phase 2: Enhanced AI** 🚧
- Conversation memory (AI remembers previous chats)
- Personalized prompts based on patterns
- Sentiment analysis trends
- Custom AI coaching

**Phase 3: Social Features** 📋
- Share entries with therapist/coach
- Collaborative journals (shared with partner/family)
- Public journal entries (optional)
- Community challenges

**Phase 4: Advanced Analytics** 📋
- Correlation analysis (mood vs. sleep, weather, etc.)
- Predictive insights (AI predicts mood trends)
- Export reports for therapy
- Integration with health apps

**Phase 5: Monetization** 💰
- Free tier (basic features)
- Premium tier ($4.99/month):
  - Unlimited AI insights
  - Advanced analytics
  - Custom themes
  - Export features
  - Priority support

---

## Glossary of Terms

**API (Application Programming Interface):** A way for different software systems to talk to each other. Like a waiter taking orders between you and the kitchen.

**Async/Await:** A programming technique that prevents the app from freezing while waiting for slow operations (like loading data from the internet).

**Backend:** The server-side part of the app that stores data and handles business logic. Users don't see this.

**Binding:** A SwiftUI feature that keeps two pieces of data synchronized. When one changes, the other automatically updates.

**Cloud Storage:** Storing data on remote servers (Supabase) instead of just on your phone.

**Closure:** A block of code that can be passed around and executed later. Like giving someone instructions to follow later.

**Environment Object:** A SwiftUI feature that makes data available to all child views without explicitly passing it.

**Frontend:** The user interface part of the app. What users see and interact with.

**HTTPS:** Secure internet protocol that encrypts data sent between app and server.

**JSON (JavaScript Object Notation):** A format for structuring data. Like organizing information in labeled boxes.

**Lazy Loading:** Loading data only when needed, not all at once. Saves memory and improves performance.

**Main Actor:** The main thread where UI updates happen. Ensures smooth animations and responsiveness.

**MVVM (Model-View-ViewModel):** Architecture pattern separating data, UI, and logic.

**Observable Object:** A class that notifies views when its data changes, triggering UI updates.

**Published Property:** A variable that automatically notifies listeners when it changes.

**State:** Data that can change over time and triggers UI updates when modified.

**SwiftUI:** Apple's modern framework for building user interfaces declaratively.

**Task:** A unit of asynchronous work. Runs in the background without blocking the UI.

**UUID (Universally Unique Identifier):** A unique ID that's practically guaranteed to never repeat. Like a super-long serial number.

**View:** A SwiftUI component that displays UI. Can be a button, text, screen, or entire interface.

**ViewModel:** The layer between Views and Services that handles business logic.

---

## Code Quality Standards

### Standards Followed

**1. Swift Style Guide**
- Follows Apple's official Swift style guide
- Clear, descriptive variable names
- Consistent indentation and formatting

**2. Comments & Documentation**
- All public functions documented
- Complex logic explained
- File headers with purpose statements

**3. SOLID Principles**
- **S**ingle Responsibility: Each file has one clear purpose
- **O**pen/Closed: Easy to extend without modifying existing code
- **L**iskov Substitution: Components are interchangeable
- **I**nterface Segregation: Focused, minimal interfaces
- **D**ependency Inversion: Depend on abstractions, not concrete implementations

**4. DRY (Don't Repeat Yourself)**
- Reusable components (MoodSelector, ThemeSelector, etc.)
- Shared utilities (Color+Hex, Font+Remy)
- Single source of truth for data

**5. Error Handling**
- All network calls wrapped in try/catch
- User-friendly error messages
- Graceful degradation when features unavailable

---

## Accessibility Features

### Implemented Accessibility

**1. VoiceOver Support**
- All buttons labeled for screen readers
- Images have descriptive alt text
- Logical navigation order

**2. Dynamic Type**
- Text scales with device settings
- Large text mode supported
- Maintains readability at all sizes

**3. Color Contrast**
- WCAG AA compliant contrast ratios
- Not relying solely on color to convey info
- Supports light/dark mode

**4. Haptic Feedback**
- Tactile confirmation for actions
- Helps users with visual impairments
- Different patterns for different actions

---

## Deployment & Distribution

### App Store Requirements Met

**1. Privacy Policy** ✅
- Linked in authentication screen
- Explains data collection and usage
- Contact information provided

**2. Permissions** ✅
- Camera access for photo journals
- Microphone access for voice journals
- Photo library access for selecting images
- All permissions have clear explanations

**3. Age Rating**
- Rated 4+ (no mature content)
- Safe for all ages

**4. App Store Description**
- Clear description of features
- Screenshots of all main screens
- Privacy highlights
- No misleading claims

**5. Testing**
- Tested on multiple iOS versions
- Tested on different device sizes
- No crashes in critical flows
- Performance benchmarks met

---

## Contact & Support

For questions about this codebase or the Remy app:

**Developer:** [Your Name]
**Email:** [Your Email]
**Website:** [Your Website]
**GitHub:** [Your GitHub]

---

**Document Version:** 1.0
**Last Updated:** October 23, 2025
**Next Review:** Every major release

---

*This documentation is intended to help auditors, future developers, and stakeholders understand the Remy codebase. All technical decisions have been made with user privacy, performance, and experience as top priorities.*
