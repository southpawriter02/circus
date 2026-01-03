#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: 1Password Configuration
#
# DESCRIPTION:
#   This script configures 1Password preferences including security settings,
#   browser integration, and quick access behavior. 1Password is a password
#   manager that stores credentials, secure notes, and other sensitive data.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - 1Password 8 installed (this config is for 1Password 8)
#
# REFERENCES:
#   - 1Password Support: Security preferences
#     https://support.1password.com/security-preferences/
#   - 1Password Support: Get started on your Mac
#     https://support.1password.com/getting-started-mac/
#
# DOMAIN:
#   com.1password.1password
#
# NOTES:
#   - 1Password 8 uses com.1password.1password (7 used com.agilebits.onepassword7)
#   - Most settings sync with your 1Password account
#   - Lock settings affect all vaults
#   - Browser extension settings are separate
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set 1Password preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring 1Password settings..."

# ==============================================================================
# 1Password Configuration Notes
#
# 1Password 8 uses a combination of macOS defaults and its own preferences
# synced via your 1Password account. Most security settings are configured
# in-app for safety reasons.
#
# SECURITY (Settings > Security):
#
#   Lock 1Password:
#   - After X minutes of inactivity
#   - When system sleeps
#   - When screen is locked
#   - When switching users
#
#   Biometric Unlock:
#   - Touch ID / Apple Watch unlock
#   - Requires master password periodically
#
#   Watchtower:
#   - Check for compromised passwords
#   - Check for vulnerable passwords
#   - Check for reused passwords
#   - Check for unsecured websites
#
# APPEARANCE (Settings > Appearance):
#
#   Theme: Light, Dark, System
#   Density: Comfortable, Compact
#   Always show in sidebar: Categories to display
#
# QUICK ACCESS (Settings > Quick Access):
#
#   Keyboard shortcut: Cmd+Shift+Space (default)
#   Show in: Menu bar
#
# BROWSER (Settings > Browser):
#
#   Connect with 1Password in the browser
#   - Enables browser extension integration
#   - Auto-fill credentials
#   - Save new logins
#
# DEVELOPER (Settings > Developer):
#
#   SSH Agent:
#   - Use 1Password as SSH agent
#   - Authorize with biometrics
#
#   CLI:
#   - Connect with 1Password CLI
#   - Biometric unlock for CLI
#
# ==============================================================================

# ==============================================================================
# System Integration Settings
# ==============================================================================

# Note: Most 1Password settings should be configured in-app for security.
# The following are safe system integration preferences:

# --- Show in Menu Bar ---
# Key:          showInMenuBar
# Domain:       com.1password.1password
# Description:  Shows the 1Password icon in the macOS menu bar for quick access
#               to passwords and secure notes.
# Default:      true
# Options:      true  = Show in menu bar
#               false = Hide from menu bar
# Set to:       true (quick access)
# UI Location:  1Password > Settings > General > Keep 1Password in the menu bar
# Source:       https://support.1password.com/getting-started-mac/
run_defaults "com.1password.1password" "showInMenuBar" "-bool" "true"

msg_success "1Password configuration notes displayed."
echo ""
msg_info "1Password settings are configured in-app for security:"
echo "  1. Open 1Password > Settings (Cmd+,)"
echo "  2. Security: Lock behavior, biometric unlock"
echo "  3. Developer: SSH agent, CLI integration"
echo "  4. Browser: Extension connection"
echo ""
msg_info "Recommended security settings:"
echo "  - Lock after 5 minutes of inactivity"
echo "  - Lock when system sleeps"
echo "  - Enable Touch ID unlock"
echo "  - Enable Watchtower for compromised passwords"
echo ""
msg_info "Quick Access shortcut: Cmd+Shift+Space"
echo "  (Customize in Settings > Quick Access)"
