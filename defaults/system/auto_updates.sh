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

# ==============================================================================
# launchd Architecture
# ==============================================================================

# launchd is macOS's init system and service manager. It replaces the older
# Unix init, cron, and inetd systems with a unified framework.
#
# AGENTS vs DAEMONS:
#
#   LaunchAgent                          LaunchDaemon
#   ────────────────────────────────────────────────────────────────────
#   Location: ~/Library/LaunchAgents/    /Library/LaunchDaemons/
#             /Library/LaunchAgents/     /System/Library/LaunchDaemons/
#   Runs as:  The logged-in user         root (or specified user)
#   Context:  Per-user session           System-wide
#   Access:   User's files, GUI apps     System resources only
#   Use for:  User automation, syncs     Services, servers, startup tasks
#
# PLIST STRUCTURE:
#   A launchd plist is an XML property list containing:
#
#   <key>Label</key>             Unique identifier (reverse DNS style)
#   <key>Program</key>           Path to executable OR
#   <key>ProgramArguments</key>  Array of command + arguments
#   <key>StartInterval</key>     Run every N seconds
#   <key>StartCalendarInterval</key>  Cron-like scheduling (Hour, Minute, etc.)
#   <key>RunAtLoad</key>         Run immediately when loaded (true/false)
#   <key>KeepAlive</key>         Restart if crashes (true/false)
#   <key>StandardOutPath</key>   Log file for stdout
#   <key>StandardErrorPath</key> Log file for stderr
#
# DEBUGGING COMMANDS:
#   launchctl list                       # Show all loaded jobs
#   launchctl list | grep circus         # Find our job
#   launchctl print gui/$(id -u)/com.southpawriter02.circus.update
#   log show --predicate 'subsystem == "com.apple.launchd"' --last 1h
#
# Source:       man launchd.plist
# See also:     https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html

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
