#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Safari Configuration
#
# This script configures settings for the Safari web browser.
# It is sourced by Stage 11 of the main installer. It supports Dry Run mode.
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

# ------------------------------------------------------------------------------
# Developer & Security Settings
# ------------------------------------------------------------------------------

# --- Enable the Develop Menu and Web Inspector ---
# Description:  Enables the Develop menu, which is essential for web development.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.Safari" "IncludeDevelopMenu" "-bool" "true"
run_defaults "com.apple.Safari" "WebKitDeveloperExtrasEnabledPreferenceKey" "-bool" "true"
run_defaults "com.apple.Safari" "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" "-bool" "true"

# --- Disable AutoFill ---
# Description:  Disables the AutoFill feature for privacy and security.
# Default:      true
# Possible:     true, false
# Set to:       false
run_defaults "com.apple.Safari" "AutoFillFromAddressBook" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillPasswords" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillCreditCardData" "-bool" "false"
run_defaults "com.apple.Safari" "AutoFillMiscellaneousForms" "-bool" "false"

# --- Warn About Fraudulent Websites ---
# Description:  Enables Safari's built-in phishing protection.
# Default:      true
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.Safari" "WarnAboutFraudulentWebsites" "-bool" "true"

# ------------------------------------------------------------------------------
# Search & Behavior Settings
# ------------------------------------------------------------------------------

# --- Don't Send Search Queries to Apple ---
# Description:  Prevents Safari from sending search queries from the Smart Search Field
#               to Apple for analysis.
# Default:      true
# Possible:     true, false
# Set to:       false
run_defaults "com.apple.Safari" "UniversalSearchEnabled" "-bool" "false"
run_defaults "com.apple.Safari" "SuppressSearchSuggestions" "-bool" "true"

# --- Show Full URL ---
# Description:  Shows the full URL in the address bar, including the protocol and
#               trivial subdomains.
# Default:      false
# Possible:     true, false
# Set to:       true
run_defaults "com.apple.Safari" "ShowFullURLInSmartSearchField" "-bool" "true"


msg_success "Safari settings applied."
