#Requires -Version 5.1
<#
.SYNOPSIS
    Bootstrap dotfiles on Windows — installs apps, symlinks configs, sets up WSL2.
.DESCRIPTION
    Run from an elevated PowerShell prompt:
        Set-ExecutionPolicy -Scope Process Bypass
        .\bootstrap-windows.ps1
    Requires Developer Mode enabled (Settings > Privacy & Security > For developers)
    or an Administrator shell for symlink creation.
#>
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$DotfilesDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
function New-Symlink {
    param(
        [string]$Link,
        [string]$Target
    )
    if (Test-Path $Link) {
        $item = Get-Item $Link -Force
        if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $Target) {
            Write-Host "  OK  $Link" -ForegroundColor DarkGray
            return
        }
        Write-Host "  Backing up existing $Link -> $Link.bak" -ForegroundColor Yellow
        Move-Item $Link "$Link.bak" -Force
    }

    $parent = Split-Path $Link -Parent
    if (-not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    New-Item -ItemType SymbolicLink -Path $Link -Target $Target -Force | Out-Null
    Write-Host "  LINK $Link -> $Target" -ForegroundColor Green
}

function Install-WithWinget {
    param([string]$Id, [string]$Name)
    $installed = winget list --id $Id 2>$null | Select-String $Id
    if ($installed) {
        Write-Host "  $Name already installed." -ForegroundColor DarkGray
    } else {
        Write-Host "  Installing $Name..."
        winget install --id $Id --accept-source-agreements --accept-package-agreements
    }
}

# ---------------------------------------------------------------------------
# 1. Install WSL2
# ---------------------------------------------------------------------------
Write-Host "`n=== WSL2 ===" -ForegroundColor Cyan
$wslInstalled = Get-Command wsl.exe -ErrorAction SilentlyContinue
if ($wslInstalled) {
    Write-Host "  WSL is available."
    $distros = wsl --list --quiet 2>$null
    if (-not $distros -or $distros.Length -eq 0) {
        Write-Host "  No WSL distro found. Installing Ubuntu..."
        wsl --install -d Ubuntu
        Write-Host "  Ubuntu installed. You may need to restart and set up your user." -ForegroundColor Yellow
    }
} else {
    Write-Host "  Installing WSL..."
    wsl --install
    Write-Host "  WSL installed. Please restart your machine, then re-run this script." -ForegroundColor Yellow
    exit 0
}

# ---------------------------------------------------------------------------
# 2. Install apps via winget
# ---------------------------------------------------------------------------
Write-Host "`n=== Applications ===" -ForegroundColor Cyan
Install-WithWinget 'Git.Git'                 'Git'
Install-WithWinget 'Alacritty.Alacritty'     'Alacritty'
Install-WithWinget 'Neovim.Neovim'           'Neovim'

# ---------------------------------------------------------------------------
# 3. Symlink configs
# ---------------------------------------------------------------------------
Write-Host "`n=== Symlinks ===" -ForegroundColor Cyan

# Git
Write-Host "Git:" -ForegroundColor White
New-Symlink "$env:USERPROFILE\.gitconfig" "$DotfilesDir\git\.gitconfig"
New-Symlink "$env:USERPROFILE\.gitignore" "$DotfilesDir\git\.gitignore"

# Alacritty — config file lives in %APPDATA%\alacritty\
# The import path (~/.config/alacritty/local.toml) resolves to %USERPROFILE%\.config\alacritty\
Write-Host "Alacritty:" -ForegroundColor White
New-Symlink "$env:APPDATA\alacritty\alacritty.toml" "$DotfilesDir\alacritty\.config\alacritty\alacritty.toml"
New-Symlink "$env:USERPROFILE\.config\alacritty\local.toml" "$DotfilesDir\alacritty-windows\.config\alacritty\local.toml"

# Zed — config lives in %APPDATA%\Zed\
Write-Host "Zed:" -ForegroundColor White
$zedConfigDir = "$env:APPDATA\Zed"
if (Test-Path "$DotfilesDir\zed\.config\zed\settings.json") {
    New-Symlink "$zedConfigDir\settings.json" "$DotfilesDir\zed\.config\zed\settings.json"
}
if (Test-Path "$DotfilesDir\zed\.config\zed\keymap.json") {
    New-Symlink "$zedConfigDir\keymap.json" "$DotfilesDir\zed\.config\zed\keymap.json"
}

# ---------------------------------------------------------------------------
# 4. Next steps
# ---------------------------------------------------------------------------
Write-Host "`n=== Next steps ===" -ForegroundColor Cyan
Write-Host @"
  Windows-side setup complete!

  To finish setting up your dev environment inside WSL2:
    1. Open a WSL terminal (or launch Alacritty)
    2. Clone this repo:
         git clone <your-repo-url> ~/dotfiles
    3. Run the bootstrap script:
         cd ~/dotfiles && ./bootstrap.sh

  Font: Install "JetBrainsMono Nerd Font" manually from
        https://www.nerdfonts.com/font-downloads
"@
