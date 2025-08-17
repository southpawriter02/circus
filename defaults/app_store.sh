#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: App Store Configuration
#
# This script configures settings for the Mac App Store, particularly for
# automatic updates. It is sourced by Stage 11 of the main installer.
# It supports Dry Run mode.
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

msg_info "Configuring App Store settings..."

# ------------------------------------------------------------------------------
# Automatic Update Settings
# ------------------------------------------------------------------------------

# --- Enable Automatic Check for Updates ---
# Description:  Tells the App Store to automatically check for updates.
# Default:      true
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.SoftwareUpdate" "AutomaticCheckEnabled" "-bool" "true"

# --- Enable Background Downloading of Updates ---
# Description:  Allows the App Store to download newly available updates in the background.
# Default:      true
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.SoftwareUpdate" "AutomaticDownload" "-bool" "true"

# --- Enable Automatic Installation of App Updates ---
# Description:  Automatically installs app updates that have been downloaded.
# Default:      true
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.commerce" "AutoUpdate" "-bool" "true"

# --- Enable Automatic Installation of macOS Updates ---
# Description:  Automatically installs macOS updates.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.SoftwareUpdate" "AutomaticallyInstallMacOSUpdates" "-bool" "true"

# --- Enable Automatic Installation of Security Updates ---
# Description:  Automatically installs system data files and security updates.
#               This is a critical security setting.
# Default:      true
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.SoftwareUpdate" "CriticalUpdateInstall" "-bool" "true"


msg_success "App Store settings applied."
