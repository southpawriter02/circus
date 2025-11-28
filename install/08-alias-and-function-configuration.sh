#!/usr/bin/env bash

# ==============================================================================
#
# Stage 8: Alias and Function Configuration
#
# This script sources any shell files found in the `lib/installer_source`
# directory. This provides a modular way to add aliases, functions, or
# installer-specific environment variables to the current installation session.
#
# UNUSED CODE NOTICE:
#   This script is NOT currently referenced in install.sh's INSTALL_STAGES array.
#   Note: The only file in lib/installer_source/ is examples.sh which contains
#   commented-out example code and no active functionality.
#   
#   RECOMMENDATION: Only add to INSTALL_STAGES when lib/installer_source/
#   contains actual aliases/functions needed during installation. Currently
#   can be safely ignored.
#
# ==============================================================================

#
# The main logic for the alias and function configuration stage.
#
main() {
  msg_info "Stage 8: Alias and Function Configuration"

  local source_dir="$DOTFILES_ROOT/lib/installer_source"

  # Check if the source directory exists. If not, there's nothing to do.
  if [ ! -d "$source_dir" ]; then
    msg_info "Installer source directory not found. Skipping."
    return 0
  fi

  # Check if there are any .sh files to source.
  local sh_files
  sh_files=$(find "$source_dir" -name "*.sh" 2>/dev/null)
  if [ -z "$sh_files" ]; then
    msg_info "No shell files found to source in '$source_dir'. Skipping."
    return 0
  fi

  msg_info "Sourcing shell files from '$source_dir'..."

  # Loop through all .sh files in the directory and source them.
  for file in $sh_files; do
    if [ -f "$file" ]; then
      msg_info "Sourcing '$file'..."
      # shellcheck source=/dev/null
      source "$file"
    fi
  done

  msg_success "Alias and function configuration complete."
}

#
# Execute the main function.
#
main
