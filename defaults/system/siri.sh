#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Siri
#
# DESCRIPTION:
#   Configures Siri assistant settings including enable/disable,
#   suggestions, and voice feedback options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Logout may be required for changes to take effect
#
# REFERENCES:
#   - Apple Support: Use Siri on your Mac
#     https://support.apple.com/guide/mac-help/mchl6b029310/mac
#
# DOMAIN:
#   com.apple.assistant.support
#   com.apple.Siri
#
# NOTES:
#   - Siri requires internet connection
#   - Voice recordings can be managed in privacy.sh
#
# ==============================================================================

msg_info "Configuring Siri settings..."

# ==============================================================================
# Siri Enable/Disable
# ==============================================================================

# --- Enable/Disable Siri ---
# Key:          Assistant Enabled
# Domain:       com.apple.assistant.support
# Description:  Master toggle for Siri functionality. When disabled,
#               Siri features are completely turned off.
# Default:      true (Siri enabled)
# Options:      true = Siri enabled
#               false = Siri disabled
# Set to:       false (disable for privacy/security)
# UI Location:  System Settings > Siri & Spotlight
run_defaults "com.apple.assistant.support" "Assistant Enabled" "-bool" "false"

# ==============================================================================
# Siri Suggestions
# ==============================================================================

# --- Disable Siri Suggestions in Apps ---
# Key:          SiriSuggestionsEnabled
# Domain:       com.apple.Siri
# Description:  Controls whether Siri provides suggestions based on app usage.
#               Disabling prevents Siri from analyzing your app activity.
# Default:      true
# Options:      true = Show suggestions
#               false = Disable suggestions
# Set to:       false (privacy-focused)
# UI Location:  System Settings > Siri & Spotlight
run_defaults "com.apple.Siri" "SiriSuggestionsEnabled" "-bool" "false"

# --- Disable Siri Suggestions in Spotlight ---
# Key:          ShowSiriSuggestionsInSpotlight
# Domain:       com.apple.Siri
# Description:  Controls Siri suggestions appearing in Spotlight searches.
# Default:      true
# Options:      true = Show in Spotlight
#               false = Hide from Spotlight
# Set to:       false (privacy-focused)
run_defaults "com.apple.Siri" "ShowSiriSuggestionsInSpotlight" "-bool" "false"

# ==============================================================================
# Voice Feedback
# ==============================================================================

# --- Siri Voice Feedback ---
# Key:          VoiceFeedback
# Domain:       com.apple.Siri
# Description:  Controls whether Siri speaks responses aloud.
# Default:      On
# Options:      On = Always speak
#               Off = Silent (text only)
# Set to:       Off (quiet mode)
run_defaults "com.apple.Siri" "VoiceFeedback" "-string" "Off"

# ==============================================================================
# Type to Siri
# ==============================================================================

# --- Enable Type to Siri ---
# Key:          TypeToSiriEnabled
# Domain:       com.apple.Siri
# Description:  Allows typing queries to Siri instead of speaking.
# Default:      false
# Options:      true = Enable typing
#               false = Voice only
# Set to:       true (more discreet)
run_defaults "com.apple.Siri" "TypeToSiriEnabled" "-bool" "true"

msg_success "Siri settings configured."
msg_info "Note: Logout may be required for changes to take full effect."
