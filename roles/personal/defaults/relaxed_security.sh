#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Relaxed Security Settings (Personal Role)
#
# DESCRIPTION:
#   Less restrictive security settings for personal/home use.
#   Prioritizes convenience while maintaining reasonable security.
#   Contrast with roles/work/defaults/security.sh which is stricter.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#
# REFERENCES:
#   - Apple Platform Security Guide
#     https://support.apple.com/guide/security/welcome/web
#
# DOMAIN:
#   com.apple.screensaver
#   com.apple.finder
#   com.apple.NetworkBrowser
#   NSGlobalDomain
#
# NOTES:
#   - These settings are more permissive than corporate defaults
#   - Suitable for personal machines in trusted environments
#   - Review and adjust based on your security needs
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Personal Security preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Applying personal (relaxed) security settings..."

# ==============================================================================
# Screen Lock Settings (More Relaxed)
# ==============================================================================

# --- Require Password After Sleep ---
# Key:          askForPassword
# Domain:       com.apple.screensaver
# Description:  Require password when waking from sleep.
# Work:         1 (always require)
# Set to:       1 (still require - basic security)
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- Password Delay ---
# Key:          askForPasswordDelay
# Domain:       com.apple.screensaver
# Description:  Delay before requiring password (in seconds).
# Work:         0 (immediately)
# Set to:       5 (5 seconds - time to cancel accidental sleep)
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "5"

# --- Screen Saver Activation Time ---
# Key:          idleTime
# Domain:       com.apple.screensaver
# Description:  Start screen saver after idle time (in seconds).
# Work:         300 (5 minutes)
# Set to:       600 (10 minutes - more relaxed at home)
run_defaults -currentHost "com.apple.screensaver" "idleTime" "-int" "600"

# ==============================================================================
# AirDrop & Sharing (More Open)
# ==============================================================================

# --- Enable AirDrop ---
# Key:          DisableAirDrop
# Domain:       com.apple.NetworkBrowser
# Description:  AirDrop file sharing capability.
# Work:         true (disabled)
# Set to:       false (enabled - convenient for home use)
run_defaults "com.apple.NetworkBrowser" "DisableAirDrop" "-bool" "false"

# --- AirDrop Discovery Mode ---
# Key:          BrowseAllInterfaces
# Domain:       com.apple.NetworkBrowser
# Description:  Allow AirDrop to browse all network interfaces.
# Set to:       true (enable for better device discovery)
run_defaults "com.apple.NetworkBrowser" "BrowseAllInterfaces" "-bool" "true"

# ==============================================================================
# Bluetooth Settings (Convenient)
# ==============================================================================

# --- Enable Bluetooth Sharing ---
# Key:          PrefKeyServicesEnabled
# Domain:       com.apple.Bluetooth
# Description:  Bluetooth file sharing services.
# Work:         false (disabled)
# Set to:       true (enabled for easy file transfers)
run_defaults "com.apple.Bluetooth" "PrefKeyServicesEnabled" "-bool" "true"

# --- Bluetooth Discoverability ---
# Key:          DiscoverableState
# Domain:       com.apple.Bluetooth
# Description:  Allow device to be discovered.
# Work:         0 (not discoverable)
# Set to:       1 (discoverable for easy pairing)
run_defaults "com.apple.Bluetooth" "DiscoverableState" "-int" "1"

# ==============================================================================
# Continuity Features (Enabled)
# ==============================================================================

# --- Enable Handoff ---
# Key:          Allowed
# Domain:       com.apple.Handoff
# Description:  Continue tasks between Apple devices.
# Work:         May be disabled
# Set to:       true (convenient across personal devices)
run_defaults "com.apple.Handoff" "Allowed" "-bool" "true"

# --- Universal Clipboard ---
# Note: Enabled by default when Handoff is on
# Allows copy/paste between devices

# --- AirPlay Receiver ---
# Key:          AirPlayRecieverEnabled
# Domain:       com.apple.controlcenter
# Description:  Allow AirPlay to this Mac.
# Set to:       true (stream to Mac from iPhone/iPad)
run_defaults "com.apple.controlcenter" "AirPlayRecieverEnabled" "-bool" "true"

# ==============================================================================
# Finder Settings (Convenient)
# ==============================================================================

# --- Show File Extensions ---
# Key:          AppleShowAllExtensions
# Domain:       NSGlobalDomain
# Description:  Show all file extensions.
# Set to:       true (still a good practice)
run_defaults "NSGlobalDomain" "AppleShowAllExtensions" "-bool" "true"

# --- Warn Before Changing File Extension ---
# Key:          FXEnableExtensionChangeWarning
# Domain:       com.apple.finder
# Description:  Warn when changing a file extension.
# Work:         true
# Set to:       false (power user preference - less nagging)
run_defaults "com.apple.finder" "FXEnableExtensionChangeWarning" "-bool" "false"

