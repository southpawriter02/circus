#!/bin/sh

# ==============================================================================
#
# FILE:         .profile
#
# DESCRIPTION:  This is the primary configuration file for login shells. It is
#               the standard entry point for setting up a user's environment
#               and is read by most POSIX-compliant shells.
#
#               This script orchestrates the loading of all other modular
#               shell configuration files.
#
# ==============================================================================

#
# Source all modular configuration files.
# The `[ -f ... ]` check ensures that the script doesn't fail if a file
# is missing.
#

# Source environment variables first, as other scripts may depend on them.
[ -f "$HOME/.shenv" ] && . "$HOME/.shenv"

# Source path configurations.
[ -f "$HOME/.shell_paths" ] && . "$HOME/.shell_paths"

# Source aliases and functions.
[ -f "$HOME/.shell_aliases" ] && . "$HOME/.shell_aliases"
[ -f "$HOME/.shell_functions" ] && . "$HOME/.shell_functions"

# Source local, user-specific configurations last, to allow for overrides.
[ -f "$HOME/.sh.local" ] && . "$HOME/.sh.local"
