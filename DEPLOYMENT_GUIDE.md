# Remy App - Deployment Guide

## 🚀 Pre-Deployment Checklist

### ⚠️ CRITICAL SECURITY ISSUES TO FIX

#### 1. **REMOVE HARDCODED API KEYS** (HIGHEST PRIORITY)
**Current Issue:** OpenAI API key is hardcoded in `AIService.swift`

**❌ Current (INSECURE):**
```swift
private var apiKey: String {
    return "sk-proj-SXpIFvsY_QCgWe2_..." // EXPOSED IN CODE!
}
```

**✅ Solution Options:**

**Option A: Use Xcode Configuration (Recommended for Solo Dev)**
1. Keep API keys in `Config.xcconfig` file
2. Add `Config.xcconfig` to `.gitignore`
3. Load keys at runtime from Info.plist
4. Never commit the config file

**Option B: Use Backend Proxy (Most Secure)**
1. Create a backend API endpoint (e.g., Firebase Functions, Vercel)
2. Store OpenAI key on server
3. App calls your backend, backend calls OpenAI
4. Prevents key exposure in app binary

**Option C: Environment Variables (Good for CI/CD)**
1. Use Xcode build configurations
2. Different keys for Debug/Release
3. Store in keychain at runtime

#### 2. **Supabase Security**
**Current Status:** ✅ Using anon key is OK for client-side apps

The Supabase anon key in `SupabaseConfig.swift` is designed for client use and is safe to include in the app. However:

**Required Supabase Settings:**
- [ ] Enable Row Level Security (RLS) on all tables
- [ ] Create policies for user data access
- [ ] Verify anonymous users can only access their own data
- [ ] Set up storage bucket policies for photos

---

## 📋 Deployment Checklist

### Phase 1: Security & Configuration ✅

#### Step 1.1: Secure OpenAI API Key
```bash
# 1. Add to .gitignore if not already there
echo "Remy/Remy/Config/Config.xcconfig" >> .gitignore

# 2. Update AIService.swift to read from Info.plist
```

**Update `AIService.swift`:**
```swift
private var apiKey: String {
    guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String else {
        fatalError("OpenAI API key not found in Info.plist")
    }
    return key
}
```

**Add to `Info.plist`:**
```xml
<key>OPENAI_API_KEY</key>
<string>$(OPENAI_API_KEY)</string>
```

#### Step 1.2: Configure Supabase RLS
```sql
-- Run these in Supabase SQL Editor

-- Enable RLS on journal_entries table
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own entries
CREATE POLICY "Users can view own entries"
ON journal_entries FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Users can insert their own entries
CREATE POLICY "Users can create own entries"
ON journal_entries FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own entries
CREATE POLICY "Users can update own entries"
ON journal_entries FOR UPDATE
USING (auth.uid() = user_id);

-- Policy: Users can delete their own entries
CREATE POLICY "Users can delete own entries"
ON journal_entries FOR DELETE
USING (auth.uid() = user_id);

-- Storage bucket policies
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
```

#### Step 1.3: Add Environment-Based Configuration
Create separate configs for Debug/Release builds.

### Phase 2: Code Quality & Testing 🧪

#### Step 2.1: Remove Debug Logging
```bash
# Search for all print statements
grep -r "print\(" Remy/Remy --include="*.swift"

# Remove or comment out debug prints in production
```

**Files to clean:**
- `AIService.swift` - Remove all `print("[AIService]...")`
- `JournalDetailView.swift` - Remove debug logs
- `JournalScreen.swift` - Keep only error logs

#### Step 2.2: Add Crash Reporting (Optional but Recommended)
Consider adding:
- Firebase Crashlytics
- Sentry
- Apple's built-in crash reporting

#### Step 2.3: Test All Features
- [ ] Create journal entries (all types)
- [ ] View journal history
- [ ] AI chat functionality
- [ ] Photo upload/display
- [ ] Mood and theme selection
- [ ] Streak tracking
- [ ] Delete entries
- [ ] Offline functionality

### Phase 3: App Store Preparation 📱

#### Step 3.1: Update Version & Build Number
In Xcode:
1. Select `Remy` target
2. General tab
3. Update:
   - **Version**: 1.0.0 (or your version)
   - **Build**: 1

