# Remy - AI-Powered Journal App

<div align="center">

**A mindful journaling companion with AI guidance**

[![Platform](https://img.shields.io/badge/platform-iOS%2018.5%2B-blue)](https://www.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-Private-red)]()

</div>

---

## 📱 About

Remy is an AI-powered journaling app designed to help users explore their thoughts, emotions, and inner world through mindful reflection. It combines beautiful design with intelligent features to create a delightful journaling experience.

### Key Features

- **🤖 AI Companion** - Chat with Remy for gentle prompts and reflective guidance
- **📔 Multiple Journal Types** - Quick entries, goals, dreams, reflections, gratitude, and photo journals
- **🎨 Beautiful Design** - Warm, aesthetic UI inspired by Material Design
- **😊 Mood & Theme Tracking** - Track emotional patterns and journal themes
- **📸 Photo Journals** - Capture visual memories with captions
- **🔥 Streak Tracking** - Build consistent journaling habits
- **📊 Insights Dashboard** - Visualize your journaling journey
- **🔒 Private & Secure** - Your data, your journal

---

## 🛠️ Tech Stack

- **Frontend**: SwiftUI
- **Backend**: Supabase (PostgreSQL + Auth + Storage)
- **AI**: OpenAI GPT-4o-mini
- **Platforms**: iOS 18.5+, macOS 15.5+, visionOS 2.5+

---

## 🚀 Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 18.5+ SDK
- Apple Developer Account
- Supabase Account
- OpenAI API Key

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd Remy
```

2. **Install dependencies**
```bash
# Dependencies are managed via Swift Package Manager
# Xcode will automatically resolve packages on first build
```

3. **Configure API Keys**

Create or edit `Remy/Remy/Config/Config.xcconfig`:
```
OPENAI_API_KEY = your_openai_api_key_here
SUPABASE_URL = https://your-project.supabase.co
SUPABASE_ANON_KEY = your_supabase_anon_key_here
```

4. **Add to Xcode Build Settings**
- Open project in Xcode
- Select Remy target
- Build Settings tab
- Add User-Defined Setting:
  - Key: `OPENAI_API_KEY`
  - Value: (your OpenAI key)

5. **Build & Run**
```bash
# Command line
xcodebuild -project Remy.xcodeproj -scheme Remy -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Or in Xcode: Cmd+R
```

---

## 📦 Project Structure

```
Remy/
├── Models/              # Data models (JournalEntry, MoodTag, etc.)
├── Views/
│   ├── Screens/        # Full-screen views
│   └── Components/     # Reusable UI components
├── ViewModels/         # Business logic
├── Services/           # API services (Supabase, OpenAI)
├── Config/             # Configuration files
├── Utils/              # Helper functions
└── Extensions/         # Swift extensions
```

---

## 🔧 Configuration

### Supabase Setup

1. Create project at [supabase.com](https://supabase.com)
2. Create tables:
```sql
-- Journal entries
CREATE TABLE journal_entries (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id),
  content TEXT NOT NULL,
  journal_type TEXT NOT NULL,
  mood_tag TEXT,
  theme_tag TEXT,
  image_uri TEXT,
  timestamp TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own entries
CREATE POLICY "Users can view own entries"
  ON journal_entries FOR SELECT
  USING (auth.uid() = user_id);
```

3. Update `SupabaseConfig.swift` with your credentials

### OpenAI Setup

1. Get API key from [platform.openai.com](https://platform.openai.com)
2. Add to `Config.xcconfig`
3. Model used: `gpt-4o-mini` (cost-effective, fast)

---

## 📝 Development

### Running Tests
```bash
xcodebuild test -project Remy.xcodeproj -scheme Remy -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Code Style
- SwiftUI for all views
- MVVM architecture
- Swift concurrency (async/await)
- Following Apple's Swift API Design Guidelines

### Git Workflow
```bash
# Never commit API keys!
git add .
git commit -m "feat: add new feature"
git push origin main
```

---

## 🚢 Deployment

See detailed guides:
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete step-by-step guide
- **[QUICK_DEPLOY_CHECKLIST.md](QUICK_DEPLOY_CHECKLIST.md)** - Quick reference checklist

### Quick Steps:
1. Configure API keys (see above)
2. Create app icons (1024x1024 + all sizes)
3. Take screenshots (all device sizes)
4. Write privacy policy
5. Archive in Xcode (Product > Archive)
6. Upload to App Store Connect
7. Submit for review

---

## 🔒 Security

- ✅ API keys loaded from environment (not hardcoded)
- ✅ Supabase Row Level Security enabled
- ✅ HTTPS for all network requests
- ✅ User data encrypted at rest and in transit
- ✅ No tracking or analytics

### Security Checklist:
- [ ] `Config.xcconfig` in `.gitignore`
- [ ] No hardcoded secrets in code
- [ ] Supabase RLS policies configured
- [ ] App Transport Security enabled

---

## 📄 License

Private - All rights reserved.

---

## 👥 Team

Built by [Your Name]

---

## 📞 Support

- Email: [your-email@example.com]
- Issues: [GitHub Issues](https://github.com/your-repo/issues)
- Docs: See `DEPLOYMENT_GUIDE.md`

---

## 🙏 Acknowledgments

- **OpenAI** for GPT-4o-mini API
- **Supabase** for backend infrastructure
- **Apple** for SwiftUI and iOS platform

---

**Made with ❤️ and mindfulness**
