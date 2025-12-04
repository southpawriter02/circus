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
# Key:          IncludeDevelopMenu
#               WebKitDeveloperExtrasEnabledPreferenceKey
#               com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled
# Domain:       com.apple.Safari
# Description:  Enables the Develop menu in Safari's menu bar, which provides
#               access to Web Inspector (DOM inspector, debugger, network
#               monitor, console, etc.), responsive design mode, and other
#               developer tools. Multiple keys are set to ensure full functionality
#               across different Safari and WebKit versions.
# Default:      false (Develop menu hidden by default)
# Options:      true  = Show Develop menu in menu bar
#               false = Hide Develop menu
# Set to:       true (essential for web development and debugging)
# UI Location:  Safari > Settings > Advanced > Show features for web developers
# Source:       https://support.apple.com/guide/safari/use-the-developer-tools-in-the-develop-menu-sfri20948/mac
# See also:     https://webkit.org/web-inspector/
# Note:         After enabling, access Web Inspector with ⌥⌘I or right-click
#               and select "Inspect Element".
run_defaults "com.apple.Safari" "IncludeDevelopMenu" "-bool" "true"
run_defaults "com.apple.Safari" "WebKitDeveloperExtrasEnabledPreferenceKey" "-bool" "true"
run_defaults "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" "-bool" "true"

# ==============================================================================
# Privacy & Security Settings
# ==============================================================================

# --- Disable AutoFill ---
# Key:          AutoFillFromAddressBook
#               AutoFillPasswords
#               AutoFillCreditCardData
#               AutoFillMiscellaneousForms
# Domain:       com.apple.Safari
# Description:  Disables Safari's AutoFill feature for various data types.
#               AutoFill can be convenient but poses security risks in shared
#               environments or if your Mac is compromised:
#               - Address book: Can leak personal contact information
#               - Passwords: Better handled by a dedicated password manager
#               - Credit cards: Sensitive financial data
#               - Forms: Miscellaneous form data including names, addresses
# Default:      true (AutoFill enabled for all categories)
# Options:      true  = Enable AutoFill for this data type
#               false = Disable AutoFill for this data type
# Set to:       false (disabled for enhanced privacy and security)
# UI Location:  Safari > Settings > AutoFill
# Source:       https://support.apple.com/guide/safari/autofill-web-forms-ibrw1103/mac
# Security:     Use a dedicated password manager (1Password, Bitwarden) or
#               iCloud Keychain instead of Safari's built-in AutoFill.
run_defaults "com.apple.Safari" "AutoFillFromAddressBook" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillPasswords" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillCreditCardData" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillMiscellaneousForms" "-bool" "false"

# --- Warn About Fraudulent Websites ---
# Key:          WarnAboutFraudulentWebsites
# Domain:       com.apple.Safari
# Description:  Enables Safari's built-in phishing and malware protection.
#               Safari checks visited URLs against Google's Safe Browsing
#               database and Apple's own database of known malicious sites.
#               If a match is found, Safari displays a warning before loading.
# Default:      true (warning enabled)
# Options:      true  = Show warning for suspicious websites
#               false = Do not warn about fraudulent websites
# Set to:       true (critical security feature - keep enabled)
# UI Location:  Safari > Settings > Security > Warn when visiting a fraudulent website
# Source:       https://support.apple.com/guide/safari/security-ibrw1074/mac
# Security:     This is a critical security feature that should always be
#               enabled. It provides protection against phishing attacks.
run_defaults "com.apple.Safari" "WarnAboutFraudulentWebsites" "-bool" "true"

# ==============================================================================
# Search & Privacy Settings
# ==============================================================================

# --- Don't Send Search Queries to Apple ---
# Key:          UniversalSearchEnabled
#               SuppressSearchSuggestions
# Domain:       com.apple.Safari
# Description:  Controls whether Safari sends search queries from the Smart
#               Search Field to Apple for processing and suggestions. When
#               enabled, your keystrokes are sent to Apple servers to generate
#               search suggestions. Disabling this keeps searches private.
# Default:      UniversalSearchEnabled: true
#               SuppressSearchSuggestions: false
# Options:      true/false for each key
# Set to:       UniversalSearchEnabled: false (don't send queries to Apple)
#               SuppressSearchSuggestions: true (suppress Safari Suggestions)
# UI Location:  Safari > Settings > Search > Include Safari Suggestions
# Source:       https://support.apple.com/guide/safari/search-the-web-ibrw1044/mac
# See also:     https://support.apple.com/guide/safari/privacy-ibrw1074/mac
# Security:     Disabling this reduces data shared with Apple's servers and
#               keeps your search queries more private.
run_defaults "com.apple.Safari" "UniversalSearchEnabled" "-bool" "false"
run_defaults "com.apple.Safari" "SuppressSearchSuggestions" "-bool" "true"

# --- Show Full URL ---
# Key:          ShowFullURLInSmartSearchField
# Domain:       com.apple.Safari
# Description:  Shows the complete URL in the address bar, including the
#               protocol (http:// or https://) and trivial subdomains (www).
#               By default, Safari simplifies URLs to show only the domain.
#               Showing the full URL makes it easier to identify the exact
#               page and spot phishing attempts using deceptive URLs.
# Default:      false (simplified URL, shows only domain name)
# Options:      true  = Show complete URL including protocol and path
#               false = Show simplified URL (domain only)
# Set to:       true (show complete URL for security awareness)
# UI Location:  Safari > Settings > Advanced > Show full website address
# Source:       https://support.apple.com/guide/safari/customize-settings-ibrwb0c38ea7/mac
# Security:     Seeing the full URL helps identify fraudulent sites that
#               use subdomains to mimic legitimate sites (e.g., bank.evil.com).
run_defaults "com.apple.Safari" "ShowFullURLInSmartSearchField" "-bool" "true"


msg_success "Safari settings applied."
