# 🚀 Remy - Quick Deployment Checklist

## ⚡ CRITICAL - Do These FIRST (30 mins)

### 1. Configure API Key in Xcode
- [ ] Open Xcode
- [ ] Go to Project Navigator > Remy (top level)
- [ ] Select Remy target
- [ ] Build Settings tab
- [ ] Click "+" > Add User-Defined Setting
- [ ] Name: `OPENAI_API_KEY`
- [ ] Value: `your-openai-api-key-here`

### 2. Test AI Chat Works
- [ ] Run app in simulator (Cmd+R)
- [ ] Navigate to Journal/AI screen
- [ ] Send a test message
- [ ] Verify you get AI response (not error)

### 3. Set Up Supabase (if using database)
Login to https://supabase.com/dashboard

- [ ] Go to your project: `pwyweperbipjdisrkoio`
- [ ] Navigate to Authentication > Policies
- [ ] Click "Enable RLS" if not enabled
- [ ] Create basic SELECT policy for journal_entries table
- [ ] Test creating a journal entry in app

---

## 📱 App Store Prep (2-3 hours)

### 4. Create App Icons
- [ ] Use https://appicon.co to generate all sizes
- [ ] Upload your 1024x1024 design
- [ ] Download and drag into Assets.xcassets/AppIcon

### 5. Take Screenshots (Use Simulator)
Required device sizes:
- [ ] iPhone 15 Pro Max (6.7")
- [ ] iPhone 11 Pro Max (6.5")
- [ ] iPad Pro 12.9"

Recommended screens to capture:
1. Home screen with journal entries
2. Quick journal entry
3. AI chat
4. Goals or Dreams journal
5. Dashboard

**How to take screenshots:**
```bash
# Run simulator
# Navigate to screen
# Press Cmd+S to save screenshot
# Screenshots save to ~/Desktop
```

### 6. Write Privacy Policy (30 mins)
Create simple text file:

```
REMY PRIVACY POLICY

We collect:
- Journal entries (stored in Supabase)
- User authentication info

We don't:
- Sell your data
- Track you
- Share data with third parties (except OpenAI for AI features)

Your Rights:
- Delete your data anytime
- Export your journal
- Contact: [YOUR_EMAIL]

Last updated: [DATE]
```

Host on:
- [ ] GitHub Gist (set to public)
- [ ] Notion page (set to public)
- [ ] Copy URL for App Store

---

## 🏗️ Build & Upload (1 hour)

### 7. Update Version Info
In Xcode:
- [ ] Select Remy target
- [ ] General tab
- [ ] Identity section:
  - Display Name: `Remy`
  - Bundle Identifier: `dds.Remy`
  - Version: `1.0.0`
  - Build: `1`

### 8. Configure Signing
- [ ] Xcode > Preferences > Accounts
- [ ] Sign in with Apple ID
- [ ] In Remy target > Signing & Capabilities:
  - Team: (Select your team)
  - Signing: Automatic
- [ ] Verify no signing errors

### 9. Archive Build
- [ ] In Xcode, select "Any iOS Device (arm64)"
- [ ] Product > Archive (wait ~5 mins)
- [ ] When complete, Organizer opens
- [ ] Select your archive
- [ ] Click "Distribute App"
- [ ] Choose "App Store Connect"
- [ ] Upload

---

## 🍎 App Store Connect (1 hour)

### 10. Create App Listing
Go to https://appstoreconnect.apple.com

- [ ] My Apps > + icon > New App
- [ ] Platform: iOS
- [ ] Name: Remy
- [ ] Primary Language: English (U.S.)
- [ ] Bundle ID: dds.Remy
- [ ] SKU: remy-001
- [ ] User Access: Full Access

### 11. Fill App Information

**App Information:**
- [ ] Privacy Policy URL: (your URL from step 6)
- [ ] Category: Health & Fitness
- [ ] Secondary Category: Lifestyle

**Pricing:**
- [ ] Price: Free (or set price)
- [ ] Availability: All countries

**App Privacy:**
- [ ] Data Collection: Yes (journal entries)
- [ ] Data Linked to User: Yes
- [ ] Tracking: No

### 12. Upload Assets
- [ ] Screenshots (all device sizes)
- [ ] App Description (copy from DEPLOYMENT_GUIDE.md)
- [ ] Keywords: `journal, diary, ai, mindfulness, gratitude, mood`
- [ ] Support URL: (same as privacy policy)
- [ ] Marketing URL: (optional)

### 13. Build Selection
- [ ] Version Information > Build
- [ ] Select the build you uploaded
- [ ] Save

### 14. Submit for Review
- [ ] Click "Add for Review"
- [ ] Answer App Store review questions
- [ ] Submit

---

## ✅ Final Verification

Before submitting, test these:

### Core Features:
- [ ] Create quick journal entry
- [ ] Create goals journal
- [ ] Create dreams journal
- [ ] Take photo journal (on real device)
- [ ] AI chat sends/receives messages
- [ ] View journal history
- [ ] Delete journal entry
- [ ] Streak counter updates

### Edge Cases:
- [ ] App works without internet (UI doesn't crash)
- [ ] AI shows error gracefully when offline
- [ ] Camera permission request works
- [ ] Photo library permission request works

---

## 📊 Timeline

| Task | Time |
|------|------|
| Configure API key | 10 min |
| Test features | 30 min |
| Create app icons | 30 min |
| Take screenshots | 45 min |
| Write privacy policy | 30 min |
| Build & archive | 20 min |
| Upload to App Store Connect | 15 min |
| Fill out app listing | 45 min |
| **TOTAL** | **~4 hours** |
| **Apple Review** | **1-7 days** |

---

## 🚨 Common Issues

### "No signing certificate"
```bash
# Solution:
# 1. Xcode > Preferences > Accounts
# 2. Download Manual Profiles
# 3. Try archiving again
```

### "API key not working"
```bash
# Solution:
# 1. Clean build folder (Cmd+Shift+K)
# 2. Verify OPENAI_API_KEY is in Build Settings
# 3. Build again
```

### "Archive fails"
```bash
# Solution:
rm -rf ~/Library/Developer/Xcode/DerivedData
# Then Product > Clean Build Folder
# Then Product > Archive
```

---

## 📞 Need Help?

- **Apple Developer Support**: https://developer.apple.com/support/
- **App Review Status**: https://developer.apple.com/contact/app-store/?topic=review
- **Supabase Support**: https://supabase.com/docs
- **OpenAI API Docs**: https://platform.openai.com/docs

---

## 🎉 After Approval

When your app is approved (usually 1-7 days):

1. **Release:**
   - Go to App Store Connect
   - Select your app
   - Click "Release this Version"
   - App goes live in ~24 hours

2. **Monitor:**
   - Check crash reports in App Store Connect
   - Monitor reviews
   - Track downloads

3. **Update:**
   - Fix any issues reported
   - Increment version number
   - Submit updates same process

---

**You're ready to ship! 🚀**

Remember: The first submission takes longest. Updates are much faster.
