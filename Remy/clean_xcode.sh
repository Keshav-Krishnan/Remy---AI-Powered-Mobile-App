#!/bin/bash

# Clean Xcode Build Script for Remy

echo "🧹 Cleaning Xcode build artifacts..."

# Clean Xcode derived data
echo "Removing DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/Remy-*

# Clean build folder
echo "Cleaning build folder..."
cd "$(dirname "$0")"
xcodebuild clean -project Remy.xcodeproj -scheme Remy 2>/dev/null || echo "Note: xcodebuild clean skipped (version mismatch)"

# Clean Swift Package Manager cache
echo "Resetting Swift Package Manager cache..."
rm -rf .build
rm -rf ~/Library/Caches/org.swift.swiftpm

echo "✅ Clean complete!"
echo ""
echo "Next steps:"
echo "1. Open Remy.xcodeproj in Xcode"
echo "2. Go to Product → Clean Build Folder (⌘+Shift+K)"
echo "3. Go to File → Packages → Reset Package Caches"
echo "4. Go to File → Packages → Resolve Package Versions"
echo "5. Build the project (⌘+B)"
