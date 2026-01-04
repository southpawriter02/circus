#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Corporate Security Settings
#
# DESCRIPTION:
#   Stricter security defaults for corporate/enterprise environments.
#   These settings prioritize security over convenience.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Administrator privileges for some settings
#   - Some settings may be overridden by MDM profiles
#
# REFERENCES:
#   - Apple Platform Security Guide
#     https://support.apple.com/guide/security/welcome/web
#   - CIS Benchmarks for macOS
#     https://www.cisecurity.org/benchmark/apple_os
#   - NIST macOS Security Guidelines
#     https://csrc.nist.gov/projects/macos-security
#
# DOMAIN:
#   com.apple.screensaver
#   com.apple.Safari
#   com.apple.finder
#   NSGlobalDomain
#
# NOTES:
#   - These settings are more restrictive than personal defaults
#   - Verify with your security team before applying
#   - MDM policies may override these settings
#
# ==============================================================================

msg_info "Configuring corporate security settings..."

# ==============================================================================
# Screen Lock & Password
# ==============================================================================

# --- Require Password Immediately After Sleep ---
# Key:          askForPassword
# Domain:       com.apple.screensaver
# Description:  Require password when waking from sleep or screen saver.
# Default:      1 (require password)
# Set to:       1 (always require - mandatory for corporate)
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- No Password Delay ---
# Key:          askForPasswordDelay
# Domain:       com.apple.screensaver
# Description:  Delay before requiring password (in seconds).
# Default:      0 (immediately)
# Set to:       0 (no delay - immediately require password)
# Security:     Critical for preventing unauthorized access
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"

# --- Screen Saver Activation Time ---
# Key:          idleTime
# Domain:       com.apple.screensaver
# Description:  Start screen saver after idle time (in seconds).
# Default:      1200 (20 minutes)
# Set to:       300 (5 minutes - shorter for corporate security)
# Note:         This can be set via: defaults -currentHost write
run_defaults -currentHost "com.apple.screensaver" "idleTime" "-int" "300"

# ==============================================================================
# Firewall
# ==============================================================================

# --- Enable Application Firewall ---
# The firewall is controlled via socketfilterfw, not defaults.
# Enable with: sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
msg_info "Checking firewall status..."
if ! /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
    msg_warn "Firewall is not enabled. Enable with: sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on"
fi

# --- Block All Incoming Connections ---
# Blocks all incoming connections except those required for basic services
# Enable with: sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setblockall on
# Note: This may interfere with file sharing, screen sharing, etc.

# --- Enable Stealth Mode ---
# Don't respond to ICMP ping or connection attempts
# Enable with: sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# ==============================================================================
# Safari Security
# ==============================================================================

# --- Disable AutoFill for Credit Cards ---
# Key:          AutoFillCreditCardData
# Domain:       com.apple.Safari
# Description:  Don't auto-fill credit card information (use corporate cards).
# Default:      true
# Set to:       false (don't store payment info)
run_defaults "com.apple.Safari" "AutoFillCreditCardData" "-bool" "false"

# --- Warn About Fraudulent Websites ---
# Key:          WarnAboutFraudulentWebsites
# Domain:       com.apple.Safari
# Description:  Show warning when visiting known phishing sites.
# Default:      true
# Set to:       true (keep enabled for security)
run_defaults "com.apple.Safari" "WarnAboutFraudulentWebsites" "-bool" "true"

# --- Block Pop-up Windows ---
# Key:          WebKitJavaScriptCanOpenWindowsAutomatically
# Domain:       com.apple.Safari
# Description:  Prevent JavaScript from opening pop-up windows.
# Default:      false
# Set to:       false (block pop-ups)
run_defaults "com.apple.Safari" "WebKitJavaScriptCanOpenWindowsAutomatically" "-bool" "false"

# --- Enable Do Not Track ---
# Key:          SendDoNotTrackHTTPHeader
# Domain:       com.apple.Safari
# Description:  Send Do Not Track header to websites.
# Default:      false
# Set to:       true (request not to be tracked)
run_defaults "com.apple.Safari" "SendDoNotTrackHTTPHeader" "-bool" "true"

# ==============================================================================
# Finder Security
# ==============================================================================

# --- Show File Extensions ---
# Key:          AppleShowAllExtensions
# Domain:       NSGlobalDomain
# Description:  Show all file extensions to identify file types.
# Default:      false
# Set to:       true (prevent disguised executables)
# Security:     Helps identify malicious files hiding extensions
run_defaults "NSGlobalDomain" "AppleShowAllExtensions" "-bool" "true"

