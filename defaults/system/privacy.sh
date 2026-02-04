#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Privacy & Analytics
#
# DESCRIPTION:
#   Configures privacy settings to limit data collection and sharing with Apple
#   and third parties. These settings help protect your privacy by disabling
#   analytics, diagnostics, and personalized advertising.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings may require logout or restart to take effect
#
# REFERENCES:
#   - Apple Support: Share analytics information
#     https://support.apple.com/guide/mac-help/share-analytics-information-mh27990/mac
#   - Apple Support: About Apple Advertising & Privacy
#     https://support.apple.com/en-us/HT205223
#
# DOMAIN:
#   com.apple.CrashReporter
#   com.apple.AdLib
#   com.apple.assistant.support
#
# NOTES:
#   - These settings affect data sent to Apple, not third-party app analytics
#   - For Siri settings, some features may be disabled
#
# ==============================================================================

# ==============================================================================
# macOS Telemetry Overview
# ==============================================================================

# Apple collects several categories of data from macOS for product improvement:
#
# 1. CRASH REPORTS (CrashReporter)
#    - Application crash dumps with stack traces
#    - Hardware configuration at time of crash
#    - Recent user actions leading to crash
#    - Destination: Apple's crash processing servers
#
# 2. ANALYTICS & DIAGNOSTICS (SubmitDiagInfo)
#    - App usage statistics
#    - Performance metrics
#    - Feature usage patterns
#    - Destination: Apple's analytics servers
#
# 3. SIRI & DICTATION (Siri Data Sharing)
#    - Audio recordings of Siri interactions
#    - Transcriptions of dictation
#    - Used to train speech recognition
#    - Destination: Apple's Siri improvement team
#
# 4. ADVERTISING DATA (AdLib)
#    - Cross-app behavior for ad targeting
#    - Advertising identifier
#    - Used in Apple News, App Store, Stocks
#    - Destination: Apple Advertising platform
#
# Privacy Commitment:
#   Apple states that analytics are anonymized/aggregated and not linked to
#   your Apple ID. However, research has shown device identifiers can persist.
#   For maximum privacy, disable all optional telemetry.
#
# Source:       https://www.apple.com/legal/privacy/data/en/analytics/
# See also:     https://support.apple.com/guide/mac-help/share-analytics-information-mh27990/mac
#               https://www.apple.com/privacy/

msg_info "Configuring privacy and analytics settings..."

# ==============================================================================
# Crash Reporter & Diagnostics
# ==============================================================================

# --- Crash Reporter Dialog Behavior ---
# Key:          DialogType
# Domain:       com.apple.CrashReporter
# Description:  Controls the behavior of the crash reporter dialog when an
#               application crashes unexpectedly. macOS can show a dialog asking
#               if you want to send the crash report to Apple.
#
#               What a Crash Report Contains:
#               - Exception type and code (why it crashed)
#               - Full stack trace (what code was running)
#               - Thread states (all running threads)
#               - Loaded dynamic libraries
#               - Hardware configuration (CPU, RAM, GPU)
#               - macOS version and build number
#               - Crashed application version
#               - Recent console log entries
#
#               Privacy Consideration:
#               Crash reports can contain file paths, which may reveal:
#               - Project names you're working on
#               - Directory structure of your files
#               - Usernames (in /Users/yourusername/...)
#               Apple claims these are processed to remove identifying info.
#
# Default:      crashreport (show dialog with options)
# Options:      crashreport = Show "Report..." dialog with details
#               developer = Show minimal dialog (for developers)
#               server = Silently log to server (enterprise use)
#               none = Disable crash reporting UI entirely
# Set to:       none (disable the dialog; crashes still logged locally)
# UI Location:  No direct UI equivalent
# Source:       man ReportCrash
# See also:     ~/Library/Logs/DiagnosticReports/ (local crash logs)
# Note:         Local crash logs are still created regardless of this setting.
#               View them in Console.app > Crash Reports or the directory above.
run_defaults "com.apple.CrashReporter" "DialogType" "-string" "none"

# ==============================================================================
# Apple Advertising
# ==============================================================================

# Apple's advertising platform shows ads in:
# - App Store (Search Ads)
# - Apple News
# - Stocks app
# - TV app (limited)
#
# When personalized ads are enabled, Apple uses:
# - Apps you've downloaded
# - Content you've read in News
# - Your age, gender, location
# - Device usage patterns
#
# Advertising Identifier (IDFA):
#   A unique device identifier used for ad attribution and targeting.
#   Resetting or disabling it reduces cross-app tracking.
#
# Regulatory Context:
#   GDPR, CCPA, and similar regulations give you the right to opt out of
#   personalized advertising. Apple provides these controls to comply.
#
# Source:       https://support.apple.com/en-us/HT205223

# --- Disable Personalized Ads ---
# Key:          allowApplePersonalizedAdvertising
# Domain:       com.apple.AdLib
# Description:  Controls whether Apple can use your data to deliver personalized
#               advertisements in Apple apps and services. When disabled, you'll
#               still see the same NUMBER of ads, but they won't be targeted to
#               your interests—they'll be generic or contextual instead.
#
#               What Apple Uses for Personalization:
#               - Your Apple News reading history
#               - Apps you've downloaded from the App Store
#               - Search queries in App Store
#               - Demographics (age, gender from Apple ID)
#               - General location (not precise GPS)
#
# Default:      true (personalized ads enabled)
# Options:      true = Personalized ads based on your data
#               false = Generic/contextual ads only
# Set to:       false (disable personalized advertising)
# UI Location:  System Settings > Privacy & Security > Apple Advertising
# Source:       https://support.apple.com/en-us/HT205223
# See also:     https://www.apple.com/legal/privacy/data/en/apple-advertising/
run_defaults "com.apple.AdLib" "allowApplePersonalizedAdvertising" "-bool" "false"

