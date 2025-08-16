#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zshrc
#
# DESCRIPTION:  This is the primary configuration file for interactive Zsh
#               shells. It is sourced after .zshenv and is the main entry
#               point for configuring the interactive shell environment.
#
# ==============================================================================

#
# Source all modular configuration files.
# The `if [ -f ... ]` check ensures that the script doesn't fail if a file
# is missing.
#

# Source the generic, POSIX-compliant aliases and functions.
[ -f "$HOME/.shell_aliases" ] && . "$HOME/.shell_aliases"
[ -f "$HOME/.shell_functions" ] && . "$HOME/.shell_functions"

# Source Zsh-specific options.
[ -f "$HOME/.zoptions" ] && . "$HOME/.zoptions"

# Source the Zsh prompt configuration.
[ -f "$HOME/.zprompt" ] && . "$HOME/.zprompt"

# TODO: Add sourcing for Zsh completion setup.

# Source local, user-specific configurations last, to allow for overrides.
[ -f "$HOME/.zsh.local" ] && . "$HOME/.zsh.local"
