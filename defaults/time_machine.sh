#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Time Machine Configuration
#
# This script configures Time Machine with optimized settings for developers,
# such as excluding cache and dependency directories.
# It requires administrative privileges.
#
# ==============================================================================

# --- Sudo Check & Re-invocation ---------------------------------------------
if [ "$EUID" -ne 0 ] && [ "$DRY_RUN_MODE" = false ]; then
  msg_info "Time Machine configuration requires administrative privileges."
  sudo "$0" "$@"
  exit $?
fi

# --- Main Logic -------------------------------------------------------------

msg_info "Configuring Time Machine settings..."

# --- Developer-focused Exclusions ---
# A list of common developer and cache directories to exclude from backups.
# This saves space and speeds up the backup process.
local exclusions=(
  "$HOME/node_modules"
  "$HOME/.npm"
  "$HOME/.cache"
  "$HOME/Library/Caches"
  "/private/var/db/diagnostics"
  "/private/var/folders"
  "$HOME/Downloads" # Optional: often contains temporary files
)

msg_info "Adding developer-focused exclusions to Time Machine..."
for path in "${exclusions[@]}"; do
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would add exclusion for: $path"
  else
    # The `tmutil addexclusion` command is idempotent. Running it multiple
    # times with the same path has no negative effect.
    if tmutil addexclusion "$path"; then
      msg_success "Added exclusion for: $path"
    else
      msg_warning "Could not add exclusion for: $path (it may not exist yet)"
    fi
  fi
done

# --- Enable Automatic Backups ---
msg_info "Enabling automatic Time Machine backups..."
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would run: tmutil enable"
else
  if tmutil enable; then
    msg_success "Automatic backups enabled."
  else
    msg_error "Failed to enable automatic backups. Is a backup disk connected?"
  fi
fi

msg_success "Time Machine configuration complete."
