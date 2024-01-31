#!/bin/bash

brewPath=/opt/homebrew/bin/brew

# Set up Homebrew environment
eval "$($brewPath shellenv)"

# Check if .bashrc exists, and source if it does
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi
