#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Gatekeeper & Quarantine
#
# DESCRIPTION:
#   Configures Gatekeeper security settings that control which applications
#   are allowed to run on your Mac. Gatekeeper verifies downloaded apps
#   against known malware and checks developer signatures.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings may require disabling SIP (not recommended)
#
# REFERENCES:
#   - Apple Support: Safely open apps on your Mac
#     https://support.apple.com/en-us/HT202491
#   - Apple Support: About Gatekeeper
#     https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df/web
#
# DOMAIN:
#   com.apple.LaunchServices
#
# NOTES:
#   - Gatekeeper's strictest settings are recommended for most users
#   - Quarantine attributes can be manually removed with: xattr -d com.apple.quarantine <file>
#   - Extended attributes can be viewed with: xattr -l <file>
#
# ==============================================================================

msg_info "Configuring Gatekeeper and quarantine settings..."

# ==============================================================================
# Quarantine Dialog
# ==============================================================================

# --- Disable Quarantine Prompt for Downloaded Applications ---
# Key:          LSQuarantine
# Domain:       com.apple.LaunchServices
# Description:  Controls whether macOS shows the "Are you sure you want to open
#               this application?" dialog for apps downloaded from the internet.
#               The quarantine system adds extended attributes to downloaded files.
# Default:      true (show quarantine dialog)
# Options:      true = Show quarantine dialog for downloaded apps
#               false = Skip quarantine dialog (less secure)
# Set to:       true (keep the quarantine dialog for security)
# UI Location:  No direct UI equivalent (Gatekeeper in Security & Privacy)
# Security:     IMPORTANT: Keeping this enabled is strongly recommended
#               as it protects against malicious downloaded software
run_defaults "com.apple.LaunchServices" "LSQuarantine" "-bool" "true"

# ==============================================================================
# Gatekeeper Configuration
#
# NOTE: Gatekeeper settings are primarily controlled via spctl command, not
# defaults. The following documents the available options for reference:
#
# Check Gatekeeper status:
#   spctl --status
#
# Enable Gatekeeper (recommended):
#   sudo spctl --master-enable
#
# Disable Gatekeeper (not recommended):
#   sudo spctl --master-disable
#
# Gatekeeper policies:
#   - App Store only: spctl --master-enable
#   - App Store and identified developers: This is the default
#   - Anywhere: Removed in macOS Sierra, requires disabling Gatekeeper
#
# To allow a specific blocked app:
#   sudo spctl --add /path/to/app
#   OR right-click the app and select "Open"
#
# To remove an app from allowed list:
#   sudo spctl --remove /path/to/app
#
# ==============================================================================

msg_success "Gatekeeper and quarantine settings configured."
