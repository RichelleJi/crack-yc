#!/bin/bash

# Brand VS Code with custom names and settings
set -e

echo "🎨 Applying Custom Branding"
echo "=========================="

# Source configuration
source config.txt

# Validate config
if [ -z "$APP_NAME" ] || [ -z "$AI_NAME" ]; then
    echo "❌ Please edit config.txt first"
    exit 1
fi

# Check if base exists
if [ ! -d "base/Visual Studio Code.app" ]; then
    echo "❌ Run ./setup.sh first"
    exit 1
fi

# Clean and create output
rm -rf "output/${APP_NAME}.app"
echo "📁 Copying base application..."
cp -R "base/Visual Studio Code.app" "output/${APP_NAME}.app"

APP_PATH="output/${APP_NAME}.app"

# Update Info.plist
echo "📝 Updating Info.plist..."
PLIST_PATH="${APP_PATH}/Contents/Info.plist"

# Use PlistBuddy to update values
/usr/libexec/PlistBuddy -c "Set :CFBundleName '${APP_NAME}'" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName '${APP_DISPLAY_NAME}'" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier '${BUNDLE_ID}'" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString '${APP_VERSION}'" "$PLIST_PATH"
/usr/libexec/PlistBuddy -c "Set :NSHumanReadableCopyright '${COPYRIGHT}'" "$PLIST_PATH"

# Rename executable
echo "🔧 Renaming executable..."
mv "${APP_PATH}/Contents/MacOS/Electron" "${APP_PATH}/Contents/MacOS/${APP_NAME}"
/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable '${APP_NAME}'" "$PLIST_PATH"

# Update product.json
echo "⚙️ Updating product configuration..."
PRODUCT_JSON="${APP_PATH}/Contents/Resources/app/product.json"

# Create temporary Python script for JSON manipulation
cat > /tmp/update_product.py << EOF
import json
import sys

with open('${PRODUCT_JSON}', 'r') as f:
    data = json.load(f)

data['nameShort'] = '${APP_NAME}'
data['nameLong'] = '${APP_DISPLAY_NAME}'
data['applicationName'] = '${APP_NAME}'.lower()
data['dataFolderName'] = '.${APP_NAME}'.lower()
data['serverDataFolderName'] = '.${APP_NAME}'.lower() + '-server'
data['licenseName'] = 'MIT'
data['licenseUrl'] = '${COMPANY_WEBSITE}'
data['reportIssueUrl'] = 'mailto:${SUPPORT_EMAIL}'

with open('${PRODUCT_JSON}', 'w') as f:
    json.dump(data, f, indent=2)
EOF

python3 /tmp/update_product.py
rm /tmp/update_product.py

# Create settings for Featherless.ai
echo "🤖 Configuring Featherless.ai..."
SETTINGS_DIR="${APP_PATH}/Contents/Resources/app/user-data/User"
mkdir -p "$SETTINGS_DIR"

cat > "${SETTINGS_DIR}/settings.json" << EOF
{
  "window.title": "${APP_DISPLAY_NAME} - \${activeEditorShort}",
  "claude-dev.apiProvider": "openrouter",
  "claude-dev.openRouterBaseUrl": "${FEATHERLESS_ENDPOINT}",
  "claude-dev.openRouterModelId": "${DEFAULT_MODEL}",
  "claude-dev.customInstructions": "You are ${AI_DISPLAY_NAME}, powered by Featherless.ai",
  "workbench.colorTheme": "Default Dark Modern",
  "telemetry.telemetryLevel": "off"
}
EOF

# Replace VS Code and Cline references
echo "🔄 Replacing application references..."

# Find and replace in JavaScript files (careful with binary files)
find "${APP_PATH}/Contents/Resources/app" -type f -name "*.js" -o -name "*.json" -o -name "*.html" | while read file; do
    # Skip binary and large files
    if file "$file" | grep -q "text"; then
        # Use sed to replace strings
        sed -i '' "s/Visual Studio Code/${APP_DISPLAY_NAME}/g" "$file" 2>/dev/null || true
        sed -i '' "s/VS Code/${APP_NAME}/g" "$file" 2>/dev/null || true
        sed -i '' "s/Code - OSS/${APP_NAME}/g" "$file" 2>/dev/null || true
        
        # Replace Cline references in extension files
        if [[ "$file" == *"extensions"* ]]; then
            sed -i '' "s/Cline/${AI_DISPLAY_NAME}/g" "$file" 2>/dev/null || true
            sed -i '' "s/claude-dev/${AI_COMMAND}/g" "$file" 2>/dev/null || true
        fi
    fi
done

# Update icon if provided
if [ -f "$ICON_PATH" ]; then
    echo "🎨 Processing custom icon..."
    
    # Create iconset
    ICONSET_PATH="/tmp/${APP_NAME}.iconset"
    mkdir -p "$ICONSET_PATH"
    
    # Use sips to resize icon for different sizes
    for size in 16 32 128 256 512; do
        sips -z $size $size "$ICON_PATH" --out "${ICONSET_PATH}/icon_${size}x${size}.png" >/dev/null 2>&1
    done
    
    # Also create @2x versions
    sips -z 32 32 "$ICON_PATH" --out "${ICONSET_PATH}/icon_16x16@2x.png" >/dev/null 2>&1
    sips -z 64 64 "$ICON_PATH" --out "${ICONSET_PATH}/icon_32x32@2x.png" >/dev/null 2>&1
    sips -z 256 256 "$ICON_PATH" --out "${ICONSET_PATH}/icon_128x128@2x.png" >/dev/null 2>&1
    sips -z 512 512 "$ICON_PATH" --out "${ICONSET_PATH}/icon_256x256@2x.png" >/dev/null 2>&1
    sips -z 1024 1024 "$ICON_PATH" --out "${ICONSET_PATH}/icon_512x512@2x.png" >/dev/null 2>&1
    
    # Convert to icns
    iconutil -c icns "$ICONSET_PATH" -o "${APP_PATH}/Contents/Resources/Code.icns"
    rm -rf "$ICONSET_PATH"
    
    echo "✅ Custom icon applied"
fi

# Create first-run setup script
echo "📄 Creating first-run configuration..."
cat > "${APP_PATH}/Contents/Resources/app/first-run.sh" << EOF
#!/bin/bash
CONFIG_FILE="\$HOME/.${APP_NAME,,}/configured"
if [ ! -f "\$CONFIG_FILE" ]; then
    osascript -e 'display dialog "Welcome to ${APP_DISPLAY_NAME}!\n\nTo use ${AI_DISPLAY_NAME}, you need a Featherless.ai API key.\n\nGet one at: https://featherless.ai" buttons {"Get API Key", "Later"} default button 1'
    if [ \$? -eq 0 ]; then
        open "https://featherless.ai/signup"
    fi
    mkdir -p "\$HOME/.${APP_NAME,,}"
    touch "\$CONFIG_FILE"
fi
EOF
chmod +x "${APP_PATH}/Contents/Resources/app/first-run.sh"

# Sign the app if certificate is available
if [ -n "$CODESIGN_IDENTITY" ]; then
    echo "✍️ Signing application..."
    codesign --deep --force --sign "$CODESIGN_IDENTITY" "${APP_PATH}"
fi

echo ""
echo "✅ Successfully built ${APP_DISPLAY_NAME}!"
echo "📍 Location: ${APP_PATH}"
echo ""
echo "To create a DMG installer, run: ./package.sh"