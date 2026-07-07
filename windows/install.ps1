#Requires -Version 5.1
<#
    Windows equivalent of install.sh.
    Sets up the PowerShell prompt stack (Oh My Posh + PSReadLine + posh-git),
    a Nerd Font, Windows Terminal colors, and Herdr (Windows beta).

    Run from an elevated-or-normal PowerShell:
        Set-ExecutionPolicy -Scope Process Bypass -Force
        .\windows\install.ps1
#>

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Installing Windows dotfiles..." -ForegroundColor Cyan

# --- winget must be present (ships with modern Windows via 'App Installer') ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget not found. Install 'App Installer' from the Microsoft Store, then re-run."
}

function Install-WingetPackage([string]$Id) {
    $found = winget list --id $Id -e --accept-source-agreements 2>$null | Select-String -SimpleMatch $Id
    if ($found) { Write-Host "  $Id already installed"; return }
    Write-Host "  installing $Id..."
    winget install -e --id $Id --accept-source-agreements --accept-package-agreements
}

# --- core packages ---
Install-WingetPackage 'Microsoft.PowerShell'
Install-WingetPackage 'Microsoft.WindowsTerminal'
Install-WingetPackage 'Git.Git'
Install-WingetPackage 'JanDeDobbeleer.OhMyPosh'

# refresh PATH so freshly installed tools are callable in this session
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' +
            [Environment]::GetEnvironmentVariable('Path', 'User')

# --- Nerd Font (MesloLGS) via Oh My Posh ---
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    Write-Host "Installing MesloLGS Nerd Font..."
    oh-my-posh font install Meslo
} else {
    Write-Warning "oh-my-posh not on PATH yet; open a new terminal and run: oh-my-posh font install Meslo"
}

# --- PowerShell modules ---
if ((Get-PSRepository -Name PSGallery).InstallationPolicy -ne 'Trusted') {
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}
foreach ($mod in 'posh-git', 'Terminal-Icons') {
    if (-not (Get-Module -ListAvailable -Name $mod)) {
        Write-Host "Installing module $mod..."
        Install-Module $mod -Scope CurrentUser -Force -AllowClobber
    }
}

# --- PowerShell profile (symlink to repo; fall back to copy without Developer Mode) ---
$profileSrc = Join-Path $scriptDir 'Microsoft.PowerShell_profile.ps1'
$profileDst = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path -Parent $profileDst
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }

if ((Test-Path $profileDst) -and -not (Get-Item $profileDst).LinkType) {
    Write-Host "Backing up existing profile to $profileDst.backup"
    Copy-Item $profileDst "$profileDst.backup" -Force
}
try {
    New-Item -ItemType SymbolicLink -Path $profileDst -Target $profileSrc -Force -ErrorAction Stop | Out-Null
    Write-Host "Linked profile -> $profileSrc"
} catch {
    Copy-Item $profileSrc $profileDst -Force
    Write-Host "Copied profile (symlink needs Developer Mode/admin) -> $profileDst"
}

# --- Windows Terminal: font + color scheme (mirrors the Ghostty palette) ---
function Update-WindowsTerminal {
    $candidates = @(
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json",
        "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"
    )
    $settingsPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
    if (-not $settingsPath) {
        Write-Warning "Windows Terminal settings.json not found; open Windows Terminal once, then re-run."
        return
    }

    Copy-Item $settingsPath "$settingsPath.backup" -Force

    try {
        # Windows Terminal ships settings.json as JSONC (e.g. "// Add custom color schemes to
        # this array."). PowerShell 5.1's ConvertFrom-Json has zero JSONC tolerance and throws
        # on any comment, so strip // and /* */ comments while leaving string literals (URLs
        # like "https://aka.ms/...") untouched.
        $raw = Get-Content $settingsPath -Raw
        $noComments = [regex]::Replace(
            $raw,
            '"(?:\\.|[^"\\])*"|(?<comment>//[^\r\n]*|/\*[\s\S]*?\*/)',
            { param($m) if ($m.Groups['comment'].Success) { '' } else { $m.Value } }
        )
        $json = $noComments | ConvertFrom-Json
    } catch {
        Write-Warning "Could not parse Windows Terminal settings.json ($($_.Exception.Message)); skipping terminal patch."
        return
    }

    $scheme = [ordered]@{
        name = 'BasicDotfiles'; background = '#071B22'; foreground = '#7C8B8D'
        cursorColor = '#9C9A9C'; selectionBackground = '#7C8B8D'
        black = '#000000'; red = '#990000'; green = '#72A52E'; yellow = '#96993D'
        blue = '#2B8BD2'; purple = '#AF6CB0'; cyan = '#6FB2A9'; white = '#BFBFBF'
        brightBlack = '#666666'; brightRed = '#E52F31'; brightGreen = '#67D85D'; brightYellow = '#E6E45A'
        brightBlue = '#5255FE'; brightPurple = '#CF63E5'; brightCyan = '#93E6E4'; brightWhite = '#E5E5E5'
    }

    if (-not ($json.PSObject.Properties.Name -contains 'schemes')) {
        $json | Add-Member -NotePropertyName schemes -NotePropertyValue @()
    }
    $json.schemes = @($json.schemes | Where-Object { $_.name -ne 'BasicDotfiles' }) + ([pscustomobject]$scheme)

    if (-not ($json.PSObject.Properties.Name -contains 'profiles')) {
        $json | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{})
    }
    if (-not ($json.profiles.PSObject.Properties.Name -contains 'defaults')) {
        $json.profiles | Add-Member -NotePropertyName defaults -NotePropertyValue ([pscustomobject]@{}) -Force
    }
    $defaults = $json.profiles.defaults
    $font = [pscustomobject]@{ face = 'MesloLGS NF' }
    if ($defaults.PSObject.Properties.Name -contains 'font') { $defaults.font = $font }
    else { $defaults | Add-Member -NotePropertyName font -NotePropertyValue $font }
    if ($defaults.PSObject.Properties.Name -contains 'colorScheme') { $defaults.colorScheme = 'BasicDotfiles' }
    else { $defaults | Add-Member -NotePropertyName colorScheme -NotePropertyValue 'BasicDotfiles' }

    try {
        $json | ConvertTo-Json -Depth 32 | Set-Content $settingsPath -Encoding utf8
        Write-Host "Windows Terminal patched (font=MesloLGS NF, scheme=BasicDotfiles); backup at $settingsPath.backup"
    } catch {
        Write-Warning "Could not write Windows Terminal settings.json ($($_.Exception.Message)); restoring backup."
        Copy-Item "$settingsPath.backup" $settingsPath -Force
    }
}
Update-WindowsTerminal

# --- Herdr (Windows beta) ---
if (-not (Get-Command herdr -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Herdr (Windows beta)..."
    Invoke-RestMethod https://herdr.dev/install.ps1 | Invoke-Expression
} else {
    Write-Host "  herdr already installed"
}

Write-Host "Done! Open a new Windows Terminal tab (or run: . `$PROFILE)." -ForegroundColor Green
