#!/usr/bin/env bash

# ==============================================================================
#
# Stage 10: Dotfiles Deployment
#
# This script is the core of the installation process. It handles the backup
# of existing dotfiles, the creation of necessary directories, and the copying
# and symlinking of the new dotfiles from the repository.
#
# Implementation Strategy:
#
# The entire process is driven by a series of arrays defined in the
# configuration section. This makes it easy to add, remove, or change
# dotfiles without touching the core deployment logic. The script performs
# its operations in a safe, idempotent manner:
#
# 1.  **Backup:** Any existing files or directories at the target locations
#     are moved to a timestamped backup directory.
# 2.  **Directory Creation:** All necessary directories are created using `mkdir -p`.
# 3.  **File Deployment:** Files are copied and symlinked from the repository
#     to their target locations as defined in the configuration arrays.
#
# ==============================================================================

#
# The main logic for the dotfiles deployment stage.
#
main() {
  msg_info "Stage 10: Dotfiles Deployment"

  # --- Configuration ----------------------------------------------------------
  # @description: A list of directories to be created in the home directory.
  # @customization: Add any directories that your dotfiles or tools require.
  local DIRECTORIES_TO_CREATE=(
    "$HOME/.config"
    "$HOME/.config/zsh"
    "$HOME/.config/bash"
    "$HOME/Projects"
  )

  # @description: An associative array of files to be copied.
  # @customization: Use this for files that should be copied, not symlinked,
  #                such as templates for local-only configuration.
  declare -A FILES_TO_COPY
  # FILES_TO_COPY["$DOTFILES_DIR/.gitconfig.local.template"]="$HOME/.gitconfig.local"

  # @description: An associative array of files and directories to be symlinked.
  # @customization: This is the primary mechanism for deploying your dotfiles.
  #   - Key: The path to the source file/directory within the dotfiles repository.
  #   - Value: The absolute path to the symlink in your home directory.
  declare -A FILES_TO_SYMLINK

  # --- Shell (sh) Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.profile"]="$HOME/.profile"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shenv"]="$HOME/.shenv"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_aliases"]="$HOME/.shell_aliases"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_functions"]="$HOME/.shell_functions"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_paths"]="$HOME/.shell_paths"

  # --- Bash Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_profile"]="$HOME/.bash_profile"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bashrc"]="$HOME/.bashrc"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_logout"]="$HOME/.bash_logout"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_login"]="$HOME/.bash_login"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_init"]="$HOME/.bash_init"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_prompt"]="$HOME/.bash_prompt"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_exports"]="$HOME/.bash_exports"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_aliases"]="$HOME/.bash_aliases"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_functions"]="$HOME/.bash_functions"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_autocompletion"]="$HOME/.bash_autocompletion"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_options"]="$HOME/.bash_options"

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


  # --- Backup -----------------------------------------------------------------
  msg_info "Backing up existing dotfiles..."
  local backup_dir="$HOME/.dotfiles-backup-$(date +%Y-%m-%d-%H%M%S)"
  local needs_backup=false

  # Combine all target paths into a single list for checking.
  local all_targets=(
    "${DIRECTORIES_TO_CREATE[@]}"
    "${FILES_TO_COPY[@]}"
    "${FILES_TO_SYMLINK[@]}"
  )

  for target in "${all_targets[@]}"; do
    if [ -e "$target" ]; then
      needs_backup=true
      break
    fi
  done

  if [ "$needs_backup" = true ]; then
    msg_info "Creating backup directory at: $backup_dir"
    mkdir -p "$backup_dir"
    for target in "${all_targets[@]}"; do
      if [ -e "$target" ]; then
        msg_info "Backing up '$target'..."
        if ! mv "$target" "$backup_dir/"; then
          msg_error "Failed to back up '$target'. Aborting to prevent data loss."
          exit 1
        fi
      fi
    done
    msg_success "Backup of existing files complete."
  else
    msg_info "No existing files found to back up."
  fi

  # --- Directory Creation -----------------------------------------------------
  msg_info "Creating required directories..."
  for dir in "${DIRECTORIES_TO_CREATE[@]}"; do
    if mkdir -p "$dir"; then
      msg_success "Created directory: $dir"
    else
      msg_error "Failed to create directory: $dir"
    fi
  done

  # --- File Copying -----------------------------------------------------------
  msg_info "Copying files..."
  for src in "${!FILES_TO_COPY[@]}"; do
    dest="${FILES_TO_COPY[$src]}"
    if cp -r "$src" "$dest"; then
      msg_success "Copied '$src' to '$dest'"
    else
      msg_error "Failed to copy '$src' to '$dest'"
    fi
  done

  # --- Symlinking -------------------------------------------------------------
  msg_info "Creating symbolic links..."
  for src in "${!FILES_TO_SYMLINK[@]}"; do
    dest="${FILES_TO_SYMLINK[$src]}"
    if ln -s "$src" "$dest"; then
      msg_success "Linked '$src' to '$dest'"
    else
      msg_error "Failed to link '$src' to '$dest'"
    fi
  done

  msg_success "Dotfiles deployment complete."
}

#
# Execute the main function.
#
main
