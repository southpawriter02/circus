#!/usr/bin/env bash

# ==============================================================================
#
# Stage 12: Aliases Configuration
#
# This script handles the deployment of all modular alias files, symlinking
# them into a dedicated directory for the shell to source.
#
# ==============================================================================

main() {
  msg_info "Stage 12: Aliases Configuration"

  # --- Configuration ---
  local aliases_profile_dir="$DOTFILES_DIR/profiles/aliases"
  local aliases_target_dir="$HOME/.config/shell/aliases"

  # --- Directory Creation ---
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would create directory: $aliases_target_dir"
  else
    mkdir -p "$aliases_target_dir"
    msg_success "Created directory for alias files: $aliases_target_dir"
  fi

  # --- Symlinking ---
  msg_info "Symlinking alias files..."
  local alias_files
  alias_files=$(find "$aliases_profile_dir" -name "*.aliases.sh" 2>/dev/null)

  for source_file in $alias_files; do
    local target_file="$aliases_target_dir/$(basename "$source_file")"
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would symlink '$source_file' to '$target_file'"
    else
      if ln -sf "$source_file" "$target_file"; then
        msg_success "Symlinked: $(basename "$target_file")"
      else
        msg_error "Failed to symlink: $(basename "$target_file")"
      fi
    fi
  done

  msg_success "Aliases configuration complete."
}

main
