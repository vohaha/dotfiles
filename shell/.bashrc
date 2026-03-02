# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------
case "$(uname -s)" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
esac

# ---------------------------------------------------------------------------
# Homebrew (before interactive guard so PATH is available to all login shells)
# ---------------------------------------------------------------------------
if [[ "$PLATFORM" == "macos" ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  if [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# If not running interactively, don't do anything else
[[ $- != *i* ]] && return

# ---------------------------------------------------------------------------
# nvm
# ---------------------------------------------------------------------------
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

# ---------------------------------------------------------------------------
# fzf
# ---------------------------------------------------------------------------
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias chmox='chmod +x'

# ---------------------------------------------------------------------------
# Machine-local overrides (not tracked)
# ---------------------------------------------------------------------------
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
