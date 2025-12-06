#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Terminal.app Configuration
#
# DESCRIPTION:
#   This script configures Apple's built-in Terminal.app with sensible defaults
#   for security and usability. Terminal.app is the default terminal emulator
#   included with macOS and is suitable for most users who don't need advanced
#   features provided by iTerm2 or other third-party terminals.
#
# REQUIRES:
#   - macOS 10.10 (Yosemite) or later
#   - Terminal.app (pre-installed with macOS)
#
# REFERENCES:
#   - Apple Support: Use Terminal on Mac
#     https://support.apple.com/guide/terminal/welcome/mac
#   - Apple Support: Terminal profiles
#     https://support.apple.com/guide/terminal/profiles-trmlprofiles/mac
#   - Apple Support: Terminal window and tab settings
#     https://support.apple.com/guide/terminal/change-terminal-window-settings-trml107/mac
#   - man defaults (macOS man page)
#
# DOMAIN:
#   com.apple.Terminal
#
# NOTES:
#   - Terminal.app stores preferences in ~/Library/Preferences/com.apple.Terminal.plist
#   - Profile settings can be exported/imported via Terminal > Settings > Profiles
#   - Changes take effect on new Terminal windows (restart recommended)
#   - For advanced users, consider iTerm2 (see defaults/applications/iterm2.sh)
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Terminal preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Terminal.app settings..."

# ==============================================================================
# Security Settings
# ==============================================================================

# --- Secure Keyboard Entry ---
# Key:          SecureKeyboardEntry
# Domain:       com.apple.Terminal
# Description:  Enables Secure Keyboard Entry mode, which prevents other
#               applications on your Mac (including potential keyloggers or
#               malware) from intercepting keystrokes typed in Terminal. When
#               enabled, only Terminal receives your keyboard input. This is
#               essential security for entering passwords, API keys, or other
#               sensitive information in the terminal.
# Default:      false (disabled)
# Options:      true  = Enable secure keyboard entry (blocks keystroke capture)
#               false = Disable secure keyboard entry (other apps can see input)
# Set to:       true (enhanced security against keylogging)
# UI Location:  Terminal > Secure Keyboard Entry (menu bar)
# Source:       https://support.apple.com/guide/terminal/use-secure-keyboard-entry-trmlkeyboard/mac
# Security:     ⚠️ STRONGLY RECOMMENDED - Protects against keyloggers and
#               malicious software that attempts to capture passwords, SSH keys,
#               or other sensitive terminal input. Minimal performance impact.
# Note:         When enabled, a checkmark appears next to "Secure Keyboard Entry"
#               in the Terminal menu. This setting persists across sessions.
run_defaults "com.apple.Terminal" "SecureKeyboardEntry" "-bool" "true"

# ==============================================================================
# Window and Tab Behavior Settings
# ==============================================================================

# --- Focus Follows Mouse ---
# Key:          FocusFollowsMouse
# Domain:       com.apple.Terminal
# Description:  Controls whether Terminal windows automatically receive focus
#               (become active) when the mouse cursor hovers over them, without
#               requiring a click. This is a Unix-style window management behavior
#               familiar to X11 users. When disabled, you must click a window to
#               give it focus.
# Default:      false (click required to focus window)
# Options:      true  = Window under cursor receives focus automatically
#               false = Click required to focus window (standard macOS behavior)
# Set to:       false (maintain standard macOS behavior)
# UI Location:  Not exposed in UI (defaults only)
# Source:       https://macos-defaults.com/terminal/focusfollowsmouse.html
# See also:     https://support.apple.com/guide/terminal/change-terminal-window-settings-trml107/mac
# Note:         This is a power-user setting. Most users prefer standard macOS
#               click-to-focus behavior. If enabled, be aware that windows can
#               change focus unexpectedly as you move the mouse.
run_defaults "com.apple.Terminal" "FocusFollowsMouse" "-bool" "false"

# --- New Window Working Directory Behavior ---
# Key:          NewWindowWorkingDirectoryBehavior
# Domain:       com.apple.Terminal
# Description:  Determines which directory is used as the working directory
#               when opening a new Terminal window. This affects where the shell
#               starts and is useful for maintaining context when opening
#               multiple windows.
# Default:      1 (home directory)
# Options:      1 = Home directory (~)
#               2 = Same directory as current (frontmost) Terminal window
#               3 = Custom directory (configured separately)
# Set to:       1 (home directory - predictable starting point)
# UI Location:  Terminal > Settings > General > New windows open with
# Source:       https://support.apple.com/guide/terminal/change-terminal-startup-settings-trml107/mac
# Note:         Option 2 is convenient for developers who frequently open
#               windows in project directories. Consider changing based on
#               your workflow preferences.
run_defaults "com.apple.Terminal" "NewWindowWorkingDirectoryBehavior" "-int" "1"

