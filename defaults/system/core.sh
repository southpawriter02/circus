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

# --- Set Network Time Server ---
# Command:      systemsetup -setnetworktimeserver <server>
# Description:  Sets the server used for network time synchronization.
#               Apple's time server is reliable and well-maintained.
# Default:      time.apple.com
# Possible:     Any valid NTP server (e.g., time.google.com, pool.ntp.org)
# Set to:       time.apple.com
# Reference:    System Preferences > Date & Time > Date & Time
run_systemsetup "-setnetworktimeserver" "time.apple.com"

# --- Enable Network Time ---
# Command:      systemsetup -setusingnetworktime <on|off>
# Description:  Enables or disables automatic time synchronization with
#               the configured NTP server. Accurate time is important for
#               security (certificate validation), file timestamps, and
#               collaboration tools.
# Default:      on
# Possible:     on, off
# Set to:       on
run_systemsetup "-setusingnetworktime" "on"

# ==============================================================================
# Timezone Settings
# ==============================================================================

# --- Enable Location Services for Timezone ---
# Command:      systemsetup -setusinglocationservices <on|off>
# Description:  Allows macOS to automatically determine and set the timezone
#               based on the Mac's current geographic location.
# Default:      Varies
# Possible:     on, off
# Set to:       on (automatic timezone is convenient for travelers)
# Note:         This requires Location Services to be enabled in System Preferences
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
