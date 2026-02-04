#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Menu Bar Settings
#
# DESCRIPTION:
#   Configures menu bar appearance, clock format, battery display, and
#   which system icons appear in the menu bar.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require logout to take effect
#
# REFERENCES:
#   - Apple Support: Use the menu bar on Mac
#     https://support.apple.com/guide/mac-help/use-the-menu-bar-mchlp1446/mac
#   - Apple Support: Change Date & Time preferences
#     https://support.apple.com/guide/mac-help/change-date-time-preferences-mchlp2996/mac
#   - ICU Date Format Patterns
#     https://unicode-org.github.io/icu/userguide/format_parse/datetime/
#
# DOMAIN:
#   com.apple.menuextra.clock
#   com.apple.menuextra.battery
#   com.apple.controlcenter
#   NSGlobalDomain
#
# NOTES:
#   - Menu bar items are configured through Control Center in modern macOS
#   - Some legacy MenuExtras paths may not work on newer macOS versions
#
# ==============================================================================

# ==============================================================================
# Menu Bar Architecture
# ==============================================================================

# The menu bar is managed by multiple processes:
#
#   - SystemUIServer: Core menu bar management, menu extras
#   - ControlCenter: Control Center modules (Big Sur+)
#   - Finder: Apple menu and some menu items
#   - WindowServer: Visual rendering
#
# MENU BAR LAYOUT:
#
#   ┌────────────────────────────────────────────────────────────────────────┐
#   │ │Apple│File│Edit│View│...│            │🔋│📶│🔊│⊞│🔍│⏰│
#   │ │Menu │                   │   Spacer   │Menu Extras    │Clock│
#   └────────────────────────────────────────────────────────────────────────┘
#
# MENU EXTRAS (Icons on the right):
#   - macOS manages built-in extras (battery, WiFi, Bluetooth, etc.)
#   - Third-party apps add their own (Bartender, 1Password, etc.)
#   - ⌘-drag to reorder menu extras
#   - ⌘-drag off the menu bar to remove (some items)
#
# NOTCH CONSIDERATIONS (MacBook Pro 14"/16"):
#   - Menu bar items may be hidden behind the notch
#   - macOS automatically hides overflow items
#   - Third-party apps like Bartender can help manage notch overflow
#
# CLOCK CUSTOMIZATION:
#   The menu bar clock uses ICU (International Components for Unicode)
#   format patterns. Common pattern elements:
#
#   PATTERN │ EXAMPLE    │ DESCRIPTION
#   ────────┼────────────┼─────────────────────────
#   E       │ Mon        │ Abbreviated weekday
#   EE      │ Mon        │ Same as E
#   EEEE    │ Monday     │ Full weekday name
#   d       │ 5          │ Day of month
#   dd      │ 05         │ Day with leading zero
#   M       │ 1          │ Month number
#   MM      │ 01         │ Month with leading zero
#   MMM     │ Jan        │ Abbreviated month name
#   MMMM    │ January    │ Full month name
#   y       │ 2024       │ Year
#   yy      │ 24         │ Two-digit year
#   h       │ 1          │ Hour (12-hour)
#   hh      │ 01         │ Hour 12h with zero
#   H       │ 13         │ Hour (24-hour)
#   HH      │ 13         │ Hour 24h with zero
#   m       │ 5          │ Minute
#   mm      │ 05         │ Minute with zero
#   s       │ 9          │ Second
#   ss      │ 09         │ Second with zero
#   a       │ PM         │ AM/PM marker
#
# EXAMPLE DATE FORMATS:
#   "EEE MMM d  h:mm a"     → Mon Jan 5  1:23 PM
#   "EEE d MMM  HH:mm:ss"   → Mon 5 Jan  13:23:45
#   "EEEE, MMMM d, yyyy"    → Monday, January 5, 2024
#   "HH:mm"                 → 13:23 (minimal 24h)
#
# Source:       https://unicode-org.github.io/icu/userguide/format_parse/datetime/

msg_info "Configuring menu bar settings..."

# ==============================================================================
# Clock Settings
# ==============================================================================

# --- Show Date in Menu Bar ---
# Key:          ShowDate
# Domain:       com.apple.menuextra.clock
# Description:  Controls whether the date is shown alongside the time.
# Default:      1 (when space allows)
# Options:      0 = Never show date
#               1 = When space allows
#               2 = Always show date
# Set to:       1 (show when space allows)
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "ShowDate" "-int" "1"

# --- Show Day of Week ---
# Key:          ShowDayOfWeek
# Domain:       com.apple.menuextra.clock
# Description:  Controls whether the day of the week is shown (e.g., "Mon").
# Default:      true
# Options:      true = Show day of week, false = Hide day of week
# Set to:       true (show day of week)
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "ShowDayOfWeek" "-bool" "true"

# --- Use 24-Hour Time ---
# Key:          DateFormat
# Domain:       com.apple.menuextra.clock
# Description:  Sets the clock format. The format string uses ICU patterns.
# Default:      Varies by locale
# Options:      Custom ICU date format string
# Examples:     "EEE MMM d  h:mm a" = Mon Jan 1  1:23 PM
#               "EEE MMM d  HH:mm" = Mon Jan 1  13:23
#               "EEE d MMM  HH:mm:ss" = Mon 1 Jan  13:23:45
# Set to:       24-hour format with seconds
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "DateFormat" "-string" "EEE d MMM  HH:mm:ss"

