#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source "$XDG_CONFIG_HOME/bash/utils"
source "$XDG_CONFIG_HOME/bash/base"
source "$XDG_CONFIG_HOME/bash/git"
