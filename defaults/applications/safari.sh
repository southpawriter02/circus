#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Safari Configuration
#
# DESCRIPTION:
#   This script configures Safari, Apple's built-in web browser. The settings
#   focus on developer features, privacy, and security. Safari has extensive
#   web developer tools that are disabled by default.
#
# REQUIRES:
#   - macOS 10.10 (Yosemite) or later for most settings
#   - Safari must have been run at least once to create its preferences file
#
# REFERENCES:
#   - Apple Support: Safari preferences
#     https://support.apple.com/guide/safari/welcome/mac
#   - Apple Developer: Safari Web Inspector
#     https://developer.apple.com/safari/tools/
#   - WebKit Developer Documentation
#     https://webkit.org/web-inspector/
#
# DOMAIN:
#   com.apple.Safari
#
# NOTES:
#   - The Develop menu provides access to Web Inspector and other dev tools
#   - AutoFill is disabled for security in shared environments
#   - Safari's privacy features are among the best of any browser
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Safari preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Safari settings..."

# ==============================================================================
# Developer Settings
# ==============================================================================

# --- Enable the Develop Menu and Web Inspector ---
# Keys:         IncludeDevelopMenu
#               WebKitDeveloperExtrasEnabledPreferenceKey
#               com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled
# Description:  Enables the Develop menu in Safari's menu bar, which provides
#               access to Web Inspector (DOM inspector, debugger, network
#               monitor, etc.), responsive design mode, and other developer tools.
# Default:      false (Develop menu hidden)
# Possible:     true, false
# Set to:       true (essential for web development)
# Reference:    Safari > Preferences > Advanced > Show Develop menu in menu bar
# Shortcut:     Develop > Show Web Inspector (⌥⌘I)
run_defaults "com.apple.Safari" "IncludeDevelopMenu" "-bool" "true"
run_defaults "com.apple.Safari" "WebKitDeveloperExtrasEnabledPreferenceKey" "-bool" "true"
run_defaults "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" "-bool" "true"

# ==============================================================================
# Privacy & Security Settings
# ==============================================================================

# --- Disable AutoFill ---
# Keys:         AutoFillFromAddressBook, AutoFillPasswords,
#               AutoFillCreditCardData, AutoFillMiscellaneousForms
# Description:  Disables Safari's AutoFill feature for various data types.
#               AutoFill can be convenient but poses security risks:
#               - Address book: Can leak personal information
#               - Passwords: Consider using a dedicated password manager
#               - Credit cards: Sensitive financial data
#               - Forms: Miscellaneous form data
# Default:      true (AutoFill enabled)
# Possible:     true, false
# Set to:       false (disabled for enhanced privacy/security)
# Reference:    Safari > Preferences > AutoFill
# Note:         Use 1Password, Bitwarden, or iCloud Keychain instead
run_defaults "com.apple.Safari" "AutoFillFromAddressBook" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillPasswords" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillCreditCardData" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillMiscellaneousForms" "-bool" "false"

# --- Warn About Fraudulent Websites ---
# Key:          WarnAboutFraudulentWebsites
# Description:  Enables Safari's built-in phishing and malware protection.
#               Safari checks visited URLs against a database of known
#               malicious sites and displays a warning if a match is found.
# Default:      true
# Possible:     true, false
# Set to:       true (critical security feature)
# Reference:    Safari > Preferences > Security > Warn when visiting fraudulent website
run_defaults "com.apple.Safari" "WarnAboutFraudulentWebsites" "-bool" "true"

# ==============================================================================
# Search & Privacy Settings
# ==============================================================================

# --- Don't Send Search Queries to Apple ---
# Keys:         UniversalSearchEnabled, SuppressSearchSuggestions
# Description:  Controls whether Safari sends search queries from the Smart
#               Search Field to Apple for processing and suggestions.
#               Disabling this prevents search data from being sent to Apple.
# Default:      UniversalSearchEnabled: true
#               SuppressSearchSuggestions: false
# Possible:     true, false
# Set to:       UniversalSearchEnabled: false (don't send to Apple)
#               SuppressSearchSuggestions: true (suppress suggestions)
# Reference:    Safari > Preferences > Search > Include Safari Suggestions
# Privacy:      This reduces data shared with Apple's servers
run_defaults "com.apple.Safari" "UniversalSearchEnabled" "-bool" "false"
run_defaults "com.apple.Safari" "SuppressSearchSuggestions" "-bool" "true"

# --- Show Full URL ---
# Key:          ShowFullURLInSmartSearchField
# Description:  Shows the complete URL in the address bar, including the
#               protocol (http:// or https://) and trivial subdomains (www).
#               This makes it easier to identify the exact page you're on
#               and spot phishing attempts that use deceptive URLs.
# Default:      false (simplified URL display)
# Possible:     true, false
# Set to:       true (show complete URL)
# Reference:    Safari > Preferences > Advanced > Smart Search Field: Show full website address
# Security:     Seeing the full URL helps identify fraudulent sites
run_defaults "com.apple.Safari" "ShowFullURLInSmartSearchField" "-bool" "true"


msg_success "Safari settings applied."
