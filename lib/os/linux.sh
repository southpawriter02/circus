#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/os/linux.sh
#
# DESCRIPTION:  Linux-specific implementations of cross-platform functions.
#               Supports Debian/Ubuntu, Fedora/RHEL, and Arch-based distros.
#
# REQUIRES:
#   - Linux or WSL environment
#   - lib/os/detect.sh must be sourced first
#
# ==============================================================================

# --- Guard: Only load on Linux ------------------------------------------------
if ! is_linux 2>/dev/null; then
    return 0
fi

# ==============================================================================
# SECTION: PACKAGE MANAGEMENT
# ==============================================================================

#
# @description Install a package using the appropriate package manager
# @param $@ Package names to install
#
os_install_package() {
    if is_debian_based; then
        sudo apt-get update && sudo apt-get install -y "$@"
    elif is_rhel_based; then
        sudo dnf install -y "$@"
    elif is_arch_based; then
        sudo pacman -Sy --noconfirm "$@"
    else
        die "Unsupported distro for package installation: $(detect_distro)"
    fi
}

#
# @description Update all installed packages
#
os_update_packages() {
    if is_debian_based; then
        sudo apt-get update && sudo apt-get upgrade -y
    elif is_rhel_based; then
        sudo dnf upgrade -y
    elif is_arch_based; then
        sudo pacman -Syu --noconfirm
    else
        die "Unsupported distro for package update: $(detect_distro)"
    fi
}

#
# @description Check if a package is installed
# @param $1 Package name
#
os_is_package_installed() {
    if is_debian_based; then
        dpkg -l "$1" 2>/dev/null | grep -q "^ii"
    elif is_rhel_based; then
        rpm -q "$1" &>/dev/null
    elif is_arch_based; then
        pacman -Q "$1" &>/dev/null
    else
        command -v "$1" &>/dev/null
    fi
}

# ==============================================================================
# SECTION: CLIPBOARD OPERATIONS
# ==============================================================================

#
# @description Detect available clipboard tool
# @return Tool name or empty string
#
_detect_clipboard_tool() {
    if command -v xclip &>/dev/null; then
        echo "xclip"
    elif command -v xsel &>/dev/null; then
        echo "xsel"
    elif command -v wl-copy &>/dev/null; then
        echo "wl-clipboard"
    else
        echo ""
    fi
}

#
# @description Copy stdin to clipboard
#
os_clipboard_copy() {
    local tool
    tool="$(_detect_clipboard_tool)"
    
    case "$tool" in
        xclip)
            xclip -selection clipboard
            ;;
        xsel)
            xsel --clipboard --input
            ;;
        wl-clipboard)
            wl-copy
            ;;
        *)
            die "No clipboard tool found. Install one of: xclip, xsel, wl-clipboard"
            ;;
    esac
}

#
# @description Paste clipboard contents to stdout
#
os_clipboard_paste() {
    local tool
    tool="$(_detect_clipboard_tool)"
    
    case "$tool" in
        xclip)
            xclip -selection clipboard -o
            ;;
        xsel)
            xsel --clipboard --output
            ;;
        wl-clipboard)
            wl-paste
            ;;
        *)
            die "No clipboard tool found"
            ;;
    esac
}

#
# @description Clear the clipboard
#
os_clipboard_clear() {
    local tool
    tool="$(_detect_clipboard_tool)"
    
    case "$tool" in
        xclip)
            echo -n "" | xclip -selection clipboard
            ;;
        xsel)
            xsel --clipboard --clear
            ;;
        wl-clipboard)
            wl-copy ""
            ;;
        *)
            die "No clipboard tool found"
            ;;
    esac
}

# ==============================================================================
# SECTION: NETWORKING
# ==============================================================================

#
# @description Get the primary Wi-Fi interface name
#
os_get_wifi_interface() {
    # Find wireless interface using iw or /sys
    if command -v iw &>/dev/null; then
        iw dev 2>/dev/null | awk '$1=="Interface"{print $2}' | head -1
    else
        ls /sys/class/net/ 2>/dev/null | while read -r iface; do
            if [[ -d "/sys/class/net/$iface/wireless" ]]; then
                echo "$iface"
                break
            fi
        done
    fi
}

#
# @description Turn Wi-Fi on (requires NetworkManager)
#
os_wifi_on() {
    if command -v nmcli &>/dev/null; then
        nmcli radio wifi on
    else
        msg_warning "NetworkManager not found. Manual Wi-Fi control not available."
    fi
}

#
# @description Turn Wi-Fi off
#
os_wifi_off() {
    if command -v nmcli &>/dev/null; then
        nmcli radio wifi off
    else
        msg_warning "NetworkManager not found"
    fi
}

