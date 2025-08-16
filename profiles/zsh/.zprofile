#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zprofile
#
# DESCRIPTION:  This file is sourced for login shells, after .zshenv. It is
#               the Zsh equivalent of the standard .profile and is the ideal
#               place to run commands that should only be executed at login.
#
# ==============================================================================

#
# Source the generic, POSIX-compliant profile.
# This loads the baseline aliases, functions, and other settings.
#
if [ -f "$HOME/.profile" ]; then
  . "$HOME/.profile"
fi
