#!/usr/bin/env bash

# ==============================================================================
#
# Stage 13: Cleanup
#
# This script handles the cleanup of any temporary files, directories, or
# environment variables that were created during the installation process.
# This ensures that the system is left in a clean and tidy state.
#
# Implementation Strategy:
#
# This script is responsible for ensuring that the installer leaves no trace,
# other than the intended changes. It will:
#
# 1.  **Stop Background Processes:** Any long-running background processes
#     started by the installer (e.g., `caffeinate`) will be stopped here.
# 2.  **Remove Temporary Files:** A dedicated temporary directory (e.g.,
#     `/tmp/dotfiles-install`) should be used throughout the installer, and
#     this script will be responsible for removing it.
# 3.  **Unset Sensitive Variables:** Any sensitive variables (e.g., tokens,
#     passwords) that were exported should be explicitly unset here.
#
# ==============================================================================

#
# The main logic for the cleanup stage.
#
main() {
  msg_info "Stage 13: Cleanup"

  # --- Stop Background Processes ----------------------------------------------
  # Check if the caffeinate process was started and, if so, stop it.
  if [ -n "${caffeinate_pid:-}" ]; then
    msg_info "Stopping the caffeinate process (PID: $caffeinate_pid)..."
    if kill "$caffeinate_pid"; then
      msg_success "Caffeinate process stopped."
    else
      msg_warning "Failed to stop the caffeinate process. It may have already exited."
    fi
  fi

  # --- Remove Temporary Files -------------------------------------------------
  # TODO: Add logic to remove any temporary directories or files created by
  # the installer.
  # Example:
  # if [ -d "/tmp/dotfiles-install" ]; then
  #   rm -rf "/tmp/dotfiles-install"
  #   msg_success "Removed temporary installation directory."
  # fi

  # --- Unset Sensitive Variables ----------------------------------------------
  # TODO: Add logic to unset any sensitive environment variables.
  # Example:
  # unset MY_API_TOKEN

  msg_success "Cleanup stage complete."
}

#
# Execute the main function.
#
main
