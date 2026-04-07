# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Operating Mode

Claude drives. The human's role is to support — clarifying intent, reviewing decisions,
and providing context Claude doesn't have. Not the other way around.

Operational implications:

- Claude acts on obvious improvements without waiting for permission
- Honest pushback is preferred over polite compliance
- When evaluating a change, the first question is: does this reduce friction or move the work forward?

## Domain

This is a personal dotfiles repo for a macOS/Windows/Linux developer (Volodymyr).
The goal is a reproducible, keyboard-first environment with a clear mental model of layers.

Layer model (in order): Hardware (Glove80+TailorKey) → Config management (Stow) → Shell (zsh+OMZ) → Terminal (Alacritty+tmux) → Window management (Aerospace/GlazeWM) → Editor (Zed+vim mode / WebStorm+IdeaVim) → Apps

Key patterns:
- Secrets live in `~/.secrets` (gitignored), sourced from `.zshrc`
- Machine-managed tool configs (GCM, git-lfs) go in `~/.gitconfig.local` via `[include]`
- Platform-specific configs use `-macos`/`-linux`/`-windows` package suffix
- `scripts/generate-layers.sh` produces `LAYERS.md` — run on every commit via pre-commit hook
- `alacritty migrate` replaces symlinks with real files — must re-stow after running it

## North Star

**This repo must work on macOS, Linux, and Windows (WSL2).** This is non-negotiable.

- Never hardcode OS-specific paths silently (e.g. `/Applications/`, `C:\Users\`, `~/Library/`)
- If something is OS-specific, it must be explicitly conditional and handled for all three platforms
- When adding a new tool, script, or check — ask: does this work on all three? If not, make it explicit

## What This Is

Personal dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package containing config files mirroring their home-directory structure. Supports **macOS**, **Linux**, **WSL2**, and **Windows**.

## Bootstrap

Single entry point for all platforms:
```bash
./bootstrap.sh
```
On macOS/Linux/WSL2 it installs Homebrew, Ansible, Stow, runs the playbook, and stows packages. On Windows (Git Bash) it delegates to `bootstrap-windows.ps1` for winget installs + config symlinks, then offers to bootstrap WSL2 automatically.

## Manual Deploying

Symlink a package to the home directory (macOS/Linux):
```bash
stow <package> -t ~/
```
The `.stowrc` file configures stow to ignore `.git/` by default.

## Provisioning Dependencies

An Ansible playbook installs base tooling via Homebrew:
```bash
ansible-playbook -i inventory.ini localhost.yaml
```
This installs: curl, htop, fzf, ripgrep, luarocks, fd, lazygit, stow, and nvm.

## Packages

| Directory           | Target                 | Description                              |
|---------------------|------------------------|------------------------------------------|
| `alacritty`         | `~/.config/alacritty/` | Alacritty terminal (shared config)       |
| `alacritty-linux`   | `~/.config/alacritty/` | Linux-specific window/shell settings     |
| `alacritty-macos`   | `~/.config/alacritty/` | macOS-specific window/shell settings     |
| `alacritty-windows` | *(symlinked by PS1)*   | Windows-specific settings (WSL launcher) |
| `git`               | `~/`                   | Git user config and global gitignore     |
| `nvim`              | `~/.config/nvim/`      | Neovim config (LazyVim framework)        |
| `shell`             | `~/`                   | `.zshrc` (primary), `.bashrc`, `.bash_profile` |
| `tmux`              | `~/`                   | tmux config                              |
| `zed`               | `~/.config/zed/`       | Zed editor settings and keybindings      |

## Platform-Specific Packages

Directories ending in `-macos`, `-linux`, or `-windows` contain platform-specific overrides. On macOS/Linux, `bootstrap.sh` auto-stows the matching suffix. On Windows, `bootstrap-windows.ps1` symlinks files to their Windows paths (`%APPDATA%\alacritty\`, `%APPDATA%\Zed\`, `%USERPROFILE%`).

The Alacritty base config uses `import = ["~/.config/alacritty/local.toml"]` to pull in the platform-specific `local.toml` (window decorations and shell program).

## Neovim Setup

Built on [LazyVim](https://www.lazyvim.org/) with [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Custom plugin overrides go in `nvim/.config/nvim/lua/plugins/`. Config entry point is `nvim/.config/nvim/init.lua` -> `lua/config/lazy.lua`.

<!-- groundwork:start -->

## Groundwork

### Session Start

Orientation is handled automatically by the groundwork `SessionStart` hook —
the session start box contains branch, last commit, trajectory, open questions,
uncommitted count, and agreement item count.

Check `WORKING_AGREEMENT.md` if there are open items.

### During Work

Commit at logical checkpoints with `/groundwork:commit`.

Format: `type(scope): summary` + `Why:` (required) + `State:/Next:` (required)
Optional: `Discovered:` (non-obvious findings) | `Open:` (unresolved questions)
Types: `feat` | `fix` | `refactor` | `docs` | `test` | `chore` | `session` | `decide`

Commit autonomously. The commit message IS the state — don't defer commits.

### Session End

Run `/groundwork:check-in` — updates WORKING_AGREEMENT.md and creates checkpoint commit.

<!-- groundwork:end -->

## Conventions

- Each package directory mirrors the target filesystem layout relative to `~/`. For example, `alacritty/.config/alacritty/alacritty.toml` becomes `~/.config/alacritty/alacritty.toml`.
- Neovim plugins use Lua and follow LazyVim conventions (return a table from each file in `lua/plugins/`).
- Zed config uses hard tabs (except YAML which uses spaces).
- Platform-specific packages use the naming convention `<base>-macos`, `<base>-linux`, or `<base>-windows`.
