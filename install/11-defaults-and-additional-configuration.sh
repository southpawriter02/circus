#!/usr/bin/env bash

# ==============================================================================
#
# Stage 11: Defaults and Additional Configuration
#
# This script orchestrates the application of macOS system and application
# defaults by sourcing all shell scripts found in the top-level `defaults/`
# directory. This provides a modular way to manage user preferences.
#
# ==============================================================================

#
# The main logic for the defaults and additional configuration stage.
#
main() {
  msg_info "Stage 11: Defaults and Additional Configuration"

  local defaults_dir="$DOTFILES_DIR/defaults"

  # Check if the defaults configuration directory exists.
  if [ ! -d "$defaults_dir" ]; then
    msg_info "Defaults configuration directory not found. Skipping."
    return 0
  fi

  # Check if there are any .sh files to source.
  local sh_files
  sh_files=$(find "$defaults_dir" -name "*.sh" 2>/dev/null)
  if [ -z "$sh_files" ]; then
    msg_info "No defaults configuration scripts found in '$defaults_dir'. Skipping."
    return 0
  fi

  msg_info "Applying macOS defaults from '$defaults_dir'..."

  # Loop through all .sh files in the directory and source them.
  for file in $sh_files; do
    if [ -f "$file" ]; then
      msg_info "Running configuration script: '$file'..."
      # shellcheck source=/dev/null
      source "$file"
    fi
  done

  msg_success "Defaults and additional configuration complete."
}

#
# Execute the main function.
#
main
