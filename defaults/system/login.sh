#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Login Window Settings
#
# DESCRIPTION:
#   Configures login window behavior, security settings, and display options.
#   These settings affect the login screen appearance and authentication.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Administrator privileges for most settings
#   - Some settings require logout to take effect
#
# REFERENCES:
#   - Apple Support: Change Login Items on Mac
#     https://support.apple.com/guide/mac-help/open-items-automatically-when-you-log-in-mh15189/mac
#   - Apple Support: Log in to your Mac
#     https://support.apple.com/guide/mac-help/log-in-to-your-mac-mh35843/mac
#
# DOMAIN:
#   com.apple.loginwindow
#   com.apple.screensaver
#
# NOTES:
#   - Login window settings affect all users on the Mac
#   - Some security settings may be enforced by MDM profiles
#   - FileVault settings are separate (use fdesetup command)
#
# ==============================================================================

msg_info "Configuring login window settings..."

# ==============================================================================
# Login Window Appearance
# ==============================================================================

# --- Show Full Name and Password Fields ---
# Key:          SHOWFULLNAME
# Domain:       com.apple.loginwindow
# Description:  Controls whether the login window shows a list of users or
#               requires typing username and password.
# Default:      false (show list of users)
# Options:      true = Show name and password fields (more secure)
#               false = Show list of users with icons
# Set to:       false (show user list for convenience)
# UI Location:  System Settings > Users & Groups > Login Options
# Security:     Setting to true hides usernames from potential attackers
run_defaults "com.apple.loginwindow" "SHOWFULLNAME" "-bool" "false"

# --- Show Input Menu in Login Window ---
# Key:          showInputMenu
# Domain:       com.apple.loginwindow
# Description:  Show the input source menu (keyboard layout selector) on
#               the login window.
# Default:      false
# Options:      true = Show input menu, false = Hide input menu
# Set to:       true (useful if you use multiple keyboard layouts)
# UI Location:  System Settings > Users & Groups > Login Options
run_defaults "com.apple.loginwindow" "showInputMenu" "-bool" "true"

# --- Show Password Hints ---
# Key:          RetriesUntilHint
# Domain:       com.apple.loginwindow
# Description:  Number of failed password attempts before showing password hint.
#               Set to 0 to disable password hints.
# Default:      3
# Options:      0 = Never show hints (more secure)
#               1-10 = Show after N failed attempts
# Set to:       0 (disable password hints for security)
# UI Location:  System Settings > Users & Groups > Login Options
# Security:     Disabling hints prevents hint information disclosure
run_defaults "com.apple.loginwindow" "RetriesUntilHint" "-int" "0"

# ==============================================================================
# Power Options on Login Screen
# ==============================================================================

# --- Show Restart Button ---
# Key:          PowerOffDisabled
# Domain:       com.apple.loginwindow
# Description:  Controls whether the Shut Down button is shown on the login window.
# Default:      false (show button)
# Options:      true = Hide power button, false = Show power button
# Set to:       false (allow restart/shutdown from login window)
# UI Location:  Not directly in UI, requires MDM or terminal
run_defaults "com.apple.loginwindow" "PowerOffDisabled" "-bool" "false"

# --- Show Sleep Button ---
# Key:          SleepDisabled
# Domain:       com.apple.loginwindow
# Description:  Controls whether the Sleep option is available from login window.
# Default:      false (allow sleep)
# Options:      true = Disable sleep, false = Allow sleep
# Set to:       false (allow sleep from login window)
run_defaults "com.apple.loginwindow" "SleepDisabled" "-bool" "false"

# ==============================================================================
# Guest Account
# ==============================================================================

# --- Disable Guest Account ---
# Key:          GuestEnabled
# Domain:       com.apple.loginwindow
# Description:  Controls whether the Guest User account is available.
#               Guest account has limited access and data is deleted on logout.
# Default:      false (guest disabled)
# Options:      true = Enable guest account
#               false = Disable guest account
# Set to:       false (disable guest account for security)
# UI Location:  System Settings > Users & Groups > Guest User
# Security:     Disabling guest account prevents unauthorized access
run_defaults "com.apple.loginwindow" "GuestEnabled" "-bool" "false"

# ==============================================================================
# Automatic Login
# ==============================================================================

# --- Disable Automatic Login ---
# Key:          autoLoginUser
# Domain:       com.apple.loginwindow
# Description:  When set, the specified user logs in automatically at startup.
#               Deleting this key disables automatic login.
# Default:      Not set (automatic login disabled)
# Set to:       Delete key (ensure automatic login is disabled)
# UI Location:  System Settings > Users & Groups > Login Options
# Security:     Automatic login should be disabled for security
# Note:         Cannot be enabled when FileVault is on
sudo defaults delete "com.apple.loginwindow" "autoLoginUser" 2>/dev/null || true

# ==============================================================================
# Login Window Message
# ==============================================================================

# --- Show Custom Login Window Message ---
# Key:          LoginwindowText
# Domain:       com.apple.loginwindow
# Description:  Displays a custom message on the login window.
#               Useful for contact information if laptop is lost.
# Default:      Empty (no message)
# Set to:       Contact information (uncomment and customize below)
# UI Location:  System Settings > Lock Screen > Show message when locked
# run_defaults "com.apple.loginwindow" "LoginwindowText" "-string" "If found, please contact: your.email@example.com"

# ==============================================================================
# Screen Lock Settings
# ==============================================================================

# --- Require Password After Sleep/Screen Saver ---
# Key:          askForPassword
# Domain:       com.apple.screensaver
# Description:  Require password when waking from sleep or screen saver.
# Default:      1 (require password)
# Options:      0 = Don't require password, 1 = Require password
# Set to:       1 (always require password for security)
# UI Location:  System Settings > Lock Screen
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- Password Delay After Sleep/Screen Saver ---
# Key:          askForPasswordDelay
# Domain:       com.apple.screensaver
# Description:  Seconds to wait before requiring password after sleep or
#               screen saver begins. 0 = immediately.
# Default:      0 (immediately)
# Options:      0 = Immediately
#               60 = 1 minute
#               300 = 5 minutes
#               etc.
# Set to:       0 (require password immediately for security)
# UI Location:  System Settings > Lock Screen > Require password after...
# Security:     Setting to 0 provides strongest security
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"

# ==============================================================================
# Console Access
# ==============================================================================

# --- Disable Console Login ---
# Key:          DisableConsoleAccess
# Domain:       com.apple.loginwindow
# Description:  Prevents users from accessing the console by typing ">console"
#               as the username at the login window.
# Default:      false (console access allowed)
# Options:      true = Disable console access
#               false = Allow console access
# Set to:       true (disable for security)
# Security:     Console access can be used to bypass some security measures
run_defaults "com.apple.loginwindow" "DisableConsoleAccess" "-bool" "true"

msg_success "Login window settings configured."

# ==============================================================================
# Additional Notes
#
# FileVault (Full Disk Encryption):
#   FileVault is managed separately using the fdesetup command.
#   - Check status: sudo fdesetup status
#   - Enable: sudo fdesetup enable
#   - Disable: sudo fdesetup disable
#
# Login Items (Apps that launch at login):
#   - User login items: System Settings > Users & Groups > Login Items
#   - System login items: /Library/LaunchAgents/ and /Library/LaunchDaemons/
#
# Fast User Switching:
#   System Settings > Control Center > Fast User Switching
#
# ==============================================================================
