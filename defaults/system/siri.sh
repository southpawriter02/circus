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
# Description:  Master toggle for Siri functionality on your Mac. When disabled,
#               Siri is completely turned off—the menu bar icon is hidden, keyboard
#               shortcuts are disabled, and no voice or text queries are processed.
#               Disabling Siri also prevents any data from being sent to Apple's
#               Siri servers for processing.
# Default:      true (Siri enabled on first macOS setup)
# Options:      true = Siri enabled (voice assistant active)
#               false = Siri disabled (no voice assistant features)
# Set to:       false (disable for privacy; prevents voice data from being
#               sent to Apple servers for processing)
# UI Location:  System Settings > Siri & Spotlight > Ask Siri
# Source:       https://support.apple.com/guide/mac-help/mchl6b029310/mac
# Security:     When Siri is enabled, voice queries are sent to Apple servers
#               for processing. Disable if you're concerned about voice data
#               privacy or are in a high-security environment.
# See also:     https://support.apple.com/en-us/102641
run_defaults "com.apple.assistant.support" "Assistant Enabled" "-bool" "false"

# ==============================================================================
# Siri Suggestions
# ==============================================================================

# --- Disable Siri Suggestions in Apps ---
# Key:          SiriSuggestionsEnabled
# Domain:       com.apple.Siri
# Description:  Controls whether Siri analyzes your app usage, browsing history,
#               and other activity to provide proactive suggestions. When enabled,
#               Siri may suggest apps, contacts, or actions based on your patterns.
#               This data processing occurs both on-device and on Apple servers.
# Default:      true (suggestions enabled)
# Options:      true = Show personalized suggestions based on usage
#               false = Disable suggestions (no activity analysis)
# Set to:       false (privacy-focused; prevents Apple from analyzing your
#               app usage patterns to generate suggestions)
# UI Location:  System Settings > Siri & Spotlight > Siri Suggestions & Privacy
# Source:       https://support.apple.com/guide/mac-help/mchl6b029310/mac
# Security:     Enabling allows Apple to analyze your usage patterns. Disable
#               for maximum privacy or in enterprise environments.
run_defaults "com.apple.Siri" "SiriSuggestionsEnabled" "-bool" "false"

# --- Disable Siri Suggestions in Spotlight ---
# Key:          ShowSiriSuggestionsInSpotlight
# Domain:       com.apple.Siri
# Description:  Controls whether Siri-powered suggestions appear in Spotlight
#               search results. These include web results, Wikipedia articles,
#               news, and App Store suggestions alongside local file matches.
# Default:      true (show Siri suggestions in Spotlight)
# Options:      true = Show Siri suggestions in Spotlight results
#               false = Hide Siri suggestions (local results only)
# Set to:       false (privacy-focused; keeps Spotlight searches local and
#               prevents queries from being sent to Apple)
# UI Location:  System Settings > Siri & Spotlight > Search Results
# Source:       https://support.apple.com/guide/mac-help/spotlight-mchlp1008/mac
# See also:     spotlight.sh for additional Spotlight privacy settings
run_defaults "com.apple.Siri" "ShowSiriSuggestionsInSpotlight" "-bool" "false"

# ==============================================================================
# Voice Feedback
# ==============================================================================

# --- Siri Voice Feedback ---
# Key:          VoiceFeedback
# Domain:       com.apple.Siri
# Description:  Controls whether Siri speaks responses aloud through your Mac's
#               speakers. When set to "Off", Siri displays responses on screen
#               but doesn't speak them, which is useful in quiet environments
#               or when you prefer visual-only feedback.
# Default:      On (Siri speaks responses)
# Options:      On = Always speak responses aloud
#               Off = Silent mode (text-only responses)
# Set to:       Off (quiet mode; responses shown on screen but not spoken,
#               reducing audio disturbance in shared spaces)
# UI Location:  System Settings > Siri & Spotlight > Siri Responses > Voice Feedback
# Source:       https://support.apple.com/guide/mac-help/mchl6b029310/mac
run_defaults "com.apple.Siri" "VoiceFeedback" "-string" "Off"

# ==============================================================================
# Type to Siri
# ==============================================================================

# --- Enable Type to Siri ---
# Key:          TypeToSiriEnabled
# Domain:       com.apple.Siri
# Description:  Enables typing queries to Siri instead of speaking them. When
#               activated via keyboard shortcut or menu bar, a text input field
#               appears instead of voice listening. This is useful in quiet
#               environments, for users with speech difficulties, or when you
#               prefer not to speak aloud.
# Default:      false (voice-only Siri activation)
# Options:      true = Enable typing to Siri (shows text field)
#               false = Voice-only Siri activation
# Set to:       true (more discreet; allows silent Siri interaction in
#               office environments or public spaces)
# UI Location:  System Settings > Accessibility > Siri > Type to Siri
# Source:       https://support.apple.com/guide/mac-help/mchl6b029310/mac
# See also:     https://support.apple.com/guide/mac-help/mh40578/mac (Accessibility)
run_defaults "com.apple.Siri" "TypeToSiriEnabled" "-bool" "true"

msg_success "Siri settings configured."
msg_info "Note: Logout may be required for changes to take full effect."
