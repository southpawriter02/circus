#!/usr/bin/env bash

# ==============================================================================
#
# Stage 13: Environment Configuration
#
# This script handles the deployment of all modular environment variable files,
# symlinking them into a dedicated directory for the shell to source.
#
# ==============================================================================

main() {
  msg_info "Stage 13: Environment Configuration"

  # --- Configuration ---
  local env_profile_dir="$DOTFILES_DIR/profiles/env"
  local env_target_dir="$HOME/.config/shell/env"

  # --- Directory Creation ---
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would create directory: $env_target_dir"
  else
    mkdir -p "$env_target_dir"
    msg_success "Created directory for environment files: $env_target_dir"
  fi

  # --- Symlinking ---
  msg_info "Symlinking environment files..."
  local env_files
  env_files=$(find "$env_profile_dir" -name "*.env.sh" 2>/dev/null)

  for source_file in $env_files; do
    local target_file="$env_target_dir/$(basename "$source_file")"
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

  msg_success "Environment configuration complete."
}

main
