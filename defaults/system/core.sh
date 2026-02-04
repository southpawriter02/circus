#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Core System Settings (systemsetup)
#
# DESCRIPTION:
#   This script uses the `systemsetup` command to configure core system-level
#   settings. These are low-level settings that affect the entire system,
#   including network time, timezone, and restart behavior.
#
# REQUIRES:
#   - Administrative privileges (runs commands with sudo)
#   - macOS 10.0 or later
#
# REFERENCES:
#   - systemsetup man page: man systemsetup
#   - Apple Support: Date & Time preferences on Mac
#     https://support.apple.com/guide/mac-help/set-the-date-and-time-automatically-mchlp2996/mac
#   - Apple Support: Share your Mac with other users
#     https://support.apple.com/guide/mac-help/share-your-mac-with-other-users-mh35594/mac
#
# COMMAND:
#   systemsetup - System configuration tool for administrators
#
# NOTES:
#   - Most systemsetup commands require sudo privileges
#   - Some settings may require a restart to take effect
#   - Remote login should typically be disabled for security
#
# ==============================================================================

# --- Sudo Check & Re-invocation ---------------------------------------------
if [ "$EUID" -ne 0 ] && [ "$DRY_RUN_MODE" = false ]; then
  msg_info "System setup requires administrative privileges."
  sudo "$0" "$@"
  exit $?
fi

# --- Main Logic -------------------------------------------------------------

msg_info "Configuring core system settings with systemsetup..."

# A helper function to run `systemsetup` commands or print them in dry run mode.
run_systemsetup() {
  local command_args=("$@")
  local description="${command_args[0]}"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: systemsetup ${command_args[*]}"
  else
    if systemsetup "${command_args[@]}"; then
      msg_success "System setting configured: ${description}"
    else
      msg_error "Failed to configure system setting: ${description}"
    fi
  fi
}

# ==============================================================================
# Network Time Protocol (NTP) Settings
# ==============================================================================

# Why Accurate Time Matters:
#
# Accurate time is critical for many system functions:
#
# 1. SECURITY (TLS/SSL Certificates)
#    - Certificates have validity windows (Not Before / Not After)
#    - If your clock is wrong, valid certs may appear expired
#    - Attackers can't replay old signed content on time-synced systems
#
# 2. FILE TIMESTAMPS (Make, Git, Backups)
#    - Build systems rely on modification times
#    - Version control tracks when changes occurred
#    - Time Machine needs accurate file dates
#
# 3. LOGS & AUDITING
#    - Correlating events across systems requires synchronized time
#    - Compliance requirements often mandate accurate timestamps
#
# 4. KERBEROS AUTHENTICATION
#    - Active Directory/SSO requires clocks within 5 minutes
#    - Time skew breaks enterprise authentication
#
# NTP Architecture:
#   NTP uses a hierarchy of time sources called "strata":
#   - Stratum 0: Atomic clocks, GPS receivers (reference clocks)
#   - Stratum 1: Servers directly connected to Stratum 0
#   - Stratum 2: Servers synced to Stratum 1 (time.apple.com is here)
#   - Stratum 3+: Further downstream servers
#
# Source:       https://support.apple.com/guide/mac-help/set-the-date-and-time-automatically-mchlp2996/mac

# --- Set Network Time Server ---
# Command:      systemsetup -setnetworktimeserver <server>
# Description:  Specifies which NTP server macOS uses for time synchronization.
#               Apple's time.apple.com is a reliable, geographically distributed
#               pool that provides low-latency responses worldwide.
#
#               Alternative NTP Servers:
#               - time.apple.com    (Apple's default, anycast, worldwide)
#               - time.google.com   (Google's smeared leap-second pool)
#               - pool.ntp.org      (Volunteer pool, variable quality)
#               - time.windows.com  (Microsoft, for mixed environments)
#               - time.cloudflare.com (Cloudflare, low latency)
#
#               Enterprise Considerations:
#               - Many enterprises run internal NTP servers
#               - This ensures time sync even if internet is down
#               - Reduces external dependencies
#
# Default:      time.apple.com (Apple's anycast NTP pool)
# Set to:       time.apple.com (reliable, low-latency, anycast)
# UI Location:  System Settings > General > Date & Time > Source
# Source:       man systemsetup
# Security:     Using a trusted NTP source prevents time-based attacks.
#               Rogue NTP servers could manipulate certificate validation.
run_systemsetup "-setnetworktimeserver" "time.apple.com"

