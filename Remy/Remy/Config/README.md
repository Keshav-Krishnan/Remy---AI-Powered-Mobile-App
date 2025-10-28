# Configuration Setup

This directory contains configuration files for API keys and environment variables.

## 🚀 Quick Setup

### 1. Create Your Config File

```bash
cd Remy/Remy/Config
cp Config.xcconfig.template Config.xcconfig
```

### 2. Add Your API Keys

Open `Config.xcconfig` and replace the placeholder values:

```xcconfig
OPENAI_API_KEY = sk-proj-YOUR-ACTUAL-KEY-HERE
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = your-actual-anon-key-here
```

### 3. Get Your API Keys

**OpenAI:**
1. Visit https://platform.openai.com/api-keys
2. Create a new API key
3. Copy the key (starts with `sk-proj-` or `sk-`)

**Supabase:**
1. Visit https://app.supabase.com/project/_/settings/api
2. Copy your Project URL
3. Copy your `anon` public key

### 4. Build the Project

```bash
# In Xcode: Product > Build (Cmd+B)
# Or via command line:
xcodebuild -project Remy.xcodeproj -scheme Remy build
```

## 🔒 Security Notes

- ✅ `Config.xcconfig` is in `.gitignore` and will NOT be committed
- ✅ `Config.xcconfig.template` IS committed (no secrets)
- ⚠️ Never share your `Config.xcconfig` file
- ⚠️ Never commit API keys to version control

## ❓ Troubleshooting

### "OpenAI API key not configured" error

**Cause:** Config.xcconfig file is missing or has wrong format

**Fix:**
1. Ensure `Config.xcconfig` exists in this directory
2. Check that keys don't have quotes or extra spaces
3. Clean build folder (Cmd+Shift+K) and rebuild

### Example Config.xcconfig

```xcconfig
OPENAI_API_KEY = sk-proj-abc123xyz...
SUPABASE_URL = https://pwyweperbipjdisrkoio.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 📝 How It Works

1. **Config.xcconfig** → Defines build variables
2. **Info.plist** → References `$(OPENAI_API_KEY)` variable
3. **AIService.swift** → Loads key at runtime from Info.plist

This keeps secrets out of source code while remaining easy to configure.

## 🌍 Environment Separation (Future)

For multiple environments (dev/staging/prod), create:
- `Config.Debug.xcconfig`
- `Config.Release.xcconfig`

And configure in Xcode build settings.
