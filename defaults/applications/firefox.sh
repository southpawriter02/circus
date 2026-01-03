#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Firefox Configuration
#
# DESCRIPTION:
#   Documentation of Firefox configuration options. Firefox uses its own
#   profile-based preferences system (about:config) rather than macOS defaults.
#   This script provides guidance on configuring Firefox for privacy and
#   performance.
#
# REQUIRES:
#   - macOS 10.12 (Sierra) or later
#   - Firefox installed
#
# REFERENCES:
#   - Firefox Enterprise Policy Templates
#     https://github.com/mozilla/policy-templates
#   - Firefox Configuration Guide
#     https://support.mozilla.org/en-US/kb/about-config-editor-firefox
#
# DOMAIN:
#   org.mozilla.firefox
#
# NOTES:
#   - Firefox profiles stored in ~/Library/Application Support/Firefox/
#   - Preferences are in profile/prefs.js (don't edit directly while running)
#   - user.js can be used for custom defaults
#   - Enterprise policies use /Applications/Firefox.app/Contents/Resources/distribution/policies.json
#
# ==============================================================================

msg_info "Configuring Firefox settings..."

# ==============================================================================
# Firefox Configuration Notes
#
# Firefox does not use macOS defaults for most settings. Configuration is done
# through:
#
# 1. IN-BROWSER SETTINGS (about:preferences):
#    - General: Startup, tabs, language
#    - Home: Homepage and new tab settings
#    - Search: Default search engine
#    - Privacy & Security: Enhanced Tracking Protection
#    - Sync: Firefox account sync
#
# 2. ABOUT:CONFIG (about:config):
#    Advanced settings for power users. Common tweaks:
#
#    Privacy:
#    - privacy.trackingprotection.enabled = true
#    - privacy.donottrackheader.enabled = true
#    - network.cookie.cookieBehavior = 1 (block third-party)
#
#    Performance:
#    - gfx.webrender.all = true (hardware acceleration)
#    - browser.cache.disk.capacity = 512000 (512MB cache)
#
#    DNS over HTTPS:
#    - network.trr.mode = 2 (DoH with fallback)
#    - network.trr.uri = https://mozilla.cloudflare-dns.com/dns-query
#
# 3. USER.JS FILE (in profile directory):
#    For persistent custom defaults, create user.js:
#
#    user_pref("privacy.trackingprotection.enabled", true);
#    user_pref("browser.startup.homepage", "about:blank");
#
# 4. ENTERPRISE POLICIES:
#    Create /Applications/Firefox.app/Contents/Resources/distribution/policies.json
#
#    {
#      "policies": {
#        "DisableTelemetry": true,
#        "DisableFirefoxAccounts": false,
#        "PasswordManagerEnabled": false,
#        "OfferToSaveLogins": false
#      }
#    }
#
# ==============================================================================

# ==============================================================================
# macOS Integration Settings
# ==============================================================================

# Firefox respects some macOS defaults for system integration:

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Firefox preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

# --- Disable Swipe Navigation ---
# Key:          AppleEnableSwipeNavigateWithScrolls
# Domain:       org.mozilla.firefox
# Description:  Disables the two-finger swipe gesture for navigating back and
#               forward in browser history.
# Default:      true (swipe enabled)
# Options:      true  = Enable swipe navigation
#               false = Disable swipe navigation
# Set to:       false (prevent accidental navigation)
# UI Location:  Not in Firefox UI - macOS defaults only
# Source:       macOS standard preference
run_defaults "org.mozilla.firefox" "AppleEnableSwipeNavigateWithScrolls" "-bool" "false"

# --- Expanded Print Dialog ---
# Key:          PMPrintingExpandedStateForPrint2
# Domain:       org.mozilla.firefox
# Description:  Shows the expanded print dialog with more options by default.
# Default:      false
# Options:      true  = Show expanded print dialog
#               false = Show collapsed print dialog
# Set to:       true (see all print options)
# UI Location:  Print dialog
# Source:       macOS standard preference
run_defaults "org.mozilla.firefox" "PMPrintingExpandedStateForPrint2" "-bool" "true"

msg_success "Firefox macOS integration settings applied."
echo ""
msg_info "Firefox settings are configured in-browser:"
echo "  1. about:preferences - General settings"
echo "  2. about:config - Advanced tweaks"
echo "  3. about:support - View profile folder"
echo ""
msg_info "Recommended privacy settings:"
echo "  Privacy & Security > Enhanced Tracking Protection: Strict"
echo "  Privacy & Security > Send websites a 'Do Not Track' signal: Always"
echo "  Privacy & Security > HTTPS-Only Mode: Enable in all windows"
echo ""
msg_info "For enterprise deployments, use policies.json in Firefox.app bundle."
