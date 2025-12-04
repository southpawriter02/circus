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
# Domain:       NSGlobalDomain
# Description:  Controls the speed at which a character repeats when a key
#               is held down. This setting determines the interval between
#               repeated keystrokes. Lower values mean faster repeating,
#               which is essential for efficient text navigation and editing.
# Default:      6 (approximately 90ms between repeats)
# Options:      Integer value; lower is faster:
#               1  = ~15ms (extremely fast, ~67 chars/sec)
#               2  = ~30ms (very fast, ~33 chars/sec)
#               6  = ~90ms (Apple's default, ~11 chars/sec)
#               10 = ~150ms (slow)
# Set to:       1 (fastest for vim users and power typists)
# UI Location:  System Settings > Keyboard > Key repeat rate (slider)
# Source:       https://support.apple.com/guide/mac-help/change-keyboard-settings-mchlp1054/mac
# Note:         A restart may be required for changes to take effect. This
#               setting is essential for vim users who hold j/k for navigation.
run_defaults "KeyRepeat" "-int" "1"

# --- Delay Until Repeat ---
# Key:          InitialKeyRepeat
# Domain:       NSGlobalDomain
# Description:  Controls the delay (in frames, ~15ms each) before key repeat
#               begins when a key is held down. This is the "warm-up" period
#               before characters start repeating. Shorter delays make the
#               keyboard feel more responsive for navigation tasks.
# Default:      25 (approximately 375ms)
# Options:      Integer value; lower is shorter delay:
#               10 = ~150ms (very short, immediate response)
#               15 = ~225ms (short)
#               25 = ~375ms (Apple's default)
#               35 = ~525ms (long)
# Set to:       10 (very short delay for responsive key repeat)
# UI Location:  System Settings > Keyboard > Delay until repeat (slider)
# Source:       https://support.apple.com/guide/mac-help/change-keyboard-settings-mchlp1054/mac
# Note:         Shorter delay is useful when deleting text by holding
#               backspace or navigating with arrow keys.
run_defaults "InitialKeyRepeat" "-int" "10"


# ==============================================================================
# Keyboard Navigation Settings
# ==============================================================================

# --- Full Keyboard Access ---
# Key:          AppleKeyboardUIMode
# Domain:       NSGlobalDomain
# Description:  Controls which UI elements can be accessed via the Tab key.
#               When set to full access, you can Tab through all controls
#               in dialogs (buttons, dropdowns, checkboxes, etc.), not just
#               text fields. This enables a keyboard-driven workflow without
#               needing to reach for the mouse.
# Default:      0 or 1 (varies by macOS version; text fields only)
# Options:      0 = Text boxes and lists only (limited navigation)
#               2 = All controls (full keyboard access)
#               3 = All controls (same as 2, alternate value)
# Set to:       2 (full keyboard access for power users)
# UI Location:  System Settings > Keyboard > Keyboard navigation (toggle)
# Source:       https://support.apple.com/guide/mac-help/use-your-keyboard-like-a-mouse-mh27469/mac
# See also:     https://support.apple.com/guide/mac-help/use-keyboard-shortcuts-mchlp2262/mac
# Note:         In dialogs, use Tab to move between controls and Space to
#               activate buttons. Press Escape to cancel or Enter to confirm.
run_defaults "AppleKeyboardUIMode" "-int" "2"


msg_success "Keyboard settings applied. Note: A restart is required for these changes to take full effect."
