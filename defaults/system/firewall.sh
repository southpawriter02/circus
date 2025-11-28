#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Firewall Configuration
#
# DESCRIPTION:
#   This script configures and enables the macOS Application Level Firewall (ALF).
#   The firewall provides protection by blocking incoming network connections
#   from applications that are not authorized to receive them.
#
# REQUIRES:
#   - Administrative privileges (runs commands with sudo)
#   - macOS 10.7 (Lion) or later
#
# REFERENCES:
#   - Apple Support: Use stealth mode in firewall options on Mac
#     https://support.apple.com/guide/mac-help/use-stealth-mode-to-keep-your-mac-more-secure-mh11463/mac
#   - Apple Support: About the application firewall
#     https://support.apple.com/en-us/102445
#   - launchd.plist man page: man launchd.plist
#   - Mathias Bynens' dotfiles (inspiration)
#     https://github.com/mathiasbynens/dotfiles/blob/main/.macos
#
# DOMAIN:
#   /Library/Preferences/com.apple.alf
#
# NOTES:
#   - Changes require a restart of the firewall service (alf.agent)
#   - Stealth mode prevents the Mac from responding to ICMP ping requests
#   - Firewall logging is useful for debugging connection issues
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

# ==============================================================================
# Firewall State Configuration
# ==============================================================================

# --- Enable Firewall ---
# Key:          globalstate
# Description:  Controls the overall state of the application firewall.
#               When enabled, macOS monitors incoming connections and can
#               block unauthorized applications from receiving connections.
# Default:      0 (Off - firewall is disabled)
# Possible:     0 = Off (disabled)
#               1 = On (enabled for specific services)
#               2 = On (block all incoming connections except essential services)
# Set to:       1 (enabled with per-app control)
# Reference:    System Preferences > Security & Privacy > Firewall
run_sudo_defaults "/Library/Preferences/com.apple.alf" "globalstate" "-int" "1"

# --- Enable Stealth Mode ---
# Key:          stealthenabled
# Description:  When enabled, the Mac does not respond to network probing
#               requests such as ICMP ping, port scans, or service discovery.
#               This makes the Mac harder to detect on a network.
# Default:      0 (Off - Mac responds to network probes)
# Possible:     0 = Off (responds to probes)
#               1 = On (ignores probes silently)
# Set to:       1 (enabled for enhanced security)
# Reference:    System Preferences > Security & Privacy > Firewall > Firewall Options
run_sudo_defaults "/Library/Preferences/com.apple.alf" "stealthenabled" "-int" "1"

# --- Enable Logging ---
# Key:          loggingenabled
# Description:  Enables logging of firewall activity. Logs can be viewed using
#               Console.app or by examining /var/log/appfirewall.log
# Default:      0 (Off - no logging)
# Possible:     0 = Off
#               1 = On
# Set to:       1 (enabled for security auditing and debugging)
# Reference:    Use `log show --predicate 'subsystem == "com.apple.alf"'` to view logs
run_sudo_defaults "/Library/Preferences/com.apple.alf" "loggingenabled" "-int" "1"


# ==============================================================================
# Apply Changes
# ==============================================================================

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
