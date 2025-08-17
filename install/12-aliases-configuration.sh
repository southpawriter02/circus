#!/usr/bin/env bash

# ==============================================================================
#
# Stage 12: Aliases Configuration
#
# This script handles the deployment of all modular alias files, symlinking
# them into a dedicated directory for the shell to source. It supports both
# base aliases and role-specific aliases.
#
# ==============================================================================

#
# Helper function to find and symlink alias files from a given directory.
#
symlink_aliases_from_dir() {
  local source_dir="$1"
  local target_dir="$2"
  local type="$3"

  if [ ! -d "$source_dir" ]; then
    msg_info "Alias directory for $type not found at $source_dir. Skipping."
    return
  fi

  msg_info "Symlinking $type alias files from $source_dir..."
  local alias_files
  alias_files=$(find "$source_dir" -name "*.aliases.sh" 2>/dev/null)

  for source_file in $alias_files; do
    local target_file="$target_dir/$(basename "$source_file")"
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
}

main() {
  msg_info "Stage 12: Aliases Configuration"

  # --- Configuration ---
  local aliases_target_dir="$HOME/.config/shell/aliases"

  # --- Directory Creation ---
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would create directory: $aliases_target_dir"
  else
    mkdir -p "$aliases_target_dir"
    msg_success "Created directory for alias files: $aliases_target_dir"
  fi

  # --- Symlinking ---
  # 1. Symlink base aliases for all roles.
  local base_aliases_dir="$DOTFILES_DIR/profiles/aliases"
  symlink_aliases_from_dir "$base_aliases_dir" "$aliases_target_dir" "base"

  # 2. If a role is specified, symlink role-specific aliases.
  if [ -n "$INSTALL_ROLE" ]; then
    local role_aliases_dir="$DOTFILES_DIR/roles/$INSTALL_ROLE/aliases"
    symlink_aliases_from_dir "$role_aliases_dir" "$aliases_target_dir" "role-specific ($INSTALL_ROLE)"
  fi

  msg_success "Aliases configuration complete."
}

main
