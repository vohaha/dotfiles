#!/bin/bash

if [[ "$OSTYPE" == "darwin"* ]]; then
  # that was brew ask to do after the instalation 
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [ -r ~/.bashrc ]; then
  source ~/.bashrc
fi
