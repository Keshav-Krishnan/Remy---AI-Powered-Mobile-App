-- =================================================
-- SUPABASE DATABASE SETUP FOR REMY
-- =================================================
-- Run this entire file in Supabase SQL Editor
-- Dashboard: https://pwyweperbipjdisrkoio.supabase.co
-- Go to: SQL Editor → New Query → Paste this → Run
-- =================================================

-- STEP 1: Enable UUID Extension
-- =================================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";


-- STEP 2: Create Tables
-- =================================================

-- Profiles table (user information)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Journal entries table (main data)
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

-- Streak data table (tracking streaks)
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

-- Chat messages table (AI therapy conversations)
CREATE TABLE chat_messages (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  is_user BOOLEAN NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);


-- STEP 3: Create Indexes for Performance
-- =================================================

CREATE INDEX idx_journal_entries_user_id ON journal_entries(user_id);
CREATE INDEX idx_journal_entries_timestamp ON journal_entries(timestamp DESC);
CREATE INDEX idx_journal_entries_journal_type ON journal_entries(journal_type);
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_timestamp ON chat_messages(timestamp DESC);


-- STEP 4: Enable Row Level Security
-- =================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE streak_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;


-- STEP 5: Create RLS Policies for Profiles
-- =================================================

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON profiles FOR INSERT
  WITH CHECK (auth.uid() = id);


-- STEP 6: Create RLS Policies for Journal Entries
-- =================================================

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


-- STEP 7: Create RLS Policies for Streak Data
-- =================================================

CREATE POLICY "Users can view own streak data"
  ON streak_data FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own streak data"
  ON streak_data FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own streak data"
  ON streak_data FOR UPDATE
  USING (auth.uid() = user_id);


-- STEP 8: Create RLS Policies for Chat Messages
-- =================================================

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
-- 1. Go to Storage → Create bucket named "journal-photos" (Private)
-- 2. Run the storage policies below in a NEW query
-- 3. Enable Email auth in Authentication → Providers
-- =================================================
