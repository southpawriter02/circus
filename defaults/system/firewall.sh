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
# Domain:       /Library/Preferences/com.apple.alf
# Description:  Controls the overall state of the macOS Application Level
#               Firewall (ALF). When enabled, macOS monitors incoming network
#               connections and can block unauthorized applications from
#               receiving connections. The firewall operates at the application
#               level, meaning it controls which apps can accept connections.
# Default:      0 (Off - firewall is disabled on most Macs)
# Options:      0 = Off (firewall disabled, all incoming connections allowed)
#               1 = On (firewall enabled, per-app control)
#               2 = On (block all incoming connections except essential services)
# Set to:       1 (enabled with per-app control for balanced security)
# UI Location:  System Settings > Network > Firewall
# Source:       https://support.apple.com/en-us/102445
# See also:     https://support.apple.com/guide/mac-help/block-connections-to-your-mac-with-a-firewall-mh34041/mac
# Security:     The firewall is essential for Macs used on public networks
#               (coffee shops, airports) to prevent unauthorized access.
run_sudo_defaults "/Library/Preferences/com.apple.alf" "globalstate" "-int" "1"

# --- Enable Stealth Mode ---
# Key:          stealthenabled
# Domain:       /Library/Preferences/com.apple.alf
# Description:  When enabled, the Mac does not respond to network probing
#               requests such as ICMP ping, port scans, or service discovery
#               protocols (like Bonjour). This makes the Mac harder to detect
#               and fingerprint on a network, reducing its attack surface.
# Default:      0 (Off - Mac responds to network probes normally)
# Options:      0 = Off (Mac responds to ping and network probes)
#               1 = On (Mac ignores probes silently, appears offline)
# Set to:       1 (enabled for enhanced security on untrusted networks)
# UI Location:  System Settings > Network > Firewall > Options > Enable stealth mode
# Source:       https://support.apple.com/guide/mac-help/use-stealth-mode-to-keep-your-mac-more-secure-mh11463/mac
# Security:     Stealth mode provides defense-in-depth by making your Mac
#               invisible to casual network scans. However, this may prevent
#               legitimate services (like network discovery) from working.
run_sudo_defaults "/Library/Preferences/com.apple.alf" "stealthenabled" "-int" "1"

# --- Enable Logging ---
# Key:          loggingenabled
# Domain:       /Library/Preferences/com.apple.alf
# Description:  Enables logging of firewall activity. When enabled, the firewall
#               records blocked connections and security events to the system log.
#               Logs can be viewed using Console.app or the log command.
# Default:      0 (Off - no firewall logging)
# Options:      0 = Off (firewall events not logged)
#               1 = On (firewall events logged to system log)
# Set to:       1 (enabled for security auditing and troubleshooting)
# UI Location:  No direct UI toggle - accessible via command line only
# Source:       https://support.apple.com/en-us/102445
# Note:         View logs with: log show --predicate 'subsystem == "com.apple.alf"'
#               or check /var/log/appfirewall.log on older macOS versions.
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
