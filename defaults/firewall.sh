#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Firewall Configuration
#
# This script configures and enables the macOS application firewall.
# It requires administrative privileges to modify system-level settings.
# It is sourced by Stage 11 of the main installer. It supports Dry Run mode.
#
# ==============================================================================

# --- Sudo Check & Re-invocation ---------------------------------------------
# This script needs to run as root to modify firewall settings.
# If not running as root, it re-launches itself with sudo.
if [ "$EUID" -ne 0 ] && [ "$DRY_RUN_MODE" = false ]; then
  msg_info "Firewall configuration requires administrative privileges."
  sudo "$0" "$@"
  exit $?
fi

# --- Main Logic -------------------------------------------------------------

msg_info "Configuring macOS Application Firewall..."

# A helper function to run `defaults write` commands or print them in dry run mode.
# This version is for system-level domains that require sudo.
run_sudo_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Firewall preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

# --- Enable Firewall ---
# Description:  Turns on the macOS application firewall.
# Default:      0 (Off)
# Possible:     1 (On for specific services), 2 (On for essential services)
# Set to:       1 (On)
run_sudo_defaults "/Library/Preferences/com.apple.alf" "globalstate" "-int" "1"

# --- Enable Stealth Mode ---
# Description:  Prevents the Mac from responding to network probing requests (e.g., ping).
# Default:      0 (Off)
# Possible:     1 (On), 0 (Off)
# Set to:       1 (On)
run_sudo_defaults "/Library/Preferences/com.apple.alf" "stealthenabled" "-int" "1"

# --- Enable Logging ---
# Description:  Enables logging for the firewall.
# Default:      0 (Off)
# Possible:     1 (On), 0 (Off)
# Set to:       1 (On)
run_sudo_defaults "/Library/Preferences/com.apple.alf" "loggingenabled" "-int" "1"


# --- Apply Changes ----------------------------------------------------------
# Changes to the firewall require a restart of the service.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would restart the firewall service to apply changes."
else
  msg_info "Restarting firewall service to apply changes..."
  # Unload and reload the launchd agent for the firewall.
  launchctl unload /System/Library/LaunchDaemons/com.apple.alf.agent.plist
  launchctl load /System/Library/LaunchDaemons/com.apple.alf.agent.plist
fi

msg_success "Firewall configuration complete."
