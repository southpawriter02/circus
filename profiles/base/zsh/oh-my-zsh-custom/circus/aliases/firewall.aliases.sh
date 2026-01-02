# ==============================================================================
#
# FILE:         firewall.aliases.sh
#
# DESCRIPTION:  Aliases for managing the macOS application-level firewall.
#
# ==============================================================================

# Check firewall status
alias fwstatus='sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate'

# Enable the firewall
alias fwon='sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on'

# Disable the firewall
alias fwoff='sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate off'

# List all applications with firewall rules
alias fwlist='sudo /usr/libexec/ApplicationFirewall/socketfilterfw --listapps'
