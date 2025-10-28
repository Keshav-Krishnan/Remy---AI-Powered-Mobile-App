# Supabase Integration Guide for Remy

Complete step-by-step guide to integrate Supabase authentication and database into your Remy journaling app.

## Project Information
- **Project URL**: `https://pwyweperbipjdisrkoio.supabase.co`
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB3eXdlcGVyYmlwamRpc3Jrb2lvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3Nzk2NzksImV4cCI6MjA3NjM1NTY3OX0.1NXcmTFGOA7xLQPUDPW102el0zaO0zEZkSQ6Zi_PH-U`

---

## Table of Contents
1. [Phase 1: Database Setup (20 min)](#phase-1-database-setup)
2. [Phase 2: Xcode Integration (15 min)](#phase-2-xcode-integration)
3. [Phase 3: Authentication Setup (25 min)](#phase-3-authentication-setup)
4. [Phase 4: Database Integration (30 min)](#phase-4-database-integration)
5. [Phase 5: Testing & Verification (15 min)](#phase-5-testing--verification)

---

## Phase 1: Database Setup

### Step 1: Create Database Tables

Go to your Supabase Dashboard → SQL Editor and run these SQL commands:

```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users profile table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create journal entries table
CREATE TABLE journal_entries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  journal_type TEXT NOT NULL,
  mood_tag TEXT,
  theme_tags TEXT[],
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Photo journal specific
  photo_url TEXT,
  photo_caption TEXT,

  -- Goals journal specific
  goal_title TEXT,
  goal_category TEXT,
  target_date TIMESTAMP WITH TIME ZONE,
  progress DECIMAL DEFAULT 0.0,
  milestones JSONB,

  -- Dreams journal specific
  dream_type TEXT,
  dream_emotions TEXT[],
  dream_clarity INTEGER,

  -- Reflection journal specific
  reflection_responses JSONB
);

-- Create streak data table
CREATE TABLE streak_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_entry_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Create chat messages table (for AI therapy conversations)
CREATE TABLE chat_messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX idx_journal_entries_timestamp ON journal_entries(timestamp DESC);
CREATE INDEX idx_journal_entries_journal_type ON journal_entries(journal_type);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp DESC);
```

### Step 2: Set Up Row Level Security (RLS)

Run these commands to enable RLS and create policies:

```sql
-- Enable Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Journal entries policies
CREATE POLICY "Users can view own journal entries"
  ON journal_entries FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own journal entries"
  ON journal_entries FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own journal entries"
  ON journal_entries FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own journal entries"
  ON journal_entries FOR DELETE
  USING (auth.uid() = user_id);

-- Streak data policies
CREATE POLICY "Users can view own streak data"
  ON streak_data FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own streak data"
  ON streak_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own streak data"
  ON streak_data FOR UPDATE
  USING (auth.uid() = user_id);

-- Chat messages policies
CREATE POLICY "Users can view own chat messages"
  ON chat_messages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own chat messages"
  ON chat_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat messages"
  ON chat_messages FOR DELETE
  USING (auth.uid() = user_id);
```

### Step 3: Create Storage Bucket for Photos

1. Go to **Storage** in Supabase Dashboard
2. Click **New bucket**
3. Name it `journal-photos`
4. Set to **Private** (user photos should be private)
5. Click **Save**

Then set up storage policies in SQL Editor:

```sql
-- Storage policies for journal photos
CREATE POLICY "Users can upload own photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view own photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can delete own photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );
```

### Step 4: Enable Email Authentication

1. Go to **Authentication → Providers** in Supabase Dashboard
2. Enable **Email** provider
3. Configure email templates (optional):
   - Go to **Authentication → Email Templates**
   - Customize "Confirm signup" and "Reset password" templates

---

## Phase 2: Xcode Integration

### Step 1: Install Supabase Swift SDK

1. Open your Xcode project
2. Go to **File → Add Package Dependencies**
3. Enter: `https://github.com/supabase/supabase-swift`
4. Select version: **Up to Next Major Version** (latest)
5. Add to your **Remy** target
6. Click **Add Package**

