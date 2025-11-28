#!/usr/bin/env bash

# ==============================================================================
#
# Privacy & Security Profile: Privacy
#
# DESCRIPTION:
#   An enhanced privacy profile that minimizes data sharing with Apple and
#   third parties, disables telemetry, and strengthens tracking protection.
#   This profile is recommended for users who prioritize data privacy.
#
# PROFILE LEVEL: Enhanced (2 of 3)
#
# INCLUDES:
#   All settings from the 'standard' profile, plus:
#   - Siri and Dictation disabled
#   - Spotlight Suggestions disabled
#   - Location Services restricted
#   - Safari tracking prevention maximized
#   - Personalized ads disabled
#   - Analytics and diagnostics disabled
#
# REFERENCES:
#   - Apple Privacy: https://www.apple.com/privacy/
#   - macOS Security Compliance Project: https://github.com/usnistgov/macos_security
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

msg_info "Applying Privacy profile (includes Standard profile settings)..."

# First, apply the standard profile as a base
standard_profile="$DOTFILES_ROOT/defaults/profiles/standard.sh"
if [ -f "$standard_profile" ]; then
  # shellcheck source=/dev/null
  source "$standard_profile"
fi

msg_info "Applying additional Privacy profile settings..."

# ==============================================================================
# SECTION: Siri and Voice Services
# ==============================================================================

msg_info "Disabling Siri and voice services..."

# --- Disable Siri ---
# Key:          StatusMenuVisible
# Description:  Removes Siri from the menu bar and disables Siri functionality.
#               This prevents voice data from being sent to Apple.
# Privacy:      Siri queries are processed by Apple servers
run_defaults "com.apple.Siri" "StatusMenuVisible" "-bool" "false"
run_defaults "com.apple.Siri" "UserHasDeclinedEnable" "-bool" "true"
run_defaults "com.apple.assistant.support" "Assistant Enabled" "-bool" "false"

# --- Disable Dictation ---
# Prevents keyboard dictation, which sends audio to Apple
run_defaults "com.apple.HIToolbox" "AppleDictationAutoEnable" "-int" "0"

# ==============================================================================
# SECTION: Spotlight Suggestions
# ==============================================================================

msg_info "Disabling Spotlight Suggestions and web search..."

# --- Disable Spotlight Suggestions ---
# Key:          SuggestionsAllowed
# Description:  Disables Spotlight Suggestions (Siri Suggestions) which send
#               search queries to Apple servers.
# Privacy:      Search queries can reveal sensitive information
run_defaults "com.apple.lookup.shared" "LookupSuggestionsDisabled" "-bool" "true"

# --- Disable Safari Suggestions ---
# Prevents Safari from sending search queries to Apple
run_defaults "com.apple.Safari" "UniversalSearchEnabled" "-bool" "false"
run_defaults "com.apple.Safari" "SuppressSearchSuggestions" "-bool" "true"

# ==============================================================================
# SECTION: Location Services
# ==============================================================================

msg_info "Restricting location services..."

# --- Disable Location Services for Timezone ---
# While convenient, this feature continuously accesses location data
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would disable automatic timezone based on location"
else
  sudo systemsetup -setusinglocationservices off 2>/dev/null || true
fi

# Note: Find My Mac location services should be configured separately
# in System Preferences if needed for device recovery

# ==============================================================================
# SECTION: Safari Enhanced Privacy
# ==============================================================================

msg_info "Applying Safari enhanced privacy settings..."

# --- Prevent Cross-Site Tracking ---
# Key:          WebKitPreferences.allowIdentifyingUserForUserMedia
# Description:  Blocks websites from tracking you across the web
run_defaults "com.apple.Safari" "BlockStoragePolicy" "-int" "2"

# --- Enable Fraudulent Website Warning ---
run_defaults "com.apple.Safari" "WarnAboutFraudulentWebsites" "-bool" "true"

# --- Disable Preloading Top Hit ---
# Prevents Safari from preloading pages, which could leak browsing intent
run_defaults "com.apple.Safari" "PreloadTopHit" "-bool" "false"

# --- Do Not Track ---
# Send DNT header with requests (note: many sites ignore this)
run_defaults "com.apple.Safari" "SendDoNotTrackHTTPHeader" "-bool" "true"

# ==============================================================================
# SECTION: Analytics and Diagnostics
# ==============================================================================

msg_info "Disabling analytics and diagnostics..."

# --- Disable Crash Reporter ---
# Key:          DialogType
# Description:  Disables the crash reporter dialog and prevents automatic
#               submission of crash reports to Apple.
# Privacy:      Crash reports may contain sensitive data
run_defaults "com.apple.CrashReporter" "DialogType" "-string" "none"

# --- Disable Diagnostic Data Sharing ---
# Prevents sharing diagnostic and usage data with Apple
# Note: These are typically controlled via System Preferences > Privacy > Analytics
# The following may require user confirmation in newer macOS versions

# --- Disable Personalized Ads ---
# Key:          allowApplePersonalizedAdvertising
# Description:  Opts out of Apple's personalized advertising
# Privacy:      Reduces tracking for ad targeting
run_defaults "com.apple.AdLib" "allowApplePersonalizedAdvertising" "-bool" "false"

# --- Disable App Analytics ---
# Prevents sharing app usage data with developers
run_defaults "com.apple.AppStore" "SendDeveloperUsageDataToApple" "-bool" "false"

# ==============================================================================
# SECTION: Mail Privacy
# ==============================================================================

msg_info "Configuring Mail privacy settings..."

# --- Disable Remote Content Loading ---
# Key:          DisableURLLoading
# Description:  Prevents Mail from automatically loading remote images and
#               content, which can be used to track email opens.
# Privacy:      Remote content can reveal IP address and track opens
run_defaults "com.apple.mail" "DisableURLLoading" "-bool" "true"

# ==============================================================================
# SECTION: Recent Items and Activity
# ==============================================================================

msg_info "Limiting recent items tracking..."

# --- Clear Recent Applications ---
# Limits the number of recent items tracked
run_defaults "NSGlobalDomain" "NSRecentDocumentsLimit" "-int" "0"

# --- Disable Recent Places in Finder ---
run_defaults "com.apple.finder" "ShowRecentTags" "-bool" "false"

msg_success "Privacy profile applied."
