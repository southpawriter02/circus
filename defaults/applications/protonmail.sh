#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: ProtonMail Bridge Configuration
#
# DESCRIPTION:
#   Documentation of ProtonMail Bridge configuration options. ProtonMail Bridge
#   is a desktop application that runs in the background and provides IMAP/SMTP
#   access to your ProtonMail account for use with standard email clients.
#
# REQUIRES:
#   - macOS 10.12 (Sierra) or later
#   - ProtonMail Bridge installed
#   - ProtonMail account (paid plan required for Bridge)
#
# REFERENCES:
#   - ProtonMail Bridge: Setup guide
#     https://proton.me/support/protonmail-bridge-install
#   - ProtonMail Bridge: Configuration
#     https://proton.me/support/protonmail-bridge-configure-client
#
# DOMAIN:
#   ch.protonmail.protonmail-bridge
#
# NOTES:
#   - Bridge settings are stored in ~/.config/protonmail/bridge/
#   - IMAP default port: 1143
#   - SMTP default port: 1025
#   - Passwords are stored in macOS Keychain
#   - Bridge must be running for email clients to sync
#
# ==============================================================================

msg_info "Configuring ProtonMail Bridge settings..."

# ==============================================================================
# ProtonMail Bridge Configuration
#
# ProtonMail Bridge stores configuration in:
# ~/.config/protonmail/bridge/prefs.json
#
# Key configuration options:
#
# {
#   "user_ssl_choice": "SSL",
#   "cache_enabled": true,
#   "cache_compression": true,
#   "imap_port": 1143,
#   "smtp_port": 1025,
#   "smtp_ssl": true,
#   "first_start": false,
#   "autostart": true,
#   "autoupdate": true
# }
#
# ==============================================================================

# ==============================================================================
# Default Ports
# ==============================================================================

# ProtonMail Bridge uses non-standard ports to avoid conflicts:
#
# IMAP Configuration:
#   - Server: 127.0.0.1
#   - Port: 1143
#   - Security: STARTTLS
#
# SMTP Configuration:
#   - Server: 127.0.0.1
#   - Port: 1025
#   - Security: STARTTLS
#
# These ports are configurable in Bridge settings if needed.

# ==============================================================================
# Keychain Integration
# ==============================================================================

# ProtonMail Bridge stores account credentials in macOS Keychain:
#   - Service: ProtonMail Bridge
#   - Account: Your ProtonMail email address
#
# The bridge-specific password (not your ProtonMail password) is generated
# for each account and must be used in your email client.

# ==============================================================================
# Launch at Login Configuration
# ==============================================================================

BRIDGE_PLIST="$HOME/Library/LaunchAgents/ch.protonmail.protonmail-bridge.plist"

if [ -f "$BRIDGE_PLIST" ]; then
  msg_info "ProtonMail Bridge launch agent is configured"
else
  msg_info "ProtonMail Bridge: Configure 'Start on login' in Bridge settings"
fi

msg_success "ProtonMail Bridge configuration notes displayed."
echo ""
msg_info "ProtonMail Bridge settings are configured in the app:"
echo "  1. Click the Bridge icon in the menu bar"
echo "  2. Select 'Settings' or press Cmd+,"
echo ""
msg_info "Default connection settings for email clients:"
echo "  IMAP Server: 127.0.0.1:1143 (STARTTLS)"
echo "  SMTP Server: 127.0.0.1:1025 (STARTTLS)"
echo ""
msg_info "Password: Use the Bridge-generated password, not your ProtonMail password"
