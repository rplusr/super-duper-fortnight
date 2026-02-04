#!/bin/bash

set -e

echo "🍎 Building iOS App..."

cd "$(dirname "$0")/../apps/mobile"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ iOS builds can only be done on macOS"
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Install CocoaPods dependencies
echo "📦 Installing CocoaPods dependencies..."
cd ios && pod install && cd ..

# Build
if [ "$1" == "--release" ]; then
    echo "🔨 Building release IPA..."
    flutter build ios --release

    echo ""
    echo "✅ Release build complete!"
    echo "📱 Open Xcode to archive and distribute:"
    echo "   open ios/Runner.xcworkspace"
    echo ""
    echo "📋 In Xcode:"
    echo "   1. Select 'Any iOS Device' as target"
    echo "   2. Product > Archive"
    echo "   3. Distribute App"
else
    echo "🔨 Building debug (no codesign)..."
    flutter build ios --debug --no-codesign

    echo ""
    echo "✅ Debug build complete!"
    echo "📱 To run on simulator:"
    echo "   flutter run"
fi

echo ""
echo "💡 For release builds, use: ./build-ios.sh --release"
