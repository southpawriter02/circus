#!/usr/bin/env bash

# ==============================================================================
#
# Stage: Backup Dotfiles
#
# This script performs a bulk backup of existing dotfiles before any changes
# are made by the installer. It identifies files that would be overwritten
# and moves them to a timestamped backup directory.
#
# ==============================================================================

main() {
  msg_info "Stage: Backup Dotfiles"

  # List of files that the installer manages and might overwrite.
  local files_to_backup=(
    ".zshrc"
    ".gitconfig"
    ".gitignore_global"
    ".gitattributes"
    ".githelpers"
    ".ideavimrc"
    ".config/JetBrains/ide-scripting.js"
  )

  local backup_base_dir="$HOME/dotfiles_backup"
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  local backup_dir="$backup_base_dir/$timestamp"
  local backup_needed=false

  # Check if any files exist to be backed up
  for file in "${files_to_backup[@]}"; do
    if [ -e "$HOME/$file" ] || [ -L "$HOME/$file" ]; then
      backup_needed=true
      break
    fi
  done

  if [ "$backup_needed" = false ]; then
    msg_info "No existing dotfiles found to backup. Skipping."
    return 0
  fi

  msg_info "Backing up existing dotfiles to: $backup_dir"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would create backup directory: $backup_dir"
  else
    mkdir -p "$backup_dir"
  fi

  for file in "${files_to_backup[@]}"; do
    local source_path="$HOME/$file"

    if [ -e "$source_path" ] || [ -L "$source_path" ]; then
      # Handle files in subdirectories (like .config/JetBrains/ide-scripting.js)
      local rel_dir
      rel_dir=$(dirname "$file")
      local target_dir="$backup_dir/$rel_dir"

      if [ "$DRY_RUN_MODE" = true ]; then
        if [ "$rel_dir" != "." ]; then
            msg_info "[Dry Run] Would create directory: $target_dir"
        fi
        msg_info "[Dry Run] Would move '$source_path' to '$target_dir/$(basename "$file")'"
      else
        if [ "$rel_dir" != "." ]; then
            mkdir -p "$target_dir"
        fi
        mv "$source_path" "$target_dir/"
        msg_success "  -> Moved '$file' to backup."
      fi
    fi
  done

  msg_success "Backup process complete."
}

main
