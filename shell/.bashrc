#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# UTILS

_have() { type "$1" &>/dev/null; }
_source_if() { [[ -r "$1" ]] && source "$1"; }

# read and set the env file
envx() {
	local envfile="${1:-"$HOME/.env"}"
	[[ ! -e "$envfile" ]] && echo "$envfile not found" && return 1
	while IFS= read -r line; do
		name=${line%%=*}
		value=${line#*=}
		[[ -z "${name}" || $name =~ ^# ]] && continue
		export "$name"="$value"
	done <"$envfile"
} && export -f envx

# BASE

export USER="${USER:-$(whoami)}"
export VISUAL=nvim
export EDITOR=nvim
export BROWSER=arc

# common folders
export REPOS="$HOME/Repos"
export SHARED="$HOME/Documents"

mkdir -p $REPOS
mkdir -p $SHARED

alias repos="cd $REPOS"
alias shared="cd $SHARED"

# secondbrain
export SB="$SHARED/SecondBrain"

mkdir -p $SB

alias sb="cd $SB"

# HISTORY
export HISTFILE="$HOME/.histfile"
export HISTSIZE=25000
export SAVEHIST=25000
export HISTCONTROL=ignorespace

# ALIASES
_have nvim && alias vim=nvim
alias ..="cd .."
alias c="clear"
alias ls='ls --color=auto'
alias ll='ls -la'
alias chmox='chmod +x'
alias nvimrc='nvim ~/.config/nvim/'
_have bat && alias cat=bat

# enables the vi editing mode for the CLI
#set -o vi

# Enable dynamic updating of terminal window size variables $COLUMNS and $LINES.
shopt -s checkwinsize
# Allow the expansion of aliases, making them effective in scripts or interactive sessions.
shopt -s expand_aliases
# Enable recursive matching of all files and directories using the ** pattern.
#shopt -s globstar
# Include hidden files (those starting with a dot) when using * in filename expansion.
shopt -s dotglob
# Append rather than overwrite the history file, preserving command history across sessions.
shopt -s histappend

# GIT

export REPOS="$HOME/Repos"
export GHREPOS="$REPOS/github.com/"
export GHUSER="vohaha"
export VHREPOS="$GHREPOS/$GHUSER"

# my repos
mkdir -p $VHREPOS

alias vh="cd $VHREPOS"
alias dot="cd $VHREPOS/dotfiles"

# promt
PROMPT_MAX=95
PROMPT_LONG=20
PROMPT_AT=@

__ps1() {
	local P='$' dir="${PWD##*/}" B countme short long double \
		r='\[\e[31m\]' g='\[\e[30m\]' h='\[\e[34m\]' \
		u='\[\e[33m\]' p='\[\e[34m\]' w='\[\e[35m\]' \
		b='\[\e[36m\]' x='\[\e[0m\]'

	[[ $EUID == 0 ]] && P='#' && u=$r && p=$u # root
	[[ $PWD = / ]] && dir=/
	[[ $PWD = "$HOME" ]] && dir='~'

	B=$(git branch --show-current 2>/dev/null)
	[[ $dir = "$B" ]] && B=.
	countme="$USER$PROMPT_AT$(hostname):$dir($B)\$ "

	[[ $B == master || $B == main ]] && b="$r"
	[[ -n "$B" ]] && B="$g($b$B$g)"

	short="$u\u$g$PROMPT_AT$h\h$g:$w$dir$B$p$P$x "
	long="$g╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir$B\n$g╚ $p$P$x "
	double="$g╔ $u\u$g$PROMPT_AT$h\h$g:$w$dir\n$g║ $B\n$g╚ $p$P$x "

	if ((${#countme} > PROMPT_MAX)); then
		PS1="$double"
	elif ((${#countme} > PROMPT_LONG)); then
		PS1="$long"
	else
		PS1="$short"
	fi
}

PROMPT_COMMAND="__ps1"

_source_if "$XDG_CONFIG_HOME/bash/git-prompt"
_source_if "$XDG_CONFIG_HOME/bash/git-completion"

# OTHER STUFF
