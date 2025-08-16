#!/usr/bin/env bash

# ==============================================================================
#
# Stage 11: Defaults and Additional Configuration
#
# This script applies system-level and application-specific default settings.
# It also handles the setup of other system services and configurations that
# fall outside the scope of standard dotfiles.
#
# Implementation Strategy:
#
# Hardcoding `defaults write` commands and other setup logic directly in the
# installer is inflexible. The best practice is to group these commands into
# dedicated, topic-specific scripts (e.g., `system/macos-defaults.sh`,
# `system/app-defaults.sh`).
#
# This installer's role is to execute those dedicated scripts at the appropriate
# time. This keeps the main installation flow clean and separates the "what"
# (the installation process) from the "how" (the specific settings).
#
# ==============================================================================

#
# The main logic for the defaults and additional configuration stage.
#
main() {
  msg_info "Stage 11: Defaults and Additional Configuration"
  msg_info "This stage is a placeholder. Dedicated configuration scripts will be executed from here."

  # --- Caffeinate Machine -----------------------------------------------------
  # Prevent the machine from sleeping during the rest of the installation.
  msg_info "Preventing the machine from sleeping..."
  caffeinate -d -i -m -s &
  caffeinate_pid=$!
  msg_success "Caffeinate process started with PID: $caffeinate_pid"

  # --- Execute Dedicated Configuration Scripts ------------------------------
  # TODO: Add logic to execute the dedicated configuration scripts.
  # Example:
  # source "$DOTFILES_DIR/system/macos-defaults.sh"
  # source "$DOTFILES_DIR/system/app-defaults.sh"
  # source "$DOTFILES_DIR/system/cron-jobs.sh"
  # source "$DOTFILES_DIR/system/outset-scripts.sh"

  # --- Stop Caffeinate --------------------------------------------------------
  # Stop the caffeinate process once the configuration is complete.
  msg_info "Allowing the machine to sleep again..."
  kill "$caffeinate_pid"
  msg_success "Caffeinate process stopped."

  msg_success "Defaults and additional configuration stage complete."
}

#
# Execute the main function.
#
main
