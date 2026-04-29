# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Operating Mode

Codex drives. The human's role is to support — clarifying intent, reviewing decisions,
and providing context Codex doesn't have. Not the other way around.

Operational implications:

- Codex acts on obvious improvements without waiting for permission
- Honest pushback is preferred over polite compliance
- When evaluating a change, the first question is: does this reduce friction or move the work forward?

## Domain

This is a personal dotfiles repo for a macOS/Windows/Linux developer (Volodymyr).
The goal is a reproducible, keyboard-first environment with a clear mental model of layers.

Layer model (in order): Hardware (Glove80+TailorKey) → Config management (Stow) → Shell (zsh+OMZ) → Terminal (Alacritty+tmux) → Window management (native macOS / GlazeWM on Windows) → Editor (Zed+vim mode / WebStorm+IdeaVim) → Apps

Key patterns:
- Secrets live in `~/.secrets` (gitignored), sourced from `.zshrc`
- Machine-managed tool configs (GCM, git-lfs) go in `~/.gitconfig.local` via `[include]`
- Platform-specific configs use `-macos`/`-linux`/`-windows` package suffix
- `scripts/generate-layers.sh` produces `LAYERS.md` — run on every commit via pre-commit hook
- `alacritty migrate` replaces symlinks with real files — must re-stow after running it
- Optional features gate their ansible role via `when: ansible_env.SECRET_NAME is defined` — NextDNS uses this pattern (`NEXTDNS_PROFILE`); role skipped silently if the env var is absent, bootstrap still passes

## North Star

Two non-negotiables.

**Cross-platform: macOS, Linux, Windows (WSL2).**

- Never hardcode OS-specific paths silently (e.g. `/Applications/`, `C:\Users\`, `~/Library/`)
- If something is OS-specific, it must be explicitly conditional and handled for all three platforms
- When adding a new tool, script, or check — ask: does this work on all three? If not, make it explicit

**`./bootstrap.sh` is the single provisioning entry point.**

- Any new capability must plug into the Ansible playbook (role or task) so a fresh machine gets it from one command
- Standalone scripts (`scripts/*.sh`) are valid only as thin convenience wrappers around canonical roles — never as the sole install path
- "Run the bootstrap, get a working machine" is the contract. Anything requiring separate manual steps to be reproduced is a gap to close
- When designing a change, prefer the option that preserves this property, even if it's slightly more work upfront

## What This Is

Personal dotfiles repository managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level directory is a stow package containing config files mirroring their home-directory structure. Supports **macOS**, **Linux**, **WSL2**, and **Windows**.

## Bootstrap

Single entry point for all platforms:
```bash
./bootstrap.sh                          # install (default)
./bootstrap.sh doctor                   # read-only verify; exits non-zero on drift
./bootstrap.sh install --non-interactive  # CI / scripted; no sudo prompt
```
On macOS/Linux/WSL2 it installs Homebrew, Ansible, Stow, runs the playbook, and stows packages. On Windows (Git Bash) it delegates to `bootstrap-windows.ps1` for winget installs + config symlinks, then offers to bootstrap WSL2 automatically.

`bootstrap.sh` sources `~/.secrets` automatically before running the playbook, so role gates like `NEXTDNS_PROFILE is defined` resolve without the caller having to source first.

### Doctor mode

`./bootstrap.sh doctor` runs read-only checks: prerequisite tools on PATH (shell), then `ansible-playbook --tags verify` over the playbook. Verify tasks live alongside their role's install tasks and assert end-state — symlinks resolve into the repo, hook scripts installed and executable, NextDNS resolver answering with `status=ok`, etc. Verify tasks must be tagged `verify`, must not mutate, and must set `changed_when: false`.

## Manual Deploying

Symlink a package to the home directory (macOS/Linux):
```bash
stow <package> -t ~/
```
The `.stowrc` file configures stow to ignore `.git/` by default.

## Provisioning Dependencies

`bootstrap.sh` drives everything — installs Homebrew + Ansible, then runs the playbook:
```bash
ansible-playbook -i inventory.ini site.yml
```
Roles: `packages` (brew bundle from Brewfile), `stow` (explicit package list, OS-conditional), `hooks` (git hooks from `scripts/hooks/`).

## CI

Two workflows under `.github/workflows/`:

- **`lint.yml`** — every PR + push to main. Runs `shellcheck`, `yamllint`, and `ansible-lint --offline`. Fast (~1 min). `ansible-lint` is configured (`.ansible-lint`) to enforce the `basic` profile with a documented `skip_list` for patterns deferred to a focused refactor.
- **`bootstrap.yml`** — `./bootstrap.sh install --non-interactive` followed by `./bootstrap.sh doctor`. Ubuntu runs on every PR + push. macOS runs only on the weekly cron (Mondays 06:00 UTC) and on `workflow_dispatch`, since macOS runners are ~10× the billing rate.

`NEXTDNS_PROFILE` is unset in CI, so the NextDNS role auto-skips via its site.yml gate. Casks in the Brewfile are macOS-only; Linux runs of `brew bundle` skip them silently.

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
