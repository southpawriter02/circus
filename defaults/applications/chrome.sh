#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Google Chrome Configuration
#
# DESCRIPTION:
#   This script configures Google Chrome preferences for privacy, performance,
#   and usability. Chrome uses a combination of macOS defaults and its own
#   preferences file. Some settings require Chrome policy configuration.
#
# REQUIRES:
#   - macOS 10.13 (High Sierra) or later
#   - Google Chrome installed
#
# REFERENCES:
#   - Chrome Enterprise policies
#     https://chromeenterprise.google/policies/
#   - Chrome Help: Settings
#     https://support.google.com/chrome/answer/114836
#
# DOMAIN:
#   com.google.Chrome
#
# NOTES:
#   - Chrome preferences in ~/Library/Application Support/Google/Chrome/
#   - Many settings are in Chrome's internal profile, not macOS defaults
#   - Enterprise policies override user settings
#   - Chrome syncs settings via Google account
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Chrome preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Google Chrome settings..."

# ==============================================================================
# Privacy Settings
# ==============================================================================

# --- Disable Swipe Navigation ---
# Key:          AppleEnableSwipeNavigateWithScrolls
# Domain:       com.google.Chrome
# Description:  Disables the two-finger swipe gesture for navigating back and
#               forward in browser history. Prevents accidental navigation.
# Default:      true (swipe enabled)
# Options:      true  = Enable swipe navigation
#               false = Disable swipe navigation
# Set to:       false (prevent accidental navigation)
# UI Location:  Not in Chrome UI - macOS defaults only
# Source:       https://support.google.com/chrome/answer/114836
run_defaults "com.google.Chrome" "AppleEnableSwipeNavigateWithScrolls" "-bool" "false"

# --- Disable Print Preview ---
# Key:          DisablePrintPreview
# Domain:       com.google.Chrome
# Description:  Uses the native macOS print dialog instead of Chrome's built-in
#               print preview. The macOS dialog offers better printer support.
# Default:      false (use Chrome's print preview)
# Options:      true  = Use macOS native print dialog
#               false = Use Chrome's print preview
# Set to:       true (native macOS experience)
# UI Location:  Affects Cmd+P behavior
# Source:       https://chromeenterprise.google/policies/#DisablePrintPreview
run_defaults "com.google.Chrome" "DisablePrintPreview" "-bool" "true"

# --- Use Native macOS Print Dialog ---
# Key:          PMPrintingExpandedStateForPrint2
# Domain:       com.google.Chrome
# Description:  Expands the print dialog to show additional options by default.
# Default:      false
# Options:      true  = Show expanded print dialog
#               false = Show collapsed print dialog
# Set to:       true (see all print options)
# UI Location:  Print dialog
# Source:       macOS standard preference
run_defaults "com.google.Chrome" "PMPrintingExpandedStateForPrint2" "-bool" "true"

# ==============================================================================
# Behavior Settings
# ==============================================================================

# --- Confirm Before Quitting ---
# Key:          confirmBeforeQuitting
# Domain:       com.google.Chrome
# Description:  Requires holding Cmd+Q to quit Chrome, preventing accidental
#               closure. Shows a confirmation overlay when pressing Cmd+Q.
# Default:      false (quit immediately)
# Options:      true  = Require hold to quit
#               false = Quit immediately on Cmd+Q
# Set to:       true (prevent accidental quit)
# UI Location:  Chrome > Warn Before Quitting (Cmd+Q)
# Source:       https://support.google.com/chrome/answer/114836
run_defaults "com.google.Chrome" "confirmBeforeQuitting" "-bool" "true"

# --- External Protocol Dialog ---
# Key:          ExternalProtocolDialogShowAlwaysOpenCheckbox
# Domain:       com.google.Chrome
# Description:  Shows the "Always open" checkbox in external protocol dialogs
#               (e.g., opening Zoom, Slack, or other app links from browser).
# Default:      false
# Options:      true  = Show "Always open" checkbox
#               false = Hide checkbox (ask every time)
# Set to:       true (allow remembering choice)
# UI Location:  Appears in external protocol confirmation dialogs
# Source:       https://chromeenterprise.google/policies/
run_defaults "com.google.Chrome" "ExternalProtocolDialogShowAlwaysOpenCheckbox" "-bool" "true"

# ==============================================================================
# Performance Settings
# ==============================================================================

# --- Disable Automatic Updates (for managed environments) ---
# Note: Automatic updates are generally recommended for security.
# Only disable if managing updates through another system.
#
# Key:          DisableAutomaticUpdates
# Domain:       com.google.Chrome
# Description:  Disables automatic Chrome updates. Only recommended for
#               enterprise environments with managed update policies.
# Default:      false (updates enabled)
# Set to:       (not setting - let Chrome update automatically)
# UI Location:  Chrome > About Google Chrome
# Source:       https://chromeenterprise.google/policies/

# ==============================================================================
# Chrome Configuration Notes
#
# Most Chrome settings are configured in-browser and sync with your Google
# account. The following are commonly adjusted settings:
#
# PRIVACY (chrome://settings/privacy):
#   - Send a "Do Not Track" request
#   - Block third-party cookies
#   - Clear browsing data on exit
#
# PASSWORD MANAGER (chrome://settings/passwords):
#   - Offer to save passwords: Disable if using 1Password/Bitwarden
#   - Auto Sign-in: Enable or disable
#
# STARTUP (chrome://settings/onStartup):
#   - Open the New Tab page
#   - Continue where you left off
#   - Open specific pages
#
# DOWNLOADS (chrome://settings/downloads):
#   - Download location
#   - Ask where to save each file
#
# PERFORMANCE (chrome://settings/performance):
#   - Memory Saver: Frees up memory from inactive tabs
#   - Energy Saver: Reduces background activity
#
# ==============================================================================

# ==============================================================================
# Enterprise Policy Configuration
#
# For managed environments, Chrome policies can be set via:
# /Library/Managed Preferences/com.google.Chrome.plist
#
# Common policies:
#   PasswordManagerEnabled: false (disable built-in password manager)
#   AutofillCreditCardEnabled: false (disable credit card autofill)
#   BookmarkBarEnabled: true (always show bookmarks bar)
#   HardwareAccelerationModeEnabled: true (use GPU acceleration)
#
# To apply policies, use MDM or create a configuration profile.
# ==============================================================================

msg_success "Chrome settings applied."
echo ""
msg_info "Most Chrome settings are configured in-browser:"
echo "  1. Open chrome://settings"
echo "  2. Privacy and security: Block trackers, clear data"
echo "  3. Passwords: Disable if using external password manager"
echo "  4. Performance: Enable Memory Saver for efficiency"
echo ""
msg_info "For enterprise deployments, use Chrome policies via MDM."
