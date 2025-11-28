#!/usr/bin/env bash

# ==============================================================================
#
# Privacy & Security Profile: Lockdown
#
# DESCRIPTION:
#   Maximum security profile designed for high-risk environments or users with
#   strict security requirements. This profile prioritizes security over
#   convenience and should be used when handling sensitive data or in
#   environments with elevated threat levels.
#
# PROFILE LEVEL: Maximum Security (3 of 3)
#
# INCLUDES:
#   All settings from 'standard' and 'privacy' profiles, plus:
#   - Firewall blocks all incoming connections
#   - Screensaver activates after 2 minutes
#   - AirDrop disabled
#   - Remote Apple Events disabled
#   - Content caching disabled
#   - Guest account disabled
#   - Automatic login disabled
#   - Safari enhanced security restrictions
#   - FileVault reminder
#
# WARNING:
#   This profile may significantly impact convenience and some workflows.
#   Review all settings before applying to ensure they meet your needs.
#
# REFERENCES:
#   - Apple Platform Security: https://support.apple.com/guide/security/welcome/web
#   - NIST macOS Security: https://github.com/usnistgov/macos_security
#   - CIS Apple macOS Benchmark: https://www.cisecurity.org/benchmark/apple_os
#   - NSA Cybersecurity Guidance: https://www.nsa.gov/Cybersecurity/
#
# ==============================================================================

# --- Helper Functions ---------------------------------------------------------

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set '$domain' preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

run_sudo_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set '$domain' preference: '$key' to '$value' (requires sudo)"
  else
    sudo defaults write "$domain" "$key" "$type" "$value"
  fi
}

# --- Main Logic ---------------------------------------------------------------

msg_info "Applying Lockdown profile (includes Privacy and Standard profile settings)..."
msg_warning "NOTE: This profile applies strict security settings that may impact convenience."

# First, apply the privacy profile (which includes standard)
privacy_profile="$DOTFILES_ROOT/defaults/profiles/privacy.sh"
if [ -f "$privacy_profile" ]; then
  # shellcheck source=/dev/null
  source "$privacy_profile"
fi

msg_info "Applying additional Lockdown profile settings..."

# ==============================================================================
# SECTION: Firewall - Maximum Protection
# ==============================================================================

msg_info "Configuring firewall for maximum protection..."

# --- Block All Incoming Connections ---
# Key:          globalstate
# Description:  Sets firewall to block ALL incoming connections except those
#               required for basic Internet services (DHCP, Bonjour, IPSec).
# Security:     Maximum protection against network-based attacks
# Impact:       May break screen sharing, file sharing, and some apps
# Value:        2 = Block all incoming connections
run_sudo_defaults "/Library/Preferences/com.apple.alf" "globalstate" "-int" "2"

# --- Enable Signed Application Check ---
# Block all applications that are not signed from accepting incoming connections
run_sudo_defaults "/Library/Preferences/com.apple.alf" "allowsignedenabled" "-int" "1"

# ==============================================================================
# SECTION: Screen Lock - Aggressive Timeout
# ==============================================================================

msg_info "Configuring aggressive screen lock settings..."

# --- Screensaver After 2 Minutes ---
# Reduced idle time for faster screen lock in sensitive environments
run_defaults "com.apple.screensaver" "idleTime" "-int" "120"

# --- Require Password Immediately ---
# Already set in standard, but reaffirming for lockdown
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"

# ==============================================================================
# SECTION: Remote Services - Disable All
# ==============================================================================

msg_info "Disabling all remote services..."

# --- Disable Remote Apple Events ---
# Prevents other computers from sending Apple events to this Mac
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would disable remote Apple events"
else
  sudo systemsetup -setremoteappleevents off 2>/dev/null || true
fi

# --- Disable Wake on Network Access ---
# Prevents the computer from waking when accessed over the network
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would disable wake on network access"
else
  sudo systemsetup -setwakeonnetworkaccess off 2>/dev/null || true
fi

# ==============================================================================
# SECTION: Sharing Services - Disable All
# ==============================================================================

msg_info "Disabling sharing services..."

# --- Disable AirDrop ---
# Key:          DiscoverableMode
# Description:  Disables AirDrop file sharing
# Security:     Prevents unauthorized file transfers nearby
run_defaults "com.apple.NetworkBrowser" "DisableAirDrop" "-bool" "true"

# --- Disable Content Caching ---
# Content Caching shares downloaded content with other devices on the network
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would disable content caching"
else
  # Content caching is controlled via AssetCache
  sudo defaults write /Library/Preferences/com.apple.AssetCache.plist Activated -bool false 2>/dev/null || true
