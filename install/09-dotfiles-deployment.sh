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
  )
  declare -A FILES_TO_COPY
  declare -A FILES_TO_SYMLINK

  # --- Shell (sh) Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.profile"]="$HOME/.profile"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shenv"]="$HOME/.shenv"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_aliases"]="$HOME/.shell_aliases"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_functions"]="$HOME/.shell_functions"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/sh/.shell_paths"]="$HOME/.shell_paths"

  # --- Bash Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/bash/.bash_profile"]="$HOME/.bash_profile"
  # ... (other bash files) ...

  # --- Zsh Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zshenv"]="$HOME/.zshenv"
  FILES_TO_SYMLINK["$DOTFILES_DIR/profiles/zsh/.zshrc"]="$HOME/.zshrc"
  # ... (other zsh files) ...

  # --- Other Dotfiles ---
  FILES_TO_SYMLINK["$DOTFILES_DIR/.config/git/config"]="$HOME/.gitconfig"

  local FILES_TO_MAKE_EXECUTABLE=(
    "$DOTFILES_DIR/bin/fc"
    "$DOTFILES_DIR/lib/commands/fc-template"
    # ... (all fc commands) ...
    "$DOTFILES_DIR/lib/commands/fc-redis"
  )

  # --- Backup -----------------------------------------------------------------
  msg_info "Checking for existing files to back up..."
  local backup_dir="$HOME/.dotfiles-backup-$(date +%Y-%m-%d-%H%M%S)"
  local all_targets=("${DIRECTORIES_TO_CREATE[@]}" "${FILES_TO_COPY[@]}" "${FILES_TO_SYMLINK[@]}")
  local targets_to_backup=()

  for target in "${all_targets[@]}"; do
    if [ -e "$target" ]; then
      targets_to_backup+=("$target")
    fi
  done

  if [ ${#targets_to_backup[@]} -gt 0 ]; then
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would create backup directory: $backup_dir"
      for target in "${targets_to_backup[@]}"; do
        msg_info "[Dry Run] Would move '$target' to '$backup_dir/'"
      done
    else
      msg_info "Creating backup directory at: $backup_dir"
      mkdir -p "$backup_dir"
      for target in "${targets_to_backup[@]}"; do
        msg_info "Backing up '$target'..."
        if ! mv "$target" "$backup_dir/"; then
          msg_error "Failed to back up '$target'. Aborting to prevent data loss."
          exit 1
        fi
      done
      msg_success "Backup of existing files complete."
    fi
  else
    msg_info "No existing files found to back up."
  fi

  # --- Directory Creation -----------------------------------------------------
  msg_info "Creating required directories..."
  for dir in "${DIRECTORIES_TO_CREATE[@]}"; do
    if [ "$DRY_RUN_MODE" = true ]; then
      if [ ! -d "$dir" ]; then
        msg_info "[Dry Run] Would create directory: $dir"
      fi
    else
      if mkdir -p "$dir"; then
        msg_success "Created directory: $dir"
      else
        msg_error "Failed to create directory: $dir"
      fi
    fi
  done

  # --- File Copying -----------------------------------------------------------
  msg_info "Copying files..."
  if [ ${#FILES_TO_COPY[@]} -eq 0 ]; then
    msg_info "No files configured to be copied."
  else
    for src in "${!FILES_TO_COPY[@]}"; do
      dest="${FILES_TO_COPY[$src]}"
      if [ "$DRY_RUN_MODE" = true ]; then
        msg_info "[Dry Run] Would copy '$src' to '$dest'"
      else
        if cp -r "$src" "$dest"; then
          msg_success "Copied '$src' to '$dest'"
        else
          msg_error "Failed to copy '$src' to '$dest'"
        fi
      fi
    done
  fi

  # --- Symlinking -------------------------------------------------------------
  msg_info "Creating symbolic links..."
  for src in "${!FILES_TO_SYMLINK[@]}"; do
    dest="${FILES_TO_SYMLINK[$src]}"
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would link '$src' to '$dest'"
    else
      if ln -s "$src" "$dest"; then
        msg_success "Linked '$src' to '$dest'"
      else
        msg_error "Failed to link '$src' to '$dest'"
      fi
    fi
  done

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

#
# Execute the main function.
#
main