# --- Show AM/PM ---
# Key:          ShowAMPM
# Domain:       com.apple.menuextra.clock
# Description:  Show or hide AM/PM indicator (only relevant for 12-hour time).
# Default:      true
# Options:      true = Show AM/PM, false = Hide AM/PM
# Set to:       false (using 24-hour format)
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "ShowAMPM" "-bool" "false"

# --- Show Seconds ---
# Key:          ShowSeconds
# Domain:       com.apple.menuextra.clock
# Description:  Display seconds in the menu bar clock.
# Default:      false
# Options:      true = Show seconds, false = Hide seconds
# Set to:       true (show seconds for precision)
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "ShowSeconds" "-bool" "true"

# --- Flash Time Separators ---
# Key:          FlashDateSeparators
# Domain:       com.apple.menuextra.clock
# Description:  Make the time separators (colons) flash each second.
# Default:      false
# Options:      true = Flash separators, false = Static separators
# Set to:       false (no flashing for less distraction)
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "FlashDateSeparators" "-bool" "false"

# --- Analog vs Digital Clock ---
# Key:          IsAnalog
# Domain:       com.apple.menuextra.clock
# Description:  Use analog clock face instead of digital time.
# Default:      false (digital)
# Options:      true = Analog clock, false = Digital clock
# Set to:       false (use digital clock)
# UI Location:  System Settings > Control Center > Clock Options
run_defaults "com.apple.menuextra.clock" "IsAnalog" "-bool" "false"

# ==============================================================================
# Battery Settings
# ==============================================================================

# --- Show Battery Percentage ---
# Key:          ShowPercent
# Domain:       com.apple.menuextra.battery
# Description:  Display battery percentage next to the battery icon.
# Default:      false
# Options:      true = Show percentage, false = Hide percentage
# Set to:       true (always show battery percentage)
# UI Location:  System Settings > Control Center > Battery > Show Percentage
run_defaults "com.apple.menuextra.battery" "ShowPercent" "-bool" "true"

# --- Show Battery in Menu Bar ---
# Key:          Battery
# Domain:       com.apple.controlcenter
# Description:  Controls battery icon visibility in menu bar.
# Default:      Shown in menu bar on laptops
# Options:      See control center options below
# Note:         Battery is typically always shown on laptops
# UI Location:  System Settings > Control Center > Battery
# This is handled by Control Center settings (see control_center.sh)

# ==============================================================================
# Menu Bar Appearance
# ==============================================================================

# --- Automatically Hide Menu Bar ---
# Key:          _HIHideMenuBar
# Domain:       NSGlobalDomain
# Description:  Automatically hide the menu bar until you move the mouse
#               to the top of the screen.
# Default:      false (always visible)
# Options:      true = Auto-hide menu bar
#               false = Always show menu bar
# Set to:       false (keep menu bar visible)
# UI Location:  System Settings > Desktop & Dock > Automatically hide menu bar
run_defaults "NSGlobalDomain" "_HIHideMenuBar" "-bool" "false"

# --- Menu Bar Spacing ---
# Key:          NSStatusItemSpacing
# Domain:       NSGlobalDomain
# Description:  Controls spacing between menu bar items (in points).
#               Requires Monterey or later. Lower values = tighter spacing.
# Default:      Platform dependent
# Options:      Integer value (e.g., 6, 8, 12)
# Set to:       Commented out (use system default)
# Note:         Smaller values fit more icons but may look crowded
# run_defaults "NSGlobalDomain" "NSStatusItemSpacing" "-int" "8"

# --- Menu Bar Item Padding ---
# Key:          NSStatusItemSelectionPadding
# Domain:       NSGlobalDomain
# Description:  Controls padding around menu bar items when selected.
# Default:      Platform dependent
# Options:      Integer value
# Set to:       Commented out (use system default)
# run_defaults "NSGlobalDomain" "NSStatusItemSelectionPadding" "-int" "6"

# ==============================================================================
# Menu Bar Transparency
# ==============================================================================

# --- Reduce Menu Bar Transparency ---
# Key:          AppleReduceDesktopTinting
# Domain:       NSGlobalDomain
# Description:  Reduces the transparency and vibrancy of the menu bar.
#               Also affects sidebars and other translucent UI elements.
# Default:      false
# Options:      true = Reduce transparency (more solid)
#               false = Normal transparency
# Set to:       false (keep normal appearance)
# UI Location:  System Settings > Accessibility > Display > Reduce transparency
# Note:         This is primarily an accessibility setting
run_defaults "NSGlobalDomain" "AppleReduceDesktopTinting" "-bool" "false"

msg_success "Menu bar settings configured."

# ==============================================================================
# Restart Menu Bar
#
# Some menu bar changes require restarting the menu bar process:
#   killall SystemUIServer
#
# Or log out and back in for all changes to take effect.
#
# ==============================================================================
