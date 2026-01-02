#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zshenv
#
# DESCRIPTION:  This file is sourced on all invocations of the shell, unless
#               the -f option is set. It should contain commands to set the
#               command search path, plus other important environment variables.
#               It should not contain commands that produce output or assume
#               the shell is attached to a tty.
#
# ==============================================================================

#
# Source the generic, POSIX-compliant environment variable setup.
# This ensures a consistent baseline environment across all shells.
#
if [ -f "$HOME/.shenv" ]; then
  . "$HOME/.shenv"
fi

#
# Source the generic, POSIX-compliant path setup.
#
if [ -f "$HOME/.shell_paths" ]; then
  . "$HOME/.shell_paths"
fi
