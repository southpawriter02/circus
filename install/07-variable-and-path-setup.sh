#!/usr/bin/env bash

# ==============================================================================
#
# Stage 7: Variable and Path Setup
#
# This script configures the environment for the *currently running* installer
# session. Its primary responsibility is to ensure that any tools that were
# just installed (like Homebrew) are immediately available on the PATH.
#
# ==============================================================================

#
# The main logic for the variable and path setup stage.
#
main() {
  msg_info "Stage 7: Variable and Path Setup"

  # --- Homebrew Environment Setup ---------------------------------------------
  # The preflight check in Stage 3 set the `SYSTEM_HAS_HOMEBREW` variable.
  # If Homebrew was NOT installed before this script was run, it means Stage 4
  # just installed it. Therefore, we need to add it to the current session's PATH.
  if [ "$SYSTEM_HAS_HOMEBREW" = false ]; then
    msg_info "Configuring shell environment for newly installed Homebrew..."

    # The `brew shellenv` command is the official way to get the necessary
    # environment variable exports to make Homebrew work.
    local brew_shellenv_command="$(/opt/homebrew/bin/brew shellenv)"

    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would configure the shell environment for Homebrew by running:"
      msg_info "[Dry Run] eval "$brew_shellenv_command""
    else
      # We use `eval` to execute the output of the `brew shellenv` command.
      # This will export the correct PATH and other variables for this session.
      eval "$brew_shellenv_command"
      msg_success "Homebrew shell environment configured for the current session."
    fi
  else
    msg_info "Skipping Homebrew environment setup (Homebrew was already present)."
  fi

  msg_success "Variable and path setup stage complete."
}

#
# Execute the main function.
#
main
