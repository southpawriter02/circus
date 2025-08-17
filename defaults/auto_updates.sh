#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Automated Update Configuration
#
# This script installs and enables a launchd agent to automatically update
# the dotfiles repository and Homebrew packages every 24 hours.
# It is sourced by Stage 11 of the main installer. It supports Dry Run mode.
#
# ==============================================================================

msg_info "Configuring automated daily updates..."

# --- Configuration ---
local plist_name="com.southpawriter02.circus.update.plist"
local source_plist="$DOTFILES_DIR/etc/launchd/$plist_name"
local target_dir="$HOME/Library/LaunchAgents"
local target_plist="$target_dir/$plist_name"

# --- Installation Logic ---

# First, ensure the target directory exists.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would ensure directory exists: $target_dir"
else
  mkdir -p "$target_dir"
fi

msg_info "Installing launchd agent for automated updates..."

if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would copy '$source_plist' to '$target_plist'"
  msg_info "[Dry Run] Would dynamically replace placeholder paths in the plist."
  msg_info "[Dry Run] Would run: launchctl load -w $target_plist"
else
  # Read the source plist, replace the placeholder user path with the actual
  # user's home directory, and write the corrected file to the target.
  # This makes the agent portable.
  sed "s|/Users/southpawriter02|$HOME|g" "$source_plist" > "$target_plist"

  # Use launchctl to load the agent. The -w flag makes it persistent.
  if launchctl load -w "$target_plist"; then
    msg_success "Automated update agent installed and enabled."
    msg_info "System will now automatically update dotfiles and Homebrew packages daily."
  else
    msg_error "Failed to load the automated update agent."
  fi
fi

msg_success "Automated update configuration complete."