#### Step 3.2: Configure Code Signing
1. Open Xcode > Preferences > Accounts
2. Add your Apple ID
3. In project settings:
   - Team: Select your team
   - Signing: Automatic
   - Bundle Identifier: `dds.Remy` (or unique identifier)

#### Step 3.3: Create App Icons
Required sizes (all in Assets.xcassets/AppIcon):
- 1024x1024 (App Store)
- 180x180 (iPhone)
- 167x167 (iPad Pro)
- 152x152 (iPad)
- 120x120 (iPhone)
- 87x87 (iPhone)
- 76x76 (iPad)
- 60x60 (iPhone)
- 58x58 (iPhone)
- 40x40 (All)
- 29x29 (All)
- 20x20 (All)

Use a tool like: https://appicon.co

#### Step 3.4: Prepare Screenshots
Required for App Store:
- 6.7" iPhone (iPhone 15 Pro Max)
- 6.5" iPhone (iPhone 11 Pro Max)
- 5.5" iPhone (iPhone 8 Plus)
- 12.9" iPad Pro

**Recommended Screenshots:**
1. Home screen with journal history
2. Quick journal entry screen
3. AI chat conversation
4. Goals/Dreams journal
5. Dashboard with insights

#### Step 3.5: Write App Store Listing
**App Name:** Remy - AI Journal

**Subtitle:** Mindful journaling with AI guidance

**Description:**
```
Remy is your personal AI journaling companion, designed to help you explore your thoughts, emotions, and inner world through mindful reflection.

FEATURES:
• Multiple Journal Types - Quick entries, goals, dreams, reflections, and more
• AI Guidance - Chat with Remy for gentle prompts and self-reflection
• Mood & Theme Tracking - Track your emotional patterns
• Photo Journals - Capture moments with images
• Streak Tracking - Build a consistent journaling habit
• Beautiful Design - Warm, aesthetic interface
• Private & Secure - Your data, your journal

JOURNAL TYPES:
- Quick Entries for daily thoughts
- Goals to track your aspirations
- Dreams to remember your sleep adventures
- Reflections for deep introspection
- Gratitude to count your blessings
- Photo Journals to capture visual memories

AI COMPANION:
Remy serves as a compassionate reflective companion that promotes self-awareness and personal growth. Not a therapist - just a mindful friend for your journaling journey.

Your privacy matters. All journal entries are securely stored and only you have access to them.
```

**Keywords:**
journal, diary, reflection, mindfulness, ai, gratitude, mood, therapy, wellness, mental health

**Category:** Health & Fitness (Primary), Lifestyle (Secondary)

**Age Rating:** 4+

### Phase 4: Build & Archive 🏗️

#### Step 4.1: Clean Build
```bash
# In terminal, navigate to project directory
cd /Users/keshavkrishnan/Remy

# Clean build folder
xcodebuild clean -project Remy.xcodeproj -scheme Remy -configuration Release

# Or in Xcode: Product > Clean Build Folder (Shift+Cmd+K)
```

#### Step 4.2: Archive for Distribution
In Xcode:
1. Select "Any iOS Device (arm64)" as destination
2. Product > Archive (Cmd+Shift+B)
3. Wait for archive to complete
4. Organizer window will open

#### Step 4.3: Upload to App Store Connect
1. In Organizer, select your archive
2. Click "Distribute App"
3. Choose "App Store Connect"
4. Click "Upload"
5. Select options:
   - ✅ Include bitcode: NO (deprecated)
   - ✅ Upload symbols: YES
   - ✅ Manage Version: Automatically
6. Sign with your distribution certificate
7. Click "Upload"

### Phase 5: App Store Connect Setup 🍎

#### Step 5.1: Create App in App Store Connect
1. Go to https://appstoreconnect.apple.com
2. My Apps > + > New App
3. Fill in:
   - Platform: iOS
   - Name: Remy
   - Primary Language: English
   - Bundle ID: dds.Remy
   - SKU: remy-journal-001

