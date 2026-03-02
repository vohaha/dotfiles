#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# bootstrap.sh — single entry point for macOS, Linux, WSL2, and Windows
###############################################################################

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Detect platform
# ---------------------------------------------------------------------------
detect_platform() {
  case "$(uname -s)" in
    Darwin)       PLATFORM="macos" ;;
    Linux)        PLATFORM="linux" ;;
    MSYS*|MINGW*) PLATFORM="windows" ;;
    *)            echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
  esac
  echo "Detected platform: $PLATFORM"
}

# ===========================================================================
# Windows path (delegates to PowerShell + optionally bootstraps WSL2)
# ===========================================================================
bootstrap_windows() {
  local win_dotfiles
  win_dotfiles="$(cygpath -w "$DOTFILES_DIR")"

  echo "Running Windows setup via PowerShell..."
  powershell.exe -ExecutionPolicy Bypass -File "$win_dotfiles\\bootstrap-windows.ps1"

  echo ""
  echo "Windows-side setup complete!"

  # Offer to bootstrap WSL2 dev environment
  if command -v wsl.exe &>/dev/null; then
    echo ""
    read -rp "Also bootstrap the WSL2 dev environment? [Y/n] " answer
    if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
      bootstrap_wsl
    fi
  fi
}

bootstrap_wsl() {
  local git_url
  git_url="$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null || true)"

  if [[ -z "$git_url" ]]; then
    echo "Could not detect git remote. Please bootstrap WSL manually:"
    echo "  wsl bash -c 'git clone <repo-url> ~/dotfiles && cd ~/dotfiles && ./bootstrap.sh'"
    return
  fi

  echo "Bootstrapping inside WSL2..."
  wsl.exe bash -c "
    set -euo pipefail
    if [ -d ~/dotfiles ]; then
      echo 'Updating existing ~/dotfiles...'
      cd ~/dotfiles && git pull
    else
      git clone '$git_url' ~/dotfiles
    fi
    cd ~/dotfiles && ./bootstrap.sh
  "
  echo "WSL2 bootstrap complete!"
}

# ===========================================================================
# Unix path (macOS / Linux / WSL2)
# ===========================================================================
install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "Homebrew already installed."
    return
  fi
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Make brew available for the rest of this script
  if [[ "$PLATFORM" == "macos" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
  else
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
}

install_prerequisites() {
  echo "Installing Ansible and Stow..."
  brew install ansible stow
}

run_playbook() {
  echo "Running Ansible playbook..."
  ansible-playbook -i "$DOTFILES_DIR/inventory.ini" "$DOTFILES_DIR/localhost.yaml" --ask-become-pass
}

stow_packages() {
  echo "Stowing packages..."
  cd "$DOTFILES_DIR"

  for dir in */; do
    dir="${dir%/}"

    # Skip non-package directories
    case "$dir" in
      .git|.claude) continue ;;
    esac

    # Platform-specific packages: only stow if suffix matches current platform
    if [[ "$dir" == *-macos ]]; then
      [[ "$PLATFORM" == "macos" ]] && stow --adopt "$dir" -t ~/
      continue
    fi
    if [[ "$dir" == *-linux ]]; then
      [[ "$PLATFORM" == "linux" ]] && stow --adopt "$dir" -t ~/
      continue
    fi
    if [[ "$dir" == *-windows ]]; then
      continue  # Handled by bootstrap-windows.ps1
    fi

    # Common packages
    stow --adopt "$dir" -t ~/
  done

  # --adopt moves existing files into the package dirs; restore the repo versions
  git -C "$DOTFILES_DIR" checkout -- .

  echo "All packages stowed."
}

bootstrap_unix() {
  install_homebrew
  install_prerequisites
  run_playbook
  stow_packages
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
detect_platform

if [[ "$PLATFORM" == "windows" ]]; then
  bootstrap_windows
else
  bootstrap_unix
fi

echo "Bootstrap complete!"