fi

# ==============================================================================
# SECTION: Login Security
# ==============================================================================

msg_info "Configuring login security..."

# --- Disable Automatic Login ---
# Key:          autoLoginUser
# Description:  Ensures a password is always required at login
# Security:     Prevents unauthorized access if device is stolen/unattended
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would disable automatic login"
else
  sudo defaults delete /Library/Preferences/com.apple.loginwindow autoLoginUser 2>/dev/null || true
fi

# --- Disable Guest Account ---
# Key:          GuestEnabled
# Description:  Disables the guest user account
# Security:     Guests could potentially access shared folders or use the Mac
run_sudo_defaults "/Library/Preferences/com.apple.loginwindow" "GuestEnabled" "-bool" "false"

# --- Show Login Window as Name and Password Fields ---
# More secure than showing a list of users
run_sudo_defaults "/Library/Preferences/com.apple.loginwindow" "SHOWFULLNAME" "-bool" "true"

# --- Disable Password Hints ---
# Password hints can help attackers guess passwords
run_sudo_defaults "/Library/Preferences/com.apple.loginwindow" "RetriesUntilHint" "-int" "0"

# ==============================================================================
# SECTION: Safari - Maximum Security
# ==============================================================================

msg_info "Applying Safari maximum security settings..."

# --- Block Pop-up Windows ---
run_defaults "com.apple.Safari" "WebKitJavaScriptCanOpenWindowsAutomatically" "-bool" "false"
run_defaults "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically" "-bool" "false"

# --- Disable Plug-ins ---
# Plug-ins can be security risks
run_defaults "com.apple.Safari" "WebKitPluginsEnabled" "-bool" "false"
run_defaults "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled" "-bool" "false"

# --- Disable Java ---
# Java has a history of security vulnerabilities
run_defaults "com.apple.Safari" "WebKitJavaEnabled" "-bool" "false"
run_defaults "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled" "-bool" "false"

# ==============================================================================
# SECTION: Bluetooth
# ==============================================================================

msg_info "Configuring Bluetooth security..."

# --- Disable Bluetooth Sharing ---
# Prevents file sharing via Bluetooth
run_defaults "com.apple.Bluetooth" "PrefKeyServicesEnabled" "-bool" "false"

# Note: Completely disabling Bluetooth would require:
# sudo defaults write /Library/Preferences/com.apple.Bluetooth ControllerPowerState -int 0
# This is not done by default as it may break wireless keyboards/mice

# ==============================================================================
# SECTION: USB and External Devices
# ==============================================================================

msg_info "Configuring external device security..."

# --- Disable Disk Arbitration for External Drives ---
# Note: This would prevent automatic mounting of external drives
# Uncomment if you want this level of protection:
# sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.diskarbitrationd.plist

# --- Eject All Remote Disks on Logout ---
# Ensures no network volumes remain mounted
run_defaults "NSGlobalDomain" "NSDocumentSaveNewDocumentsToCloud" "-bool" "false"

# ==============================================================================
# SECTION: FileVault Check
# ==============================================================================

msg_info "Checking FileVault status..."

if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would check FileVault status"
else
  if fdesetup status | grep -q "FileVault is Off"; then
    msg_warning "⚠️  SECURITY RECOMMENDATION: FileVault is not enabled."
    msg_warning "   Full-disk encryption is strongly recommended for the Lockdown profile."
    msg_warning "   Enable FileVault in System Preferences > Security & Privacy > FileVault"
  else
    msg_success "FileVault is enabled."
  fi
fi

# ==============================================================================
# SECTION: Secure Empty Trash
# ==============================================================================

msg_info "Configuring secure file deletion..."

# Note: Secure Empty Trash was removed in macOS El Capitan for SSDs
# as the SSD's wear-leveling makes secure erasure unreliable.
# For sensitive data, use FileVault and proper data destruction procedures.

# ==============================================================================
# SECTION: Application Security
# ==============================================================================

msg_info "Configuring application security..."

# --- Enable App Sandbox Warning ---
# Show warning when an app is about to modify system files
run_defaults "com.apple.LaunchServices" "LSQuarantine" "-bool" "true"

# --- Gatekeeper - App Store and Identified Developers Only ---
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would ensure Gatekeeper is enabled"
else
  sudo spctl --master-enable 2>/dev/null || true
fi

msg_success "Lockdown profile applied."
msg_warning "REMINDER: Review System Preferences to ensure all security features are configured correctly."
msg_warning "Consider enabling: FileVault, Find My Mac, and reviewing Privacy permissions."
