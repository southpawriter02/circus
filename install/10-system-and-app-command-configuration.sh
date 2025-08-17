#!/usr/bin/env bash

# ==============================================================================
#
# Stage 10: System and App Command Configuration
#
# This script orchestrates the application of low-level system settings by
# sourcing all shell scripts found in the top-level `system/` directory.
#
# ==============================================================================

#
# The main logic for the system and app command configuration stage.
#
main() {
  msg_info "Stage 10: System and App Command Configuration"

  local system_config_dir="$DOTFILES_DIR/system"

  # Check if the system configuration directory exists.
  if [ ! -d "$system_config_dir" ]; then
    msg_info "System configuration directory not found. Skipping."
    return 0
  fi

  # Check if there are any .sh files to source.
  local sh_files
  sh_files=$(find "$system_config_dir" -name "*.sh" 2>/dev/null)
  if [ -z "$sh_files" ]; then
    msg_info "No system configuration scripts found in '$system_config_dir'. Skipping."
    return 0
  fi

  msg_info "Applying system configurations from '$system_config_dir'..."

  # Loop through all .sh files in the directory and source them.
  for file in $sh_files; do
    if [ -f "$file" ]; then
      msg_info "Running configuration script: '$file'..."
      # shellcheck source=/dev/null
      source "$file"
    fi
  done

  msg_success "System and app command configuration complete."
}

#
# Execute the main function.
#
main