# --- Limit Ad Tracking (Force) ---
# Key:          forceLimitAdTracking
# Domain:       com.apple.AdLib
# Description:  Forces the "Limit Ad Tracking" setting system-wide. This tells
#               apps and advertisers that you prefer not to be tracked. Apps
#               respecting this flag will not use your Advertising Identifier
#               for cross-app tracking purposes.
#
#               What This Does:
#               - Signals to third-party apps not to track you
#               - Encourages apps to use contextual ads instead of behavioral
#               - Does NOT prevent all tracking (apps can ignore the flag)
#               - Works alongside App Tracking Transparency (ATT)
#
# Default:      false (ad tracking not forcibly limited)
# Options:      true = Force limit ad tracking
#               false = Normal ad tracking behavior
# Set to:       true (limit ad tracking across all apps)
# UI Location:  Related to Apple Advertising settings
# See also:     https://developer.apple.com/documentation/apptrackingtransparency
run_defaults "com.apple.AdLib" "forceLimitAdTracking" "-bool" "true"

# --- Disable Advertising Identifier Access ---
# Key:          allowIdentifierForAdvertising
# Domain:       com.apple.AdLib
# Description:  Controls whether apps can access your device's Advertising
#               Identifier (IDFA). The IDFA is a unique ID that advertisers use
#               to track you across different apps for ad attribution and
#               targeting. Disabling this returns a zeroed-out identifier.
#
#               IDFA Format: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX
#               When disabled: 00000000-0000-0000-0000-000000000000
#
#               Impact of Disabling:
#               - Advertisers cannot link your activity across apps
#               - Ad attribution (install tracking) becomes less accurate
#               - You may see less relevant ads (but same number of ads)
#               - Some apps may complain or reduce free features
#
# Default:      true (IDFA available to apps)
# Options:      true = Allow apps to access Advertising Identifier
#               false = Return zeroed identifier (blocks cross-app tracking)
# Set to:       false (disable for maximum privacy)
# UI Location:  System Settings > Privacy & Security > Apple Advertising >
#               Personalized Ads (toggle affects this)
# Source:       https://support.apple.com/en-us/HT205223
# Note:         iOS has App Tracking Transparency (ATT) which prompts per-app.
#               macOS uses this system-wide setting instead.
run_defaults "com.apple.AdLib" "allowIdentifierForAdvertising" "-bool" "false"

# ==============================================================================
# Siri & Dictation
# ==============================================================================

# --- Disable Siri Data Sharing ---
# Key:          Siri Data Sharing Opt-In Status
# Domain:       com.apple.assistant.support
# Description:  Controls whether Siri recordings can be reviewed by Apple to
#               improve Siri and dictation. When disabled, Apple won't store
#               or review your Siri interactions.
# Default:      0 (default/not set)
# Options:      0 = Not opted in (default)
#               1 = Opted in to data sharing
#               2 = Explicitly opted out
# Set to:       2 (explicitly opt out of Siri data sharing)
# UI Location:  System Settings > Privacy & Security > Analytics & Improvements > Improve Siri & Dictation
# Source:       https://support.apple.com/en-us/HT210657
run_defaults "com.apple.assistant.support" "Siri Data Sharing Opt-In Status" "-int" "2"

# ==============================================================================
# Analytics & Recommendations
# ==============================================================================

# --- Disable App Analytics Sharing ---
# Key:          ShareAppAnalytics
# Domain:       com.apple.assistant.support
# Description:  Controls whether app crash data and usage analytics are shared
#               with app developers to help them improve their applications.
#               Disabling this prevents your app usage patterns from being shared.
# Default:      true (analytics shared)
# Options:      true = Share analytics with developers
#               false = Don't share app analytics
# Set to:       false (disable for privacy)
# UI Location:  System Settings > Privacy & Security > Analytics & Improvements > Share with App Developers
# Source:       https://support.apple.com/guide/mac-help/share-analytics-information-mh27990/mac
run_defaults "com.apple.assistant.support" "ShareAppAnalytics" "-bool" "false"

# --- Disable Personalized Recommendations ---
# Key:          AllowPersonalizedRecommendations
# Domain:       com.apple.assistant.support
# Description:  Controls whether Apple can use your data to provide personalized
#               recommendations across Apple apps like News, Music, and the App Store.
#               Disabling this gives you more generic, non-personalized suggestions.
# Default:      true (personalized recommendations enabled)
# Options:      true = Enable personalized recommendations
#               false = Disable personalized recommendations
# Set to:       false (disable for privacy)
# UI Location:  System Settings > Privacy & Security > Apple Advertising
# Source:       https://support.apple.com/en-us/HT205223
run_defaults "com.apple.assistant.support" "AllowPersonalizedRecommendations" "-bool" "false"

msg_success "Privacy and analytics settings configured."
