# PowerShell profile — Windows equivalent of .zshrc (agnoster look + autosuggestions + git).
# Managed by dotfiles/windows. Edit it in the repo, not here (the installed copy may be a symlink).

# --- Oh My Posh (prompt engine; agnoster theme = same look as the macOS zsh setup) ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if ($env:POSH_THEMES_PATH -and (Test-Path "$env:POSH_THEMES_PATH\agnoster.omp.json")) {
        oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\agnoster.omp.json" | Invoke-Expression
    } else {
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# --- PSReadLine (autosuggestions + syntax highlighting, ships with PowerShell 7+) ---
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView
    Set-PSReadLineOption -EditMode Windows
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

# --- posh-git (git status segment + completion) ---
if (Get-Module -ListAvailable posh-git) { Import-Module posh-git }

# --- Terminal-Icons (file-type icons in listings; needs a Nerd Font) ---
if (Get-Module -ListAvailable Terminal-Icons) { Import-Module Terminal-Icons }

# --- Aliases / functions (mirror of the zsh aliases) ---
# PowerShell aliases can't carry arguments, so the multi-arg ones are functions.
function wrk    { Set-Location "$HOME\dev\vitaly\Workspace" }
function vplay  { Set-Location "$HOME\dev\vitaly\TPS" }
function mci    { mvn clean install @args }
function mcs    { mvn clean install -DskipTests @args }
function greset { git reset --soft HEAD~1 }
function gdev   { git checkout develop }
function gmain  { git checkout main }
function grbs   { git pull --rebase origin develop }

# --- Herdr auto-attach on every new interactive terminal ---
# Rollback: comment out or delete this block, then open a new terminal.
if ($Host.Name -eq 'ConsoleHost' -and
    (Get-Command herdr -ErrorAction SilentlyContinue) -and
    -not $env:HERDR_ENV -and -not $env:TMUX -and -not $env:ZELLIJ) {
    herdr
    exit $LASTEXITCODE
}
