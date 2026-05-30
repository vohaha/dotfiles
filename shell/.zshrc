# ── Oh My Zsh ────────────────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # disabled — starship handles the prompt
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

# ── SSH agent — Bitwarden ─────────────────────────────────────────────────────
bitwarden_ssh_agent() {
    [[ -z "${SSH_CONNECTION:-}" ]] || return

    local sock=""
    if [[ -n "${BITWARDEN_SSH_AUTH_SOCK:-}" ]]; then
        sock="$BITWARDEN_SSH_AUTH_SOCK"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        local candidate
        for candidate in \
            "$HOME/.bitwarden-ssh-agent.sock" \
            "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
        do
            [[ -S "$candidate" ]] && sock="$candidate" && break
        done
        [[ -z "$sock" ]] && sock="$HOME/.bitwarden-ssh-agent.sock"
    else
        local candidate
        for candidate in \
            "$HOME/.bitwarden-ssh-agent.sock" \
            "$HOME/snap/bitwarden/current/.bitwarden-ssh-agent.sock" \
            "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
        do
            [[ -S "$candidate" ]] && sock="$candidate" && break
        done
        [[ -z "$sock" ]] && sock="$HOME/.bitwarden-ssh-agent.sock"
    fi

    [[ -n "$sock" ]] && export SSH_AUTH_SOCK="$sock"
}
bitwarden_ssh_agent
unset -f bitwarden_ssh_agent

ghostty_fuzzy_cd_on_start() {
    [[ -o interactive ]] || return
    [[ -t 0 && -t 1 ]] || return
    [[ "${TERM_PROGRAM:l}" == "ghostty" ]] || return
    [[ -z "${GHOSTTY_FUZZY_CD_DONE:-}" ]] || return
    [[ -z "${GHOSTTY_FUZZY_CD_DISABLE:-}" ]] || return
    command -v fzf &>/dev/null || return

    export GHOSTTY_FUZZY_CD_DONE=1

    local dir
    if command -v fd &>/dev/null; then
        dir="$(
            fd . "$HOME" \
                --type d \
                --hidden \
                --follow \
                --exclude .cache \
                --exclude .git \
                --exclude .Trash \
                --exclude Library \
                --exclude node_modules \
                2>/dev/null |
                fzf --prompt="cd> " --height=40% --reverse --select-1 --exit-0
        )"
    else
        dir="$(
            find "$HOME" \
                \( -name .cache -o -name .git -o -name .Trash -o -name Library -o -name node_modules \) -prune \
                -o -type d -print 2>/dev/null |
                fzf --prompt="cd> " --height=40% --reverse --select-1 --exit-0
        )"
    fi

    [[ -n "$dir" && -d "$dir" ]] && cd "$dir"
}
ghostty_fuzzy_cd_on_start
unset -f ghostty_fuzzy_cd_on_start

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
alias stf="cd ~/.config; ${EDITOR:-nvim} starship.toml"

# ── Aliases — macOS specific ──────────────────────────────────────────────────
if [[ "$(uname -s)" == "Darwin" ]]; then
    alias fonts="ls /Library/Fonts /System/Library/Fonts ~/Library/Fonts"
    alias icd="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
fi

# ── Starship ──────────────────────────────────────────────────────────────────
command -v starship &>/dev/null && eval "$(starship init zsh)"
