# Info.plist Duplicate Output Fix

## Problem
```
duplicate output file '/Users/.../Remy.app/Info.plist' on task: ProcessInfoPlistFile
```

This error occurred because Xcode was configured to **both**:
1. Auto-generate an Info.plist file (`GENERATE_INFOPLIST_FILE = YES`)
2. Process the manual Info.plist file in the project

This caused a build conflict where two processes tried to output to the same location.

## Root Cause
The project was created with Xcode 16's new default setting to auto-generate Info.plist files. However, the project also includes a manual `Remy/Info.plist` file with important permissions:
- NSMicrophoneUsageDescription
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
- NSPhotoLibraryAddUsageDescription
- NSSpeechRecognitionUsageDescription

## Solution Applied

Modified the Xcode project build settings in `Remy.xcodeproj/project.pbxproj`:

### Changed (for all configurations):
```
GENERATE_INFOPLIST_FILE = YES;  // OLD - auto-generation enabled
```

### To:
```
GENERATE_INFOPLIST_FILE = NO;   // NEW - disable auto-generation
INFOPLIST_FILE = Remy/Info.plist; // Use manual file
```

This tells Xcode to:
- **Not** generate an Info.plist automatically
- **Use** the existing manual `Remy/Info.plist` file

## Targets Modified
The fix was applied to all targets and configurations:
- ✅ Remy (Debug)
- ✅ Remy (Release)
- ✅ RemyTests (Debug)
- ✅ RemyTests (Release)
- ✅ RemyUITests (Debug)
- ✅ RemyUITests (Release)

## Verification Steps

1. **Close Xcode** (if open)

2. **Clean DerivedData**:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/Remy-*
   ```

3. **Reopen Xcode**:
   ```bash
   cd /Users/keshavkrishnan/Remy/Remy
   open Remy.xcodeproj
   ```

4. **Clean Build Folder**:
   - In Xcode: **Product → Clean Build Folder** (⇧⌘K)

5. **Build**:
   - Press **⌘B**
   - Should now build without the duplicate Info.plist error

6. **Run**:
   - Select iPhone 16 simulator
   - Press **⌘R**
   - App should launch successfully

## What to Expect

### Before Fix:
```
❌ Error: duplicate output file '/Users/.../Remy.app/Info.plist'
```

### After Fix:
```
✅ Build Succeeded
```

## Why This Approach?

### Option 1: Auto-Generate (Modern) ❌
- Xcode auto-generates Info.plist
- Permissions must be set in Build Settings as `INFOPLIST_KEY_*`
- Requires migrating all Info.plist content to Build Settings
- More modern but requires more changes

### Option 2: Manual Info.plist (Chosen) ✅
- Keep existing `Remy/Info.plist` file
- All permissions already properly configured
- Easier to manage and read
- No additional changes needed

## Manual Info.plist Contents

The `Remy/Info.plist` file contains essential permissions for:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Remy needs access to your microphone to record voice journal entries.</string>

<key>NSCameraUsageDescription</key>
<string>Remy needs access to your camera to capture photos for photo journals.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Remy needs access to your photo library to select photos for photo journals.</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Remy needs permission to save photos to your library.</string>

<key>NSSpeechRecognitionUsageDescription</key>
<string>Remy needs access to speech recognition to transcribe your voice recordings.</string>
```

These are required for Phase 3+ features:
- Voice recording (Personal Journal)
- Photo capture (Photo Journal)
- Speech-to-text transcription

## Alternative: Migrate to Auto-Generated (Future)

If you prefer the modern approach in the future:

1. Delete `Remy/Info.plist`
2. Set `GENERATE_INFOPLIST_FILE = YES`
3. Add permissions to Build Settings:
   ```
   INFOPLIST_KEY_NSMicrophoneUsageDescription = "Remy needs..."
   INFOPLIST_KEY_NSCameraUsageDescription = "Remy needs..."
   INFOPLIST_KEY_NSPhotoLibraryUsageDescription = "Remy needs..."
   INFOPLIST_KEY_NSPhotoLibraryAddUsageDescription = "Remy needs..."
   INFOPLIST_KEY_NSSpeechRecognitionUsageDescription = "Remy needs..."
   ```

## Troubleshooting

### If Error Persists:
1. Make sure Xcode is fully closed
2. Delete DerivedData again
3. Check that `Remy/Info.plist` exists in the project
4. Verify Build Settings in Xcode:
   - Select Remy target → Build Settings
   - Search "Info.plist"
   - Should show:
     - **Generate Info.plist File**: No
     - **Info.plist File**: Remy/Info.plist

### If Info.plist Not Found:
In Xcode:
1. Right-click on `Remy` folder in Project Navigator
2. Add Files to "Remy"...
3. Select `Info.plist`
4. Make sure "Remy" target is checked

## Status

✅ **Fixed**: Project no longer tries to generate Info.plist
✅ **Configured**: Manual Info.plist is properly referenced
✅ **Ready**: Build should succeed without errors

---

**Date Fixed**: October 17, 2025
**Issue**: Duplicate Info.plist output
**Resolution**: Disabled auto-generation, use manual Info.plist
