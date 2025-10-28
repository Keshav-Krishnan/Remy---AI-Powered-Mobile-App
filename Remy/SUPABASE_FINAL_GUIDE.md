# Supabase Integration - Final Step-by-Step Guide

This is your complete guide to setting up Supabase for the Remy journaling app.

---

## 📋 Overview

**What you'll set up:**
- ✅ Supabase project and database
- ✅ Authentication (Email/Password)
- ✅ Database tables with Row Level Security (RLS)
- ✅ Storage bucket for photos/audio
- ✅ Your iOS app configuration

**Time required:** ~15 minutes

---

## 🚀 Step 1: Create Supabase Project

### 1.1 Sign Up / Sign In
1. Go to [https://supabase.com](https://supabase.com)
2. Click **"Start your project"** or **"Sign In"**
3. Sign in with GitHub (recommended) or email

### 1.2 Create New Project
1. Click **"New Project"**
2. Fill in details:
   - **Name:** `remy-journal` (or your preferred name)
   - **Database Password:** Create a strong password (save this!)
   - **Region:** Choose closest to your users
   - **Pricing Plan:** Free tier is fine for development
3. Click **"Create new project"**
4. Wait 2-3 minutes for project to initialize

### 1.3 Get Your Credentials
Once the project is ready:

1. Go to **Settings** (gear icon in sidebar) → **API**
2. Copy these two values (you'll need them later):
   - **Project URL:** `https://[your-project-ref].supabase.co`
   - **anon/public key:** `eyJhbGci...` (long string)

---

## 🗄️ Step 2: Set Up Database

### 2.1 Open SQL Editor
1. In Supabase dashboard, click **SQL Editor** (left sidebar)
2. Click **"New query"**

### 2.2 Run Database Setup SQL

**Copy and paste this entire SQL script, then click "Run":**

```sql
-- =================================================
-- REMY DATABASE SETUP - COMPLETE SCHEMA
-- =================================================
-- This creates all tables, indexes, and security policies
-- Run this entire script in one go
-- =================================================

-- Step 1: Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =================================================
-- Step 2: Create Tables
-- =================================================

-- Profiles table (user information)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Journal entries table (main data)
CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  journal_type TEXT NOT NULL,
  mood_tag TEXT,
  theme_tags TEXT[],
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Media URLs
  photo_url TEXT,
  audio_url TEXT,

  -- Optional fields for future features
  photo_caption TEXT,
  goal_title TEXT,
  goal_category TEXT,
  target_date TIMESTAMP WITH TIME ZONE,
  progress DECIMAL DEFAULT 0.0,
  milestones JSONB,
  dream_type TEXT,
  dream_emotions TEXT[],
  dream_clarity INTEGER,
  reflection_responses JSONB
);

-- Streak data table (tracking journaling streaks)
CREATE TABLE IF NOT EXISTS streak_data (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_entry_date DATE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Chat messages table (AI therapy conversations)
CREATE TABLE IF NOT EXISTS chat_messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =================================================
-- Step 3: Create Indexes for Performance
-- =================================================

CREATE INDEX IF NOT EXISTS idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_timestamp ON journal_entries(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_journal_entries_journal_type ON journal_entries(journal_type);
CREATE INDEX IF NOT EXISTS idx_journal_entries_mood_tag ON journal_entries(mood_tag);
CREATE INDEX IF NOT EXISTS idx_streak_data_user_id ON streak_data(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_timestamp ON chat_messages(timestamp DESC);

-- =================================================
-- Step 4: Enable Row Level Security (RLS)
-- =================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- =================================================
-- Step 5: Create RLS Policies for Profiles
-- =================================================

-- Drop existing policies if they exist (for re-running script)
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- =================================================
-- Step 6: Create RLS Policies for Journal Entries
-- =================================================

DROP POLICY IF EXISTS "Users can view own journal entries" ON journal_entries;
DROP POLICY IF EXISTS "Users can create own journal entries" ON journal_entries;
DROP POLICY IF EXISTS "Users can update own journal entries" ON journal_entries;
DROP POLICY IF EXISTS "Users can delete own journal entries" ON journal_entries;

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

-- =================================================
-- Step 7: Create RLS Policies for Streak Data
-- =================================================

DROP POLICY IF EXISTS "Users can view own streak data" ON streak_data;
DROP POLICY IF EXISTS "Users can create own streak data" ON streak_data;
DROP POLICY IF EXISTS "Users can update own streak data" ON streak_data;

CREATE POLICY "Users can view own streak data"
  ON streak_data FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own streak data"
  ON streak_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own streak data"
  ON streak_data FOR UPDATE
  USING (auth.uid() = user_id);

-- =================================================
-- Step 8: Create RLS Policies for Chat Messages
-- =================================================

DROP POLICY IF EXISTS "Users can view own chat messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can create own chat messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can delete own chat messages" ON chat_messages;

CREATE POLICY "Users can view own chat messages"
  ON chat_messages FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own chat messages"
  ON chat_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own chat messages"
  ON chat_messages FOR DELETE
  USING (auth.uid() = user_id);

-- =================================================
-- SETUP COMPLETE!
-- =================================================
-- Next steps:
-- 1. Create storage bucket "journal-photos" in Storage UI
-- 2. Run storage policies SQL (see next section)
-- 3. Enable Email auth in Authentication → Providers
-- =================================================
```

### 2.3 Verify Tables Created
1. Click **Table Editor** (left sidebar)
2. You should see 4 tables:
   - ✅ profiles
   - ✅ journal_entries
   - ✅ streak_data
   - ✅ chat_messages

---

## 📁 Step 3: Set Up Storage

### 3.1 Create Storage Bucket
1. Click **Storage** (left sidebar)
2. Click **"New bucket"**
3. Fill in:
   - **Name:** `journal-photos`
   - **Public bucket:** ❌ **OFF** (keep it PRIVATE)
   - **File size limit:** 50 MB (default)
   - **Allowed MIME types:** Leave as default
4. Click **"Create bucket"**

### 3.2 Set Up Storage Policies
1. Go back to **SQL Editor**
2. Click **"New query"**
3. **Copy and paste this SQL, then click "Run":**

```sql
-- =================================================
-- STORAGE POLICIES FOR JOURNAL PHOTOS
-- =================================================
-- Run this AFTER creating the "journal-photos" bucket
-- =================================================

-- Drop existing policies if they exist (for re-running)
DROP POLICY IF EXISTS "Users can upload own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can view own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can update own photos" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own photos" ON storage.objects;

-- Allow users to upload their own photos
CREATE POLICY "Users can upload own photos"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow users to view their own photos
CREATE POLICY "Users can view own photos"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow users to update their own photos
CREATE POLICY "Users can update own photos"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Allow users to delete their own photos
CREATE POLICY "Users can delete own photos"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'journal-photos' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- =================================================
-- STORAGE SETUP COMPLETE!
-- =================================================
-- Photos will be stored as: userId/photoId.jpg
-- Only the user who uploaded a photo can access it
-- =================================================
```

### 3.3 Verify Storage Policies
1. Go to **Storage** → Click **"journal-photos"**
2. Click **"Policies"** tab
3. You should see 4 policies enabled

---

## 🔐 Step 4: Enable Authentication

### 4.1 Enable Email Provider
1. Click **Authentication** (left sidebar)
2. Click **"Providers"**
3. Find **"Email"** in the list
4. Click to expand it
5. Toggle **"Enable Email provider"** to **ON**

### 4.2 Configure Email Settings (Optional but Recommended)
- **Enable email confirmations:** OFF (easier for testing)
- **Secure email change:** ON (recommended)
- **Double confirm email changes:** OFF (easier for testing)

6. Click **"Save"**

### 4.3 Disable Email Confirmations (For Development)
1. Stay in **Authentication** → **Providers** → **Email**
2. Scroll down to **"Email confirmation"**
3. Toggle to **OFF** (so you can test without confirming emails)
4. Click **"Save"**

⚠️ **Note:** Re-enable email confirmations before production!

---

## 📱 Step 5: Configure iOS App

### 5.1 Update SupabaseConfig.swift

1. Open your Xcode project
2. Navigate to `Remy/Config/SupabaseConfig.swift`
3. Replace the values with YOUR credentials:

```swift
//
//  SupabaseConfig.swift
//  Remy
//

import Foundation

/// Supabase configuration and credentials
struct SupabaseConfig {
    // MARK: - Credentials

    /// Supabase project URL
    /// TODO: Replace with YOUR project URL from Supabase dashboard
    static let projectURL = "https://YOUR-PROJECT-REF.supabase.co"

    /// Supabase anonymous (public) API key
    /// TODO: Replace with YOUR anon key from Supabase dashboard
    static let anonKey = "YOUR-ANON-KEY-HERE"

    // MARK: - Storage Buckets

    static let photoBucketName = "journal-photos"

    // MARK: - Validation

    static func validate() throws {
        guard !projectURL.isEmpty else {
            throw SupabaseConfigError.missingProjectURL
        }

        guard !anonKey.isEmpty else {
            throw SupabaseConfigError.missingAnonKey
        }

        guard URL(string: projectURL) != nil else {
            throw SupabaseConfigError.invalidProjectURL
        }
    }
}

// MARK: - Configuration Errors

enum SupabaseConfigError: LocalizedError {
    case missingProjectURL
    case missingAnonKey
    case invalidProjectURL

    var errorDescription: String? {
        switch self {
        case .missingProjectURL:
            return "Supabase project URL is missing"
        case .missingAnonKey:
            return "Supabase anon key is missing"
        case .invalidProjectURL:
            return "Supabase project URL is invalid"
        }
    }
}
```

### 5.2 Get Your Credentials

**Where to find them:**
1. Go to Supabase Dashboard
2. Click **Settings** (gear icon) → **API**
3. Copy:
   - **Project URL** → Replace `YOUR-PROJECT-REF`
   - **Project API keys** → **anon** **public** → Replace `YOUR-ANON-KEY-HERE`

**Example:**
```swift
static let projectURL = "https://abcdefghijklmnop.supabase.co"
static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYyOTc5NzE4MCwiZXhwIjoxOTQ1MzczMTgwfQ.example-key-here"
```

### 5.3 Build the Project
1. In Xcode, press **⌘+B** to build
2. Make sure there are no errors
3. If you see package resolution, wait for it to complete

---

## ✅ Step 6: Test Everything

### 6.1 Test Sign Up
1. Run the app in simulator
2. Complete onboarding (if shown)
3. On authentication screen:
   - Email: `test@example.com`
   - Password: `password123`
   - Tap **"Create Account"**
4. Should navigate to main app

### 6.2 Verify in Supabase
1. Go to Supabase Dashboard
2. Click **Authentication** → **Users**
3. You should see your test user!

### 6.3 Test Journal Entry
1. In the app, create a journal entry
2. Go to Supabase Dashboard
3. Click **Table Editor** → **journal_entries**
4. You should see your entry!

### 6.4 Test Sign Out
1. Go to **Insights** tab
2. Tap **gear icon**
3. Tap **Sign Out**
4. Should return to login screen

### 6.5 Test Sign In
1. Enter same credentials
2. Tap **"Sign In"**
3. Should navigate to main app
4. Your journal entries should still be there!

---

## 🔍 Troubleshooting

### Issue: "No such module 'Supabase'"
**Solution:**
1. Clean build folder: Product → Clean Build Folder (⌘+Shift+K)
2. Reset packages: File → Packages → Reset Package Caches
3. Resolve packages: File → Packages → Resolve Package Versions
4. Rebuild

### Issue: "Invalid credentials"
**Solution:**
1. Check `SupabaseConfig.swift` has correct URL and key
2. Make sure you copied the **anon** key, not the service_role key
3. Remove any trailing spaces from the strings

### Issue: "User not found" when signing in
**Solution:**
1. Make sure you created the account first (sign up)
2. Check Supabase Dashboard → Authentication → Users
3. If user exists but can't sign in, try resetting the password

### Issue: "Row Level Security" error
**Solution:**
1. Make sure you ran the RLS policies SQL
2. Verify in Table Editor → click table → Policies tab
3. Should see policies enabled

### Issue: Can't upload photos
**Solution:**
1. Verify `journal-photos` bucket exists in Storage
2. Check storage policies were created (SQL ran successfully)
3. Make sure bucket is set to PRIVATE, not public

---

## 📊 Database Schema Reference

### Tables Overview

| Table | Purpose | Key Fields |
|-------|---------|------------|
| **profiles** | User information | id, email, full_name, avatar_url |
| **journal_entries** | All journal entries | id, user_id, content, journal_type, mood_tag, photo_url |
| **streak_data** | Journaling streaks | user_id, current_streak, longest_streak |
| **chat_messages** | AI chat history | user_id, content, is_user |

### Journal Entry Types
- `quick` - Quick journal
- `personal` - Personal journal
- `photo` - Photo journal
- `gratitude` - Gratitude journal
- `goals` - Goals journal
- `reflection` - Reflection journal
- `dreams` - Dreams journal
- `travel` - Travel journal

### Mood Tags
- `happy`, `grateful`, `excited`, `neutral`, `sad`, `anxious`, `stressed`, `angry`

### Theme Tags
- `personal`, `work`, `relationships`, `family`, `health`, `goals`, `hobbies`, `school`

---

## 🔐 Security Notes

### ✅ What's Secure:
- Row Level Security (RLS) enforced on all tables
- Users can only access their own data
- API keys are safe to use in client apps
- Passwords are hashed by Supabase Auth
- Storage files are private by default

### ⚠️ Important:
- **anon/public key** is safe for client-side use
- **Never** use the **service_role** key in your app
- **Never** commit secrets to git (already in .gitignore)
- Re-enable email confirmations before production

---

## 📈 Next Steps (Optional)

### Add More Features:
1. **Social Auth:** Enable Google/Apple Sign In
2. **Email Templates:** Customize auth emails
3. **Webhooks:** Set up event notifications
4. **Realtime:** Enable realtime subscriptions
5. **Functions:** Add Edge Functions for AI features
6. **Backups:** Set up automatic backups (paid plans)

### Monitor Usage:
1. **Database:** Settings → Database → Check connection pooler
2. **Auth:** Authentication → Rate Limits
3. **Storage:** Storage → Usage
4. **Logs:** Logs → Check for errors

---

## ✅ Final Checklist

Before considering setup complete:

- [ ] Supabase project created
- [ ] Database tables created (4 tables)
- [ ] Indexes created
- [ ] Row Level Security enabled
- [ ] RLS policies created (all tables)
- [ ] Storage bucket created (`journal-photos`)
- [ ] Storage policies created
- [ ] Email authentication enabled
- [ ] Email confirmations disabled (for testing)
- [ ] `SupabaseConfig.swift` updated with your credentials
- [ ] App builds without errors
- [ ] Test user created successfully
- [ ] Test journal entry created
- [ ] Sign out works
- [ ] Sign in works
- [ ] Data persists between sessions

---

## 🎉 You're Done!

Your Remy app is now fully connected to Supabase!

**What you have:**
- ✅ Secure authentication
- ✅ User profiles
- ✅ Journal entries with photos
- ✅ Streak tracking
- ✅ AI chat history
- ✅ Private photo storage
- ✅ Row-level security

**Your app can now:**
- Create user accounts
- Store journal entries securely
- Upload and retrieve photos
- Track journaling streaks
- Save AI conversations
- Keep all data private per user

---

## 📞 Need Help?

### Supabase Resources:
- **Documentation:** [https://supabase.com/docs](https://supabase.com/docs)
- **Discord:** [https://discord.supabase.com](https://discord.supabase.com)
- **GitHub:** [https://github.com/supabase/supabase](https://github.com/supabase/supabase)

### Common Commands:

**View your project:**
```
Supabase Dashboard → Your Project
```

**Quick SQL test:**
```sql
SELECT * FROM profiles;
SELECT * FROM journal_entries;
```

**Check user count:**
```sql
SELECT COUNT(*) FROM auth.users;
```

**Reset test data:**
```sql
DELETE FROM journal_entries WHERE user_id = 'your-test-user-id';
```

---

**Happy journaling! 📝✨**
