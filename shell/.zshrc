# ── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="macovsky"
DISABLE_AUTO_TITLE="true"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"

# ── Editor ───────────────────────────────────────────────────────────────────
if command -v zed &>/dev/null; then
    export EDITOR="zed"
elif command -v nvim &>/dev/null; then
    export EDITOR="nvim"
fi

# ── PATH — common ─────────────────────────────────────────────────────────────
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# ── PATH — macOS specific ─────────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
    # Homebrew postgresql
    [[ -d "/opt/homebrew/opt/postgresql@17/bin" ]] && export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
    # WebStorm CLI
    [[ -d "/Applications/WebStorm.app/Contents/MacOS" ]] && export PATH="/Applications/WebStorm.app/Contents/MacOS:$PATH"
    # Windsurf
    [[ -d "$HOME/.codeium/windsurf/bin" ]] && export PATH="$HOME/.codeium/windsurf/bin:$PATH"
fi

# ── Node — fnm ────────────────────────────────────────────────────────────────
if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd --shell zsh)"
fi

# ── pnpm ─────────────────────────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# ── bun ───────────────────────────────────────────────────────────────────────
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ── Terminal ──────────────────────────────────────────────────────────────────
# Set TERM_PROGRAM for terminals that don't set it natively (e.g. Alacritty)
[[ -z "$TERM_PROGRAM" && "$TERM" == "alacritty" ]] && export TERM_PROGRAM="Alacritty"

# ── Secrets ───────────────────────────────────────────────────────────────────
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

# ── Clipboard ─────────────────────────────────────────────────────────────────
# OSC 52: pipe stdout to local clipboard (works over SSH + tmux)
copy() { printf '\033]52;c;%s\007' "$(cat -- "${@:--}" | base64)"; }

# ── Aliases — common ──────────────────────────────────────────────────────────
alias so="source ~/.zshrc"
alias pn=pnpm
alias nest="pnpx @nestjs/cli@latest"
alias cc="claude --allow-dangerously-skip-permissions"

# editor shortcuts
alias zsf="cd ~; ${EDITOR:-nvim} .zshrc"
alias vif="cd ~/.config/nvim; ${EDITOR:-nvim} ."
alias tmf="cd ~/.config/tmux; ${EDITOR:-nvim} ."
alias alf="cd ~/.config/alacritty; ${EDITOR:-nvim} ."

# ── Aliases — macOS specific ──────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
    alias fonts="ls /Library/Fonts /System/Library/Fonts ~/Library/Fonts"
    alias icd="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
fi
