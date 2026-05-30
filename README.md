# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).
Works on **macOS**, **Linux**, **WSL2**, and **Windows**.

> See `LAYERS.md` for the live state of this machine — auto-generated on every commit.

## Quick Start

```bash
git clone git@github.com:vohaha/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The script detects your platform and does the right thing:

| Platform | What happens |
|---|---|
| macOS / Linux / WSL2 | Installs Homebrew, Ansible, Stow; runs playbook; stows packages; installs git hooks |
| Windows (Git Bash) | Runs PowerShell to install apps via winget + symlink configs, then offers to bootstrap WSL2 |

## Packages

| Directory | Target | Description |
|---|---|---|
| `shell` | `~/` | `.zshrc` — zsh + Oh My Zsh |
| `alacritty` | `~/.config/alacritty/` | Alacritty terminal (shared config) |
| `alacritty-macos` | `~/.config/alacritty/` | macOS overrides (`local.toml`) |
| `alacritty-linux` | `~/.config/alacritty/` | Linux overrides (`local.toml`) |
| `alacritty-windows` | *(symlinked by PS1)* | Windows overrides — WSL shell launcher |
| `tmux` | `~/` | tmux config — vim keys, Tokyo Night status bar |
| `zed` | `~/.config/zed/` | Zed editor settings and keybindings |
| `git` | `~/` | Git config — user, defaults, local override include |
| `nvim` | `~/.config/nvim/` | Neovim config (LazyVim) — available, deferred |

Platform-specific packages use the `-macos`, `-linux`, `-windows` suffix.
`bootstrap.sh` auto-stows the matching suffix on unix; PowerShell handles Windows paths.

## Machine-Local Files

These are **never committed** — create them on each machine after bootstrap:

| File | Purpose |
|---|---|
| `~/.secrets` | API keys and tokens — sourced from `.zshrc` |
| `~/.gitconfig.local` | Machine-managed git config (GCM, git-lfs) — included via `[include]` |

## AI CLIs

`bootstrap.sh` installs Codex CLI and Claude Code through the `ai-clis` Ansible role.
Authentication stays machine-local: sign in interactively or put API keys in `~/.secrets`.

## Bitwarden SSH Agent

Shells point `SSH_AUTH_SOCK` at the Bitwarden SSH agent socket. On macOS, the
Bitwarden cask is installed by Homebrew. On Windows, `bootstrap-windows.ps1`
installs Bitwarden, disables the competing Windows OpenSSH Authentication Agent
service, and writes Windows OpenSSH settings to `~/.gitconfig.local`.
On Linux GUI machines, the Ansible playbook installs Bitwarden Desktop from
Flathub. WSL2 skips the Linux GUI app and uses the Windows-side Bitwarden app.

The Bitwarden desktop app still has to be unlocked and configured once:
Settings -> Enable SSH agent. Linux shells support the native, Snap, and Flatpak
socket paths.

## Tools

Install all tools via Homebrew:

```bash
brew bundle --file=Brewfile
```

## Layer Map

`LAYERS.md` shows the live status of every layer on this machine — what's installed, what's stowed, what's running. It's regenerated automatically on every commit via `scripts/hooks/pre-commit`.

Run manually anytime:

```bash
bash scripts/generate-layers.sh
```

## North Star

**This repo must work on macOS, Linux, and Windows (WSL2).** If something is OS-specific, it is explicitly conditional — never silently hardcoded.
