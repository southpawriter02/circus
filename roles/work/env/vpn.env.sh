# ==============================================================================
# VPN Environment Variables
#
# Environment settings for VPN connectivity in corporate environments.
# Includes settings for common VPN clients and network configuration.
#
# USAGE:
#   These variables are set when the work role is active.
#   Customize based on your organization's VPN solution.
#
# SECURITY:
#   - Never store VPN passwords in plain text
#   - Use Keychain or credential manager for credentials
# ==============================================================================

# --- VPN Detection Functions --------------------------------------------------

# Check if connected to corporate VPN
is_vpn_connected() {
    # Check for common VPN interface names
    ifconfig | grep -q "utun\|ppp\|tun" 2>/dev/null
}

# Check for specific VPN by interface
is_cisco_vpn() {
    pgrep -x "Cisco AnyConnect" &>/dev/null || \
    scutil --nc list 2>/dev/null | grep -q "Cisco"
}

is_globalprotect_vpn() {
    pgrep -x "GlobalProtect" &>/dev/null
}

is_pulse_vpn() {
    pgrep -x "Pulse Secure" &>/dev/null || \
    pgrep -x "PulseSecure" &>/dev/null
}

# --- VPN Gateway Configuration ------------------------------------------------

# Corporate VPN gateway (customize for your organization)
# export VPN_GATEWAY="vpn.company.com"

# VPN group/realm (for Cisco AnyConnect, etc.)
# export VPN_GROUP="corporate"

# --- DNS Configuration When VPN Connected ------------------------------------

# Corporate DNS servers (set when VPN connects)
# export VPN_DNS_SERVERS="10.0.0.1 10.0.0.2"

# Corporate DNS search domains
# export VPN_DNS_DOMAINS="company.com internal.company.com"

# --- Split Tunnel Configuration -----------------------------------------------

# Routes that should go through VPN (CIDR notation)
# These are typically configured by the VPN client automatically
# export VPN_ROUTES="10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

# --- VPN Client Paths ---------------------------------------------------------

# Cisco AnyConnect
# export CISCO_VPN_PATH="/opt/cisco/anyconnect/bin"

# GlobalProtect
# export GLOBALPROTECT_PATH="/Applications/GlobalProtect.app/Contents/MacOS"

# Pulse Secure
# export PULSE_PATH="/Applications/Pulse Secure.app/Contents/MacOS"

# --- VPN Helper Functions -----------------------------------------------------

# Connect to VPN (customize for your VPN client)
vpn_connect() {
    local gateway="${1:-$VPN_GATEWAY}"

    if [[ -z "$gateway" ]]; then
        echo "Error: VPN_GATEWAY not set. Pass gateway as argument or set VPN_GATEWAY."
        return 1
    fi

    # Example for Cisco AnyConnect CLI
    # /opt/cisco/anyconnect/bin/vpn connect "$gateway"

    # Example for macOS built-in VPN via scutil
    # scutil --nc start "Corporate VPN"

    echo "VPN connection commands vary by client. Customize this function."
}

# Disconnect from VPN
vpn_disconnect() {
    # Example for Cisco AnyConnect CLI
    # /opt/cisco/anyconnect/bin/vpn disconnect

    # Example for macOS built-in VPN via scutil
    # scutil --nc stop "Corporate VPN"

    echo "VPN disconnection commands vary by client. Customize this function."
}

# VPN status check
vpn_status() {
    echo "=== VPN Status ==="

    # Check common VPN interfaces
    if is_vpn_connected; then
        echo "VPN: Connected"

        # Show VPN interface details
        ifconfig | grep -A 5 "utun\|ppp\|tun" | head -20
    else
        echo "VPN: Disconnected"
    fi

    # List macOS VPN configurations
    echo ""
    echo "=== Configured VPN Connections ==="
    scutil --nc list 2>/dev/null || echo "No VPN configurations found"
}

# --- Automatic Proxy Toggle ---------------------------------------------------

# Enable corporate proxy when VPN connects
# Call this from a VPN connect hook if your VPN client supports it
vpn_connected_hook() {
    # Enable proxy settings
    # export HTTP_PROXY="http://proxy.company.com:8080"
    # export HTTPS_PROXY="http://proxy.company.com:8080"

    # Switch to corporate DNS
    # networksetup -setdnsservers "Wi-Fi" 10.0.0.1 10.0.0.2

    echo "VPN connected hook executed"
}

# Disable corporate proxy when VPN disconnects
vpn_disconnected_hook() {
    # Disable proxy settings
    # unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy

    # Restore default DNS (empty = DHCP)
    # networksetup -setdnsservers "Wi-Fi" Empty

    echo "VPN disconnected hook executed"
}

# ==============================================================================
# macOS VPN Configuration via scutil
#
# List VPN connections:
#   scutil --nc list
#
# Connect to VPN:
#   scutil --nc start "VPN Name"
#
# Disconnect from VPN:
#   scutil --nc stop "VPN Name"
#
# Show VPN status:
#   scutil --nc status "VPN Name"
#
# ==============================================================================

# ==============================================================================
# networksetup VPN Commands
#
# List network services:
#   networksetup -listallnetworkservices
#
# Connect L2TP VPN:
#   networksetup -connectpppoeservice "VPN Name"
#
# Disconnect VPN:
#   networksetup -disconnectpppoeservice "VPN Name"
#
# ==============================================================================
