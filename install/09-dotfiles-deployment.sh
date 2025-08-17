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

  # --- Configuration ----------------------------------------------------------
  local DIRECTORIES_TO_CREATE=(
    "$HOME/.config"
    "$HOME/.config/zsh"
    "$HOME/.config/bash"
    "$HOME/Projects"
    "$HOME/.circus" # For storing state files like PIDs
    "$HOME/.ssh" # For SSH keys
  )
  declare -A FILES_TO_COPY
  declare -A FILES_TO_SYMLINK

  # ... (Symlinking logic remains the same) ...

  # @description: A list of files to make executable.
  local FILES_TO_MAKE_EXECUTABLE=(
    "$DOTFILES_DIR/bin/fc"
    "$DOTFILES_DIR/lib/commands/fc-airdrop"
    "$DOTFILES_DIR/lib/commands/fc-backup"
    "$DOTFILES_DIR/lib/commands/fc-bluetooth"
    "$DOTFILES_DIR/lib/commands/fc-caffeine"
    "$DOTFILES_DIR/lib/commands/fc-dns"
    "$DOTFILES_DIR/lib/commands/fc-firewall"
    "$DOTFILES_DIR/lib/commands/fc-info"
    "$DOTFILES_DIR/lib/commands/fc-redis"
    "$DOTFILES_DIR/lib/commands/fc-ssh-keygen"
    "$DOTFILES_DIR/lib/commands/fc-template"
    "$DOTFILES_DIR/lib/commands/fc-wifi"
  )

  # ... (Backup, Directory Creation, Local Override, etc. logic remains the same) ...

  # --- Make Executable --------------------------------------------------------
  msg_info "Making scripts executable..."
  for file in "${FILES_TO_MAKE_EXECUTABLE[@]}"; do
    if [ -f "$file" ]; then
      if [ "$DRY_RUN_MODE" = true ]; then
        msg_info "[Dry Run] Would make executable: $file"
      else
        if chmod +x "$file"; then
          msg_success "Made executable: $file"
        else
          msg_error "Failed to make executable: $file"
        fi
      fi
    fi
  done

  msg_success "Dotfiles deployment stage complete."
}

main
