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

# --- HTTP Client Settings ----------------------------------------------------

# Default HTTP request timeout (in seconds)
export REQUESTS_TIMEOUT="${REQUESTS_TIMEOUT:-30}"

# curl connection timeout
export CURL_CONNECT_TIMEOUT="${CURL_CONNECT_TIMEOUT:-30}"

# wget timeout
export WGET_TIMEOUT="${WGET_TIMEOUT:-30}"

# --- SSL/TLS Settings --------------------------------------------------------

# Git SSL verification (uncomment to disable for self-signed certs)
# WARNING: Only use if required by corporate proxy/firewall
# export GIT_SSL_NO_VERIFY="${GIT_SSL_NO_VERIFY:-true}"

# curl CA bundle path (corporate CA)
# export CURL_CA_BUNDLE="${CURL_CA_BUNDLE:-/path/to/corporate-ca-bundle.crt}"

# pip certificate path
# export PIP_CERT="${PIP_CERT:-/path/to/corporate-ca-bundle.crt}"

# npm SSL strictness (set to false only if required)
# export NPM_STRICT_SSL="${NPM_STRICT_SSL:-true}"

# Node.js TLS rejection (DANGEROUS - only for debugging)
# export NODE_TLS_REJECT_UNAUTHORIZED="${NODE_TLS_REJECT_UNAUTHORIZED:-0}"

# --- Corporate Tooling Paths -------------------------------------------------

# Company-specific tools directory
export CORPORATE_TOOLS_PATH="${CORPORATE_TOOLS_PATH:-/opt/company-tools}"
[[ -d "$CORPORATE_TOOLS_PATH/bin" ]] && export PATH="$CORPORATE_TOOLS_PATH/bin:$PATH"

# Company CLI tools configuration
export COMPANY_CLI_CONFIG="${COMPANY_CLI_CONFIG:-$HOME/.config/company}"

# --- Identity & Authentication -----------------------------------------------

# LDAP server for directory services (template)
# export LDAP_SERVER="${LDAP_SERVER:-ldap.company.com}"
# export LDAP_BASE_DN="${LDAP_BASE_DN:-dc=company,dc=com}"

# Okta organization URL (for SSO)
# export OKTA_ORG_URL="${OKTA_ORG_URL:-https://company.okta.com}"

# SSO provider identifier
# export SSO_PROVIDER="${SSO_PROVIDER:-okta}"

# SAML configuration
# export SAML_IDP_URL="${SAML_IDP_URL:-https://idp.company.com/saml}"

# --- API Rate Limiting -------------------------------------------------------

# GitHub Enterprise rate limit awareness
export GITHUB_API_RATE_LIMIT_AWARE="${GITHUB_API_RATE_LIMIT_AWARE:-1}"

# GitLab API requests per second
export GITLAB_API_RATE_LIMIT="${GITLAB_API_RATE_LIMIT:-10}"

# --- Compliance & Audit ------------------------------------------------------

# Enable audit logging for CLI tools
export AUDIT_LOG_ENABLED="${AUDIT_LOG_ENABLED:-true}"

# Audit log location
export AUDIT_LOG_PATH="${AUDIT_LOG_PATH:-$HOME/.logs/audit}"
[[ -d "$AUDIT_LOG_PATH" ]] || mkdir -p "$AUDIT_LOG_PATH"

# --- Monitoring & Observability ---------------------------------------------

# Sentry DSN for error reporting (template)
# export SENTRY_DSN="${SENTRY_DSN:-https://key@sentry.company.com/project}"

# OpenTelemetry endpoint (template)
# export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-https://otel.company.com}"

# Splunk HEC endpoint (template)
# export SPLUNK_HEC_URL="${SPLUNK_HEC_URL:-https://splunk.company.com:8088}"

# --- Feature Flags & Configuration -------------------------------------------

# LaunchDarkly SDK key (template)
# export LAUNCHDARKLY_SDK_KEY="${LAUNCHDARKLY_SDK_KEY:-sdk-key-here}"

# Feature flag service
# export FEATURE_FLAG_SERVICE="${FEATURE_FLAG_SERVICE:-launchdarkly}"

# --- Internal Service Discovery ----------------------------------------------

# Consul/Service Discovery endpoint (template)
# export CONSUL_HTTP_ADDR="${CONSUL_HTTP_ADDR:-consul.company.com:8500}"

# Vault address for secrets (template)
# export VAULT_ADDR="${VAULT_ADDR:-https://vault.company.com:8200}"

# --- Terraform/Infrastructure ------------------------------------------------

# Terraform backend configuration
# export TF_STATE_BUCKET="${TF_STATE_BUCKET:-company-terraform-state}"
# export TF_LOCK_TABLE="${TF_LOCK_TABLE:-terraform-locks}"

# Terraform workspace
# export TF_WORKSPACE="${TF_WORKSPACE:-development}"
