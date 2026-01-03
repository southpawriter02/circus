# ==============================================================================
# Work Aliases
#
# Aliases for corporate/enterprise workflow including VPN, proxy,
# and common work-related commands.
#
# USAGE:
#   These aliases are automatically loaded when the work role is active.
# ==============================================================================

# --- Quick Navigation ---------------------------------------------------------

# Go to work projects directory
alias work='cd "${WORK_PROJECTS_DIR:-$HOME/Work}"'
alias w='work'

# Common work directories (customize as needed)
# alias proj='cd "$WORK_PROJECTS_DIR/current-project"'
# alias docs='cd "$WORK_PROJECTS_DIR/documentation"'

# --- VPN Commands -------------------------------------------------------------

# VPN status (works with scutil for macOS VPNs)
alias vpns='scutil --nc list 2>/dev/null | grep -E "^\*|Connected"'

# List all network connections
alias netls='scutil --nc list'

# Quick VPN connect/disconnect (customize VPN name)
# alias vpnc='scutil --nc start "Corporate VPN"'
# alias vpnd='scutil --nc stop "Corporate VPN"'

# --- Proxy Management ---------------------------------------------------------

# Enable proxy (customize for your proxy)
proxy_on() {
    export HTTP_PROXY="${1:-http://proxy.company.com:8080}"
    export HTTPS_PROXY="$HTTP_PROXY"
    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTPS_PROXY"
    export NO_PROXY="localhost,127.0.0.1,.company.com"
    export no_proxy="$NO_PROXY"
    echo "Proxy enabled: $HTTP_PROXY"
}

# Disable proxy
proxy_off() {
    unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy NO_PROXY no_proxy
    echo "Proxy disabled"
}

# Show current proxy settings
alias proxystatus='env | grep -i proxy'

# --- Git with Corporate Identity ----------------------------------------------

# Git commit with work email
# alias gcw='git commit --author="Your Name <your.name@company.com>"'

# Git log with corporate filter
# alias glogwork='git log --author="@company.com"'

# --- SSH to Corporate Servers -------------------------------------------------

# Quick SSH to common servers (customize as needed)
# alias ssh-dev='ssh dev.company.com'
# alias ssh-prod='ssh prod.company.com'
# alias ssh-bastion='ssh bastion.company.com'

# SSH via bastion/jump host
# alias ssh-jump='ssh -J bastion.company.com'

# --- Corporate Tools ----------------------------------------------------------

# Jira CLI (if using go-jira or similar)
# alias j='jira'
# alias jls='jira list --project MYPROJECT'
# alias jmy='jira list --assignee currentUser()'

# Slack CLI (if installed)
# alias slk='slack-cli'

# --- Security -----------------------------------------------------------------

# Lock screen immediately
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Alternative lock (newer macOS)
alias afk='pmset displaysleepnow'

# Clear terminal and history (for sensitive sessions)
alias clear-session='clear && history -c && history -w'

# Show login history
alias loginhistory='last -20'

# --- Network Diagnostics ------------------------------------------------------

# Show active network interfaces
alias netactive='ifconfig | grep -E "^[a-z]|inet "'

# Show routing table
alias routes='netstat -rn'

# DNS lookup
alias dnslookup='nslookup'

# Check connectivity to common services
netcheck() {
    echo "=== Network Connectivity Check ==="
    echo -n "Internet (Google DNS): "
    ping -c 1 8.8.8.8 &>/dev/null && echo "✓ OK" || echo "✗ FAILED"
    echo -n "DNS Resolution: "
    nslookup google.com &>/dev/null && echo "✓ OK" || echo "✗ FAILED"
    # Add corporate checks
    # echo -n "VPN Gateway: "
    # ping -c 1 vpn.company.com &>/dev/null && echo "✓ OK" || echo "✗ FAILED"
}

# --- Certificate Management ---------------------------------------------------

# View certificate for a host
certcheck() {
    local host="${1:-localhost}"
    local port="${2:-443}"
    echo | openssl s_client -connect "${host}:${port}" -servername "$host" 2>/dev/null | \
        openssl x509 -noout -text | head -30
}

# View certificate expiry
certexpiry() {
    local host="${1:-localhost}"
    local port="${2:-443}"
    echo | openssl s_client -connect "${host}:${port}" -servername "$host" 2>/dev/null | \
        openssl x509 -noout -dates
}

# --- Meeting/Calendar Helpers -------------------------------------------------

# Open calendar (customize URL as needed)
# alias cal='open "https://calendar.google.com"'
# alias meet='open "https://meet.google.com"'
# alias zoom='open "zoommtg://"'

# --- Time Zone Helpers (for distributed teams) --------------------------------

# Show multiple time zones
alias worldtime='TZ="America/New_York" date; TZ="America/Los_Angeles" date; TZ="Europe/London" date; TZ="Asia/Tokyo" date'

# Convert time to UTC
alias utc='TZ=UTC date'

# --- Kubernetes for Work ------------------------------------------------------

# Use work kubeconfig
alias kwork='export KUBECONFIG=$HOME/.kube/config.work && kubectl'

# Common k8s with work context
# alias kwget='kubectl --context=work get'
# alias kwlogs='kubectl --context=work logs'

# --- AWS for Work -------------------------------------------------------------

# Use work AWS profile
alias aws-work='AWS_PROFILE=work aws'

# Switch to work AWS profile
alias workaws='export AWS_PROFILE=work && echo "AWS Profile: work"'

# --- Docker for Work ----------------------------------------------------------

# Login to corporate registry
# alias docker-login-work='docker login registry.company.com'

# Pull from corporate registry
# alias dpullwork='docker pull registry.company.com/'
