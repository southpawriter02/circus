#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Notion Configuration
#
# DESCRIPTION:
#   Documentation of Notion configuration options. Notion is a note-taking and
#   project management application. Most Notion settings are stored server-side
#   and sync across devices via your account, not local macOS preferences.
#
# REQUIRES:
#   - macOS 10.13 (High Sierra) or later
#   - Notion desktop app installed
#
# REFERENCES:
#   - Notion Help: Desktop app settings
#     https://www.notion.so/help/notion-for-mac-windows
#   - Notion Help: Keyboard shortcuts
#     https://www.notion.so/help/keyboard-shortcuts
#
# DOMAIN:
#   notion.id
#
# NOTES:
#   - Most Notion preferences are account-based, not local
#   - Theme, font, and display settings sync via Notion account
#   - The desktop app has minimal local preferences
#   - Quick Note feature is configured in the app
#
# ==============================================================================

msg_info "Configuring Notion settings..."

# ==============================================================================
# Notion Configuration Notes
#
# Notion uses primarily account-based settings that sync across all devices.
# The following settings are configured within the Notion app, not via defaults:
#
# APPEARANCE (In-App Settings):
#   Settings > Appearance > Theme
#   - Light, Dark, or System
#
#   Settings > Appearance > Small text
#   - Reduces default text size for denser content display
#
#   Settings > Appearance > Full width by default
#   - New pages use full width layout
#
# QUICK NOTE (In-App Settings):
#   Settings > Quick Note
#   - Global keyboard shortcut (default: Control+Command+N)
#   - Opens a floating quick capture window
#
# STARTUP (In-App Settings):
#   Settings > Startup
#   - Open on login
#   - Start minimized
#
# ==============================================================================

# ==============================================================================
# Window Position (Local Setting)
# ==============================================================================

# Notion stores window position in its preferences. This is one of the few
# local settings, but it's automatically managed by the app.

# --- Window Frame ---
# Key:          NSWindow Frame Main
# Domain:       notion.id
# Description:  Stores the window position and size. Automatically saved
#               when you move or resize the Notion window.
# Note:         This is managed automatically by the app; manual setting
#               is not recommended as it will be overwritten.

msg_success "Notion configuration notes displayed."
echo ""
msg_info "Notion settings are primarily configured in-app:"
echo "  1. Click the gear icon (Settings & Members)"
echo "  2. Navigate to 'Settings' for appearance options"
echo "  3. Most settings sync via your Notion account"
echo ""
msg_info "Recommended in-app settings:"
echo "  - Appearance > Theme: System (follows macOS)"
echo "  - Startup > Open on login: As needed"
echo "  - Quick Note shortcut: Control+Command+N"
