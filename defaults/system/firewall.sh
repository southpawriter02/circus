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
# macOS Firewall Architecture
# ==============================================================================

# The macOS Application Level Firewall (ALF) is a socket filter firewall that
# operates at Layer 7 (Application Layer) rather than Layer 3/4 (Network Layer).
#
# How ALF Differs from Traditional Firewalls:
#
#   Traditional Firewall (iptables, pf):
#   - Filters by IP address, port, protocol
#   - Rules: "Block port 22" or "Allow 192.168.1.0/24"
#   - Cannot distinguish which application owns a connection
#
#   macOS ALF:
#   - Filters by application identity (code signature)
#   - Rules: "Allow Safari" or "Block SomeApp.app"
#   - Knows which app is making/receiving each connection
#   - Integrates with Gatekeeper for trust decisions
#
# ALF + pf (Packet Filter):
#   macOS actually has TWO firewalls:
#   1. ALF (Application Level Firewall) - User-facing, app-based (this script)
#   2. pf (Packet Filter) - Low-level, BSD packet filter (off by default)
#
#   For network-level blocking (IP addresses, ports), use pf:
#     man pf.conf
#     sudo pfctl -e              # Enable pf
#     sudo pfctl -d              # Disable pf
#     cat /etc/pf.conf           # View default rules
#
# Source:       https://support.apple.com/guide/security/firewall-sec5a7cc02ce/web

# ==============================================================================
# Firewall State Configuration
# ==============================================================================

# --- Enable Application Level Firewall ---
# Key:          globalstate
# Domain:       /Library/Preferences/com.apple.alf
# Description:  Controls the overall state of the macOS Application Level
#               Firewall (ALF). When enabled, macOS monitors incoming network
#               connections and blocks unauthorized applications from receiving
#               connections based on code signing and user preferences.
#
#               What Happens When ALF is Enabled:
#               1. All signed Apple applications are automatically allowed
#               2. Signed third-party apps may be allowed based on settings
#               3. Unsigned apps trigger a "Allow or Deny" prompt on first connection
#               4. Denied apps are blocked silently thereafter
#               5. Rules are stored per-application in the firewall database
#
#               What ALF Does NOT Do:
#               - Does NOT filter outgoing connections (apps can always connect out)
#               - Does NOT block by IP address or port (use pf for that)
#               - Does NOT protect against malware already running as you
#
# Default:      0 (Off - firewall disabled on consumer Macs)
# Options:      0 = Off (firewall disabled, all incoming connections allowed)
#               1 = On (standard mode, per-app control with prompts)
#               2 = On (Block All Incoming - only essential services allowed)
#
#               Mode 2 Details (Block All Incoming):
#               - Blocks ALL incoming connections except:
#                 • DHCP (getting an IP address)
#                 • Bonjour (for AirDrop, Handoff on local network)
#                 • IPSec (VPN connections)
#               - Useful for untrusted networks (airports, coffee shops)
#               - Will break: Screen Sharing, File Sharing, SSH, etc.
#
# Set to:       1 (enabled with per-app control - balanced security)
# UI Location:  System Settings > Network > Firewall
# Source:       https://support.apple.com/en-us/102445
# See also:     https://support.apple.com/guide/mac-help/block-connections-to-your-mac-with-a-firewall-mh34041/mac
#
# Security:     The firewall is ESSENTIAL for Macs used on public networks.
#               Without it, any network service your Mac runs (intentionally or
#               not) is exposed to everyone on the same network.
#
#               Attack Scenario Without Firewall:
#               1. You enable Screen Sharing to help a friend
#               2. You forget to disable it
#               3. You connect to coffee shop Wi-Fi
#               4. Anyone on that network can attempt to connect to your Mac
#
# Enterprise:   For managed Macs, enforce via MDM configuration profile:
#               - Profile domain: com.apple.applicationfirewall
#               - Key: EnableFirewall (true/false)
#               - Key: BlockAllIncoming (true/false)
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

# --- Allow Signed Applications Automatically ---
# Key:          allowsignedenabled
# Domain:       /Library/Preferences/com.apple.alf
# Description:  Automatically allow applications signed with a valid developer
#               certificate to receive incoming connections without prompting.
#               This reduces firewall prompts for legitimate signed software.
# Default:      1 (enabled - signed apps allowed)
# Options:      0 = Prompt for all apps (most secure but annoying)
#               1 = Allow signed apps automatically (balanced)
# Set to:       1 (allow signed apps for convenience)
# UI Location:  System Settings > Network > Firewall > Options > Automatically allow built-in software
# Source:       https://support.apple.com/en-us/102445
run_sudo_defaults "/Library/Preferences/com.apple.alf" "allowsignedenabled" "-int" "1"

# --- Allow Downloaded Signed Applications ---
# Key:          allowdownloadsignedenabled
# Domain:       /Library/Preferences/com.apple.alf
# Description:  Automatically allow downloaded applications that are signed with
#               a valid certificate to receive incoming connections. Combined with
#               Gatekeeper, this ensures only trusted downloads get network access.
# Default:      1 (enabled - signed downloads allowed)
# Options:      0 = Don't automatically allow downloaded signed apps
#               1 = Allow downloaded signed apps automatically
# Set to:       1 (allow signed downloads for usability)
# UI Location:  System Settings > Network > Firewall > Options > Automatically allow downloaded signed software
# Source:       https://support.apple.com/en-us/102445
run_sudo_defaults "/Library/Preferences/com.apple.alf" "allowdownloadsignedenabled" "-int" "1"


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
