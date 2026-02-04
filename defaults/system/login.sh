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

# --- Username and Password Entry Style ---
# Key:          SHOWFULLNAME
# Domain:       com.apple.loginwindow
# Description:  Controls the login window authentication style. When false, the
#               login window displays a list of user accounts with profile icons,
#               allowing click-to-select login. When true, users must type both
#               username and password into blank fields (more secure but less
#               convenient).
#
#               Security Implications:
#               - User list visible = Attackers know valid usernames
#               - Blank fields = Username must be guessed (adds security layer)
#               - In targeted attacks, knowing usernames helps password attacks
#               - For shared/public Macs, blank fields are recommended
#
# Default:      false (show user list with profile pictures)
# Options:      true = Show name and password fields only (username hidden)
#               false = Show clickable list of user accounts with avatars
# Set to:       false (show user list; change to true for high-security environments)
# UI Location:  System Settings > Users & Groups > Login Options >
#               "Show login window as" > Name and password / List of users
# Source:       https://support.apple.com/guide/mac-help/mh35843/mac
# See also:     https://support.apple.com/guide/deployment/dep405a0f4e/web
# Security:     For public or high-security environments, set to true to prevent
#               username enumeration. An attacker who can see the user list
#               already has half the credentials they need.
run_defaults "com.apple.loginwindow" "SHOWFULLNAME" "-bool" "false"

# --- Input Source Menu on Login Window ---
# Key:          showInputMenu
# Domain:       com.apple.loginwindow
# Description:  Displays a keyboard layout/input source selector on the login
#               window. Essential for users who use non-English keyboard layouts
#               or need to enter passwords with special characters. Without this,
#               users stuck on the wrong keyboard layout may not be able to type
#               their password correctly.
# Default:      false (input menu hidden)
# Options:      true = Show keyboard/input source selector on login window
#               false = Hide input menu (use default system keyboard)
# Set to:       true (helpful for multi-keyboard-layout environments)
# UI Location:  System Settings > Users & Groups > Login Options >
#               Show Input menu in login window
# Source:       https://support.apple.com/guide/mac-help/mh35843/mac
# Note:         Particularly important for international environments or when
#               password contains characters not on the default keyboard layout.
run_defaults "com.apple.loginwindow" "showInputMenu" "-bool" "true"

# --- Password Hint Disclosure ---
# Key:          RetriesUntilHint
# Domain:       com.apple.loginwindow
# Description:  Number of failed password attempts before the system displays
#               the user's password hint. Setting to 0 completely disables hints.
#
#               Security Analysis:
#               - Password hints are often too revealing (spouse name, pet, etc.)
#               - Hints provide attackers with password-cracking intelligence
#               - Users often create hints that essentially ARE the password
#               - In phishing scenarios, hints leak private information
#               - Enterprise security policies typically disable hints
#
# Default:      3 (show hint after 3 failed attempts)
# Options:      0 = Never show password hints (most secure)
#               1-10 = Show hint after N failed attempts
# Set to:       0 (disable password hints for security)
# UI Location:  System Settings > Users & Groups > Login Options >
#               Show password hints (checkbox, not granular)
# Source:       https://support.apple.com/guide/mac-help/mh35843/mac
# Security:     STRONGLY RECOMMENDED to set to 0. Password hints are a known
#               attack vector. If users need hints, use a password manager instead.
run_defaults "com.apple.loginwindow" "RetriesUntilHint" "-int" "0"

# ==============================================================================
# Power Controls on Login Screen
# ==============================================================================

# --- Shutdown/Restart Button Visibility ---
# Key:          PowerOffDisabled
# Domain:       com.apple.loginwindow
# Description:  Controls whether the "Shut Down" and "Restart" buttons appear
#               on the login window. When disabled (set to true), users cannot
#               power off or restart the Mac from the login screen without
#               authenticating first.
#
#               Use Cases for Disabling:
#               - Kiosk deployments where reboots should require admin
#               - Servers that should stay online
#               - Preventing unauthorized reboots in shared spaces
#
# Default:      false (power buttons shown)
# Options:      true = Hide Shut Down/Restart buttons
#               false = Show Shut Down/Restart buttons (standard)
# Set to:       false (allow power control from login window for home users)
# UI Location:  Not in System Settings UI; requires command line or MDM
# Source:       https://developer.apple.com/documentation/devicemanagement/loginwindow
# Note:         Physical power button still works regardless of this setting.
run_defaults "com.apple.loginwindow" "PowerOffDisabled" "-bool" "false"

# --- Sleep Button Visibility ---
# Key:          SleepDisabled
# Domain:       com.apple.loginwindow
# Description:  Controls whether the "Sleep" option is available from the login
#               window Apple menu. When disabled, users cannot put the Mac to
#               sleep without first logging in.
# Default:      false (sleep available)
# Options:      true = Disable sleep from login window
#               false = Allow sleep from login window
# Set to:       false (allow sleep; useful for power management)
# UI Location:  Not in System Settings UI; requires command line or MDM
# Source:       https://developer.apple.com/documentation/devicemanagement/loginwindow
run_defaults "com.apple.loginwindow" "SleepDisabled" "-bool" "false"

