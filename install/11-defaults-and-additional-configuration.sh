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

  # Collect first so the "nothing found" message still works, then source.
  #
  # Two things this loop must get right:
  #
  # 1. `-path '*/profiles/*' -prune` — defaults/profiles/{standard,privacy,
  #    lockdown}.sh are NOT base defaults. They are applied explicitly by name
  #    from $PRIVACY_PROFILE in main(). Sweeping them up here sourced all three
  #    on every install regardless of the flag, so a plain `./install.sh`
  #    silently applied the lockdown profile (firewall set to block all
  #    incoming, 2-minute screen lock), and which profile "won" depended on
  #    find's traversal order — non-deterministic across machines.
  #
  # 2. -print0 with `read -r -d ''` — the previous `for file in $(find ...)`
  #    split on whitespace, so a checkout path containing a space silently
  #    sourced nothing while still reporting success.
  local sh_files=()
  local file
  while IFS= read -r -d '' file; do
    sh_files+=("$file")
  done < <(find "$dir_to_source" -path '*/profiles/*' -prune -o -name '*.sh' -print0 2>/dev/null)

  if [ ${#sh_files[@]} -eq 0 ]; then
    msg_info "No defaults scripts found in '$dir_to_source'. Skipping."
    return 0
  fi

  msg_info "Applying $type defaults from '$dir_to_source'..."
  for file in "${sh_files[@]}"; do
    if [ -f "$file" ]; then
      msg_info "Running configuration script: '$file'..."
      # One optional app's config must not abort the whole installation.
      #
      # These scripts configure apps that may simply not be installed -- which
      # is the normal case on a fresh Mac. Bare `source "$file"` under
      # `set -Eeo pipefail` let any one of them take down the entire run: a
      # missing nvm ended the installer before it reached the ~30 scripts
      # queued behind it. `|| ...` also suspends errexit for the sourced
      # script, so a failing step inside one no longer aborts either.
      # shellcheck source=/dev/null
      source "$file" || msg_warning "Configuration script did not complete: '$file' (continuing)."
    fi
  done
}

main() {
  msg_info "Stage 11: Defaults and Additional Configuration"

  # --- Apply Base Defaults ---
  local base_defaults_dir="$DOTFILES_ROOT/defaults"
  source_defaults_from_dir "$base_defaults_dir" "base"

  # --- Apply Privacy Profile ---
  # Privacy profiles are applied after base defaults but before role-specific
  # defaults. This allows role-specific settings to override if needed.
  if [ -n "$PRIVACY_PROFILE" ]; then
    local profile_script="$DOTFILES_ROOT/defaults/profiles/${PRIVACY_PROFILE}.sh"
    if [ -f "$profile_script" ]; then
      msg_info "Applying privacy profile: $PRIVACY_PROFILE"
      # shellcheck source=/dev/null
      source "$profile_script"
    else
      msg_warning "Privacy profile script not found: $profile_script"
    fi
  fi

  # --- Apply Role-Specific Defaults ---
  if [ -n "$INSTALL_ROLE" ]; then
    local role_defaults_dir="$DOTFILES_ROOT/roles/$INSTALL_ROLE/defaults"
    source_defaults_from_dir "$role_defaults_dir" "role-specific ($INSTALL_ROLE)"
  fi

  msg_success "Defaults and additional configuration complete."
}

main
