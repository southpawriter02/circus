#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/os/macos.sh
#
# DESCRIPTION:  macOS-specific implementations of cross-platform functions.
#               Provides consistent interface for macOS system operations.
#
# REQUIRES:
#   - macOS 12.0 or later
#   - lib/os/detect.sh must be sourced first
#
# ==============================================================================

# --- Guard: Only load on macOS ------------------------------------------------
if ! is_macos 2>/dev/null; then
    return 0
fi

# ==============================================================================
# SECTION: PACKAGE MANAGEMENT
# ==============================================================================

#
# @description Install a package using Homebrew
# @param $@ Package names to install
#
os_install_package() {
    if ! command -v brew &>/dev/null; then
        die "Homebrew is not installed. Visit https://brew.sh"
    fi
    brew install "$@"
}

#
# @description Update all installed packages
#
os_update_packages() {
    if ! command -v brew &>/dev/null; then
        die "Homebrew is not installed"
    fi
    brew update && brew upgrade
}

#
# @description Check if a package is installed
# @param $1 Package name
#
os_is_package_installed() {
    brew list --formula "$1" &>/dev/null || brew list --cask "$1" &>/dev/null
}

# ==============================================================================
# SECTION: CLIPBOARD OPERATIONS
# ==============================================================================

#
# @description Copy stdin to clipboard
#
os_clipboard_copy() {
    pbcopy
}

#
# @description Paste clipboard contents to stdout
#
os_clipboard_paste() {
    pbpaste
}

#
# @description Clear the clipboard
#
os_clipboard_clear() {
    pbcopy < /dev/null
}

# ==============================================================================
# SECTION: NETWORKING
# ==============================================================================

#
# @description Get the primary Wi-Fi interface name
#
os_get_wifi_interface() {
    networksetup -listallhardwareports | awk '/Wi-Fi|AirPort/{getline; print $2}' | head -1
}

#
# @description Turn Wi-Fi on
#
os_wifi_on() {
    local interface
    interface="$(os_get_wifi_interface)"
    networksetup -setairportpower "$interface" on
}

#
# @description Turn Wi-Fi off
#
os_wifi_off() {
    local interface
    interface="$(os_get_wifi_interface)"
    networksetup -setairportpower "$interface" off
}

#
# @description Get Wi-Fi power status
# @return "on" or "off"
#
os_wifi_status() {
    local interface
    interface="$(os_get_wifi_interface)"
    networksetup -getairportpower "$interface" | awk '{print tolower($NF)}'
}

#
# @description Get the active network service name
#
os_get_active_network_service() {
    networksetup -listnetworkserviceorder | grep -A1 "$(route -n get default 2>/dev/null | grep 'interface' | awk '{print $2}')" | head -2 | tail -1 | sed 's/.*: //' | sed 's/).*//'
}

#
# @description Set DNS servers
# @param $1 Network service name
# @param $@ DNS server addresses
#
os_set_dns() {
    local service="$1"
    shift
    sudo networksetup -setdnsservers "$service" "$@"
}

#
# @description Clear DNS servers (use DHCP)
# @param $1 Network service name
#
os_clear_dns() {
    sudo networksetup -setdnsservers "$1" "Empty"
}

#
# @description Get current DNS servers
# @param $1 Network service name
#
os_get_dns() {
    networksetup -getdnsservers "$1"
}

# ==============================================================================
# SECTION: SYSTEM OPERATIONS
# ==============================================================================

#
# @description Lock the screen
#
os_lock_screen() {
    osascript -e 'tell application "System Events" to keystroke "q" using {control down, command down}'
}

#
# @description Prevent system sleep
# @param $@ Options to pass to caffeinate
#
os_prevent_sleep() {
    caffeinate -d -i -m -u "$@"
}

#
# @description Kill caffeinate processes
#
os_allow_sleep() {
    pkill -x caffeinate 2>/dev/null || true
}

#
# @description Get current sleep assertion status
#
os_get_sleep_status() {
    if pgrep -x caffeinate &>/dev/null; then
        echo "prevented"
    else
        echo "normal"
    fi
}

# ==============================================================================
# SECTION: FIREWALL
# ==============================================================================

#
# @description Enable firewall
#
os_firewall_on() {
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
}

#
# @description Disable firewall
#
os_firewall_off() {
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off
}

#
# @description Get firewall status
#
os_firewall_status() {
    /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate
}

# ==============================================================================
# SECTION: BLUETOOTH
# ==============================================================================

#
# @description Turn Bluetooth on (requires blueutil)
#
os_bluetooth_on() {
    if ! command -v blueutil &>/dev/null; then
        die "blueutil is not installed. Run: brew install blueutil"
    fi
    blueutil --power 1
}

#
# @description Turn Bluetooth off
#
os_bluetooth_off() {
    if ! command -v blueutil &>/dev/null; then
        die "blueutil is not installed"
    fi
    blueutil --power 0
}

#
# @description Get Bluetooth status
#
os_bluetooth_status() {
    if ! command -v blueutil &>/dev/null; then
        die "blueutil is not installed"
    fi
    if [[ "$(blueutil --power)" == "1" ]]; then
        echo "on"
    else
        echo "off"
    fi
}

# Export all functions
export -f os_install_package os_update_packages os_is_package_installed
export -f os_clipboard_copy os_clipboard_paste os_clipboard_clear
export -f os_get_wifi_interface os_wifi_on os_wifi_off os_wifi_status
export -f os_get_active_network_service os_set_dns os_clear_dns os_get_dns
export -f os_lock_screen os_prevent_sleep os_allow_sleep os_get_sleep_status
export -f os_firewall_on os_firewall_off os_firewall_status
export -f os_bluetooth_on os_bluetooth_off os_bluetooth_status
