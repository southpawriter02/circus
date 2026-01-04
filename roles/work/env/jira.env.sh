# ==============================================================================
# Jira & Atlassian Environment Variables
#
# Configuration for Atlassian tools including Jira, Confluence, Bitbucket,
# and related CLI utilities.
#
# USAGE:
#   These variables are set when the work role is active.
#   Uncomment and customize values for your organization.
#
# SECURITY:
#   - Never commit API tokens or passwords to version control
#   - Store tokens in Keychain or a secrets manager
#   - Use environment variables for sensitive values
# ==============================================================================

# --- Jira Configuration ------------------------------------------------------

# Jira Cloud/Server URL (uncomment and set)
# export JIRA_URL="${JIRA_URL:-https://company.atlassian.net}"

# Jira username (email for Cloud, username for Server)
# export JIRA_USER="${JIRA_USER:-your.email@company.com}"

# Jira API token (stored in Keychain, retrieved via security command)
# To store: security add-generic-password -a "$USER" -s "jira-api-token" -w "your-token"
# export JIRA_API_TOKEN="${JIRA_API_TOKEN:-$(security find-generic-password -a "$USER" -s "jira-api-token" -w 2>/dev/null)}"

# Default Jira project key
# export JIRA_PROJECT="${JIRA_PROJECT:-PROJ}"

# Default issue type for new issues
# export JIRA_DEFAULT_ISSUE_TYPE="${JIRA_DEFAULT_ISSUE_TYPE:-Task}"

# Default priority for new issues
# export JIRA_DEFAULT_PRIORITY="${JIRA_DEFAULT_PRIORITY:-Medium}"

# Jira CLI configuration directory
export JIRA_CLI_CONFIG="${JIRA_CLI_CONFIG:-$HOME/.config/jira}"

# --- Confluence Configuration ------------------------------------------------

# Confluence URL (usually same base as Jira for Cloud)
# export CONFLUENCE_URL="${CONFLUENCE_URL:-https://company.atlassian.net/wiki}"

# Confluence API token (can use same as Jira for Cloud)
# export CONFLUENCE_API_TOKEN="${CONFLUENCE_API_TOKEN:-$JIRA_API_TOKEN}"

# Default Confluence space key
# export CONFLUENCE_SPACE="${CONFLUENCE_SPACE:-TEAM}"

# --- Bitbucket Configuration -------------------------------------------------

# Bitbucket URL
# export BITBUCKET_URL="${BITBUCKET_URL:-https://bitbucket.org/company}"

# Bitbucket username
# export BITBUCKET_USER="${BITBUCKET_USER:-your.email@company.com}"

# Bitbucket app password (for CLI tools)
# export BITBUCKET_APP_PASSWORD="${BITBUCKET_APP_PASSWORD:-$(security find-generic-password -a "$USER" -s "bitbucket-app-password" -w 2>/dev/null)}"

# --- Atlassian CLI Tools -----------------------------------------------------

# go-jira configuration
export JIRA_CONFIG="${JIRA_CONFIG:-$HOME/.jira.d/config.yml}"

# jira-cli (ankitpokhrel/jira-cli) configuration
export JC_CONFIG="${JC_CONFIG:-$HOME/.config/jira-cli/config.yml}"

# --- OpsGenie Configuration --------------------------------------------------

# OpsGenie URL (for incident management)
# export OPSGENIE_URL="${OPSGENIE_URL:-https://company.app.opsgenie.com}"

# OpsGenie API key
# export OPSGENIE_API_KEY="${OPSGENIE_API_KEY:-$(security find-generic-password -a "$USER" -s "opsgenie-api-key" -w 2>/dev/null)}"

# --- Statuspage Configuration ------------------------------------------------

# Statuspage URL
# export STATUSPAGE_URL="${STATUSPAGE_URL:-https://company.statuspage.io}"

# Statuspage API key
# export STATUSPAGE_API_KEY="${STATUSPAGE_API_KEY:-}"

# --- Trello Configuration ----------------------------------------------------

# Trello API key
# export TRELLO_API_KEY="${TRELLO_API_KEY:-}"

# Trello token
# export TRELLO_TOKEN="${TRELLO_TOKEN:-}"

# Default Trello board
# export TRELLO_BOARD="${TRELLO_BOARD:-}"

# --- Atlassian Forge (App Development) ---------------------------------------

# Forge environment
# export FORGE_ENV="${FORGE_ENV:-development}"

# Forge app ID
# export FORGE_APP_ID="${FORGE_APP_ID:-}"

# --- Helper Functions --------------------------------------------------------

# Open Jira issue in browser
jira-open() {
    local issue="${1:-}"
    if [ -z "$issue" ]; then
        echo "Usage: jira-open <issue-key>"
        return 1
    fi
    if [ -n "$JIRA_URL" ]; then
        open "${JIRA_URL}/browse/${issue}"
    else
        echo "JIRA_URL not set"
        return 1
    fi
}

# Open Confluence page in browser
confluence-open() {
    local page_id="${1:-}"
    if [ -z "$page_id" ]; then
        echo "Usage: confluence-open <page-id>"
        return 1
    fi
    if [ -n "$CONFLUENCE_URL" ]; then
        open "${CONFLUENCE_URL}/pages/viewpage.action?pageId=${page_id}"
    else
        echo "CONFLUENCE_URL not set"
        return 1
    fi
}

# Create branch name from Jira issue
jira-branch() {
    local issue="${1:-}"
    local type="${2:-feature}"
    if [ -z "$issue" ]; then
        echo "Usage: jira-branch <issue-key> [type]"
        echo "Types: feature, bugfix, hotfix"
        return 1
    fi
    local branch="${type}/${issue}"
    echo "$branch"
}

# Show Jira configuration info
jira-info() {
    echo "=== Jira Configuration ==="
    echo ""
    echo "JIRA_URL:          ${JIRA_URL:-<not set>}"
    echo "JIRA_USER:         ${JIRA_USER:-<not set>}"
    echo "JIRA_PROJECT:      ${JIRA_PROJECT:-<not set>}"
    echo "JIRA_CLI_CONFIG:   ${JIRA_CLI_CONFIG:-<not set>}"
    echo ""
    echo "CONFLUENCE_URL:    ${CONFLUENCE_URL:-<not set>}"
    echo "BITBUCKET_URL:     ${BITBUCKET_URL:-<not set>}"
}