# --- Warn Before Changing File Extension ---
# Key:          FXEnableExtensionChangeWarning
# Domain:       com.apple.finder
# Description:  Warn when changing a file extension.
# Default:      true
# Set to:       true (prevent accidental changes)
run_defaults "com.apple.finder" "FXEnableExtensionChangeWarning" "-bool" "true"

# --- Warn Before Emptying Trash ---
# Key:          WarnOnEmptyTrash
# Domain:       com.apple.finder
# Description:  Ask for confirmation before emptying trash.
# Default:      true
# Set to:       true (prevent accidental deletion)
run_defaults "com.apple.finder" "WarnOnEmptyTrash" "-bool" "true"

# ==============================================================================
# Privacy
# ==============================================================================

# --- Disable Personalized Advertising ---
# Key:          allowApplePersonalizedAdvertising
# Domain:       com.apple.AdLib
# Description:  Disable personalized ads from Apple.
# Default:      true
# Set to:       false (disable for privacy)
run_defaults "com.apple.AdLib" "allowApplePersonalizedAdvertising" "-bool" "false"

# --- Disable Siri Data Sharing ---
# Key:          Siri Data Sharing Opt-In Status
# Domain:       com.apple.assistant.support
# Description:  Don't share Siri recordings with Apple.
# Default:      0
# Set to:       2 (explicitly opted out)
run_defaults "com.apple.assistant.support" "Siri Data Sharing Opt-In Status" "-int" "2"

# --- Disable Location Services for Spotlight Suggestions ---
# Note: Location Services are controlled via System Preferences

# ==============================================================================
# Auto-Lock
# ==============================================================================

# --- Auto-Logout After Idle ---
# Key:          AutoLogOutDelay
# Domain:       .GlobalPreferences
# Description:  Automatically log out after specified minutes of inactivity.
# Default:      0 (disabled)
# Set to:       60 (log out after 60 minutes idle - adjust per policy)
# Note:         This is aggressive; adjust based on corporate policy
# run_defaults ".GlobalPreferences" "AutoLogOutDelay" "-int" "60"

# ==============================================================================
# AirDrop & Sharing
# ==============================================================================

# --- Disable AirDrop ---
# Key:          DisableAirDrop
# Domain:       com.apple.NetworkBrowser
# Description:  Disable AirDrop file sharing.
# Default:      Not set (AirDrop enabled)
# Set to:       true (disable for corporate security)
# Note:         This prevents file transfers via AirDrop
run_defaults "com.apple.NetworkBrowser" "DisableAirDrop" "-bool" "true"

# ==============================================================================
# Bluetooth Security
# ==============================================================================

# --- Disable Bluetooth Sharing ---
# Key:          PrefKeyServicesEnabled
# Domain:       com.apple.Bluetooth
# Description:  Disable Bluetooth file sharing services.
# Default:      true
# Set to:       false (prevent unauthorized file transfers)
run_defaults "com.apple.Bluetooth" "PrefKeyServicesEnabled" "-bool" "false"

# --- Bluetooth Discoverability Timeout ---
# Key:          DiscoverableState
# Domain:       com.apple.Bluetooth
# Description:  Disable Bluetooth discoverability by default.
# Default:      1 (discoverable)
# Set to:       0 (not discoverable - pair manually when needed)
run_defaults "com.apple.Bluetooth" "DiscoverableState" "-int" "0"

# ==============================================================================
# Power & Sleep Security
# ==============================================================================

# --- Disable Wake for Network Access ---
# Key:          womp
# Domain:       com.apple.PowerManagement
# Description:  Don't wake computer for network access (Wake-on-LAN).
# Default:      1 (enabled)
# Set to:       0 (disable for security)
# Note:         Requires sudo, so we just log the recommendation
msg_info "Recommendation: Disable Wake for Network Access"
msg_info "  Run: sudo pmset -a womp 0"

# --- Disable Power Nap ---
# Key:          powernap
# Domain:       com.apple.PowerManagement
# Description:  Don't perform background tasks during sleep.
# Default:      1 (enabled on laptops)
# Set to:       0 (disable to prevent network activity during sleep)
# Note:         Requires sudo, so we just log the recommendation
msg_info "Recommendation: Disable Power Nap"
msg_info "  Run: sudo pmset -a powernap 0"

# ==============================================================================
# Terminal Security
# ==============================================================================

# --- Enable Secure Keyboard Entry in Terminal ---
# Key:          SecureKeyboardEntry
# Domain:       com.apple.Terminal
# Description:  Prevent other apps from intercepting keyboard input.
# Default:      false
# Set to:       true (protect passwords entered in terminal)
# Security:     Critical for SSH, sudo, and other sensitive input
run_defaults "com.apple.Terminal" "SecureKeyboardEntry" "-bool" "true"

