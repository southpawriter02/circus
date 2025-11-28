#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Time Machine Configuration
#
# DESCRIPTION:
#   This script configures Time Machine with optimized settings for developers.
#   It excludes common cache and dependency directories that are easily
#   regenerated, reducing backup size and improving backup speed.
#
# REQUIRES:
#   - Administrative privileges (runs commands with sudo)
#   - macOS 10.5 (Leopard) or later
#
# REFERENCES:
#   - Apple Support: Back up your Mac with Time Machine
#     https://support.apple.com/en-us/104984
#   - tmutil man page: man tmutil
#   - Apple Developer: Time Machine Programming Guide
#     https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Archiving/Archiving.html
#
# COMMAND:
#   tmutil - Time Machine utility for managing backups
#
# NOTES:
#   - Exclusions added with `tmutil addexclusion` are "sticky" - they persist
#     even if the path doesn't exist yet
#   - The `tmutil addexclusion` command is idempotent and safe to run multiple times
#   - Consider excluding virtual machine images and Docker volumes as well
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

# ==============================================================================
# Developer-Focused Exclusions
# ==============================================================================
#
# These directories contain files that are:
# 1. Easily regenerated (npm install, pip install, etc.)
# 2. Cache files that change frequently and inflate backup size
# 3. Temporary system files that don't need to be backed up
#
# Adding these exclusions can significantly reduce backup time and storage usage.

exclusions=(
  # --- Package Manager Caches ---
  "$HOME/node_modules"           # npm/yarn project dependencies (regenerate with npm install)
  "$HOME/.npm"                   # npm global cache
  "$HOME/.yarn"                  # Yarn global cache
  "$HOME/.pnpm-store"            # pnpm global store
  "$HOME/.cargo"                 # Rust cargo cache
  "$HOME/.go"                    # Go module cache
  "$HOME/.gradle"                # Gradle build cache
  "$HOME/.m2"                    # Maven repository cache
  "$HOME/.cocoapods"             # CocoaPods cache
  
  # --- System and Application Caches ---
  "$HOME/.cache"                 # XDG cache directory (used by many tools)
  "$HOME/Library/Caches"         # macOS application caches
  "/private/var/db/diagnostics"  # System diagnostic data
  "/private/var/folders"         # System temporary folders
  
  # --- Optional: Frequently Changing Directories ---
  "$HOME/Downloads"              # Often contains temporary files
  
  # --- Virtual Machines and Containers ---
  "$HOME/.docker"                # Docker configuration and cache
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

# ==============================================================================
# Enable Automatic Backups
# ==============================================================================

# Command:      tmutil enable
# Description:  Enables the Time Machine service for automatic backups.
#               Once enabled and a backup disk is configured, Time Machine
#               will automatically back up hourly, keeping:
#               - Hourly backups for the past 24 hours
#               - Daily backups for the past month
#               - Weekly backups for all previous months
# Note:         A backup disk must be configured in System Preferences for
#               backups to actually occur.

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
