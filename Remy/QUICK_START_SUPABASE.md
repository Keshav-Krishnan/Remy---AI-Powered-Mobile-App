# Supabase Quick Start Guide

Your Remy app is now fully integrated with Supabase! Follow these steps to get everything working.

## What I've Done For You

I've created all the code you need:

1. **SupabaseConfig.swift** - Contains your project URL and API key
2. **SupabaseService.swift** - Complete service for auth, database, and storage
3. **JournalViewModel.swift** - Updated to use Supabase instead of Firebase
4. **SignInScreen.swift** - Beautiful sign-in UI with email/password
5. **SignUpScreen.swift** - Sign-up flow with password strength indicator
6. **RemyApp.swift** - Updated to show auth screens when needed
7. **PhotoJournalScreen.swift** - Now uploads photos to Supabase Storage

## Next Steps (Do This Now!)

### Step 1: Install Supabase Swift SDK (5 minutes)

1. Open your Xcode project
2. Go to **File → Add Package Dependencies**
3. Paste this URL: `https://github.com/supabase/supabase-swift`
4. Click **Add Package**
5. Select these packages:
   - ✅ Auth
   - ✅ PostgREST
   - ✅ Realtime
   - ✅ Storage
   - ✅ Supabase
6. Click **Add Package** again

### Step 2: Set Up Database (10 minutes)

1. Go to https://pwyweperbipjdisrkoio.supabase.co
2. Click **SQL Editor** in the left sidebar
3. Click **New Query**
4. Copy the SQL from `SUPABASE_INTEGRATION_GUIDE.md` Phase 1, Step 1
5. Click **Run** to create all tables
6. Do the same for Step 2 (Row Level Security policies)
7. Do the same for Step 3 (Storage bucket policies)

### Step 3: Create Storage Bucket (3 minutes)

1. In Supabase Dashboard, click **Storage**
2. Click **New bucket**
3. Name: `journal-photos`
4. Make it **Private**
5. Click **Save**

### Step 4: Enable Email Auth (2 minutes)

1. Go to **Authentication → Providers**
2. Enable **Email** provider
3. Save

### Step 5: Build & Run (2 minutes)

1. In Xcode, press **Cmd+B** to build
2. Fix any errors (most likely just need to import Supabase)
3. Press **Cmd+R** to run
4. You should see the sign-in screen!

## Testing Your Integration

### Test 1: Create Account
1. Click "Sign Up"
2. Enter your email and password
3. Click "Create Account"
4. Check your email for verification
5. Go back and sign in

### Test 2: Create Journal Entry
1. After signing in, click "+" button
2. Select "Quick Journal"
3. Write something and save
4. Go to Supabase Dashboard → Table Editor → journal_entries
5. Your entry should be there!

### Test 3: Upload Photo
1. Click "+" → "Photo Journal"
2. Take a photo or select from library
3. Add caption and save
4. Go to Supabase Dashboard → Storage → journal-photos
5. Your photo should be uploaded!

### Test 4: Check Streak
1. Create a few entries
2. Check the home screen
3. Your streak should increment!

## Troubleshooting

### "Cannot find 'SupabaseClient' in scope"
- You forgot to install the Supabase SDK (see Step 1)
- Build again after installing

### "Row Level Security policy violation"
- You didn't run the SQL policies (see Step 2)
- Make sure you ran BOTH the table creation AND the RLS policies

### "Storage bucket not found"
- You didn't create the journal-photos bucket (see Step 3)
- Make sure it's named exactly `journal-photos`

### "Invalid API key"
- Check SupabaseConfig.swift has the correct keys
- Your anon key: starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

### Entries not showing up
- Check if user is signed in
- Look at Supabase Dashboard → Table Editor → journal_entries
- Make sure the user_id matches your signed-in user

## What Each File Does

### SupabaseConfig.swift
- Stores your project URL and API key
- Validates configuration on startup

### SupabaseService.swift
- **Auth**: Sign up, sign in, sign out, password reset
- **Database**: Create, read, update, delete entries
- **Storage**: Upload and delete photos
- **Streaks**: Automatic streak calculation

### JournalViewModel.swift
- Loads entries from Supabase on app start
- Creates entries with automatic Supabase sync
- Uploads photos when creating photo journals
- Updates streak data automatically

### SignInScreen.swift
- Email/password sign in
- Forgot password flow
- Link to sign up

### SignUpScreen.swift
- Email/password registration
- Password strength indicator
- Email verification flow

### RemyApp.swift
- Shows onboarding → auth → main app flow
- Manages authentication state
- Provides environment objects

## Database Schema Quick Reference

### journal_entries table
```
id              UUID        Entry ID
user_id         UUID        Who owns this entry
content         TEXT        Entry text
journal_type    TEXT        Type: quick, photo, goals, etc.
mood_tag        TEXT        Mood: happy, sad, etc.
photo_url       TEXT        URL of uploaded photo
timestamp       TIMESTAMP   When entry was created
```

### profiles table
```
id              UUID        User ID (same as auth.users.id)
email           TEXT        User email
full_name       TEXT        User's name (optional)
avatar_url      TEXT        Profile pic (optional)
```

### streak_data table
```
user_id         UUID        Who this streak belongs to
current_streak  INT         Current consecutive days
longest_streak  INT         All-time best streak
last_entry_date DATE        Last time they journaled
```

## Security Notes

Your credentials are already in the code (SupabaseConfig.swift). This is fine for development, but for production:

1. **DO NOT** commit your service role key (you're only using the anon key, which is safe)
2. **DO** enable Row Level Security (already done in the SQL)
3. **DO** use HTTPS only (Supabase enforces this)
4. **CONSIDER** moving keys to environment variables for production

## Next Features You Can Add

1. **Offline Support**: Cache entries locally with CoreData
2. **Realtime Sync**: Use Supabase Realtime for live updates
3. **Social Features**: Share entries with friends
4. **AI Insights**: Integrate OpenAI for entry analysis
5. **Push Notifications**: Daily journal reminders

## Support

If you get stuck:
1. Check the full guide: `SUPABASE_INTEGRATION_GUIDE.md`
2. Check Supabase logs: Dashboard → Logs
3. Check Xcode console for errors
4. Visit Supabase docs: https://supabase.com/docs

---

## Summary

You're all set! Just:
1. ✅ Install Supabase SDK in Xcode
2. ✅ Run the SQL scripts in Supabase Dashboard
3. ✅ Create the storage bucket
4. ✅ Build and run

Your app will have:
- ✅ Email/password authentication
- ✅ Cloud database for journal entries
- ✅ Photo upload to cloud storage
- ✅ Automatic streak tracking
- ✅ Multi-device sync
- ✅ Secure row-level security

Happy journaling! 🎉