# --- Enable Network Time Synchronization ---
# Command:      systemsetup -setusingnetworktime <on|off>
# Description:  Enables automatic time synchronization with the configured
#               NTP server. When enabled, macOS periodically queries the time
#               server and adjusts the local clock to match.
#
#               How Often macOS Syncs:
#               - Initial sync at boot
#               - Periodic sync every few hours (frequency varies)
#               - On network change (e.g., waking from sleep, new WiFi)
#
# Default:      on (automatic time sync enabled)
# Options:      on = Automatically sync with NTP server
#               off = Use manual time only (NOT recommended)
# Set to:       on (essential for security and system function)
# UI Location:  System Settings > General > Date & Time > Set date and time automatically
# Security:     Disabling NTP can cause TLS certificate errors and break
#               Kerberos authentication. Only disable for air-gapped systems.
run_systemsetup "-setusingnetworktime" "on"

# ==============================================================================
# Timezone Settings
# ==============================================================================

# --- Enable Location-Based Timezone ---
# Command:      systemsetup -setusinglocationservices <on|off>
# Description:  Allows macOS to automatically determine and update the timezone
#               based on the Mac's geographic location (using Wi-Fi positioning,
#               IP geolocation, or GPS on supported hardware).
#
#               How Location-Based Timezone Works:
#               - Uses Wi-Fi access point database for positioning
#               - Falls back to IP geolocation if Wi-Fi unavailable
#               - Updates timezone when you travel to new time zones
#
#               Privacy Trade-off:
#               - Pro: Automatic timezone when traveling
#               - Con: Requires Location Services for "Set Time Zone"
#               - Apple receives location data (see Privacy Policy)
#
# Default:      Varies by region and setup choices
# Options:      on = Automatic timezone (uses location)
#               off = Manual timezone (you set it once)
# Set to:       on (convenient for travelers; disable for privacy)
# UI Location:  System Settings > General > Date & Time > Set time zone automatically
# Note:         Requires Location Services enabled for "System Services" >
#               "Setting Time Zone" in System Settings > Privacy & Security
# Privacy:      If you prefer not to share location, set timezone manually:
#               sudo systemsetup -settimezone "America/Los_Angeles"
#               Use `systemsetup -listtimezones` to see all options.
run_systemsetup "-setusinglocationservices" "on"

# ==============================================================================
# Security Settings
# ==============================================================================

# --- Disable Remote Login (SSH) ---
# Command:      systemsetup -setremotelogin <on|off>
# Description:  Controls whether SSH (Secure Shell) access is enabled.
#               When enabled, users can connect to this Mac remotely via SSH.
# Default:      off
# Possible:     on, off
# Set to:       off (disabled by default for security)
# Security:     Only enable if you need remote command-line access.
#               Enabling SSH creates a potential attack vector.
# Reference:    System Preferences > Sharing > Remote Login
run_systemsetup "-setremotelogin" "off"

# ==============================================================================
# Stability Settings
# ==============================================================================

# --- Restart on System Freeze ---
# Command:      systemsetup -setrestartfreeze <on|off>
# Description:  Configures the Mac to automatically restart if it becomes
#               completely unresponsive (kernel panic or freeze).
# Default:      off
# Possible:     on, off
# Set to:       on (recommended for servers or unattended Macs)
# Note:         This is particularly useful for headless servers or
#               machines that need high availability.
run_systemsetup "-setrestartfreeze" "on"

msg_success "Core system settings configuration complete."
