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
#               to check for new macOS versions, security patches, and
#               system data files. This is the foundation of keeping your
#               Mac secure and up-to-date.
# Default:      true (automatic checking enabled)
# Options:      true  = Automatically check for updates periodically
#               false = Only check when manually triggered
# Set to:       true (essential for staying informed about updates)
# UI Location:  System Settings > General > Software Update >
#               Automatic updates > Check for updates
# Source:       https://support.apple.com/en-us/102582
# See also:     https://support.apple.com/guide/mac-help/keep-your-mac-up-to-date-mchlpx1065/mac
run_defaults "com.apple.SoftwareUpdate" "AutomaticCheckEnabled" "-bool" "true"

# --- Enable Background Downloading of Updates ---
# Key:          AutomaticDownload
# Domain:       com.apple.SoftwareUpdate
# Description:  Allows macOS to download newly available updates in the
#               background without user intervention. This means updates
#               are ready to install when you are, reducing wait time.
#               Downloads are intelligent - they happen during off-peak
#               times and pause when bandwidth is needed elsewhere.
# Default:      true (background downloads enabled)
# Options:      true  = Download updates automatically in background
#               false = Wait for user to initiate download
# Set to:       true (reduces wait time when ready to install)
# UI Location:  System Settings > General > Software Update >
#               Automatic updates > Download new updates when available
# Source:       https://support.apple.com/en-us/102582
# Note:         Consider disabling on metered connections or if you have
#               limited bandwidth. Downloads are compressed to minimize impact.
run_defaults "com.apple.SoftwareUpdate" "AutomaticDownload" "-bool" "true"

# ==============================================================================
# Automatic Installation Settings
# ==============================================================================

# --- Enable Automatic Installation of App Updates ---
# Key:          AutoUpdate
# Domain:       com.apple.commerce
# Description:  Automatically installs updates for apps purchased from
#               the Mac App Store. Apps are updated in the background
#               when updates are available. This keeps your App Store
#               apps patched with the latest features and security fixes.
# Default:      true (automatic App Store updates enabled)
# Options:      true  = Install App Store app updates automatically
#               false = Notify but require manual installation
# Set to:       true (keep apps current with minimal effort)
# UI Location:  System Settings > General > Software Update >
#               Automatic updates > Install App Store app updates
# Source:       https://support.apple.com/en-us/102582
# Note:         Only affects apps from the Mac App Store. Apps installed
#               via Homebrew or direct download have their own update mechanisms.
run_defaults "com.apple.commerce" "AutoUpdate" "-bool" "true"

# --- Enable Automatic Installation of macOS Updates ---
# Key:          AutomaticallyInstallMacOSUpdates
# Domain:       com.apple.SoftwareUpdate
# Description:  Automatically installs macOS updates. Minor updates (e.g.,
#               macOS 14.1 to 14.2) are installed automatically, while major
#               version upgrades (e.g., Sonoma to next major release) typically
#               still require user confirmation. Updates requiring a restart
#               will prompt the user unless the Mac is unattended.
# Default:      false (user confirmation required for installation)
# Options:      true  = Install macOS updates automatically
#               false = Notify but require manual installation
# Set to:       true (automatic for convenience and security)
# UI Location:  System Settings > General > Software Update >
#               Automatic updates > Install macOS updates
# Source:       https://support.apple.com/en-us/102582
# See also:     https://support.apple.com/en-us/105313
# Note:         Updates are typically installed overnight when your Mac is
#               connected to power and not in active use.
run_defaults "com.apple.SoftwareUpdate" "AutomaticallyInstallMacOSUpdates" "-bool" "true"

# --- Enable Automatic Installation of Security Updates ---
# Key:          CriticalUpdateInstall
# Domain:       com.apple.SoftwareUpdate
# Description:  Automatically installs system data files and security updates.
#               These are small, critical updates that patch security
#               vulnerabilities, often without requiring a restart. Includes
#               XProtect (malware definitions), Gatekeeper data, and MRT
#               (Malware Removal Tool) updates.
# Default:      true (security responses enabled by default)
# Options:      true  = Install security updates automatically
#               false = Require manual installation (NOT recommended)
# Set to:       true (CRITICAL - should always be enabled)
# UI Location:  System Settings > General > Software Update >
#               Automatic updates > Install Security Responses and system files
# Source:       https://support.apple.com/en-us/102582
# See also:     https://support.apple.com/guide/mac-help/get-macos-updates-mchlpx1065/mac
# Security:     ⚠️ This is one of the most important security settings.
#               Security updates patch actively exploited vulnerabilities
#               and protect against emerging threats. Never disable this.
run_defaults "com.apple.SoftwareUpdate" "CriticalUpdateInstall" "-bool" "true"


msg_success "Software Update and App Store settings applied."
