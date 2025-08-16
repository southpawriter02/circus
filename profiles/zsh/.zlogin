#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zlogin
#
# DESCRIPTION:  This file is sourced for login shells, after .zshrc. It is
#               useful for commands that should be executed only once at the
#               beginning of a session.
#
# ==============================================================================

#
# Source the helper library for colored messages and other utilities.
# The $DOTFILES_DIR variable is set in .zshenv.
#
if [[ -f "$DOTFILES_DIR/lib/helpers.sh" ]]; then
  # shellcheck source=/dev/null
  source "$DOTFILES_DIR/lib/helpers.sh"
fi

#
# Display a welcome message when a new shell is opened.
#
if command -v msg_info &> /dev/null; then
  msg_info "Welcome to the Dotfiles Flying Circus! Your shell is ready."
else
  echo "Welcome to the Dotfiles Flying Circus!"
fi