#
# @description Get Wi-Fi power status
# @return "on" or "off"
#
os_wifi_status() {
    if command -v nmcli &>/dev/null; then
        nmcli radio wifi | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

#
# @description Set DNS servers (systemd-resolved or direct)
# @param $1 Connection name (ignored on Linux, uses system-wide)
# @param $@ DNS server addresses
#
os_set_dns() {
    shift  # Remove connection name arg
    local dns_servers=("$@")
    
    if command -v resolvectl &>/dev/null; then
        # systemd-resolved
        local interface
        interface="$(os_get_wifi_interface)"
        sudo resolvectl dns "$interface" "${dns_servers[@]}"
        msg_info "DNS set via resolvectl"
    else
        # Direct /etc/resolv.conf modification
        msg_warning "Modifying /etc/resolv.conf directly (may be overwritten)"
        {
            echo "# Generated by fc dns"
            for dns in "${dns_servers[@]}"; do
                echo "nameserver $dns"
            done
        } | sudo tee /etc/resolv.conf > /dev/null
    fi
}

#
# @description Clear DNS servers (revert to DHCP)
# @param $1 Connection name (ignored on Linux)
#
os_clear_dns() {
    if command -v resolvectl &>/dev/null; then
        local interface
        interface="$(os_get_wifi_interface)"
        sudo resolvectl revert "$interface"
        msg_info "DNS reverted via resolvectl"
    else
        msg_warning "Cannot automatically revert DNS. Restart networking service."
    fi
}

#
# @description Get current DNS servers
# @param $1 Connection name (ignored on Linux)
#
os_get_dns() {
    if command -v resolvectl &>/dev/null; then
        resolvectl dns
    elif [[ -f /etc/resolv.conf ]]; then
        grep "^nameserver" /etc/resolv.conf | awk '{print $2}'
    else
        echo "unknown"
    fi
}

# ==============================================================================
# SECTION: SYSTEM OPERATIONS
# ==============================================================================

#
# @description Lock the screen
#
os_lock_screen() {
    if command -v loginctl &>/dev/null; then
        loginctl lock-session
    elif command -v gnome-screensaver-command &>/dev/null; then
        gnome-screensaver-command --lock
    elif command -v xdg-screensaver &>/dev/null; then
        xdg-screensaver lock
    elif command -v dm-tool &>/dev/null; then
        dm-tool lock
    else
        msg_warning "No supported lock method found for this desktop environment"
    fi
}

#
# @description Prevent system sleep (using systemd-inhibit or caffeine)
# @param $@ Time duration (unused on Linux basic implementation)
#
os_prevent_sleep() {
    if command -v systemd-inhibit &>/dev/null; then
        msg_info "Use: systemd-inhibit --what=idle:sleep <command>"
        msg_info "Or install caffeine: sudo apt install caffeine"
    elif command -v caffeine &>/dev/null; then
        caffeine &
    else
        msg_warning "No sleep prevention tool found. Install caffeine."
    fi
}

#
# @description Allow sleep again
#
os_allow_sleep() {
    if command -v caffeine &>/dev/null; then
        pkill -x caffeine 2>/dev/null || true
    fi
}

#
# @description Get sleep prevention status
#
os_get_sleep_status() {
    if pgrep -x caffeine &>/dev/null; then
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
    if command -v ufw &>/dev/null; then
        sudo ufw enable
    elif command -v firewall-cmd &>/dev/null; then
        sudo systemctl start firewalld
    else
        die "No supported firewall found (ufw, firewalld)"
    fi
}

#
# @description Disable firewall
#
os_firewall_off() {
    if command -v ufw &>/dev/null; then
        sudo ufw disable
    elif command -v firewall-cmd &>/dev/null; then
        sudo systemctl stop firewalld
    else
        die "No supported firewall found"
    fi
}

#
# @description Get firewall status
#
os_firewall_status() {
    if command -v ufw &>/dev/null; then
        sudo ufw status
    elif command -v firewall-cmd &>/dev/null; then
        sudo firewall-cmd --state
    else
        echo "unknown"
    fi
}

# ==============================================================================
# SECTION: BLUETOOTH (Limited support)
# ==============================================================================

#
# @description Turn Bluetooth on
#
os_bluetooth_on() {
    if command -v bluetoothctl &>/dev/null; then
        bluetoothctl power on
    elif command -v rfkill &>/dev/null; then
        sudo rfkill unblock bluetooth
    else
        die "No Bluetooth control tool found"
    fi
}

#
# @description Turn Bluetooth off
#
os_bluetooth_off() {
    if command -v bluetoothctl &>/dev/null; then
        bluetoothctl power off
    elif command -v rfkill &>/dev/null; then
        sudo rfkill block bluetooth
    else
        die "No Bluetooth control tool found"
    fi
}

#
# @description Get Bluetooth status
#
os_bluetooth_status() {
    if command -v bluetoothctl &>/dev/null; then
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            echo "on"
        else
            echo "off"
        fi
    elif command -v rfkill &>/dev/null; then
        if rfkill list bluetooth 2>/dev/null | grep -q "Soft blocked: no"; then
            echo "on"
        else
            echo "off"
        fi
    else
        echo "unknown"
    fi
}

# Export all functions
export -f os_install_package os_update_packages os_is_package_installed
export -f os_clipboard_copy os_clipboard_paste os_clipboard_clear
export -f os_get_wifi_interface os_wifi_on os_wifi_off os_wifi_status
export -f os_set_dns os_clear_dns os_get_dns
export -f os_lock_screen os_prevent_sleep os_allow_sleep os_get_sleep_status
export -f os_firewall_on os_firewall_off os_firewall_status
export -f os_bluetooth_on os_bluetooth_off os_bluetooth_status
