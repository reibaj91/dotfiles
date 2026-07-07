# Dotfiles

Personal zsh, terminal and Claude Code configuration.

## What's included

- `.zshrc` - Main zsh config (oh-my-zsh + agnoster theme)
- `.p10k.zsh` - Powerlevel10k config (optional)
- `Basic.terminal` - Terminal.app profile (colors, font, cursor)
- `ghostty/config.ghostty` - Ghostty terminal config
- `claude/statusline.sh` - Claude Code statusline (powerline + rate limits bar)

### Plugins

- git
- zsh-autosuggestions
- zsh-syntax-highlighting

## Installation

```bash
git clone https://github.com/reibaj91/dotfiles.git ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Manual setup (if needed)

### Maven (optional)

If you use Maven, install it and the path in `.zshrc` will work:

```bash
brew install maven
```

Or download manually to `/usr/local/apache-maven`.

### Powerlevel10k (optional)

To enable p10k instead of agnoster, uncomment this line in `.zshrc`:

```bash
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
```

And change the theme:

```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```

### Claude Code statusline (optional)

`install.sh` symlinks `claude/statusline.sh` to `~/.claude/statusline.sh` and, if `jq` is
installed, wires it into `~/.claude/settings.json` automatically. If `jq` is missing, add this
manually to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "bash \"$HOME/.claude/statusline.sh\"" }
```

The script uses `jq` (JSON) and expects Claude Code's native `context_window` / `rate_limits`
fields in the statusline input — no extra setup needed beyond having `jq` installed.

### Nerd Font (required for the prompt)

The `agnoster` theme (and Powerlevel10k) render the prompt with Powerline glyphs — segment
separators, the git branch icon, etc. Without a patched font you'll see `?`-in-a-box placeholders.
Both the Terminal.app profile and the Ghostty config use `MesloLGS NF`. Install the Meslo Nerd Font
family if it's missing:

```bash
brew install --cask font-meslo-lg-nerd-font
```

### Ghostty (optional)

`install.sh` symlinks `ghostty/config.ghostty` to
`~/Library/Application Support/com.mitchellh.ghostty/config.ghostty`. Uses `MesloLGS NF` (see above);
change `font-family` if you prefer a different Nerd Font.

### Herdr (persistent sessions + AI agent notifications)

[Herdr](https://herdr.dev) is a terminal workspace manager: it keeps a persistent session running
in a background server, so closing a terminal window by accident doesn't kill your work, and it
tracks the status (`idle`/`working`/`blocked`) of AI coding agents running inside it, firing sound
notifications on state changes.

Requires `brew install herdr`. Two pieces:

1. **Auto-attach on every new terminal** — `.zshrc` has a guarded block (search for
   `Auto-attach a Herdr`) that `exec`s into `herdr` on any new interactive shell, unless you're
   already inside tmux/zellij/herdr. It attaches to the existing persistent session or creates one.
   Rollback: comment out or delete that block, then open a new terminal.

2. **Agent integrations** — `herdr integration install claude` (also available: `codex`,
   `opencode`, `cursor`, others — no Gemini CLI support as of this writing) wires each CLI's
   session into Herdr so it can report status and trigger notifications. This adds a single
   `SessionStart` hook to `~/.claude/settings.json` that is a no-op outside of Herdr (gated on
   `$HERDR_ENV`). Rollback: `herdr integration uninstall claude`.

`brew uninstall herdr` removes the binary but leaves the `.zshrc` block and the hook in place —
remove those manually if you uninstall.
