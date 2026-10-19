#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

if ! xcodebuild -version >/dev/null 2>&1; then
  echo 'Install full Xcode and select it with xcode-select before building.' >&2
  exit 1
fi

xcodebuild build -project Maccy.xcodeproj -scheme Maccy \
  -configuration Release -destination 'generic/platform=macOS' \
  -derivedDataPath build ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO \
  CODE_SIGNING_ALLOWED=NO ENABLE_HARDENED_RUNTIME=NO

app=build/Build/Products/Release/Maccy.app
version=$(/usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' "$app/Contents/Info.plist")
stage=$(mktemp -d)
mount_point=$(mktemp -d)
trap 'hdiutil detach "$mount_point" -quiet 2>/dev/null || true; rm -rf "$stage" "$mount_point"' EXIT

# Expand Xcode's bundle identifier in the sandbox's Sparkle service names.
sed 's/$(PRODUCT_BUNDLE_IDENTIFIER)/org.p0deje.Maccy/g' Maccy/Maccy.entitlements > "$stage/entitlements.plist"
sparkle="$app/Contents/Frameworks/Sparkle.framework"
codesign --force --sign - "$sparkle/Versions/B/XPCServices/Installer.xpc"
codesign --force --sign - --preserve-metadata=entitlements "$sparkle/Versions/B/XPCServices/Downloader.xpc"
codesign --force --sign - "$sparkle/Versions/B/Autoupdate"
codesign --force --sign - "$sparkle/Versions/B/Updater.app"
codesign --force --sign - "$sparkle"
codesign --force --sign - --entitlements "$stage/entitlements.plist" "$app"
codesign --verify --deep --strict "$app"
lipo "$app/Contents/MacOS/Maccy" -verify_arch arm64 x86_64
test ! -d "$app/Contents/PlugIns"
test ! -e "$app/Contents/MacOS/Maccy.debug.dylib"
test ! -d "$app/Contents/Frameworks/XCTest.framework"

mkdir -p dist "$stage/dmg"
ditto "$app" "$stage/dmg/Maccy.app"
ln -s /Applications "$stage/dmg/Applications"
cp INSTALL.ru.md "$stage/dmg/Установка.txt"
rm -f dist/Maccy.dmg dist/Maccy.app.zip
hdiutil create -volname "Maccy $version" -srcfolder "$stage/dmg" \
  -format UDZO -fs HFS+ dist/Maccy.dmg
hdiutil verify dist/Maccy.dmg
hdiutil attach dist/Maccy.dmg -readonly -nobrowse -mountpoint "$mount_point"
codesign --verify --deep --strict "$mount_point/Maccy.app"
diff -qr "$app" "$mount_point/Maccy.app"
test "$(readlink "$mount_point/Applications")" = /Applications
hdiutil detach "$mount_point" -quiet
ditto -c -k --sequesterRsrc --keepParent "$app" dist/Maccy.app.zip
(cd dist && shasum -a 256 Maccy.dmg Maccy.app.zip > SHA256SUMS)
echo "Release $version: dist/Maccy.dmg, dist/Maccy.app.zip, dist/SHA256SUMS"
