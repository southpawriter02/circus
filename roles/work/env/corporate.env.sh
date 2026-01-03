# ==============================================================================
# Corporate Environment Variables
#
# Environment settings for corporate/enterprise environments including
# proxy configuration, package registry settings, and corporate tooling.
#
# USAGE:
#   These variables are set when the work role is active.
#   Customize values based on your organization's requirements.
#
# SECURITY:
#   - Never commit actual credentials to version control
#   - Use environment variables or secrets management for sensitive values
#   - Proxy passwords should be stored in Keychain or vault
# ==============================================================================

# --- Proxy Configuration ------------------------------------------------------

# HTTP/HTTPS Proxy (uncomment and set for corporate networks)
# Format: http://[user:password@]proxy.example.com:port
# export HTTP_PROXY="http://proxy.company.com:8080"
# export HTTPS_PROXY="http://proxy.company.com:8080"
# export http_proxy="$HTTP_PROXY"
# export https_proxy="$HTTPS_PROXY"

# No Proxy (hosts that should bypass the proxy)
# export NO_PROXY="localhost,127.0.0.1,.company.com,.internal"
# export no_proxy="$NO_PROXY"

# --- Corporate Package Registries ---------------------------------------------

# npm registry (private npm registry)
# export NPM_REGISTRY="https://npm.company.com"
# export NPM_CONFIG_REGISTRY="$NPM_REGISTRY"

# Yarn registry
# export YARN_REGISTRY="https://npm.company.com"

# pip/PyPI (private Python package index)
# export PIP_INDEX_URL="https://pypi.company.com/simple/"
# export PIP_TRUSTED_HOST="pypi.company.com"

# Maven/Gradle (Artifactory or Nexus)
# export MAVEN_REPO="https://artifactory.company.com/artifactory/maven-repo"

# Docker registry
# export DOCKER_REGISTRY="registry.company.com"

# --- Git Configuration --------------------------------------------------------

# Corporate Git server (if not using GitHub/GitLab SaaS)
# export GIT_COMPANY_HOST="git.company.com"

# Sign commits with corporate GPG key
# export GIT_SIGNING_KEY="corporate-key-id"

# --- Cloud Provider Settings --------------------------------------------------

# AWS (for corporate AWS accounts)
# export AWS_PROFILE="work"
# export AWS_DEFAULT_REGION="us-east-1"
# export AWS_CONFIG_FILE="$HOME/.aws/config.work"

# Azure
# export AZURE_SUBSCRIPTION_ID="your-subscription-id"
# export AZURE_TENANT_ID="your-tenant-id"

# Google Cloud
# export GOOGLE_CLOUD_PROJECT="company-project-id"
# export CLOUDSDK_CORE_PROJECT="$GOOGLE_CLOUD_PROJECT"

# --- Kubernetes ---------------------------------------------------------------

# Corporate Kubernetes cluster
# export KUBECONFIG="$HOME/.kube/config.work"

# Default namespace
# export KUBE_NAMESPACE="company-namespace"

# --- Corporate Tools ----------------------------------------------------------

# Atlassian (Jira, Confluence)
# export JIRA_URL="https://company.atlassian.net"
# export CONFLUENCE_URL="https://company.atlassian.net/wiki"

# Slack (for CLI tools)
# export SLACK_WORKSPACE="company"

# Datadog/New Relic/Monitoring
# export DD_API_KEY="stored-in-keychain"
# export DD_SITE="datadoghq.com"

# --- Certificate Authority ----------------------------------------------------

# Corporate CA bundle (for internal HTTPS services)
# export SSL_CERT_FILE="/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem"
# export REQUESTS_CA_BUNDLE="$SSL_CERT_FILE"
# export NODE_EXTRA_CA_CERTS="$SSL_CERT_FILE"

# --- Corporate Directory Paths ------------------------------------------------

# Work projects directory
export WORK_PROJECTS_DIR="${WORK_PROJECTS_DIR:-$HOME/Work}"

# Shared network drives (if mounted)
# export SHARED_DRIVE="/Volumes/SharedDrive"

# Create work directory if it doesn't exist
[[ -d "$WORK_PROJECTS_DIR" ]] || mkdir -p "$WORK_PROJECTS_DIR"

# --- Session Settings ---------------------------------------------------------

# Shorter session timeout for security (in seconds)
export TMOUT="${TMOUT:-1800}"  # 30 minutes

# Clear sensitive env vars on shell exit (handled in .zlogout)