# --- New Tab Working Directory Behavior ---
# Key:          NewTabWorkingDirectoryBehavior
# Domain:       com.apple.Terminal
# Description:  Determines which directory is used as the working directory
#               when opening a new tab within an existing Terminal window.
#               Setting this to match the current tab's directory maintains
#               context when splitting work across tabs.
# Default:      1 (home directory)
# Options:      1 = Home directory (~)
#               2 = Same directory as current (selected) tab
#               3 = Custom directory (configured separately)
# Set to:       2 (same as current tab - maintains context when tabbing)
# UI Location:  Terminal > Settings > General > New tabs open with
# Source:       https://support.apple.com/guide/terminal/change-terminal-startup-settings-trml107/mac
# Tip:          Using option 2 is recommended for developers as it allows
#               quickly opening additional tabs in your current project.
run_defaults "com.apple.Terminal" "NewTabWorkingDirectoryBehavior" "-int" "2"

# ==============================================================================
# Appearance Settings
# ==============================================================================

# --- Window Resize Animation Speed ---
# Key:          NSWindowResizeTime
# Domain:       com.apple.Terminal
# Description:  Controls the duration of the window resize animation in seconds.
#               Setting a shorter time makes Terminal feel more responsive,
#               especially when frequently resizing windows or using split
#               views. This only affects Terminal.app's resize animation.
# Default:      0.20 (200 milliseconds)
# Options:      0.001-1.0 (in seconds; lower = faster, higher = slower)
#               0.001 = Near-instantaneous resizing
#               0.20  = Default smooth animation
#               0.50+ = Slow, deliberate animation
# Set to:       0.001 (near-instantaneous for snappy feel)
# UI Location:  Not exposed in UI (defaults only)
# Source:       https://macos-defaults.com/misc/nswindowresizetime.html
# Note:         This is a subtle change that improves perceived responsiveness.
#               If you prefer visual smoothness, keep the default (0.20).
run_defaults "com.apple.Terminal" "NSWindowResizeTime" "-float" "0.001"

# --- Mark Displayed Text ---
# Key:          ShowLineMarks
# Domain:       com.apple.Terminal
# Description:  Controls whether Terminal displays line marks that indicate
#               where each command prompt appears in the scrollback. These
#               marks appear in the scrollbar and can be clicked to jump to
#               that command. Useful for navigating long sessions.
# Default:      true (show line marks)
# Options:      true  = Display line marks in scrollbar
#               false = Hide line marks
# Set to:       true (helpful for navigation in long sessions)
# UI Location:  Terminal > Settings > Profiles > [Profile] > Window > Line marks
# Source:       https://support.apple.com/guide/terminal/use-marks-trml85m/mac
# See also:     View > Show Marks / Hide Marks (temporary toggle)
run_defaults "com.apple.Terminal" "ShowLineMarks" "-bool" "true"

# ==============================================================================
# Shell Settings
# ==============================================================================

# --- Close Window When Shell Exits ---
# Key:          ShellExitAction
# Domain:       com.apple.Terminal
# Description:  Controls what happens to the Terminal window or tab when the
#               shell process exits. Options include closing the window, keeping
#               it open, or closing only on clean exit. Keeping windows open can
#               help debug failed commands.
# Default:      1 (close if shell exits cleanly)
# Options:      0 = Close window when shell exits (regardless of exit status)
#               1 = Close only if shell exited cleanly (exit status 0)
#               2 = Don't close the window (keep window open after shell exits)
# Set to:       1 (close on clean exit - alerts to errors while cleaning up)
# UI Location:  Terminal > Settings > Profiles > [Profile] > Shell > When the
#               shell exits
# Source:       https://support.apple.com/guide/terminal/set-shell-in-terminal-trmlshell/mac
# Tip:          Option 2 is useful when debugging scripts - failed commands
#               keep the window open so you can review output and exit codes.
run_defaults "com.apple.Terminal" "ShellExitAction" "-int" "1"


msg_success "Terminal.app settings applied."
msg_info "You may need to restart Terminal.app for all settings to take effect."
