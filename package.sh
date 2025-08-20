#!/bin/bash

# Create DMG installer
set -e

source config.txt

APP_PATH="output/${APP_NAME}.app"
DMG_NAME="${APP_NAME}-${APP_VERSION}.dmg"
DMG_PATH="output/${DMG_NAME}"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Build the app first with ./brand.sh"
    exit 1
fi

echo "📦 Creating DMG installer..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cp -R "$APP_PATH" "$TEMP_DIR/"
ln -s /Applications "$TEMP_DIR/Applications"

# Create DMG
hdiutil create -volname "${APP_NAME}" -srcfolder "$TEMP_DIR" -ov -format UDZO "$DMG_PATH"

# Clean up
rm -rf "$TEMP_DIR"

echo "✅ DMG created: ${DMG_PATH}"