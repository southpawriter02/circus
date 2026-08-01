#!/usr/bin/env bash

# ==============================================================================
#
# Stage 10: Git Configuration
#
# This script handles the deployment of all Git-related configuration files,
# symlinking them into the user's home directory.
#
# ==============================================================================

main() {
  msg_info "Stage 10: Git Configuration"

  # --- Configuration ---
  local git_profile_dir="$DOTFILES_ROOT/profiles/base/git"
  # Indexed array of "source|target" rather than an associative array: bash 3.2
  # (the macOS system bash) has no `declare -A`, and this stage is sourced by an
  # installer that may well be running under it.
  local files_to_symlink=(
    "$git_profile_dir/.gitconfig|$HOME/.gitconfig"
    "$git_profile_dir/.gitignore_global|$HOME/.gitignore_global"
    "$git_profile_dir/.gitattributes|$HOME/.gitattributes"
    "$git_profile_dir/.githelpers|$HOME/.githelpers"
  )

  # --- Symlinking ---
  msg_info "Symlinking Git configuration files..."
  local entry source_file target_file
  for entry in "${files_to_symlink[@]}"; do
    source_file="${entry%%|*}"
    target_file="${entry##*|}"
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would symlink '$source_file' to '$target_file'"
    else
      # Back up existing file if it's not already a symlink.
      if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
        mv "$target_file" "${target_file}.bak"
        msg_info "Backed up existing file to ${target_file}.bak"
      fi
      # Create the symlink.
      if ln -sf "$source_file" "$target_file"; then
        msg_success "Symlinked: $(basename "$target_file")"
      else
        msg_error "Failed to symlink: $(basename "$target_file")"
      fi
    fi
  done

  # --- Local Override File ---
  # The main .gitconfig includes this file for user-specific (private) settings.
  local local_gitconfig="$HOME/.gitconfig.local"
  if [ ! -f "$local_gitconfig" ]; then
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would create local gitconfig for private settings at $local_gitconfig"
    else
      touch "$local_gitconfig"
      msg_success "Created empty local gitconfig at: $local_gitconfig"
      msg_info "You should add your name and email to this file."
    fi
  fi

  msg_success "Git configuration complete."
}

main
