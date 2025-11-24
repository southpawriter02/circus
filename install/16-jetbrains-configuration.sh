#!/usr/bin/env bash

# ==============================================================================
#
# Stage 16: JetBrains IDE Configuration
#
# This script handles the deployment of all JetBrains-related configuration
# files, symlinking them into the user's home directory.
#
# ==============================================================================

main() {
  msg_info "Stage 16: JetBrains IDE Configuration"

  # --- Configuration ---
  local jetbrains_profile_dir="$DOTFILES_ROOT/profiles/jetbrains"
  declare -A files_to_symlink
  files_to_symlink["$jetbrains_profile_dir/.ideavimrc"]="$HOME/.ideavimrc"
  files_to_symlink["$jetbrains_profile_dir/ide-scripting.js"]="$HOME/.config/JetBrains/ide-scripting.js"

  # --- Directory Creation for ide-scripting.js ---
  local jetbrains_config_dir="$HOME/.config/JetBrains"
  if [ ! -d "$jetbrains_config_dir" ]; then
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would create directory: $jetbrains_config_dir"
    else
      mkdir -p "$jetbrains_config_dir"
      msg_success "Created directory for JetBrains scripting: $jetbrains_config_dir"
    fi
  fi

  # --- Symlinking ---
  msg_info "Symlinking JetBrains configuration files..."
  for source_file in "${!files_to_symlink[@]}"; do
    local target_file="${files_to_symlink[$source_file]}"
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would symlink '$source_file' to '$target_file'"
    else
      if [ -f "$target_file" ] && [ ! -L "$target_file" ]; then
        mv "$target_file" "${target_file}.bak"
        msg_info "Backed up existing file to ${target_file}.bak"
      fi
      if ln -sf "$source_file" "$target_file"; then
        msg_success "Symlinked: $(basename "$target_file")"
      else
        msg_error "Failed to symlink: $(basename "$target_file")"
      fi
    fi
  done

  msg_success "JetBrains IDE configuration complete."
}

main
