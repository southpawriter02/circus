#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Automated Maintenance Agent
#
# DESCRIPTION:
#   This script installs and enables a launchd agent to automatically update
#   the dotfiles repository and Homebrew packages on a daily schedule.
#   Automated updates ensure the system stays current with minimal effort.
#
# REQUIRES:
#   - macOS 10.4 (Tiger) or later (launchd support)
#   - A properly configured launchd plist file
#
# REFERENCES:
#   - launchd.plist man page: man launchd.plist
#   - launchctl man page: man launchctl
#   - Apple Developer: Creating Launch Daemons and Agents
#     https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html
#   - Daemons and Services Programming Guide
#     https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/Introduction.html
#
# PATHS:
#   Source plist:  $DOTFILES_DIR/etc/launchd/com.southpawriter02.circus.update.plist
#   Target:        ~/Library/LaunchAgents/
#
# NOTES:
#   - LaunchAgents run in the user's context (not as root)
#   - The -w flag in launchctl makes the agent persistent across reboots
#   - Agent logs can be viewed in Console.app or ~/Library/Logs/
#
# ==============================================================================

msg_info "Configuring automated daily updates..."

# --- Configuration ---
# These variables define where the plist template is located and where
# it should be installed.
plist_name="com.southpawriter02.circus.update.plist"
source_plist="$DOTFILES_DIR/etc/launchd/$plist_name"
target_dir="$HOME/Library/LaunchAgents"
target_plist="$target_dir/$plist_name"

# ==============================================================================
# Installation Logic
# ==============================================================================

# --- Ensure Target Directory Exists ---
# The LaunchAgents directory may not exist on a fresh system.
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
  # --- Template Processing ---
  # The source plist contains a placeholder path (/Users/southpawriter02).
  # We replace this with the actual user's home directory to make the
  # configuration portable across different user accounts.
  sed "s|/Users/southpawriter02|$HOME|g" "$source_plist" > "$target_plist"

  # --- Load the Agent ---
  # Use launchctl to load the agent. The -w flag:
  # 1. Loads the job immediately
  # 2. Marks it as enabled (will load automatically on login)
  # 3. Overrides any previous "disabled" state
  if launchctl load -w "$target_plist"; then
    msg_success "Automated update agent installed and enabled."
    msg_info "System will now automatically update dotfiles and Homebrew packages daily."
  else
    msg_error "Failed to load the automated update agent."
  fi
fi

msg_success "Automated update configuration complete."
