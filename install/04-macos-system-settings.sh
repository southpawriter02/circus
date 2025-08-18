#!/usr/bin/env bash

# ==============================================================================
#
# Stage 04: macOS System Settings
#
# This script executes all the modular macOS configuration scripts located
# in the `system/macos/` directory.
#
# ==============================================================================

main() {
  msg_info "Stage 04: Applying macOS System Settings..."

  local system_config_dir="$DOTFILES_ROOT/system/macos"

  if [ ! -d "$system_config_dir" ]; then
    msg_warning "System configuration directory not found: $system_config_dir"
    return 0
  fi

  # Find and execute all .sh files in the system configuration directory.
  for config_script in "$system_config_dir"/*.sh; do
    if [ -f "$config_script" ]; then
      msg_info "  -> Running $(basename "$config_script")"
      # Source the script to run it in the current shell context
      # This makes sure it has access to all our helper functions.
      source "$config_script"
    fi
  done

  # Restart affected applications to apply all the changes at once.
  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Skipping restart of Finder and Dock."
  else
    msg_info "Restarting Finder and Dock to apply settings..."
    killall Finder
    killall Dock
  fi

  msg_success "macOS system settings stage complete."
}

main
