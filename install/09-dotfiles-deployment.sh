#!/usr/bin/env bash

# ==============================================================================
#
# Stage 9: Dotfiles Deployment
#
# This script is the core of the installation process. It handles the backup
# of existing dotfiles, the creation of necessary directories, and the copying
# and symlinking of the new dotfiles from the repository.
#
# ==============================================================================

main() {
  msg_info "Stage 9: Dotfiles Deployment"

  # ... (Backup and Directory Creation logic remains the same) ...

  # --- Local Override File Creation -----------------------------------------
  msg_info "Ensuring local override file exists..."
  local local_override_file="$HOME/.zshrc.local"

  if [ ! -f "$local_override_file" ]; then
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would create local override file: $local_override_file"
    else
      if touch "$local_override_file"; then
        msg_success "Created empty local override file at: $local_override_file"
        msg_info "You can add private, machine-specific settings to this file."
      else
        msg_error "Failed to create local override file: $local_override_file"
      fi
    fi
  else
    msg_info "Local override file already exists. Skipping creation."
  fi

  # --- File Copying -----------------------------------------------------------
  # ... (File Copying, Symlinking, and Make Executable logic remains the same) ...

  msg_success "Dotfiles deployment stage complete."
}

main
