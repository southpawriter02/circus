#!/usr/bin/env bash

# ==============================================================================
#
# Stage 18: Privacy and Security
#
# This script orchestrates the application of security and privacy settings by
# sourcing all shell scripts found in the top-level `security/` directory.
#
# ==============================================================================

#
# The main logic for the privacy and security stage.
#
main() {
  msg_info "Stage 18: Privacy and Security"

  local security_dir="$DOTFILES_ROOT/security"

  # Check if the security configuration directory exists.
  if [ ! -d "$security_dir" ]; then
    msg_info "Security configuration directory not found. Skipping."
    return 0
  fi

  # Check if there are any .sh files to source.
  local sh_files
  sh_files=$(find "$security_dir" -name "*.sh" 2>/dev/null)
  if [ -z "$sh_files" ]; then
    msg_info "No security configuration scripts found in '$security_dir'. Skipping."
    return 0
  fi

  msg_info "Applying security configurations from '$security_dir'..."

  # Loop through all .sh files in the directory and source them.
  for file in $sh_files; do
    if [ -f "$file" ]; then
      msg_info "Running configuration script: '$file'..."
      # shellcheck source=/dev/null
      source "$file"
    fi
  done

  msg_success "Privacy and security stage complete."
}

#
# Execute the main function.
#
main
