#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Spotlight
#
# DESCRIPTION:
#   Configures Spotlight indexing and search settings. Controls which categories
#   appear in search results and manages index exclusions.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some changes require Spotlight reindex to take effect
#
# REFERENCES:
#   - Apple Support: Use Spotlight on your Mac
#     https://support.apple.com/guide/mac-help/spotlight-mchlp1008/mac
#
# DOMAIN:
#   com.apple.spotlight
#
# NOTES:
#   - Reindex with: sudo mdutil -E /
#   - Check status with: mdutil -s /
#
# ==============================================================================

msg_info "Configuring Spotlight settings..."

# ==============================================================================
# Search Results Categories
# ==============================================================================

# --- Search Result Ordering ---
# Key:          orderedItems
# Domain:       com.apple.spotlight
# Description:  Controls which categories appear in Spotlight results and their
#               order. Each item has an 'enabled' key and 'name' key.
# UI Location:  System Settings > Spotlight
# Note:         This is a complex plist array - using individual toggles below

# --- Disable Spotlight Suggestions ---
# Key:          SuggestionsEnabled
# Domain:       com.apple.lookup.shared
# Description:  Controls whether Spotlight shows suggestions from the internet
#               including Wikipedia, news, iTunes, and web searches.
# Default:      true
# Options:      true = Show internet suggestions
#               false = Disable internet suggestions
# Set to:       false (privacy-focused, local search only)
# Security:     Prevents search queries from being sent to Apple
run_defaults "com.apple.lookup.shared" "LookupSuggestionsDisabled" "-bool" "true"

# ==============================================================================
# Indexing Behavior
# ==============================================================================

# --- Disable Spotlight on External Drives ---
# Key:          ExternalVolumes
# Domain:       com.apple.spotlight
# Description:  Controls whether Spotlight indexes external and network volumes.
#               Disabling can improve performance and privacy.
# Default:      true (index external volumes)
# Options:      true = Index external volumes
#               false = Skip external volumes
# Set to:       false (don't index external drives by default)
run_defaults "com.apple.spotlight" "ExternalVolumes" "-bool" "false"

# ==============================================================================
# Privacy & Search Shortcuts
# ==============================================================================

# --- Spotlight Keyboard Shortcut ---
# Key:          AppleSymbolicHotKeys
# Description:  Default is Cmd+Space. This is managed separately in keyboard.sh

msg_success "Spotlight settings configured."
msg_info "Note: Run 'sudo mdutil -E /' to reindex if needed."
