# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/) and provisioned via [Ansible](https://www.ansible.com/) + [Homebrew](https://brew.sh/). Works on **macOS**, **Linux**, **WSL2**, and **Windows**.

## Quick Start

```bash
git clone <repo-url> ~/dotfiles   # on Windows: clone anywhere and open Git Bash
cd ~/dotfiles
./bootstrap.sh
```

The script detects your platform and does the right thing:

| Platform       | What happens                                                        |
|----------------|---------------------------------------------------------------------|
| macOS          | Installs Homebrew, Ansible, Stow; runs playbook; stows packages    |
| Linux / WSL2   | Same as macOS (uses Linuxbrew)                                     |
| Windows (Git Bash) | Runs PowerShell to install apps via winget + symlink configs, then offers to bootstrap WSL2 automatically |

## Manual Usage

Symlink a single package (macOS/Linux):
```bash
stow <package> -t ~/
```

Run the Ansible playbook alone:
```bash
ansible-playbook -i inventory.ini localhost.yaml
```

## Packages

| Directory           | Target                 | Description                              |
|---------------------|------------------------|------------------------------------------|
| `alacritty`         | `~/.config/alacritty/` | Alacritty terminal (shared config)       |
| `alacritty-linux`   | `~/.config/alacritty/` | Linux overrides (`local.toml`)           |
| `alacritty-macos`   | `~/.config/alacritty/` | macOS overrides (`local.toml`)           |
| `alacritty-windows` | *(symlinked by PS1)*   | Windows overrides — WSL shell launcher   |
| `git`               | `~/`                   | Git user config and global gitignore     |
| `nvim`              | `~/.config/nvim/`      | Neovim config (LazyVim framework)        |
| `shell`             | `~/`                   | `.bashrc` and `.bash_profile`            |
| `tmux`              | `~/`                   | tmux config                              |
| `zed`               | `~/.config/zed/`       | Zed editor settings and keybindings      |

## Platform-Specific Packages

Directories ending in `-macos`, `-linux`, or `-windows` contain platform-specific overrides. On macOS/Linux, `bootstrap.sh` auto-stows the matching suffix. On Windows, `bootstrap-windows.ps1` symlinks the relevant files to the correct Windows paths (`%APPDATA%`, `%USERPROFILE%`).
