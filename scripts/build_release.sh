#!/usr/bin/env bash
# Builds a release APK and saves it to releases/KapdaKhata-v{version}.apk
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="$(grep '^version:' pubspec.yaml | sed -E 's/version: ([0-9.]+)\+.*/\1/')"
if [[ -z "$VERSION" ]]; then
  echo "Could not read version from pubspec.yaml" >&2
  exit 1
fi

echo "Building KapdaKhata v${VERSION}..."
flutter build apk --release

BUILD_APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
RELEASE_APK="$ROOT/releases/KapdaKhata-v${VERSION}.apk"

if [[ ! -f "$BUILD_APK" ]]; then
  echo "Build failed: APK not found at $BUILD_APK" >&2
  exit 1
fi

mkdir -p "$ROOT/releases"
cp "$BUILD_APK" "$RELEASE_APK"
rm -f "$BUILD_APK"

echo ""
echo "Release APK saved to:"
echo "  $RELEASE_APK"
echo ""
echo "Temporary build output removed from build/app/outputs/flutter-apk/"
