#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Date & Time
#
# DESCRIPTION:
#   Configures date, time, and timezone settings including NTP servers,
#   automatic timezone detection, and clock display options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require admin privileges
#
# REFERENCES:
#   - Apple Support: Set the date and time on your Mac
#     https://support.apple.com/guide/mac-help/mchlp2996/mac
#
# DOMAIN:
#   com.apple.menuextra.clock
#   com.apple.timed
#
# NOTES:
#   - NTP settings are typically managed via systemsetup
#   - Clock format is configured with DateFormat key
#
# ==============================================================================

msg_info "Configuring date and time settings..."

# ==============================================================================
# Clock Display (Menu Bar)
# ==============================================================================

# --- Clock Format ---
# Key:          DateFormat
# Domain:       com.apple.menuextra.clock
# Description:  Controls the format of the clock displayed in the macOS menu bar.
#               Uses Unicode Technical Standard #35 (UTS #35) date format patterns,
#               which is the same standard used by iOS, Android, and many other
#               platforms. The format string determines exactly what time/date
#               components appear and in what order.
#
# Default:      "EEE MMM d  h:mm a" (e.g., "Thu Jan 2  9:30 AM")
#
# Format Pattern Reference (UTS #35):
#   Year:     yyyy = 2025, yy = 25
#   Month:    MMMM = January, MMM = Jan, MM = 01, M = 1
#   Day:      dd = 02, d = 2
#   Weekday:  EEEE = Thursday, EEE = Thu, EEEEEE = Th
#   Hour:     HH = 09 (24h), H = 9 (24h), hh = 09 (12h), h = 9 (12h)
#   Minute:   mm = 05, m = 5
#   Second:   ss = 09, s = 9
#   AM/PM:    a = AM/PM
#   Timezone: z = PST, zzzz = Pacific Standard Time, Z = -0800
#
# Examples:
#   "EEE MMM d  h:mm a"       → Thu Jan 2  9:30 AM (Apple default)
#   "EEE d MMM  HH:mm"        → Thu 2 Jan  09:30 (European 24h)
#   "h:mm a"                  → 9:30 AM (time only, minimal)
#   "EEEE, MMMM d, yyyy"      → Thursday, January 2, 2025 (full date)
#   "yyyy-MM-dd HH:mm:ss"     → 2025-01-02 09:30:45 (ISO 8601)
#   "EEE d MMM  HH:mm:ss"     → Thu 2 Jan  09:30:45 (with seconds)
#
# Set to:       European-style 24-hour format with abbreviated weekday and month
# UI Location:  System Settings > Control Center > Clock > Clock Options
# Source:       https://support.apple.com/guide/mac-help/mchlp2996/mac
# See also:     Unicode Date Format Patterns: https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table
# Note:         Changes take effect immediately; no restart required.
#               Double-click the clock in System Settings to see format preview.
run_defaults "com.apple.menuextra.clock" "DateFormat" "-string" "EEE d MMM  HH:mm"

# --- Use 24-Hour Time ---
# Key:          Show24Hour
# Domain:       com.apple.menuextra.clock
# Description:  Toggles between 24-hour (military) time and 12-hour time with
#               AM/PM indicator. This setting affects the menu bar clock and
#               may influence time display in other system applications that
#               respect this preference.
# Default:      false (12-hour with AM/PM, typical for US locale)
# Options:      true = Use 24-hour format (00:00-23:59)
#               false = Use 12-hour format with AM/PM (12:00 AM - 11:59 PM)
# Set to:       true (24-hour format; unambiguous, widely used in technical
#               contexts, aviation, military, healthcare, and most of the world)
# UI Location:  System Settings > General > Date & Time > 24-hour time
#               Also: System Settings > Control Center > Clock > Clock Options
# Source:       https://support.apple.com/guide/mac-help/mchlp2996/mac
# See also:     https://en.wikipedia.org/wiki/24-hour_clock
run_defaults "com.apple.menuextra.clock" "Show24Hour" "-bool" "true"

