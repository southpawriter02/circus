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

# ==============================================================================
# Homebrew PATH
#
# Ensure Homebrew is in PATH for ALL shell invocations, including scripts.
# This is critical for scripts that need to find Homebrew-installed binaries.
# ==============================================================================

if [[ -f "/opt/homebrew/bin/brew" ]]; then
    # Apple Silicon (ARM) Macs
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [[ -f "/usr/local/bin/brew" ]]; then
    # Intel Macs
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

# ==============================================================================
# Circus Directory
#
# The root directory of the dotfiles repository. Used by fc commands and
# other scripts to locate configuration files.
# ==============================================================================

export CIRCUS_DIR="${CIRCUS_DIR:-$HOME/.dotfiles}"