Packages to add:
- ✅ Auth
- ✅ PostgREST
- ✅ Realtime
- ✅ Storage
- ✅ Supabase

### Step 2: Create Supabase Configuration

I've created `SupabaseConfig.swift` with your credentials (see implementation files).

**IMPORTANT SECURITY NOTE**: For production, move credentials to:
1. Create a `.xcconfig` file (excluded from git)
2. Or use Xcode's User-Defined settings
3. Never commit credentials to version control

---

## Phase 3: Authentication Setup

### Authentication Flow

1. **Sign Up**: Email + Password → Create account → Email verification
2. **Sign In**: Email + Password → Access app
3. **Sign Out**: Clear session → Return to auth screen
4. **Forgot Password**: Send reset email → User resets password

### Implementation Files

See the following files I've created:
- `SupabaseService.swift` - Main service for all Supabase operations
- `AuthService.swift` - Authentication-specific operations
- `AuthViewModel.swift` - SwiftUI ViewModel for auth state
- `SignInScreen.swift` - Sign in UI
- `SignUpScreen.swift` - Sign up UI

### Testing Authentication

1. Run your app
2. Create a test account with your email
3. Check Supabase Dashboard → Authentication → Users
4. You should see your new user

---

## Phase 4: Database Integration

### Data Flow

```
User Action → ViewModel → SupabaseService → Supabase Database → Response → Update UI
```

### Key Features Implemented

1. **Journal Entries**
   - Create, read, update, delete entries
   - Support all journal types (quick, goals, photo, dreams, reflection)
   - Auto-sync with Supabase

2. **Photo Upload**
   - Upload to Supabase Storage
   - Generate public URL
   - Associate with journal entry

3. **Streak Tracking**
   - Automatically update streaks on new entries
   - Calculate current and longest streaks
   - Store in dedicated table

4. **Chat History**
   - Save AI therapy conversations
   - Load conversation history
   - Sync across devices

### Updated Files

I've updated:
- `JournalViewModel.swift` - Now uses SupabaseService
- All journal screens - Work with Supabase backend

---

## Phase 5: Testing & Verification

### Test Checklist

#### Authentication Tests
- [ ] Sign up with new email
- [ ] Sign in with existing account
- [ ] Sign out and verify session cleared
- [ ] Test password reset flow
- [ ] Check user appears in Supabase Dashboard

#### Journal Entry Tests
- [ ] Create quick journal entry
- [ ] Create gratitude entry
- [ ] Create photo journal (with upload)
- [ ] Create goals entry with milestones
- [ ] Create dream journal entry
- [ ] Create reflection journal entry
- [ ] Verify all entries appear in Supabase Dashboard
- [ ] Edit an entry and verify update
- [ ] Delete an entry and verify removal

#### Photo Upload Tests
- [ ] Take photo with camera
- [ ] Select photo from library
- [ ] Verify upload to Supabase Storage
- [ ] Check photo appears in entry
- [ ] Verify photo URL is accessible

#### Streak Tests
- [ ] Create entry and check streak increases
- [ ] Create multiple entries same day (streak stays same)
- [ ] Check streak data in Supabase Dashboard
- [ ] Verify longest streak calculation

#### Chat Tests
- [ ] Send message to AI therapist
- [ ] Verify conversation saves to database
- [ ] Close and reopen app
- [ ] Verify chat history loads

#### Graph/Dashboard Tests
- [ ] Create several entries over multiple days
- [ ] Check Dashboard shows correct stats
- [ ] Verify weekly activity graph updates
- [ ] Check mood distribution chart
- [ ] Verify journal type breakdown

---

## Database Schema Reference