# --- Show Seconds in Clock ---
# Key:          ShowSeconds
# Domain:       com.apple.menuextra.clock
# Description:  Adds seconds to the menu bar clock display (e.g., "9:30:45" instead
#               of "9:30"). Useful for time-sensitive work like debugging, trading,
#               or synchronization tasks. Increases menu bar width slightly.
# Default:      false (seconds hidden for cleaner appearance)
# Options:      true = Display seconds (updates every second)
#               false = Hide seconds (updates every minute)
# Set to:       false (cleaner menu bar; enable if you need precise timing)
# UI Location:  System Settings > Control Center > Clock > Clock Options >
#               Display the time with seconds
# Source:       https://support.apple.com/guide/mac-help/mchlp2996/mac
# Note:         Showing seconds causes the clock to update more frequently,
#               which has negligible performance impact on modern Macs.
run_defaults "com.apple.menuextra.clock" "ShowSeconds" "-bool" "false"

# --- Flash Time Separators ---
# Key:          FlashDateSeparators
# Domain:       com.apple.menuextra.clock
# Description:  When enabled, the colon (:) separators between hours, minutes,
#               and seconds flash on and off every second, mimicking the behavior
#               of classic digital clocks. This is a purely cosmetic preference.
# Default:      false (static display)
# Options:      true = Colon flashes every second (retro digital clock style)
#               false = Static colons (modern, clean appearance)
# Set to:       false (static display; flashing can be distracting)
# UI Location:  System Settings > Control Center > Clock > Clock Options >
#               Flash the time separators
# Source:       https://support.apple.com/guide/mac-help/mchlp2996/mac
run_defaults "com.apple.menuextra.clock" "FlashDateSeparators" "-bool" "false"

# --- Analog vs Digital Clock ---
# Key:          IsAnalog
# Domain:       com.apple.menuextra.clock
# Description:  Switches the menu bar clock between a traditional analog clock
#               face (round with hands) and a digital numeric display. The analog
#               clock is compact but less precise for quick time checks.
# Default:      false (digital display)
# Options:      true = Analog clock face (traditional clock with hands)
#               false = Digital display (numeric time)
# Set to:       false (digital; easier to read at a glance)
# UI Location:  System Settings > Control Center > Clock > Clock Options > Style
# Source:       https://support.apple.com/guide/mac-help/mchlp2996/mac
# Note:         Analog mode ignores DateFormat, Show24Hour, and ShowSeconds settings.
run_defaults "com.apple.menuextra.clock" "IsAnalog" "-bool" "false"

# ==============================================================================
# Time Zone & NTP (Network Time Protocol)
# ==============================================================================

# --- Automatic Time Zone ---
# Key:          N/A (managed via systemsetup, not defaults)
# Description:  macOS can automatically determine your time zone based on your
#               current location using Wi-Fi positioning and IP geolocation.
#               This requires Location Services to be enabled for System Services.
# Default:      Enabled (Set time zone automatically using current location)
# UI Location:  System Settings > General > Date & Time > Set time zone automatically
# Source:       https://support.apple.com/guide/mac-help/mchlp2996/mac
# Commands:
#   sudo systemsetup -getusingnetworktime              # Check if NTP is enabled
#   sudo systemsetup -setusingnetworktime on           # Enable network time
#   sudo systemsetup -setusingnetworktime off          # Disable network time
#   sudo systemsetup -gettimezone                       # Get current timezone
#   sudo systemsetup -settimezone "America/Denver"     # Set timezone manually
#   sudo systemsetup -listtimezones                    # List all available zones
# Security:     Accurate time is critical for TLS certificate validation, Kerberos
#               authentication, log correlation, and file timestamp accuracy.
#               Attackers can exploit time skew to use expired certificates.
# See also:     https://en.wikipedia.org/wiki/Network_Time_Protocol
#               man systemsetup

msg_info "Timezone: Use 'sudo systemsetup -settimezone <zone>'"
msg_info "NTP: Use 'sudo systemsetup -setusingnetworktime on'"

msg_success "Date and time settings configured."
