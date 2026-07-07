#!/bin/bash

set -e

echo "Installing dotfiles..."

# Install oh-my-zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Install custom plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Backup existing configs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$HOME/.zshrc" ]; then
    echo "Backing up existing .zshrc to .zshrc.backup"
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

# Create symlinks
echo "Creating symlinks..."
ln -sf "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
ln -sf "$SCRIPT_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Claude Code statusline
mkdir -p "$HOME/.claude"
ln -sf "$SCRIPT_DIR/claude/statusline.sh" "$HOME/.claude/statusline.sh"
if command -v jq >/dev/null 2>&1; then
    SETTINGS="$HOME/.claude/settings.json"
    [ -f "$SETTINGS" ] || echo '{}' > "$SETTINGS"
    TMP=$(mktemp)
    jq '.statusLine = {"type": "command", "command": "bash \"$HOME/.claude/statusline.sh\""}' "$SETTINGS" > "$TMP" && mv "$TMP" "$SETTINGS"
    echo "Claude Code statusline wired into $SETTINGS"
else
    echo "jq not found: add this to ~/.claude/settings.json manually:"
    echo '  "statusLine": { "type": "command", "command": "bash \"$HOME/.claude/statusline.sh\"" }'
fi

# Ghostty
GHOSTTY_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
mkdir -p "$GHOSTTY_DIR"
ln -sf "$SCRIPT_DIR/ghostty/config.ghostty" "$GHOSTTY_DIR/config.ghostty"

# Terminal.app profile
if command -v open >/dev/null 2>&1 && command -v defaults >/dev/null 2>&1; then
    open "$SCRIPT_DIR/Basic.terminal"
    sleep 1
    defaults write com.apple.Terminal "Default Window Settings" -string "Basic 1"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Basic 1"
    echo "Terminal.app profile 'Basic' imported and set as default (check Terminal > Settings if the name differs)"
fi

echo "Done! Restart your terminal or run: source ~/.zshrc"