### `profiles` table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | User ID (from auth.users) |
| email | TEXT | User email |
| full_name | TEXT | User's full name |
| avatar_url | TEXT | Profile picture URL |
| created_at | TIMESTAMP | Account creation |
| updated_at | TIMESTAMP | Last update |

### `journal_entries` table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Entry ID |
| user_id | UUID | Owner user ID |
| content | TEXT | Entry content |
| journal_type | TEXT | Type: quick, gratitude, goals, photo, dreams, reflection |
| mood_tag | TEXT | Mood: happy, sad, anxious, calm, excited, grateful, neutral |
| theme_tags | TEXT[] | Array of theme tags |
| timestamp | TIMESTAMP | Entry date/time |
| photo_url | TEXT | Photo URL (for photo journals) |
| photo_caption | TEXT | Photo caption |
| goal_title | TEXT | Goal title (for goal journals) |
| goal_category | TEXT | Goal category |
| target_date | TIMESTAMP | Goal target date |
| progress | DECIMAL | Goal progress (0.0-1.0) |
| milestones | JSONB | Goal milestones array |
| dream_type | TEXT | Dream type: normal, lucid, nightmare, recurring |
| dream_emotions | TEXT[] | Emotions in dream |
| dream_clarity | INTEGER | Clarity level (1-5) |
| reflection_responses | JSONB | Reflection prompt responses |

### `streak_data` table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Record ID |
| user_id | UUID | Owner user ID |
| current_streak | INTEGER | Current consecutive days |
| longest_streak | INTEGER | All-time longest streak |
| last_entry_date | DATE | Last entry date |

### `chat_messages` table
| Column | Type | Description |
|--------|------|-------------|
| id | UUID | Message ID |
| user_id | UUID | Owner user ID |
| content | TEXT | Message content |
| is_user | BOOLEAN | true = user message, false = AI |
| timestamp | TIMESTAMP | Message time |

---

## Security Best Practices

### 1. Environment Variables
Move credentials out of code:

```swift
// DON'T commit this to git!
// Use .xcconfig or build settings instead
```

### 2. Row Level Security
All tables have RLS enabled. Users can only access their own data.

### 3. Storage Security
Photos are organized by user ID. Users can only access their own photos.

### 4. API Key Types
- **Anon Key**: Safe for client-side (used in app)
- **Service Role Key**: NEVER use in app (server-side only)

---

## Troubleshooting

### Issue: "User not authenticated"
**Solution**: Check if user is signed in with `SupabaseService.shared.currentUser`

### Issue: "Row Level Security policy violation"
**Solution**: Verify RLS policies are set up correctly and user_id matches auth.uid()

### Issue: Photo upload fails
**Solution**:
1. Check storage bucket exists and is named `journal-photos`
2. Verify storage policies are set up
3. Check file size (max 50MB by default)

### Issue: Entries not appearing
**Solution**:
1. Check Supabase Dashboard → Table Editor → journal_entries
2. Verify user_id matches the signed-in user
3. Check RLS policies allow SELECT

### Issue: "Invalid API key"
**Solution**: Verify you're using the **anon** key, not the service role key

---

## Next Steps

1. **Implement offline support**: Cache entries locally with CoreData/Realm
2. **Add realtime sync**: Use Supabase Realtime for live updates
3. **Implement social features**: Add friend system, shared journals
4. **Add analytics**: Track user engagement with Supabase Analytics
5. **Push notifications**: Remind users to journal daily

---

## Useful Supabase Resources

- Dashboard: https://pwyweperbipjdisrkoio.supabase.co
- Docs: https://supabase.com/docs
- Swift SDK: https://github.com/supabase/supabase-swift
- Community: https://github.com/supabase/supabase/discussions

---

## Support

If you encounter issues:
1. Check Supabase Dashboard → Logs
2. Enable debug logging in SupabaseService
3. Check Xcode console for errors
4. Review this guide's troubleshooting section
