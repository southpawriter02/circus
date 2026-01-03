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

msg_info "Configuring privacy and analytics settings..."

# ==============================================================================
# Crash Reporter & Diagnostics
# ==============================================================================

# --- Disable Crash Reporter Dialog ---
# Key:          DialogType
# Domain:       com.apple.CrashReporter
# Description:  Controls the behavior of the crash reporter dialog when an
#               application crashes. By default, macOS shows a dialog asking
#               if you want to report the crash to Apple.
# Default:      crashreport (show dialog with options)
# Options:      crashreport = Show dialog
#               developer = Show minimal dialog with developer options
#               server = Silently log to server
#               none = Disable crash reporting dialog entirely
# Set to:       none (disable the dialog for uninterrupted workflow)
# UI Location:  No direct UI equivalent
# Security:     Prevents crash data from being sent to Apple
run_defaults "com.apple.CrashReporter" "DialogType" "-string" "none"

# ==============================================================================
# Apple Advertising
# ==============================================================================

# --- Disable Personalized Ads ---
# Key:          allowApplePersonalizedAdvertising
# Domain:       com.apple.AdLib
# Description:  Controls whether Apple can use your data to deliver personalized
#               advertisements in Apple apps and services. When disabled, you'll
#               still see ads but they won't be based on your interests.
# Default:      true (personalized ads enabled)
# Options:      true = Personalized ads enabled
#               false = Personalized ads disabled
# Set to:       false (disable personalized advertising)
# UI Location:  System Settings > Privacy & Security > Apple Advertising
# Source:       https://support.apple.com/en-us/HT205223
run_defaults "com.apple.AdLib" "allowApplePersonalizedAdvertising" "-bool" "false"

# --- Disable Ad Tracking Identifier ---
# Key:          forceLimitAdTracking
# Domain:       com.apple.AdLib
# Description:  Forces the system to limit ad tracking across apps. This resets
#               your Advertising Identifier and prevents apps from tracking you.
# Default:      false
# Options:      true = Force limit ad tracking
#               false = Allow ad tracking
# Set to:       true (limit ad tracking)
# UI Location:  Related to Apple Advertising settings
run_defaults "com.apple.AdLib" "forceLimitAdTracking" "-bool" "true"

# --- Disable Advertising Identifier ---
# Key:          allowIdentifierForAdvertising
# Domain:       com.apple.AdLib
# Description:  Controls whether apps can use your device's advertising identifier
#               to deliver targeted advertising across apps. Disabling this prevents
#               cross-app ad tracking while still allowing contextual ads.
# Default:      true (identifier available)
# Options:      true = Allow advertising identifier
#               false = Disable advertising identifier
# Set to:       false (disable for privacy)
# UI Location:  System Settings > Privacy & Security > Apple Advertising > Personalized Ads
# Source:       https://support.apple.com/en-us/HT205223
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
