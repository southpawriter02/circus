#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         .bash_aliases
#
# DESCRIPTION:  This file is dedicated to defining shell aliases. Keeping them
#               in a separate file makes the configuration easier to manage.
#
# ==============================================================================

#
# General Aliases
#
alias ls='ls -G'          # Enable colorized output for ls
alias ll='ls -la'         # Long listing format
alias grep='grep --color=auto' # Colorize grep output

#
# Navigation
#
alias ..='cd ..'
alias ...='cd ../..'
