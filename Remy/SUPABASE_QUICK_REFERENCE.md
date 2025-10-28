# Supabase Quick Reference Card

## 🚀 Quick Setup (5 Minutes)

### 1. Create Project
```
supabase.com → New Project → Copy URL & anon key
```

### 2. Run Database SQL
```sql
-- In Supabase SQL Editor, paste and run:
-- (See SUPABASE_FINAL_GUIDE.md for full SQL)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
-- Create 4 tables: profiles, journal_entries, streak_data, chat_messages
-- Enable RLS + policies
```

### 3. Create Storage
```
Storage → New bucket → "journal-photos" (PRIVATE)
-- Then run storage policies SQL
```

### 4. Enable Auth
```
Authentication → Providers → Email → Enable
-- Disable email confirmations for testing
```

### 5. Update App
```swift
// SupabaseConfig.swift
static let projectURL = "https://YOUR-REF.supabase.co"
static let anonKey = "YOUR-ANON-KEY"
```

### 6. Test
```
Run app → Sign up → Create entry → Check Supabase Dashboard
```

---

## 📊 Database Tables

### profiles
```
id (UUID) - User ID
email (TEXT)
full_name (TEXT)
avatar_url (TEXT)
```

### journal_entries
```
id (UUID)
user_id (UUID)
content (TEXT)
journal_type (TEXT)
mood_tag (TEXT)
photo_url (TEXT)
timestamp (TIMESTAMP)
```

### streak_data
```
user_id (UUID)
current_streak (INT)
longest_streak (INT)
last_entry_date (DATE)
```

### chat_messages
```
user_id (UUID)
content (TEXT)
is_user (BOOLEAN)
timestamp (TIMESTAMP)
```

---

## 🔑 Where to Find Credentials

```
Supabase Dashboard
  → Settings (⚙️)
    → API
      → Project URL: https://xxx.supabase.co
      → anon/public key: eyJhbGci...
```

---

## ✅ Testing Checklist

```
[ ] Sign up works
[ ] Sign in works
[ ] Create journal entry
[ ] Entry appears in Supabase Table Editor
[ ] Upload photo (if implemented)
[ ] Sign out works
[ ] Data persists after sign in
```

---

## 🐛 Common Errors

| Error | Solution |
|-------|----------|
| "No such module 'Supabase'" | Clean build + Reset packages |
| "Invalid credentials" | Check SupabaseConfig.swift |
| "Row Level Security" | Run RLS policies SQL |
| Can't upload photos | Create bucket + storage policies |

---

## 📝 Useful SQL Commands

```sql
-- View all users
SELECT * FROM auth.users;

-- View all journal entries
SELECT * FROM journal_entries;

-- Count entries per user
SELECT user_id, COUNT(*)
FROM journal_entries
GROUP BY user_id;

-- Delete test data
DELETE FROM journal_entries
WHERE user_id = 'your-test-user-id';

-- Check table structure
\d journal_entries
```

---

## 🔐 Security

✅ **Safe for client:**
- anon/public key
- Project URL

❌ **Never use in app:**
- service_role key
- Database password

---

## 📞 Quick Links

- **Dashboard:** https://app.supabase.com
- **Docs:** https://supabase.com/docs
- **SQL Editor:** Dashboard → SQL Editor
- **Table Editor:** Dashboard → Table Editor
- **Storage:** Dashboard → Storage
- **Auth:** Dashboard → Authentication

---

**Full guide:** See `SUPABASE_FINAL_GUIDE.md`
