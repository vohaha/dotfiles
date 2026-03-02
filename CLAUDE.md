# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
| `shell`             | `~/`                   | `.bashrc` and `.bash_profile`            |
| `tmux`              | `~/`                   | tmux config                              |
| `zed`               | `~/.config/zed/`       | Zed editor settings and keybindings      |

## Platform-Specific Packages

Directories ending in `-macos`, `-linux`, or `-windows` contain platform-specific overrides. On macOS/Linux, `bootstrap.sh` auto-stows the matching suffix. On Windows, `bootstrap-windows.ps1` symlinks files to their Windows paths (`%APPDATA%\alacritty\`, `%APPDATA%\Zed\`, `%USERPROFILE%`).

The Alacritty base config uses `import = ["~/.config/alacritty/local.toml"]` to pull in the platform-specific `local.toml` (window decorations and shell program).

## Neovim Setup

Built on [LazyVim](https://www.lazyvim.org/) with [lazy.nvim](https://github.com/folke/lazy.nvim) as the plugin manager. Custom plugin overrides go in `nvim/.config/nvim/lua/plugins/`. Config entry point is `nvim/.config/nvim/init.lua` -> `lua/config/lazy.lua`.

## Conventions

- Each package directory mirrors the target filesystem layout relative to `~/`. For example, `alacritty/.config/alacritty/alacritty.toml` becomes `~/.config/alacritty/alacritty.toml`.
- Neovim plugins use Lua and follow LazyVim conventions (return a table from each file in `lua/plugins/`).
- Zed config uses hard tabs (except YAML which uses spaces).
- Platform-specific packages use the naming convention `<base>-macos`, `<base>-linux`, or `<base>-windows`.
