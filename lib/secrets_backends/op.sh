#!/usr/bin/env bash

# ==============================================================================
#
# BACKEND:      op (1Password CLI)
#
# DESCRIPTION:  Secrets backend for 1Password using the official CLI tool.
#               Supports the op:// URI format for referencing secrets.
#
# URI FORMAT:   op://vault/item/field
#               op://vault/item/section/field
#
# REQUIREMENTS: 1Password CLI ('op') must be installed
#               Install: brew install --cask 1password-cli
#
# ==============================================================================

# --- Backend Interface Implementation ---

# Returns human-readable backend name
secrets_backend_get_name() {
  echo "1Password CLI"
}

# Check if required CLI tools are installed
# Returns 0 if available, 1 if not
secrets_backend_check_dependencies() {
  local op_cmd="${OP_CMD:-op}"
  if ! command -v "$op_cmd" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

# Check if user is authenticated with the backend
# Returns 0 if authenticated, 1 if not
secrets_backend_check_auth() {
  local op_cmd="${OP_CMD:-op}"

  # Check if signed in by attempting to get current user
  if "$op_cmd" user get --me >/dev/null 2>&1; then
    return 0
  fi

  # Try with account flag if OP_ACCOUNT is set
  if [ -n "$OP_ACCOUNT" ]; then
    if "$op_cmd" user get --me --account "$OP_ACCOUNT" >/dev/null 2>&1; then
      return 0
    fi
  fi

  return 1
}

# Perform authentication (interactive if needed)
# Returns 0 on success, 1 on failure
secrets_backend_authenticate() {
  local op_cmd="${OP_CMD:-op}"

  msg_info "Signing in to 1Password..."
  msg_info "You may be prompted for your password or biometric authentication."
  echo ""

  # 1Password CLI 2.x uses 'op signin' which outputs session token
  # or handles biometric auth automatically
  if [ -n "$OP_ACCOUNT" ]; then
    if eval "$("$op_cmd" signin --account "$OP_ACCOUNT" 2>/dev/null)"; then
      return 0
    fi
  else
    if eval "$("$op_cmd" signin 2>/dev/null)"; then
      return 0
    fi
  fi

  # If eval fails, try direct signin (for biometric-enabled setups)
  if "$op_cmd" signin >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

# Fetch a secret value
# Arguments: $1 = secret path (without op:// prefix)
# Output: Secret value to stdout
# Returns 0 on success, 1 on failure
secrets_backend_get_secret() {
  local secret_path="$1"
  local op_cmd="${OP_CMD:-op}"

  # The path comes in as: vault/item/field or vault/item/section/field
  # We need to construct the full URI for op read
  local full_uri="op://${secret_path}"

  local secret_value
  if [ -n "$OP_ACCOUNT" ]; then
    secret_value=$("$op_cmd" read "$full_uri" --account "$OP_ACCOUNT" 2>/dev/null)
  else
    secret_value=$("$op_cmd" read "$full_uri" 2>/dev/null)
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
  local op_cmd="${OP_CMD:-op}"

  msg_info "Available 1Password vaults and items:"
  echo ""

  # List vaults
  local vaults
  if [ -n "$OP_ACCOUNT" ]; then
    vaults=$("$op_cmd" vault list --format=json --account "$OP_ACCOUNT" 2>/dev/null)
  else
    vaults=$("$op_cmd" vault list --format=json 2>/dev/null)
  fi

  if [ -z "$vaults" ]; then
    msg_warning "Could not list vaults. Are you signed in?"
    return 1
  fi

  # Parse and display vaults with item counts
  echo "$vaults" | jq -r '.[] | "  \(.name) (\(.id))"' 2>/dev/null || {
    msg_warning "Could not parse vault list"
    return 1
  }

  echo ""
  msg_info "Use 'op item list --vault <vault>' to see items in a vault."
  msg_info "Use 'op item get <item> --vault <vault>' to see fields."
}

# Get backend-specific help text
secrets_backend_get_help() {
  cat << 'EOF'
1Password CLI Backend (op://)

URI Format:
  op://vault/item/field
  op://vault/item/section/field

Examples:
  op://Personal/github.com/token
  op://Work/aws-credentials/access_key_id
  op://Shared/database/credentials/password

Finding Your Secret Path:
  1. List vaults:    op vault list
  2. List items:     op item list --vault Personal
  3. Get item:       op item get github.com --vault Personal
  4. Copy field ref: Look for the field name you need

Configuration Variables:
  OP_ACCOUNT  - Account shorthand (for multiple accounts)
  OP_CMD      - Override op command path (for testing)

Requirements:
  - 1Password CLI: brew install --cask 1password-cli
  - Sign in: op signin
  - Enable CLI integration in 1Password app settings
EOF
}
