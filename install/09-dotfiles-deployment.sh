#!/usr/bin/env bash

# ==============================================================================
#
# Stage 9: Dotfiles Deployment
#
# This script is the core of the installation process. It handles the backup
# of existing dotfiles, the creation of necessary directories, and the copying
# and symlinking of the new dotfiles from the repository.
#
# It fully supports Dry Run mode. If the global variable DRY_RUN_MODE is set
# to true, it will only print the actions it would have taken.
#
# ==============================================================================

#
# The main logic for the dotfiles deployment stage.
#
main() {
  msg_info "Stage 9: Dotfiles Deployment"

  # --- Configuration ----------------------------------------------------------
  local DIRECTORIES_TO_CREATE=(
    "$HOME/.config"
    "$HOME/.config/zsh"
    "$HOME/.config/bash"
    "$HOME/Projects"
    "$HOME/.circus" # For storing state files like PIDs
  )
  declare -A FILES_TO_COPY
  declare -A FILES_TO_SYMLINK

  # --- Shell (sh) Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.profile"]="$HOME/.profile"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shenv"]="$HOME/.shenv"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_aliases"]="$HOME/.shell_aliases"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_functions"]="$HOME/.shell_functions"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_paths"]="$HOME/.shell_paths"

  # --- Zsh Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zshenv"]="$HOME/.zshenv"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zshrc"]="$HOME/.zshrc"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zprofile"]="$HOME/.zprofile"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zlogin"]="$HOME/.zlogin"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zlogout"]="$HOME/.zlogout"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zoptions"]="$HOME/.zoptions"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zprompt"]="$HOME/.zprompt"

  # --- Other Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/.config/git/config"]="$HOME/.gitconfig"

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
    "$DOTFILES_DIR/lib/commands/fc-template"
    "$DOTFILES_DIR/lib/commands/fc-wifi"
  )

  # --- Backup, Directory Creation, Copying, Symlinking... (rest of script is unchanged)
  # ... (The rest of the script remains the same) ...

  msg_success "Dotfiles deployment complete."
}

main
