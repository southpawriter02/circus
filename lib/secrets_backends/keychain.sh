#!/usr/bin/env bash

# ==============================================================================
#
# BACKEND:      keychain (macOS Keychain)
#
# DESCRIPTION:  Secrets backend for macOS Keychain using the built-in
#               'security' command. Supports both generic and internet passwords.
#
# URI FORMAT:   keychain://service/account
#               keychain://service (uses service as both service and account)
#
# REQUIREMENTS: macOS with 'security' command (built-in)
#
# ==============================================================================

# --- Backend Interface Implementation ---

# Returns human-readable backend name
secrets_backend_get_name() {
  echo "macOS Keychain"
}

# Check if required CLI tools are installed
# Returns 0 if available, 1 if not
secrets_backend_check_dependencies() {
  local security_cmd="${SECURITY_CMD:-security}"
  if ! command -v "$security_cmd" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

# Check if user is authenticated with the backend
# Returns 0 if authenticated, 1 if not
secrets_backend_check_auth() {
  # macOS Keychain is always "authenticated" for the current user
  # Individual item access may still require password/biometric
  return 0
}

# Perform authentication (interactive if needed)
# Returns 0 on success, 1 on failure
secrets_backend_authenticate() {
  # No explicit authentication needed for Keychain
  # Access prompts are handled per-item by macOS
  msg_info "macOS Keychain does not require explicit authentication."
  msg_info "You may be prompted when accessing individual secrets."
  return 0
}

# Fetch a secret value
# Arguments: $1 = secret path (without keychain:// prefix)
# Output: Secret value to stdout
# Returns 0 on success, 1 on failure
secrets_backend_get_secret() {
  local secret_path="$1"
  local security_cmd="${SECURITY_CMD:-security}"

  # Parse the path: service/account or just service
  local service account
  if [[ "$secret_path" == */* ]]; then
    service="${secret_path%%/*}"
    account="${secret_path#*/}"
  else
    service="$secret_path"
    account="$secret_path"
  fi

  local secret_value

  # Try generic password first
  secret_value=$("$security_cmd" find-generic-password -s "$service" -a "$account" -w 2>/dev/null)

  if [ $? -eq 0 ] && [ -n "$secret_value" ]; then
    echo "$secret_value"
    return 0
  fi

  # Try internet password as fallback
  secret_value=$("$security_cmd" find-internet-password -s "$service" -a "$account" -w 2>/dev/null)

  if [ $? -eq 0 ] && [ -n "$secret_value" ]; then
    echo "$secret_value"
    return 0
  fi

  # Try with just service name (no account)
  secret_value=$("$security_cmd" find-generic-password -s "$service" -w 2>/dev/null)

  if [ $? -eq 0 ] && [ -n "$secret_value" ]; then
    echo "$secret_value"
    return 0
  fi

  return 1
}

# List available secrets (optional, for discovery)
# Returns list of secret references
secrets_backend_list_secrets() {
  local security_cmd="${SECURITY_CMD:-security}"

  msg_info "Keychain items (showing first 30):"
  echo ""

  printf "  %-12s %-30s %s\n" "Type" "Service" "Account"
  printf "  %-12s %-30s %s\n" "----" "-------" "-------"

  local count=0
  local kind="" service="" account=""

  # Parse security dump-keychain output
  while IFS= read -r line; do
    case "$line" in
      *'class: "genp"'*)
        kind="Generic"
        ;;
      *'class: "inet"'*)
        kind="Internet"
        ;;
      *'"svce"'*)
        service=$(echo "$line" | sed -n 's/.*"svce".*=.*"\([^"]*\)".*/\1/p')
        if [[ -z "$service" ]]; then
          service=$(echo "$line" | sed -n 's/.*"svce".*=.*<[^>]*>\(.*\)/\1/p')
        fi
        ;;
      *'"acct"'*)
        account=$(echo "$line" | sed -n 's/.*"acct".*=.*"\([^"]*\)".*/\1/p')
        if [[ -z "$account" ]]; then
          account=$(echo "$line" | sed -n 's/.*"acct".*=.*<[^>]*>\(.*\)/\1/p')
        fi
        ;;
      "")
        # Empty line = end of entry
        if [[ -n "$kind" ]] && [[ -n "$service" ]]; then
          # Truncate long names
          [[ ${#service} -gt 28 ]] && service="${service:0:25}..."
          [[ ${#account} -gt 25 ]] && account="${account:0:22}..."

          printf "  %-12s %-30s %s\n" "$kind" "$service" "$account"
          count=$((count + 1))

          [[ $count -ge 30 ]] && break
        fi
        kind="" service="" account=""
        ;;
    esac
  done < <("$security_cmd" dump-keychain 2>/dev/null)

  echo ""
  msg_info "Use 'fc keychain search <query>' to find specific items."
  msg_info "URI format: keychain://service/account"
}

# Get backend-specific help text
secrets_backend_get_help() {
  cat << 'EOF'
macOS Keychain Backend (keychain://)

URI Format:
  keychain://service/account
  keychain://service  (uses service name as account too)

Examples:
  keychain://my-api-service/production
  keychain://github.com/oauth-token
  keychain://wifi-password

Finding Your Secret Path:
  1. List items:    fc keychain list
  2. Search:        fc keychain search github
  3. Construct URI: keychain://service-name/account-name

Adding Secrets to Keychain:
  fc keychain add

Notes:
  - Access to Keychain items may trigger macOS authentication prompts
  - Selecting "Always Allow" grants permanent access to that item
  - Both Generic and Internet passwords are supported
  - No additional software required (uses built-in 'security' command)

Configuration Variables:
  SECURITY_CMD  - Override security command path (for testing)
EOF
}