# --- Warn Before Emptying Trash ---
# Key:          WarnOnEmptyTrash
# Domain:       com.apple.finder
# Description:  Ask for confirmation before emptying trash.
# Work:         true
# Set to:       false (personal preference - less confirmation)
run_defaults "com.apple.finder" "WarnOnEmptyTrash" "-bool" "false"

# ==============================================================================
# Login & Access Settings
# ==============================================================================

# --- Guest Account ---
# Key:          GuestEnabled
# Domain:       com.apple.loginwindow
# Description:  Allow guest access to the computer.
# Work:         false (disabled)
# Set to:       false (still disabled - basic security)
run_defaults "com.apple.loginwindow" "GuestEnabled" "-bool" "false"

# --- Show User List at Login ---
# Key:          SHOWFULLNAME
# Domain:       com.apple.loginwindow
# Description:  Show user list instead of name/password fields.
# Work:         true (name/password only)
# Set to:       false (show user list - convenient at home)
run_defaults "com.apple.loginwindow" "SHOWFULLNAME" "-bool" "false"

# --- Auto-Login ---
# Note: Not set via defaults, but this is acceptable for single-user home Macs
# Configure via: System Settings > Users & Groups > Login Options
msg_info "Note: Auto-login can be enabled via System Settings for home use"

# ==============================================================================
# Privacy Settings (Balanced)
# ==============================================================================

# --- Personalized Ads ---
# Key:          allowApplePersonalizedAdvertising
# Domain:       com.apple.AdLib
# Description:  Personalized ads from Apple.
# Set to:       false (disabled for privacy - same as work)
run_defaults "com.apple.AdLib" "allowApplePersonalizedAdvertising" "-bool" "false"

# --- Location Services ---
# Note: Controlled via System Settings, but generally enabled for personal use
# Useful for: Find My, Weather, Maps, Photos geotagging
msg_info "Recommendation: Enable Location Services for convenience apps"
msg_info "  System Settings > Privacy & Security > Location Services"

# --- Analytics & Improvements ---
# Key:          AutomaticCheckEnabled
# Domain:       com.apple.SoftwareUpdate
# Description:  Share analytics with Apple.
# Personal:     User choice (we leave it up to the user)
msg_info "Note: Sharing analytics with Apple is a personal choice"
msg_info "  System Settings > Privacy & Security > Analytics & Improvements"

# ==============================================================================
# Gatekeeper (Standard Security)
# ==============================================================================

# --- App Store and Identified Developers ---
# Note: Keep standard Gatekeeper settings (not fully open)
# This allows apps from App Store and identified developers
msg_info "Recommendation: Keep Gatekeeper at 'App Store and identified developers'"
msg_info "  Avoid 'Anywhere' - it significantly reduces security"

# --- Ensure Gatekeeper is Enabled ---
msg_info "Checking Gatekeeper status..."
if spctl --status 2>/dev/null | grep -q "disabled"; then
    msg_warn "Gatekeeper is DISABLED. Consider enabling: sudo spctl --master-enable"
else
    msg_success "Gatekeeper is enabled (good!)."
fi

# ==============================================================================
# Safari Settings (Convenient but Safe)
# ==============================================================================

# --- Warn About Fraudulent Websites ---
# Key:          WarnAboutFraudulentWebsites
# Domain:       com.apple.Safari
# Description:  Show warning for known phishing sites.
# Set to:       true (keep enabled - important protection)
run_defaults "com.apple.Safari" "WarnAboutFraudulentWebsites" "-bool" "true"

# --- AutoFill Credit Cards ---
# Key:          AutoFillCreditCardData
# Domain:       com.apple.Safari
# Description:  Auto-fill credit card information.
# Work:         false
# Set to:       true (convenient for personal shopping)
run_defaults "com.apple.Safari" "AutoFillCreditCardData" "-bool" "true"

# --- Do Not Track ---
# Key:          SendDoNotTrackHTTPHeader
# Domain:       com.apple.Safari
# Description:  Send Do Not Track header.
# Set to:       true (request not to be tracked)
run_defaults "com.apple.Safari" "SendDoNotTrackHTTPHeader" "-bool" "true"

msg_success "Personal security settings applied."
echo ""
msg_info "Summary of relaxed settings compared to work role:"
echo "  - Password delay: 5 seconds (vs immediate)"
echo "  - Screen saver: 10 minutes (vs 5 minutes)"
echo "  - AirDrop: Enabled (vs disabled)"
echo "  - Bluetooth sharing: Enabled (vs disabled)"
echo "  - Handoff/Continuity: Enabled"
echo "  - Extension warning: Disabled (vs enabled)"
echo "  - Trash warning: Disabled (vs enabled)"
echo "  - Safari AutoFill: Enabled (vs disabled)"
echo ""
msg_info "Security features still active:"
echo "  - Password required after sleep"
echo "  - File extensions shown"
echo "  - Guest account disabled"
echo "  - Gatekeeper enabled"
echo "  - Safari fraud warnings"
echo "  - Personalized ads disabled"