# --- Enable Secure Keyboard Entry in iTerm2 ---
# Key:          "Secure Input"
# Domain:       com.googlecode.iterm2
# Description:  Prevent other apps from intercepting keyboard input in iTerm2.
# Set to:       true (protect sensitive terminal input)
run_defaults "com.googlecode.iterm2" "Secure Input" "-bool" "true"

# ==============================================================================
# Sharing Services (Disable Unnecessary)
# ==============================================================================

# --- Disable Remote Apple Events ---
# Key:          Remote Apple Events
# Domain:       com.apple.remoteappleevents
# Description:  Allow remote AppleScript execution.
# Default:      Off
# Set to:       Off (ensure disabled - security risk)
# Note:         Controlled via: sudo systemsetup -setremoteappleevents off
msg_info "Recommendation: Ensure Remote Apple Events is disabled"
msg_info "  Run: sudo systemsetup -setremoteappleevents off"

# --- Disable Remote Login (SSH) by Default ---
# Note: Only enable if specifically needed
# Controlled via: sudo systemsetup -setremotelogin off
msg_info "Recommendation: Verify Remote Login (SSH) status"
msg_info "  Check: sudo systemsetup -getremotelogin"
msg_info "  Disable if not needed: sudo systemsetup -setremotelogin off"

# --- Disable Internet Sharing ---
# Key:          NAT
# Domain:       com.apple.MCX
# Description:  Prevent this Mac from sharing its internet connection.
# Note:         Controlled via System Preferences > Sharing
msg_info "Recommendation: Ensure Internet Sharing is disabled"
msg_info "  Check: System Settings > General > Sharing > Internet Sharing"

# --- Disable File Sharing ---
# Note: Controlled via System Preferences > Sharing
msg_info "Recommendation: Ensure File Sharing is disabled unless required"
msg_info "  Check: System Settings > General > Sharing > File Sharing"

# ==============================================================================
# System Preferences Protection
# ==============================================================================

# --- Require Admin Password for System-Wide Changes ---
# Key:          AdminHostInfo
# Domain:       com.apple.loginwindow
# Description:  Display admin info on login window (for IT support).
# Set to:       HostName (show hostname for identification)
run_defaults "com.apple.loginwindow" "AdminHostInfo" "-string" "HostName"

# --- Disable Guest Account ---
# Key:          GuestEnabled
# Domain:       com.apple.loginwindow
# Description:  Disable the guest account entirely.
# Default:      false
# Set to:       false (ensure guest access is disabled)
run_defaults "com.apple.loginwindow" "GuestEnabled" "-bool" "false"

# --- Show Username and Password Fields at Login ---
# Key:          SHOWFULLNAME
# Domain:       com.apple.loginwindow
# Description:  Require username entry (don't show user list).
# Default:      false (shows user list)
# Set to:       true (more secure - attacker doesn't know usernames)
run_defaults "com.apple.loginwindow" "SHOWFULLNAME" "-bool" "true"

# ==============================================================================
# Gatekeeper & App Security
# ==============================================================================

# --- Ensure Gatekeeper is Enabled ---
# Note: Controlled via spctl, not defaults
msg_info "Checking Gatekeeper status..."
if spctl --status 2>/dev/null | grep -q "disabled"; then
    msg_warn "Gatekeeper is DISABLED. Enable with: sudo spctl --master-enable"
else
    msg_success "Gatekeeper is enabled."
fi

# --- App Store and Identified Developers Only ---
# Key:          EnableAssessment
# Domain:       com.apple.security
# Description:  Control which apps can be opened.
# Note:         Controlled via System Preferences > Privacy & Security
msg_info "Recommendation: Set app installation to 'App Store and identified developers'"
msg_info "  Check: System Settings > Privacy & Security > Security"

# ==============================================================================
# Audit & Logging
# ==============================================================================

# --- Enable Security Audit Logging ---
# Note: Requires root, typically managed by MDM
msg_info "Recommendation: Enable security audit logging"
msg_info "  Run: sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist"

msg_success "Corporate security settings configured."

# ==============================================================================
# Additional Security Recommendations
#
# FileVault:
#   Enable full disk encryption: sudo fdesetup enable
#   Check status: sudo fdesetup status
#
# Firmware Password (Intel Macs):
#   Set via Recovery Mode: firmwarepasswd -setpasswd
#
# Gatekeeper:
#   Ensure enabled: spctl --status
#   Enable: sudo spctl --master-enable
#
# System Integrity Protection (SIP):
#   Check: csrutil status
#   Should be: enabled
#
# Secure Token:
#   Check: sysadminctl -secureTokenStatus <username>
#
# Remote Management:
#   Disable if not needed: sudo systemsetup -setremotelogin off
#
# Bluetooth:
#   Disable if not needed for security-sensitive environments
#
# ==============================================================================
