#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# bootstrap.sh — single provisioning entry point.
#
# Usage:
#   ./bootstrap.sh [install|doctor] [--non-interactive]
#
#   install (default)   Install Homebrew + Ansible, run site.yml, stow packages.
#   doctor              Read-only verify: tools on PATH, stow symlinks, git
#                       hooks, role-level state. Exits non-zero on any failure.
#                       Does not mutate the system.
#   --non-interactive   Drop --ask-become-pass. CI / scripted use. Roles that
#                       need sudo will fail loudly rather than prompt.
#
# Sources ~/.secrets early so role gates (e.g. NEXTDNS_PROFILE) see env vars
# without requiring the caller to source first.
###############################################################################

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source secrets so ansible_env.X gates resolve correctly. Optional: CI and
# fresh machines will not have this file, and that is a valid state.
if [ -f "$HOME/.secrets" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.secrets"
fi

# ---------------------------------------------------------------------------
# Parse args
# ---------------------------------------------------------------------------
SUBCOMMAND="install"
INTERACTIVE=1

for arg in "$@"; do
  case "$arg" in
    install|doctor)    SUBCOMMAND="$arg" ;;
    --non-interactive) INTERACTIVE=0 ;;
    -h|--help)
      sed -n '4,18p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Unknown argument: $arg" >&2
      echo "Run with --help for usage." >&2
      exit 2
      ;;
  esac
done

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

# ---------------------------------------------------------------------------
# Brew shellenv: ensure brew + ansible are on PATH for this script invocation.
# Idempotent — does nothing if brew was never installed.
# ---------------------------------------------------------------------------
load_brew_env() {
  if [[ "$PLATFORM" == "macos" ]]; then
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  elif [[ "$PLATFORM" == "linux" ]]; then
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
  fi
}

# ===========================================================================
# Windows path — delegates to PowerShell, optionally bootstraps WSL2
# ===========================================================================
bootstrap_windows() {
  local win_dotfiles
  win_dotfiles="$(cygpath -w "$DOTFILES_DIR")"
  echo "Running Windows setup via PowerShell..."
  powershell.exe -ExecutionPolicy Bypass -File "$win_dotfiles\\bootstrap-windows.ps1"
  echo "Windows-side setup complete!"

  if command -v wsl.exe &>/dev/null; then
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
    echo "No git remote detected. Bootstrap WSL manually:"
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
# Unix install path (macOS / Linux / WSL2)
# ===========================================================================
install_homebrew() {
  if command -v brew &>/dev/null; then
    echo "Homebrew already installed."
    return
  fi
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew_env
}

install_ansible() {
  if command -v ansible-playbook &>/dev/null; then
    echo "Ansible already installed."
    return
  fi
  echo "Installing Ansible..."
  brew install ansible
}

run_playbook() {
  echo "Running Ansible playbook..."
  local args=(-i "$DOTFILES_DIR/inventory.ini" "$DOTFILES_DIR/site.yml")
  # --ask-become-pass: macOS roles can need sudo too (e.g. nextdns registers a
  # launchd service). CI / scripted invocations pass --non-interactive so the
  # playbook never blocks on a TTY.
  if [[ "$INTERACTIVE" -eq 1 ]]; then
    args+=(--ask-become-pass)
  fi
  ansible-playbook "${args[@]}"
}

bootstrap_unix() {
  install_homebrew
  install_ansible
  run_playbook
}

# ===========================================================================
# Doctor — read-only verify
# ===========================================================================
doctor_unix() {
  load_brew_env

  echo "── Doctor: prerequisite tools ──────────────────────────────────────"
  local missing=0
  for tool in brew ansible-playbook stow git; do
    if command -v "$tool" &>/dev/null; then
      printf "  ✓ %s (%s)\n" "$tool" "$(command -v "$tool")"
    else
      printf "  ✗ %s (not on PATH)\n" "$tool"
      missing=$((missing + 1))
    fi
  done

  if [ ! -f "$HOME/.secrets" ]; then
    echo "  ⚠  ~/.secrets not present (optional; role gates will resolve to false)"
  fi

  if [ "$missing" -gt 0 ]; then
    echo "Doctor: $missing prerequisite tool(s) missing — run \`./bootstrap.sh\` first." >&2
    return 1
  fi

  echo
  echo "── Doctor: ansible role verify ─────────────────────────────────────"
  ansible-playbook \
    -i "$DOTFILES_DIR/inventory.ini" \
    "$DOTFILES_DIR/site.yml" \
    --tags verify \
    --diff
}

doctor_windows() {
  printf 'Doctor mode is not implemented on Windows yet.\n' >&2
  printf 'Verify manually: PowerShell symlinks at %%APPDATA%%\\alacritty\\, %%APPDATA%%\\Zed\\.\n' >&2
  return 1
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
detect_platform

case "$SUBCOMMAND" in
  install)
    if [[ "$PLATFORM" == "windows" ]]; then
      bootstrap_windows
    else
      bootstrap_unix
    fi
    echo "Bootstrap complete!"
    ;;
  doctor)
    if [[ "$PLATFORM" == "windows" ]]; then
      doctor_windows
    else
      doctor_unix
    fi
    echo "Doctor: all checks passed."
    ;;
esac
