#!/usr/bin/env bash

# ==============================================================================
#
# Stage 4: Introduction and User Interaction
#
# This script provides a user-friendly introduction to the installation
# process. It summarizes the planned actions, highlights any potentially
# destructive operations, and prompts the user for confirmation before
# proceeding. It may also allow the user to select optional features.
#
# Its responsibilities include:
#
#   4.1. Displaying an introduction and summary of changes.
#   4.2. Prompting the user for confirmation to proceed.
#   4.3. Allowing the user to select optional installation components.
#
# ==============================================================================

#
# Asks the user a yes/no question.
#
# @param string $1 The question to ask the user.
# @param string $2 The default response (optional). Should be 'Y' or 'N'.
#
# @return 0 for "yes", 1 for "no".
#
ask() {
  # http://djm.me/ask
  while true; do
    if [ "${2:-}" = "Y" ]; then
      prompt="Y/n"
      default=Y
    elif [ "${2:-}" = "N" ]; then
      prompt="y/N"
      default=N
    else
      prompt="y/n"
      default=
    fi

    # Ask the question
    read -p "$1 [$prompt] " REPLY

    # Default?
    if [ -z "$REPLY" ]; then
      REPLY=$default
    fi

    # Check if the reply is valid
    case "$REPLY" in
      Y*|y*) return 0 ;;
      N*|n*) return 1 ;;
    esac
  done
}

#
# The main logic for the introduction and user interaction stage.
#
main() {
  msg_info "Stage 4: Introduction and User Interaction"

  # --- Display Introduction ---------------------------------------------------
  # Use a "heredoc" to display a multi-line welcome message.
  cat << EOF

[1;34mWelcome to the Dotfiles Flying Circus! [0m

This script will automate the setup of your macOS device by:

  - Installing essential command-line tools and applications.
  - Configuring your system and application settings.
  - Deploying a comprehensive set of dotfiles to your home directory.

[1;33mWarning:[0m This script will make changes to your system. It is designed
to be idempotent, but it is always recommended to back up your data before
proceeding.

EOF

  # --- Prompt for Confirmation ----------------------------------------------
  if ask "Do you want to proceed with the installation?" N; then
    msg_success "Installation confirmed. Let's begin!"
  else
    msg_error "Installation aborted by user."
    exit 1
  fi
}

#
# Execute the main function.
#
main
