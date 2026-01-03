#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Setapp Configuration
#
# DESCRIPTION:
#   This script configures Setapp preferences including auto-updates, startup
#   behavior, and notifications. Setapp is a subscription service providing
#   access to a curated collection of macOS applications.
#
# REQUIRES:
#   - macOS 10.14.4 (Mojave) or later
#   - Setapp installed and signed in
#
# REFERENCES:
#   - Setapp Help: Getting Started
#     https://support.setapp.com/hc/en-us/articles/360000122313-Getting-started-with-Setapp
#   - Setapp Help: Setapp settings
#     https://support.setapp.com/hc/en-us/articles/360000130794-Setapp-settings
#
# DOMAIN:
#   com.macpaw.setapp
#
# NOTES:
#   - Setapp stores preferences in ~/Library/Preferences/com.macpaw.setapp.plist
#   - Apps installed via Setapp are managed separately in ~/Applications (Setapp)/
#   - Auto-update behavior affects all Setapp-installed applications
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Setapp preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Setapp settings..."

# ==============================================================================
# Update Settings
# ==============================================================================

# --- Automatic Updates ---
# Key:          SUAutomaticallyUpdate
# Domain:       com.macpaw.setapp
# Description:  Controls whether Setapp and its managed applications update
#               automatically in the background. Keeping this enabled ensures
#               you always have the latest features and security fixes.
# Default:      true (auto-updates enabled)
# Options:      true  = Enable automatic updates
#               false = Disable automatic updates (manual only)
# Set to:       true (recommended for security)
# UI Location:  Setapp menu bar > Settings > General > Install updates automatically
# Source:       https://support.setapp.com/hc/en-us/articles/360000130794-Setapp-settings
run_defaults "com.macpaw.setapp" "SUAutomaticallyUpdate" "-bool" "true"

# --- Check for Updates ---
# Key:          SUEnableAutomaticChecks
# Domain:       com.macpaw.setapp
# Description:  Controls whether Setapp periodically checks for available
#               updates. This is separate from auto-installing updates.
# Default:      true (update checks enabled)
# Options:      true  = Check for updates automatically
#               false = Don't check for updates
# Set to:       true (know when updates are available)
# UI Location:  Setapp menu bar > Settings > General
# Source:       https://support.setapp.com/hc/en-us/articles/360000130794-Setapp-settings
run_defaults "com.macpaw.setapp" "SUEnableAutomaticChecks" "-bool" "true"

# ==============================================================================
# Startup Settings
# ==============================================================================

# --- Launch at Login ---
# Key:          LaunchAtLogin
# Domain:       com.macpaw.setapp
# Description:  Controls whether Setapp starts automatically when you log in.
#               Having Setapp running ensures your apps are up to date and
#               you have quick access to the app catalog.
# Default:      true (launch at login)
# Options:      true  = Start Setapp when logging in
#               false = Don't start automatically
# Set to:       true (recommended for keeping apps updated)
# UI Location:  Setapp menu bar > Settings > General > Launch Setapp at login
# Source:       https://support.setapp.com/hc/en-us/articles/360000130794-Setapp-settings
run_defaults "com.macpaw.setapp" "LaunchAtLogin" "-bool" "true"

# ==============================================================================
# Menu Bar Settings
# ==============================================================================

# --- Menu Bar Icon ---
# Key:          ShowInMenuBar
# Domain:       com.macpaw.setapp
# Description:  Controls whether the Setapp icon appears in the menu bar.
#               The icon provides quick access to your Setapp apps and
#               shows update notifications.
# Default:      true (show in menu bar)
# Options:      true  = Show Setapp icon in menu bar
#               false = Hide menu bar icon
# Set to:       true (easy access to app catalog)
# UI Location:  Setapp menu bar > Settings > General > Show Setapp in menu bar
# Source:       https://support.setapp.com/hc/en-us/articles/360000130794-Setapp-settings
run_defaults "com.macpaw.setapp" "ShowInMenuBar" "-bool" "true"

msg_success "Setapp settings applied."
msg_info "Setapp apps are installed to: ~/Applications (Setapp)/"
