#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Energy & Power Management
#
# DESCRIPTION:
#   Configures power management settings for both battery and AC power.
#   These settings control sleep behavior, display timeout, and other
#   power-related preferences to optimize battery life or performance.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Administrator privileges for pmset commands
#   - Some settings only apply to portable Macs (MacBooks)
#
# REFERENCES:
#   - Apple Support: Use power nap on your Mac
#     https://support.apple.com/en-us/HT204032
#   - man pmset (Power Management Settings)
#   - pmset -g to view current settings
#   - pmset -g cap to view capabilities
#
# DOMAIN:
#   pmset (Power Management)
#   com.apple.PowerManagement
#
# NOTES:
#   - Settings are separate for battery (-b) and AC power (-c)
#   - Use -a to apply to all power sources
#   - Some settings require Full Disk Access for the terminal
#
# ==============================================================================

msg_info "Configuring energy and power management settings..."

# ==============================================================================
# Display Sleep
# ==============================================================================

# --- Display Sleep Timeout (Battery) ---
# Command:      pmset -b displaysleep
# Description:  Time in minutes before the display sleeps when on battery.
#               Shorter times save battery life.
# Default:      2 minutes
# Set to:       5 minutes (balance between usability and battery)
sudo pmset -b displaysleep 5

# --- Display Sleep Timeout (AC Power) ---
# Command:      pmset -c displaysleep
# Description:  Time in minutes before the display sleeps when on AC power.
# Default:      10 minutes
# Set to:       15 minutes (comfortable for desk work)
sudo pmset -c displaysleep 15

# ==============================================================================
# System Sleep
# ==============================================================================

# --- System Sleep Timeout (Battery) ---
# Command:      pmset -b sleep
# Description:  Time in minutes before the system sleeps when on battery.
#               Set to 0 to disable sleep (not recommended for battery).
# Default:      10 minutes
# Set to:       10 minutes (preserve battery when idle)
sudo pmset -b sleep 10

# --- System Sleep Timeout (AC Power) ---
# Command:      pmset -c sleep
# Description:  Time in minutes before the system sleeps when on AC power.
#               Set to 0 to disable sleep entirely.
# Default:      0 (never sleep on AC)
# Set to:       0 (stay awake when plugged in)
sudo pmset -c sleep 0

# ==============================================================================
# Hard Disk Sleep
# ==============================================================================

# --- Hard Disk Sleep (All Power Sources) ---
# Command:      pmset -a disksleep
# Description:  Time in minutes before hard disks spin down.
#               Set to 0 to disable disk sleep.
#               Note: SSDs don't spin down but this affects external HDDs.
# Default:      10 minutes
# Set to:       10 minutes
sudo pmset -a disksleep 10

# ==============================================================================
# Wake Features
# ==============================================================================

# --- Wake on Network Access (AC Power) ---
# Command:      pmset -c womp
# Description:  Wake the computer when a network admin packet is received
#               (Wake-on-LAN). Useful for remote access.
# Default:      1 (enabled on AC)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       1 (enable for remote access when on AC)
sudo pmset -c womp 1

# --- Wake on Network Access (Battery) ---
# Command:      pmset -b womp
# Description:  Wake on LAN is typically disabled on battery to save power.
# Default:      0 (disabled on battery)
# Set to:       0 (keep disabled to save battery)
sudo pmset -b womp 0

# ==============================================================================
# Power Nap
# ==============================================================================

# --- Power Nap (Battery) ---
# Command:      pmset -b powernap
# Description:  Allow Mac to check email, calendar, and iCloud updates while
#               sleeping on battery. Uses some battery power.
# Default:      0 (disabled on battery)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       0 (save battery, disable Power Nap on battery)
# Source:       https://support.apple.com/en-us/HT204032
sudo pmset -b powernap 0

# --- Power Nap (AC Power) ---
# Command:      pmset -c powernap
# Description:  Allow Mac to perform background tasks while sleeping on AC.
# Default:      1 (enabled on AC)
# Set to:       1 (enable on AC for background sync)
sudo pmset -c powernap 1

# ==============================================================================
# Hibernation Mode
# ==============================================================================

# --- Hibernation Mode ---
# Command:      pmset -a hibernatemode
# Description:  Controls how the Mac saves state when sleeping.
# Default:      3 (portable Macs), 0 (desktops)
# Options:
#   0 = RAM powered during sleep (fast wake, no hibernate)
#   1 = Hibernate immediately (slow wake, saves power)
#   3 = Safe sleep - RAM powered + hibernate file (default for laptops)
#   25 = Hibernate after standby delay (deep sleep)
# Set to:       3 (safe sleep - best balance for laptops)
# Note:         Desktops should use 0
sudo pmset -a hibernatemode 3

# ==============================================================================
# Standby
# ==============================================================================

# --- Standby Enabled ---
# Command:      pmset -a standby
# Description:  After the standby delay, save RAM to disk and power down RAM.
#               Saves power during extended sleep.
# Default:      1 (enabled)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       1 (enable for power savings on long sleep)
sudo pmset -a standby 1

# --- Standby Delay (High Battery) ---
# Command:      pmset -a standbydelayhigh
# Description:  Seconds to wait before entering standby when battery > 50%.
# Default:      86400 (24 hours)
# Set to:       86400 (24 hours - only hibernate after very long sleep)
sudo pmset -a standbydelayhigh 86400

# --- Standby Delay (Low Battery) ---
# Command:      pmset -a standbydelaylow
# Description:  Seconds to wait before entering standby when battery < 50%.
# Default:      10800 (3 hours)
# Set to:       10800 (3 hours)
sudo pmset -a standbydelaylow 10800

# ==============================================================================
# Additional Power Settings
# ==============================================================================

# --- Automatic Graphics Switching ---
# Command:      pmset -a gpuswitch
# Description:  Automatically switch between integrated and discrete graphics
#               to save power. Only applies to Macs with multiple GPUs.
# Default:      2 (automatic switching)
# Options:      0 = Integrated only, 1 = Discrete only, 2 = Automatic
# Set to:       2 (automatic - best balance)
sudo pmset -a gpuswitch 2

# --- TCP Keep Alive ---
# Command:      pmset -a tcpkeepalive
# Description:  Keep TCP connections alive during sleep for push notifications.
# Default:      1 (enabled)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       1 (keep connections for notifications)
sudo pmset -a tcpkeepalive 1

msg_success "Energy and power management settings configured."

# ==============================================================================
# View Current Settings
#
# To see all current power settings:
#   pmset -g
#
# To see settings for specific power source:
#   pmset -g custom
#
# To see system capabilities:
#   pmset -g cap
#
# To see battery info:
#   pmset -g batt
#
# ==============================================================================
