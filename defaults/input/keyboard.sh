#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Keyboard Configuration
#
# DESCRIPTION:
#   This script configures keyboard settings, including key repeat rate,
#   initial delay, and full keyboard access. These settings optimize typing
#   and navigation for power users.
#
# REQUIRES:
#   - macOS 10.5 (Leopard) or later
#
# REFERENCES:
#   - Apple Support: Change Keyboard preferences on Mac
#     https://support.apple.com/guide/mac-help/change-keyboard-preferences-mchlp1054/mac
#   - Apple Support: Use your keyboard like a mouse on Mac
#     https://support.apple.com/guide/mac-help/use-your-keyboard-like-a-mouse-mh27469/mac
#   - Mathias Bynens' dotfiles (inspiration)
#     https://github.com/mathiasbynens/dotfiles/blob/main/.macos
#
# DOMAIN:
#   NSGlobalDomain - System-wide keyboard settings
#
# KEY REPEAT NOTES:
#   - KeyRepeat: The interval between repeated characters (lower = faster)
#     Values: 1 (fastest, ~15ms), 2 (fast, ~30ms), 6 (normal), 10+ (slow)
#   - InitialKeyRepeat: Delay before repeat starts (lower = shorter delay)
#     Values: 10 (shortest, ~150ms), 15 (short, ~225ms), 25 (normal)
#
# NOTES:
#   - A restart is required for key repeat changes to take full effect
#   - Full keyboard access enables tabbing through all UI controls
#   - These settings apply to all keyboards (built-in and external)
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
# This version always writes to NSGlobalDomain since these are global settings.
run_defaults() {
  local key="$1"
  local type="$2"
  local value="$3"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Keyboard preference: '$key' to '$value'"
  else
    # These settings are global, so we use the NSGlobalDomain.
    defaults write NSGlobalDomain "$key" "$type" "$value"
  fi
}

msg_info "Configuring Keyboard settings..."

# ==============================================================================
# Key Repeat Settings
# ==============================================================================

# --- Key Repeat Rate ---
# Key:          KeyRepeat
# Description:  Controls the speed at which a character repeats when a key
#               is held down. Lower values mean faster repeating.
# Default:      6 (corresponds to approximately 90ms between repeats)
# Possible:     Integer value; lower is faster
#               1 = ~15ms (extremely fast)
#               2 = ~30ms (very fast)
#               6 = ~90ms (default)
#               10+ = slow
# Set to:       1 (fastest possible without hacking system values)
# Reference:    System Preferences > Keyboard > Key Repeat slider
# Use case:     Fast key repeat is essential for vim users and when
#               holding arrow keys for navigation
run_defaults "KeyRepeat" "-int" "1"

# --- Delay Until Repeat ---
# Key:          InitialKeyRepeat
# Description:  Controls the delay (in frames, ~15ms each) before key repeat
#               begins when a key is held down.
# Default:      25 (approximately 375ms)
# Possible:     Integer value; lower is shorter delay
#               10 = ~150ms (very short)
#               15 = ~225ms (short)
#               25 = ~375ms (default)
#               35+ = long
# Set to:       10 (very short delay for responsive key repeat)
# Reference:    System Preferences > Keyboard > Delay Until Repeat slider
# Use case:     Shorter delay means faster response when navigating
#               or deleting text by holding keys
run_defaults "InitialKeyRepeat" "-int" "10"


# ==============================================================================
# Keyboard Navigation Settings
# ==============================================================================

# --- Full Keyboard Access ---
# Key:          AppleKeyboardUIMode
# Description:  Controls which UI elements can be accessed via the Tab key.
#               When set to full access, you can Tab through all controls
#               in dialogs (buttons, dropdowns, etc.), not just text fields.
# Default:      0 or 1 (varies by macOS version; text fields only)
# Possible:     0 = Text boxes and lists only
#               2 = All controls (full keyboard access)
#               3 = All controls (same as 2, alternate value)
# Set to:       2 (full keyboard access for power users)
# Reference:    System Preferences > Keyboard > Shortcuts > Use keyboard navigation
# Use case:     Essential for keyboard-driven workflows; allows navigating
#               and activating buttons in dialogs without using the mouse
# Tip:          In dialogs, use Tab to move between controls and Space
#               to activate buttons
run_defaults "AppleKeyboardUIMode" "-int" "2"


msg_success "Keyboard settings applied. Note: A restart is required for these changes to take full effect."