# ==============================================================================
# Guest Account
# ==============================================================================

# --- Guest User Account ---
# Key:          GuestEnabled
# Domain:       com.apple.loginwindow
# Description:  Controls whether the Guest User account is available at login.
#               When enabled, anyone can use your Mac without a password—the
#               guest session runs in a temporary sandbox and all data is deleted
#               when the guest logs out.
#
#               Guest Account Characteristics:
#               - No password required to log in
#               - Limited access (cannot change settings, install apps)
#               - Cannot access other users' files
#               - All files deleted automatically on logout
#               - Useful for Find My Mac (lost Macs can still connect to internet)
#
#               Security Trade-off:
#               - RISK: Anyone can use your Mac and browse the internet
#               - BENEFIT: If Mac is stolen, guest can connect to internet,
#                 enabling Find My to locate and lock/erase the device
#
# Default:      false (guest disabled in modern macOS)
# Options:      true = Enable Guest User at login window
#               false = Disable Guest User (no guest access)
# Set to:       false (disable for security; enable if Find My recovery matters)
# UI Location:  System Settings > Users & Groups > Guest User
# Source:       https://support.apple.com/guide/mac-help/mh35614/mac
# See also:     https://support.apple.com/en-us/102648 (Find My Mac)
# Security:     Disable unless you specifically need guest access or rely on
#               Find My Mac's requirement for network connectivity on lost devices.
run_defaults "com.apple.loginwindow" "GuestEnabled" "-bool" "false"

# ==============================================================================
# Automatic Login
# ==============================================================================

# --- Disable Automatic Login ---
# Key:          autoLoginUser
# Domain:       com.apple.loginwindow
# Description:  When set to a username, that user is automatically logged in at
#               startup without requiring password entry. Deleting this key
#               disables automatic login entirely.
#
#               MAJOR SECURITY RISK:
#               - Anyone who turns on your Mac gets full access to your account
#               - No protection against theft—data is immediately accessible
#               - Cannot be enabled when FileVault is on (FileVault requires auth)
#               - Bypasses all login security measures
#
#               The ONLY valid use case is single-user Macs that never leave
#               a physically secured location (mounted kiosk, home entertainment).
#
# Default:      Not set (automatic login disabled)
# Set to:       Delete key (ensure automatic login is disabled)
# UI Location:  System Settings > Users & Groups > Login Options >
#               Automatic login (dropdown, disabled if FileVault on)
# Source:       https://support.apple.com/guide/mac-help/mh35843/mac
# Security:     CRITICAL - Automatic login should ALWAYS be disabled for:
#               - Laptops
#               - Macs with sensitive data
#               - Multi-user Macs
#               - Any Mac that could be physically accessed by others
# Note:         This command deletes the key if it exists; || true prevents
#               error if the key is already absent.
sudo defaults delete "com.apple.loginwindow" "autoLoginUser" 2>/dev/null || true

# ==============================================================================
# Login Window Message
# ==============================================================================

# --- Custom Login Window Message ---
# Key:          LoginwindowText
# Domain:       com.apple.loginwindow
# Description:  Displays a custom text message on the login window below the
#               user selection or login fields. This message appears before
#               anyone logs in and is visible to anyone who sees your Mac's
#               login screen.
#
#               Common Use Cases:
#               - Contact info if laptop is lost/stolen (email, phone)
#               - Device asset tag or inventory number
#               - Organization name and IT support contact
#               - Legal warning banner (required by some compliance standards)
#               - "This device is monitored" notice
#
#               Example Messages:
#               - "If found, please call 555-123-4567 or email you@email.com"
#               - "Property of Acme Corp. Asset #12345. IT: help@acme.com"
#               - "WARNING: Authorized users only. Activity is monitored."
#
# Default:      Empty (no message displayed)
# Set to:       Contact information or leave commented out
# UI Location:  System Settings > Lock Screen > Show message when locked
#               (click "Set..." button to enter message)
# Source:       https://support.apple.com/guide/mac-help/mh35843/mac
# Security:     Including contact info may help recover a lost Mac; however,
#               it also reveals ownership information to potential attackers.
#               For high-value targets, consider a generic "return to IT" message.
# Note:         Uncomment and customize the line below to set a message:
# run_defaults "com.apple.loginwindow" "LoginwindowText" "-string" "If found, please contact: your.email@example.com"

# ==============================================================================
# Screen Lock Settings
# ==============================================================================

