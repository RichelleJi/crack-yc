#!/bin/bash

# Setup script - downloads VS Code and installs Cline
set -e

echo "🚀 Custom IDE Builder Setup"
echo "=========================="

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script only works on macOS"
    exit 1
fi

# Create directories
mkdir -p base output assets/icons assets/config

# Download VS Code if not present
if [ ! -d "base/Visual Studio Code.app" ]; then
    echo "📥 Downloading VS Code..."
    curl -L "https://code.visualstudio.com/sha/download?build=stable&os=darwin-universal" -o base/vscode.zip
    cd base
    unzip -q vscode.zip
    rm vscode.zip
    cd ..
    echo "✅ VS Code downloaded"
else
    echo "✅ VS Code already present"
fi

# Install Cline extension
echo "🤖 Installing Cline extension..."
"./base/Visual Studio Code.app/Contents/Resources/app/bin/code" \
    --install-extension saoudrizwan.claude-dev \
    --extensions-dir "./base/Visual Studio Code.app/Contents/Resources/app/extensions"

echo "✅ Setup complete!"