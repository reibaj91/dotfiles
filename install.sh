#!/bin/bash

set -e

echo "Installing dotfiles..."

# Bootstrap Homebrew (portable: Apple Silicon -> /opt/homebrew, Intel -> /usr/local)
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
else
    echo "Homebrew not found. Installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Nerd Font for Powerline glyphs (agnoster / p10k). Without it the prompt shows tofu boxes.
if command -v brew >/dev/null 2>&1; then
    if ! ls "$HOME/Library/Fonts"/MesloLGS* >/dev/null 2>&1 && ! ls "/Library/Fonts"/MesloLGS* >/dev/null 2>&1; then
        echo "Installing MesloLGS Nerd Font..."
        brew install --cask font-meslo-lg-nerd-font || echo "Font install failed; run: brew install --cask font-meslo-lg-nerd-font"
    fi
else
    echo "brew unavailable: install MesloLGS NF manually or the prompt glyphs will be missing."
fi

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

# Back up any existing real file (not a symlink) before we overwrite it
backup_if_real() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        echo "Backing up existing $target to $target.backup"
        cp "$target" "$target.backup"
    fi
}

backup_if_real "$HOME/.zshrc"
backup_if_real "$HOME/.p10k.zsh"

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
backup_if_real "$GHOSTTY_DIR/config.ghostty"
ln -sf "$SCRIPT_DIR/ghostty/config.ghostty" "$GHOSTTY_DIR/config.ghostty"

# Terminal.app profile
if command -v open >/dev/null 2>&1 && command -v defaults >/dev/null 2>&1; then
    open "$SCRIPT_DIR/Basic.terminal"
    sleep 1
    defaults write com.apple.Terminal "Default Window Settings" -string "Basic 1"
    defaults write com.apple.Terminal "Startup Window Settings" -string "Basic 1"
    echo "Terminal.app profile 'Basic' imported and set as default (check Terminal > Settings if the name differs)"
fi

# Herdr: persistent sessions + AI agent notifications (.zshrc auto-attaches new terminals to it)
if command -v brew >/dev/null 2>&1; then
    if ! command -v herdr >/dev/null 2>&1; then
        echo "Installing herdr..."
        brew install herdr || echo "herdr install failed; run: brew install herdr"
    fi
    if command -v herdr >/dev/null 2>&1 && command -v claude >/dev/null 2>&1; then
        herdr integration install claude || true
    fi
else
    echo "brew unavailable: install herdr manually (https://herdr.dev) or the auto-attach in .zshrc will no-op."
fi

echo "Done! Restart your terminal or run: source ~/.zshrc"