# --- Require Password After Sleep/Screen Saver ---
# Key:          askForPassword
# Domain:       com.apple.screensaver
# Description:  Controls whether a password (or Touch ID/Apple Watch) is required
#               to unlock your Mac after the screen saver starts or the display
#               sleeps. This is one of the most important security settings on
#               any Mac, as it protects your data when you step away.
#
#               Authentication Methods (when enabled):
#               - User account password
#               - Touch ID (if available)
#               - Apple Watch unlock (if configured)
#
# Default:      1 (password required)
# Options:      0 = No password required to wake (INSECURE)
#               1 = Password/Touch ID required to wake (SECURE)
# Set to:       1 (always require authentication for security)
# UI Location:  System Settings > Lock Screen > Require password after screen
#               saver begins or display is turned off
# Source:       https://support.apple.com/guide/mac-help/mchlp2270/mac
# Security:     CRITICAL - This is your primary protection when you step away.
#               Without this, anyone can access your unlocked session while
#               you're getting coffee, in a meeting, etc.
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- Password Delay Timer ---
# Key:          askForPasswordDelay
# Domain:       com.apple.screensaver
# Description:  The grace period (in seconds) after the screen saver starts or
#               display sleeps before the password is required. During this
#               window, you can wake the Mac without authenticating.
#
#               This setting balances security vs. convenience:
#               - 0 seconds = Immediate lock (most secure, can be annoying)
#               - 5-60 seconds = Brief grace period (reasonable compromise)
#               - 300+ seconds = Long delay (convenient but less secure)
#
# Default:      0 (password required immediately)
# Options:      0 = Immediately (no grace period)
#               5 = 5 seconds grace
#               60 = 1 minute grace
#               300 = 5 minutes grace
#               3600 = 1 hour grace (not recommended)
# Set to:       0 (immediate; maximum security, no window of vulnerability)
# UI Location:  System Settings > Lock Screen > Require password after screen
#               saver begins or display is turned off (dropdown)
# Source:       https://support.apple.com/guide/mac-help/mchlp2270/mac
# Security:     The grace period creates a window where anyone can access your
#               Mac without a password. For laptops or shared spaces, use 0.
#               A small delay (5-15 sec) can be useful to avoid re-auth when
#               you accidentally trigger the screen saver.
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"

# ==============================================================================
# Console Access
# ==============================================================================

# --- Console Login via >console Username ---
# Key:          DisableConsoleAccess
# Domain:       com.apple.loginwindow
# Description:  Controls access to the text-based console (terminal) login from
#               the login window. When enabled (set to true), typing ">console"
#               as the username is blocked.
#
#               What is Console Login?
#               - At the GUI login window, typing ">console" as username
#               - Drops to a text-based login (no GUI, just a terminal)
#               - Provides full shell access after authentication
#               - Historically used for troubleshooting when GUI fails
#
#               Security Concerns:
#               - Bypasses some GUI-level security restrictions
#               - Could be used to run commands that GUI login wouldn't allow
#               - Rarely needed by typical users
#               - Often disabled in enterprise environments
#
# Default:      false (console access allowed)
# Options:      true = Disable console login (block >console username)
#               false = Allow console login (type >console to use)
# Set to:       true (disable for security; rarely needed by typical users)
# UI Location:  Not available in System Settings; command line or MDM only
# Source:       https://developer.apple.com/documentation/devicemanagement/loginwindow
# Security:     Recommended to disable unless you specifically need console
#               access for troubleshooting. Most users never need this.
run_defaults "com.apple.loginwindow" "DisableConsoleAccess" "-bool" "true"

# ==============================================================================
# External/Network Accounts
# ==============================================================================

# --- Directory Service Account Access ---
# Key:          EnableExternalAccounts
# Domain:       com.apple.loginwindow
# Description:  Controls whether network/directory service accounts can log in
#               at the login window. When disabled, only local Mac accounts are
#               allowed to log in—external accounts from LDAP, Active Directory,
#               Open Directory, or other directory services are blocked.
#
#               External Account Types Affected:
#               - Active Directory (AD) domain accounts
#               - LDAP directory users
#               - Open Directory accounts
#               - Other directory service accounts
#
#               Use Cases for Disabling:
#               - Home users (no need for directory accounts)
#               - Macs that should only allow local accounts
#               - Security hardening (reduces attack surface)
#
#               Use Cases for Enabling:
#               - Enterprise environments with AD/LDAP
#               - Shared lab computers with network authentication
#               - Multi-user environments with centralized identity
#
# Default:      true (external accounts allowed)
# Options:      true = Allow network/directory accounts at login
#               false = Only local accounts can log in
# Set to:       false (most home users don't need external accounts;
#               enable if you use Active Directory or LDAP)
# UI Location:  System Settings > Users & Groups > Login Options >
#               Network Account server (if configured)
# Source:       https://developer.apple.com/documentation/devicemanagement/loginwindow
# See also:     https://support.apple.com/guide/deployment/dep1f35dd9a/web
# Security:     Disabling reduces attack surface by preventing potential
#               directory service-based attacks. Only enable if you actually
#               use network account authentication.
run_defaults "com.apple.loginwindow" "EnableExternalAccounts" "-bool" "false"

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
