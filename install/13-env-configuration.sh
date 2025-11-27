#!/usr/bin/env bash

# ==============================================================================
#
# Stage 13: Environment Configuration
#
# This script handles the deployment of all modular environment variable files,
# symlinking them into a dedicated directory for the shell to source. It supports
# both base and role-specific environment files.
#
# UNUSED CODE NOTICE:
#   This script is NOT currently referenced in install.sh's INSTALL_STAGES array.
#   Note: The current shell configuration (circus.plugin.zsh) sources environment
#   files directly from the repository rather than from a symlinked location.
#   
#   RECOMMENDATION: Either:
#   1. Add to INSTALL_STAGES and update circus.plugin.zsh to source from 
#      ~/.config/shell/env/, OR
#   2. Remove this script since circus.plugin.zsh already handles env loading.
#
# ==============================================================================

#
# Helper function to find and symlink environment files from a given directory.
#
symlink_env_from_dir() {
  local source_dir="$1"
  local target_dir="$2"
  local type="$3"

  if [ ! -d "$source_dir" ]; then
    msg_info "Environment variable directory for $type not found at $source_dir. Skipping."
    return
  fi

  msg_info "Symlinking $type environment files from $source_dir..."
  local env_files
  env_files=$(find "$source_dir" -name "*.env.sh" 2>/dev/null)

  for source_file in $env_files; do
    local target_file
    target_file="$target_dir/$(basename "$source_file")"
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
  msg_info "Stage 13: Environment Configuration"

  # --- Configuration ---
  local env_target_dir="$HOME/.config/shell/env"

  # --- Directory Creation ---
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would create directory: $env_target_dir"
  else
    mkdir -p "$env_target_dir"
    msg_success "Created directory for environment files: $env_target_dir"
  fi

  # --- Symlinking ---
  # 1. Symlink base environment files for all roles.
  local base_env_dir="$DOTFILES_ROOT/profiles/env"
  symlink_env_from_dir "$base_env_dir" "$env_target_dir" "base"

  # 2. If a role is specified, symlink role-specific environment files.
  if [ -n "$INSTALL_ROLE" ]; then
    local role_env_dir="$DOTFILES_ROOT/roles/$INSTALL_ROLE/env"
    symlink_env_from_dir "$role_env_dir" "$env_target_dir" "role-specific ($INSTALL_ROLE)"
  fi

  msg_success "Environment configuration complete."
}

main
