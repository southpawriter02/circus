#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Software Update & App Store Configuration
#
# DESCRIPTION:
#   This script configures automatic software update settings for macOS and
#   applications from the Mac App Store. Keeping software up-to-date is one
#   of the most important security practices.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later for full functionality
#   - macOS 10.8 (Mountain Lion) or later for basic settings
#
# REFERENCES:
#   - Apple Support: Keep your Mac up to date
#     https://support.apple.com/en-us/102582
#   - Apple Support: How to get updates for macOS
#     https://support.apple.com/en-us/105313
#   - softwareupdate man page: man softwareupdate
#
# DOMAINS:
#   com.apple.SoftwareUpdate - macOS software update settings
#   com.apple.commerce       - App Store purchase and update settings
#
# NOTES:
#   - Automatic security updates are critical and should always be enabled
#   - Background downloading reduces wait time when installing updates
#   - Consider network bandwidth when enabling automatic downloads
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set App Store preference: '$key' to '$value'"
  else
    # These settings are for the App Store, so we use its domain.
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Software Update and App Store settings..."

# ==============================================================================
# Automatic Update Checking
# ==============================================================================

# --- Enable Automatic Check for Updates ---
# Key:          AutomaticCheckEnabled
# Domain:       com.apple.SoftwareUpdate
# Description:  Tells macOS to automatically check for available updates.
#               When enabled, macOS periodically contacts Apple's servers
#               to check for new macOS versions and security updates.
# Default:      true
# Possible:     true, false
# Set to:       true
# Reference:    System Preferences > Software Update > Automatically keep my Mac up to date
run_defaults "com.apple.SoftwareUpdate" "AutomaticCheckEnabled" "-bool" "true"

# --- Enable Background Downloading of Updates ---
# Key:          AutomaticDownload
# Domain:       com.apple.SoftwareUpdate
# Description:  Allows macOS to download newly available updates in the
#               background without user intervention. This means updates
#               are ready to install when you are.
# Default:      true
# Possible:     true, false
# Set to:       true
# Note:         Downloads happen during off-peak times to minimize
#               impact on network performance.
run_defaults "com.apple.SoftwareUpdate" "AutomaticDownload" "-bool" "true"

# ==============================================================================
# Automatic Installation Settings
# ==============================================================================

# --- Enable Automatic Installation of App Updates ---
# Key:          AutoUpdate
# Domain:       com.apple.commerce
# Description:  Automatically installs updates for apps purchased from
#               the Mac App Store. Apps are updated in the background
#               when updates are available.
# Default:      true
# Possible:     true, false
# Set to:       true
# Reference:    System Preferences > App Store > Automatic Updates
run_defaults "com.apple.commerce" "AutoUpdate" "-bool" "true"

# --- Enable Automatic Installation of macOS Updates ---
# Key:          AutomaticallyInstallMacOSUpdates
# Domain:       com.apple.SoftwareUpdate
# Description:  Automatically installs macOS updates. Major version upgrades
#               (e.g., Monterey to Ventura) typically still require user
#               confirmation, but minor updates (e.g., 13.1 to 13.2) can
#               be installed automatically.
# Default:      false (user confirmation required)
# Possible:     true, false
# Set to:       true (automatic for convenience and security)
# Note:         Updates requiring a restart will prompt the user unless
#               the Mac is unattended.
run_defaults "com.apple.SoftwareUpdate" "AutomaticallyInstallMacOSUpdates" "-bool" "true"

# --- Enable Automatic Installation of Security Updates ---
# Key:          CriticalUpdateInstall
# Domain:       com.apple.SoftwareUpdate
# Description:  Automatically installs system data files and security updates.
#               These are small, critical updates that patch security
#               vulnerabilities without requiring a restart in most cases.
# Default:      true
# Possible:     true, false
# Set to:       true (CRITICAL - should always be enabled)
# Security:     This is one of the most important security settings.
#               Security updates patch actively exploited vulnerabilities.
# Reference:    System Preferences > Software Update > Install system data files and security updates
run_defaults "com.apple.SoftwareUpdate" "CriticalUpdateInstall" "-bool" "true"


msg_success "Software Update and App Store settings applied."
