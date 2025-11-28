#!/usr/bin/env bash

# ==============================================================================
#
# Privacy & Security Profile: Standard
#
# DESCRIPTION:
#   The default security profile that provides a sensible balance between
#   security and convenience. This profile is suitable for most users and
#   represents the baseline security configuration.
#
# PROFILE LEVEL: Base (1 of 3)
#
# SETTINGS OVERVIEW:
#   - Firewall enabled with stealth mode
#   - Screen saver password required immediately
#   - Automatic security updates enabled
#   - Location services enabled for convenience
#   Note: Quarantine warnings are configured in the base defaults (ui_ux.sh)
#
# REFERENCES:
#   - Apple Security Guide: https://support.apple.com/guide/security/welcome/web
#   - CIS Apple macOS Benchmark: https://www.cisecurity.org/benchmark/apple_os
#
# ==============================================================================

# --- Helper Functions ---------------------------------------------------------

# A helper function to run `defaults write` commands or print them in dry run mode.
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

# A helper function for sudo-required defaults
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

msg_info "Applying Standard privacy and security profile..."

# ==============================================================================
# SECTION: Firewall Configuration
# ==============================================================================

msg_info "Configuring firewall settings..."

# --- Enable Firewall ---
# Enable the macOS Application Level Firewall with per-app control
# Reference: System Preferences > Security & Privacy > Firewall
run_sudo_defaults "/Library/Preferences/com.apple.alf" "globalstate" "-int" "1"

# --- Enable Stealth Mode ---
# Prevent the Mac from responding to network probing requests (ICMP ping, port scans)
# This makes the Mac harder to detect on a network
run_sudo_defaults "/Library/Preferences/com.apple.alf" "stealthenabled" "-int" "1"

# --- Enable Logging ---
# Log firewall activity for security auditing
run_sudo_defaults "/Library/Preferences/com.apple.alf" "loggingenabled" "-int" "1"

# ==============================================================================
# SECTION: Screen Lock Configuration
# ==============================================================================

msg_info "Configuring screen lock settings..."

# --- Require Password Immediately ---
# Require password when exiting screensaver or waking display
# This is a critical security setting
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- No Password Grace Period ---
# No delay before password is required (maximum security)
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"

# --- Screensaver Idle Time ---
# Start screensaver after 10 minutes of inactivity
# Balance between security and convenience
run_defaults "com.apple.screensaver" "idleTime" "-int" "600"

# ==============================================================================
# SECTION: Software Update Configuration
# ==============================================================================

msg_info "Configuring automatic update settings..."

# --- Enable Automatic Update Check ---
run_defaults "com.apple.SoftwareUpdate" "AutomaticCheckEnabled" "-bool" "true"

# --- Enable Background Downloading ---
run_defaults "com.apple.SoftwareUpdate" "AutomaticDownload" "-bool" "true"

# --- Enable Critical Security Updates ---
# This is one of the most important security settings - always keep enabled
run_defaults "com.apple.SoftwareUpdate" "CriticalUpdateInstall" "-bool" "true"

# --- Enable macOS Updates ---
run_defaults "com.apple.SoftwareUpdate" "AutomaticallyInstallMacOSUpdates" "-bool" "true"

# --- Enable App Store Updates ---
run_defaults "com.apple.commerce" "AutoUpdate" "-bool" "true"

# ==============================================================================
# SECTION: Safari Security Settings
# ==============================================================================

msg_info "Configuring Safari security settings..."

# --- Warn About Fraudulent Websites ---
# Enable phishing and malware protection
run_defaults "com.apple.Safari" "WarnAboutFraudulentWebsites" "-bool" "true"

# --- Show Full URL ---
# Makes it easier to identify phishing attempts
run_defaults "com.apple.Safari" "ShowFullURLInSmartSearchField" "-bool" "true"

# --- Disable AutoFill ---
# Reduces risk of credential exposure; use a password manager instead
run_defaults "com.apple.Safari" "AutoFillFromAddressBook" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillPasswords" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillCreditCardData" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillMiscellaneousForms" "-bool" "false"

# ==============================================================================
# SECTION: System Preferences
# ==============================================================================

msg_info "Configuring system preferences..."

# --- Disable Remote Login (SSH) ---
# SSH should only be enabled when explicitly needed
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would disable remote login (SSH)"
else
  sudo systemsetup -setremotelogin off 2>/dev/null || true
fi

# --- Enable Location Services for Timezone ---
# Convenience feature for travelers
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would enable location services for timezone"
else
  sudo systemsetup -setusinglocationservices on 2>/dev/null || true
fi

msg_success "Standard privacy and security profile applied."
