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
# Source:       https://support.apple.com/guide/mac-help/spotlight-mchlp1008/mac
# Note:         This is a complex plist array - using individual toggles below

# --- Disable Spotlight Suggestions (Siri Suggestions) ---
# Key:          LookupSuggestionsDisabled
# Domain:       com.apple.lookup.shared
# Description:  Controls whether Spotlight shows suggestions from the internet,
#               including Wikipedia articles, news, iTunes Store content, App Store
#               apps, nearby locations, and web search results. When enabled, these
#               suggestions are disabled and Spotlight searches only local content.
#               Disabling suggestions also prevents your search queries from being
#               sent to Apple servers.
# Default:      false (suggestions enabled - searches sent to Apple)
# Options:      true = Disable internet suggestions (local search only)
#               false = Enable internet suggestions (queries sent to Apple)
# Set to:       true (privacy-focused; prevents search queries from being
#               transmitted to Apple servers for suggestion generation)
# UI Location:  System Settings > Spotlight > "Siri Suggestions" toggle
#               System Settings > Spotlight > Search Results > uncheck categories
# Source:       https://support.apple.com/guide/mac-help/spotlight-mchlp1008/mac
# Security:     When suggestions are enabled, your search queries are sent to
#               Apple to generate relevant suggestions. Disable for privacy.
# See also:     https://support.apple.com/en-us/102441
run_defaults "com.apple.lookup.shared" "LookupSuggestionsDisabled" "-bool" "true"

# ==============================================================================
# Indexing Behavior
# ==============================================================================

# --- Disable Spotlight Indexing on External Volumes ---
# Key:          ExternalVolumes
# Domain:       com.apple.spotlight
# Description:  Controls whether Spotlight indexes external and network-mounted
#               volumes. When disabled, external drives, USB sticks, and network
#               shares are not indexed, which can improve performance during
#               large file transfers and preserve privacy of removable media.
# Default:      true (index external volumes)
# Options:      true = Index external and network volumes (searchable)
#               false = Skip indexing external volumes (not searchable)
# Set to:       false (improves performance with external drives and preserves
#               privacy of removable media; use `mdfind -onlyin /Volumes/...`
#               for manual searches when needed)
# UI Location:  System Settings > Spotlight > Search Results > External disks
#               Also: Privacy tab to exclude specific volumes
# Source:       https://support.apple.com/guide/mac-help/spotlight-mchlp1008/mac
# Note:         To prevent indexing of specific volumes, you can also add them
#               to the Privacy list in System Settings > Spotlight, or create a
#               .metadata_never_index file in the volume root.
# See also:     man mdutil, man mdfind
run_defaults "com.apple.spotlight" "ExternalVolumes" "-bool" "false"

# ==============================================================================
# Privacy & Search Shortcuts
# ==============================================================================

# --- Spotlight Keyboard Shortcut ---
# Key:          AppleSymbolicHotKeys
# Description:  Default is Cmd+Space. This is managed separately in keyboard.sh

msg_success "Spotlight settings configured."
msg_info "Note: Run 'sudo mdutil -E /' to reindex if needed."
