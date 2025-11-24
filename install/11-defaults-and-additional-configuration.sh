#!/usr/bin/env bash

# ==============================================================================
#
# Stage 11: Defaults and Additional Configuration
#
# This script orchestrates the application of macOS system and application
# defaults. It first applies all common defaults and then applies any
# role-specific defaults if a role is selected.
#
# ==============================================================================

#
# Helper function to source scripts from a given directory.
#
source_defaults_from_dir() {
  local dir_to_source="$1"
  local type="$2"

  if [ ! -d "$dir_to_source" ]; then
    msg_info "Defaults directory for $type not found at '$dir_to_source'. Skipping."
    return 0
  fi

  local sh_files
  sh_files=$(find "$dir_to_source" -name "*.sh" 2>/dev/null)
  if [ -z "$sh_files" ]; then
    msg_info "No defaults scripts found in '$dir_to_source'. Skipping."
    return 0
  fi

  msg_info "Applying $type defaults from '$dir_to_source'..."
  for file in $sh_files; do
    if [ -f "$file" ]; then
      msg_info "Running configuration script: '$file'..."
      source "$file"
    fi
  done
}

main() {
  msg_info "Stage 11: Defaults and Additional Configuration"

  # --- Apply Base Defaults ---
  local base_defaults_dir="$DOTFILES_ROOT/defaults"
  source_defaults_from_dir "$base_defaults_dir" "base"

  # --- Apply Role-Specific Defaults ---
  if [ -n "$INSTALL_ROLE" ]; then
    local role_defaults_dir="$DOTFILES_ROOT/roles/$INSTALL_ROLE/defaults"
    source_defaults_from_dir "$role_defaults_dir" "role-specific ($INSTALL_ROLE)"
  fi

  msg_success "Defaults and additional configuration complete."
}

main
