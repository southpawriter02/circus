#!/usr/bin/env bash

# ==============================================================================
#
# BACKEND:      vault (HashiCorp Vault)
#
# DESCRIPTION:  Secrets backend for HashiCorp Vault using the official CLI.
#               Supports KV v2 secrets engine with field extraction.
#
# URI FORMAT:   vault://path/to/secret#field
#               vault://path/to/secret (returns all fields as JSON)
#
# REQUIREMENTS: HashiCorp Vault CLI ('vault') must be installed
#               Install: brew install vault
#
# ==============================================================================

# --- Backend Interface Implementation ---

# Returns human-readable backend name
secrets_backend_get_name() {
  echo "HashiCorp Vault"
}

# Check if required CLI tools are installed
# Returns 0 if available, 1 if not
secrets_backend_check_dependencies() {
  local vault_cmd="${VAULT_CMD:-vault}"
  if ! command -v "$vault_cmd" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

# Check if user is authenticated with the backend
# Returns 0 if authenticated, 1 if not
secrets_backend_check_auth() {
  local vault_cmd="${VAULT_CMD:-vault}"

  # Check if we have a valid token
  if "$vault_cmd" token lookup >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

# Perform authentication (interactive if needed)
# Returns 0 on success, 1 on failure
secrets_backend_authenticate() {
  local vault_cmd="${VAULT_CMD:-vault}"

  # Check if VAULT_ADDR is set
  if [ -z "$VAULT_ADDR" ]; then
    msg_warning "VAULT_ADDR environment variable is not set."
    msg_info "Set it in your secrets.conf or environment:"
    msg_info "  export VAULT_ADDR='https://vault.example.com:8200'"
    return 1
  fi

  msg_info "Vault server: $VAULT_ADDR"
  msg_info "Authenticating to HashiCorp Vault..."
  echo ""

  # Offer authentication method selection
  msg_info "Select authentication method:"
  echo "  1) Token (paste existing token)"
  echo "  2) OIDC (browser-based SSO)"
  echo "  3) LDAP (username/password)"
  echo "  4) GitHub (personal access token)"
  echo ""
  echo -n "Choice [1-4]: "
  read -r auth_choice

  case "$auth_choice" in
    1)
      echo -n "Enter Vault token: "
      read -rs token
      echo ""
      if VAULT_TOKEN="$token" "$vault_cmd" token lookup >/dev/null 2>&1; then
        export VAULT_TOKEN="$token"
        msg_success "Authenticated successfully."
        return 0
      fi
      ;;
    2)
      if "$vault_cmd" login -method=oidc 2>/dev/null; then
        return 0
      fi
      ;;
    3)
      echo -n "LDAP Username: "
      read -r username
      echo -n "LDAP Password: "
      read -rs password
      echo ""
      if "$vault_cmd" login -method=ldap username="$username" password="$password" 2>/dev/null; then
        return 0
      fi
      ;;
    4)
      echo -n "GitHub Personal Access Token: "
      read -rs gh_token
      echo ""
      if "$vault_cmd" login -method=github token="$gh_token" 2>/dev/null; then
        return 0
      fi
      ;;
    *)
      msg_warning "Invalid choice."
      return 1
      ;;
  esac

  msg_error "Authentication failed."
  return 1
}

# Fetch a secret value
# Arguments: $1 = secret path (without vault:// prefix)
# Output: Secret value to stdout
# Returns 0 on success, 1 on failure
secrets_backend_get_secret() {
  local secret_path="$1"
  local vault_cmd="${VAULT_CMD:-vault}"

  # Parse the path: path/to/secret#field or path/to/secret
  local path field
  if [[ "$secret_path" == *"#"* ]]; then
    path="${secret_path%%#*}"
    field="${secret_path#*#}"
  else
    path="$secret_path"
    field=""
  fi

  local secret_value

  if [ -n "$field" ]; then
    # Extract specific field
    secret_value=$("$vault_cmd" kv get -field="$field" "$path" 2>/dev/null)
  else
    # Return all fields as JSON
    secret_value=$("$vault_cmd" kv get -format=json "$path" 2>/dev/null | jq -r '.data.data' 2>/dev/null)
  fi

  if [ $? -ne 0 ] || [ -z "$secret_value" ]; then
    return 1
  fi

  echo "$secret_value"
  return 0
}

# List available secrets (optional, for discovery)
# Returns list of secret references
secrets_backend_list_secrets() {
  local vault_cmd="${VAULT_CMD:-vault}"

  if [ -z "$VAULT_ADDR" ]; then
    msg_warning "VAULT_ADDR is not set. Cannot list secrets."
    return 1
  fi

  msg_info "Vault server: $VAULT_ADDR"
  msg_info "Listing secrets engines:"
  echo ""

  # List secrets engines
  "$vault_cmd" secrets list -format=table 2>/dev/null || {
    msg_warning "Could not list secrets engines. Are you authenticated?"
    return 1
  }

  echo ""
  msg_info "To list secrets in a KV engine:"
  msg_info "  vault kv list secret/"
  msg_info ""
  msg_info "To view a secret:"
  msg_info "  vault kv get secret/myapp/config"
}

# Get backend-specific help text
secrets_backend_get_help() {
  cat << 'EOF'
HashiCorp Vault Backend (vault://)

URI Format:
  vault://path/to/secret#field   (extract specific field)
  vault://path/to/secret         (get all fields as JSON)

Examples:
  vault://secret/data/myapp/config#api_key
  vault://secret/data/database/credentials#password
  vault://kv/data/certs/tls#certificate

Finding Your Secret Path:
  1. List engines:  vault secrets list
  2. List secrets:  vault kv list secret/
  3. Get secret:    vault kv get secret/myapp/config
  4. Note fields:   Look at the "data" section for field names

Environment Variables (required):
  VAULT_ADDR      - Vault server URL (e.g., https://vault.example.com:8200)
  VAULT_TOKEN     - Authentication token (optional, can authenticate interactively)
  VAULT_NAMESPACE - Namespace for Vault Enterprise (optional)

Supported Auth Methods:
  - Token (direct token input)
  - OIDC (browser-based SSO)
  - LDAP (username/password)
  - GitHub (personal access token)

Requirements:
  - Vault CLI: brew install vault
  - Network access to Vault server

Configuration Variables:
  VAULT_CMD       - Override vault command path (for testing)
EOF
}
