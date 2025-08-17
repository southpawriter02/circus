#!/usr/bin/env bash

# ==============================================================================
#
# Stage 11: Defaults and Additional Configuration
#
# This script orchestrates the application of macOS system and application
# defaults. It first applies all common defaults and then applies any
# profile-specific defaults if a profile is selected.
#
# ==============================================================================

main() {
  msg_info "Stage 11: Defaults and Additional Configuration"

  # --- Helper function to source scripts from a directory ---
  source_defaults_from_dir() {
    local dir_to_source="$1"
    if [ ! -d "$dir_to_source" ]; then
      msg_info "Defaults directory not found: '$dir_to_source'. Skipping."
      return 0
    fi

    local sh_files
    sh_files=$(find "$dir_to_source" -name "*.sh" 2>/dev/null)
    if [ -z "$sh_files" ]; then
      msg_info "No defaults scripts found in '$dir_to_source'. Skipping."
      return 0
    fi

    msg_info "Applying defaults from '$dir_to_source'..."
    for file in $sh_files; do
      if [ -f "$file" ]; then
        msg_info "Running configuration script: '$file'..."
        source "$file"
      fi
    done
  }

  # --- Apply Common Defaults ---
  local common_defaults_dir="$DOTFILES_DIR/defaults"
  source_defaults_from_dir "$common_defaults_dir"

  # --- Apply Profile-Specific Defaults ---
  if [ -n "$INSTALL_PROFILE" ]; then
    local profile_defaults_dir="$DOTFILES_DIR/defaults/profiles/$INSTALL_PROFILE"
    msg_info "Applying defaults for profile: $INSTALL_PROFILE"
    source_defaults_from_dir "$profile_defaults_dir"
  fi

  msg_success "Defaults and additional configuration complete."
}

main
