#!/bin/bash

set -e

echo "🤖 Building Android APK..."

cd "$(dirname "$0")/../apps/mobile"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter not found. Please install Flutter first."
    exit 1
fi

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build debug APK
if [ "$1" == "--release" ]; then
    echo "🔨 Building release APK..."
    flutter build apk --release
    APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

    echo "🔨 Building release AAB (for Play Store)..."
    flutter build appbundle --release
    AAB_PATH="build/app/outputs/bundle/release/app-release.aab"

    echo ""
    echo "✅ Release build complete!"
    echo "📱 APK: $APK_PATH"
    echo "📦 AAB: $AAB_PATH"
else
    echo "🔨 Building debug APK..."
    flutter build apk --debug
    APK_PATH="build/app/outputs/flutter-apk/app-debug.apk"

    echo ""
    echo "✅ Debug build complete!"
    echo "📱 APK: $APK_PATH"
fi

echo ""
echo "📋 To install on device:"
echo "   adb install $APK_PATH"
echo ""
echo "💡 For release builds, use: ./build-android.sh --release"
