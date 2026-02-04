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
# macOS Security Stack Overview
# ==============================================================================

# Gatekeeper is part of Apple's layered security approach:
#
# 1. GATEKEEPER - First-run verification of downloaded applications
#    - Checks if app is from App Store or signed by identified developer
#    - Verifies Apple notarization (app scanned for malware by Apple)
#    - Blocks apps that fail verification with option to override
#
# 2. XProtect - Signature-based malware detection
#    - Runs automatically in background
#    - Updated silently via automatic security updates
#    - Blocks known malware signatures
#
# 3. Malware Removal Tool (MRT) - Remediation
#    - Removes known malware if found
#    - Runs after system updates
#
# Source:       https://support.apple.com/guide/security/gatekeeper-and-runtime-protection-sec5599b66df/web
# See also:     https://support.apple.com/en-us/102445 (About notarization)

# ==============================================================================
# Quarantine (First-Launch Protection)
# ==============================================================================

# --- Quarantine Prompt for Downloaded Applications ---
# Key:          LSQuarantine
# Domain:       com.apple.LaunchServices
# Description:  Controls the "Are you sure you want to open this application?"
#               dialog shown when launching apps downloaded from the internet.
#
#               When you download a file via Safari, Chrome, Mail, or any
#               quarantine-aware app, macOS adds an extended attribute:
#                 com.apple.quarantine
#
#               This attribute contains:
#               - Timestamp of download
#               - Source URL (if available)
#               - Application that downloaded the file
#
#               On first launch, Gatekeeper reads this attribute and:
#               1. Verifies the app's code signature
#               2. Checks for Apple notarization (malware scan certificate)
#               3. Shows the quarantine dialog asking for confirmation
#               4. On approval, removes the quarantine flag
#
# Default:      true (quarantine system active - STRONGLY RECOMMENDED)
# Options:      true = Show quarantine dialog, verify downloads (secure)
#               false = Skip quarantine (DANGEROUS - removes malware protection)
# Set to:       true (maintain security protections for downloaded apps)
# UI Location:  No direct UI toggle - Gatekeeper setting in Security & Privacy
#               affects first-launch behavior
# Source:       https://support.apple.com/en-us/HT202491
# See also:     https://support.apple.com/guide/security/protecting-against-malware-sec469d47bd8/web
#
# Security:     CRITICAL - Disabling quarantine removes your primary protection
#               against malicious downloads. An attacker could trick you into
#               running malware that would execute without any warning.
#
# Note:         To manually inspect quarantine attributes on a file:
#                 xattr -l /path/to/file
#                 xattr -p com.apple.quarantine /path/to/file
#
#               To manually remove quarantine (use with caution):
#                 xattr -d com.apple.quarantine /path/to/file
#
#               Or recursively for app bundles:
#                 xattr -r -d com.apple.quarantine /path/to/App.app
run_defaults "com.apple.LaunchServices" "LSQuarantine" "-bool" "true"

# ==============================================================================
# Gatekeeper Configuration
# ==============================================================================

# --- Gatekeeper App Verification Policy ---
# Description:  Gatekeeper controls which applications are allowed to run based
#               on their source and signing status. This is macOS's primary
#               defense against malware distributed outside the App Store.
#
# Verification Levels (spctl):
#   1. App Store Only (most restrictive):
#      - Only apps downloaded from Mac App Store can run
#      - Apps are fully vetted by Apple's review process
#      - Sandboxed with limited system access
#
#   2. App Store and Identified Developers (default, recommended):
#      - App Store apps allowed
#      - Apps signed with Developer ID and notarized by Apple allowed
#      - Notarization = Apple scanned the app for malware
#      - Balance of security and flexibility
#
#   3. Anywhere (removed in macOS Sierra):
#      - Allowed any app to run regardless of signing
#      - No longer available in System Settings
#      - Can only be achieved by disabling Gatekeeper entirely
#
# UI Location:  System Settings > Privacy & Security > Security >
#               "Allow apps downloaded from"
# Source:       https://support.apple.com/en-us/HT202491
# See also:     https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution
#
# Note:         Gatekeeper is managed via spctl, NOT defaults write.
#               See command reference below.

# ==============================================================================
# spctl Command Reference
# ==============================================================================

# --- Status Commands ---
#   spctl --status
#       Output: "assessments enabled" or "assessments disabled"
#       Returns the current Gatekeeper state
#
# --- Enable/Disable Gatekeeper ---
#   sudo spctl --master-enable       # Enable Gatekeeper (RECOMMENDED)
#   sudo spctl --master-disable      # Disable Gatekeeper (NOT RECOMMENDED)
#
#   WARNING: Disabling Gatekeeper removes ALL app verification.
#            Any application, including malware, will run without warning.
#            Only disable temporarily for specific trusted apps if needed.
#
# --- Allow Specific Blocked Apps ---
#   When Gatekeeper blocks an app, you have several options:
#
#   Option 1 - Right-click Open (easiest):
#     1. Right-click (or Ctrl+click) the blocked app
#     2. Select "Open" from the context menu
#     3. Click "Open" in the dialog
#     4. App is now allowed permanently
#
#   Option 2 - System Settings (for already-blocked apps):
#     1. System Settings > Privacy & Security
#     2. Scroll to Security section
#     3. Click "Open Anyway" button (appears after block)
#
#   Option 3 - spctl (command line):
#     sudo spctl --add "/Applications/Some App.app"       # Allow app
#     sudo spctl --add --label "MyApps" "/path/to/app"    # Add with label
#     sudo spctl --remove "/path/to/app"                  # Remove approval
#     sudo spctl --list                                   # List all rules
#
# --- Assess Apps Without Running ---
#   spctl --assess --type execute "/path/to/app"
#       Checks if app would be allowed to run
#       Returns exit code 0 if allowed, 3 if blocked
#       Add -v for verbose reason
#
# Source:       man spctl
# See also:     man codesign, man stapler

msg_success "Gatekeeper and quarantine settings configured."