#### Step 5.2: Fill App Information
**Privacy Policy URL:**
You MUST create one. Simple template:
```
Remy Privacy Policy

Data Collection:
- Journal entries stored locally and in cloud (Supabase)
- No tracking or analytics
- No data sold to third parties
- AI chat uses OpenAI (see their privacy policy)

User Rights:
- Export your data anytime
- Delete your account and all data
- Data encrypted in transit and at rest

Contact: [your-email@example.com]
```

Host this on:
- GitHub Pages (free)
- Notion (public page)
- Simple static site

**Support URL:** Same as privacy policy page

#### Step 5.3: Upload Screenshots & Metadata
1. Add screenshots for all device sizes
2. Add promotional text (optional)
3. Add description
4. Add keywords
5. Select category
6. Add age rating

#### Step 5.4: Pricing & Availability
- Price: Free (or set your price)
- Availability: All countries

#### Step 5.5: Submit for Review
1. Click "Add for Review"
2. Fill in review notes if needed
3. Submit

**Review Notes (Optional):**
```
Test Account: Not required (no auth in v1)

Notes:
- AI chat requires internet connection
- Journal data syncs to Supabase backend
```

---

## 🔧 Common Issues & Solutions

### Issue 1: Build Fails
**Error:** "No signing certificate"
**Solution:**
```bash
# Ensure you're signed in to Xcode with Apple ID
# Go to Xcode > Preferences > Accounts
# Select your Apple ID > Manage Certificates > + > iOS Distribution
```

### Issue 2: Archive Fails
**Error:** "Framework not found Supabase"
**Solution:**
```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData
# Reset package caches
# File > Packages > Reset Package Caches
```

### Issue 3: App Rejected
**Common Reasons:**
- Missing privacy policy
- Crash on launch
- Missing permissions explanations
- Guideline violations

**Fix:** Update Info.plist with all permission descriptions

---

## ✅ Final Pre-Submission Checklist

- [ ] All API keys secured (not hardcoded)
- [ ] Debug logging removed
- [ ] Supabase RLS policies set
- [ ] All features tested
- [ ] App icons added (all sizes)
- [ ] Screenshots taken (all sizes)
- [ ] Privacy policy created
- [ ] App description written
- [ ] Code signing configured
- [ ] Build archived successfully
- [ ] Binary uploaded to App Store Connect
- [ ] All metadata filled in App Store Connect
- [ ] Submitted for review

---

## 🚨 IMMEDIATE ACTION ITEMS (Before Any Deployment)

### 1. Secure OpenAI API Key (DO THIS FIRST!)
The OpenAI key is currently exposed in the code. This is a CRITICAL security issue.

**Immediate Fix:**
```swift
// Update AIService.swift line 19-22 to:
private var apiKey: String {
    guard let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
          !key.isEmpty else {
        fatalError("OpenAI API key not configured")
    }
    return key
}
```

Then add to `Info.plist`:
```xml
<key>OPENAI_API_KEY</key>
<string>$(OPENAI_API_KEY)</string>
```

### 2. Set Up .gitignore
```bash
# Create .gitignore if it doesn't exist
cat > .gitignore << EOF
# Xcode
*.xcconfig
Config.xcconfig
DerivedData/
*.xcuserstate

# API Keys
*.plist.keys

# macOS
.DS_Store
EOF
```

### 3. Remove Sensitive Data from Git History
```bash
# If you've already committed API keys:
# WARNING: This rewrites history
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch Remy/Remy/Config/Config.xcconfig" \
  --prune-empty --tag-name-filter cat -- --all
```

---

## 📊 Estimated Timeline

| Phase | Time Estimate |
|-------|---------------|
| Security fixes | 1-2 hours |
| Testing | 2-3 hours |
| App Store assets | 2-4 hours |
| First build & upload | 1 hour |
| App Store Connect setup | 1 hour |
| **Review wait time** | **1-7 days** |
| **Total (your work)** | **7-11 hours** |

---

## 📞 Support Resources

- **Apple Developer Support:** https://developer.apple.com/support/
- **App Store Review Guidelines:** https://developer.apple.com/app-store/review/guidelines/
- **TestFlight:** https://developer.apple.com/testflight/ (for beta testing)
- **Supabase Docs:** https://supabase.com/docs
- **OpenAI API Docs:** https://platform.openai.com/docs

---

**Good luck with your launch! 🚀**
