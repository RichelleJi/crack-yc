# Custom IDE Builder for macOS

Build your own branded IDE with AI assistant powered by Featherless.ai.
No Node.js or complex dependencies - just shell scripts!

## Quick Start

1. **Run setup:**
   ```bash
   chmod +x *.sh
   ./setup.sh
   ```

2. **Edit `config.txt`** with your custom names and settings

3. **Add your icon** (optional):
   Place a 1024x1024 PNG at `assets/icons/icon.png`

4. **Build your IDE:**
   ```bash
   ./brand.sh
   ```

5. **Create installer** (optional):
   ```bash
   ./package.sh
   ```

## What Gets Customized

- ✅ Application name (replaces "Visual Studio Code")
- ✅ AI assistant name (replaces "Cline")  
- ✅ Bundle identifier
- ✅ Company information
- ✅ Application icon
- ✅ Featherless.ai integration

## Configuration

Edit `config.txt` to set:
- `APP_NAME`: Your IDE's short name
- `APP_DISPLAY_NAME`: Full display name
- `AI_NAME`: Your AI assistant's name
- `BUNDLE_ID`: macOS bundle identifier
- Icon path and other branding

## Featherless.ai Models

Pre-configured models:
- Llama 3.1 70B (default)
- Llama 3.1 8B
- Qwen 2.5 72B
- DeepSeek Coder V2
- Phi 3.5 Mini

## Requirements

- macOS 10.15+
- Xcode Command Line Tools (for icons)
- Internet connection (for setup)

## Build Time

- Setup: ~2 minutes (downloads VS Code)
- Branding: ~30 seconds
- DMG creation: ~10 seconds

Total: Under 3 minutes for a fully branded IDE!