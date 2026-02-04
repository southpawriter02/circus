#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/security.sh
#
# DESCRIPTION:  Security library for input sanitization and validation.
#               Provides functions to prevent command injection, path traversal,
#               and other security vulnerabilities in shell scripts.
#
# USAGE:        source "$DOTFILES_ROOT/lib/security.sh"
#
# ==============================================================================

# --- Constants --------------------------------------------------------------

# Allowed characters for package names (brew, cask, mas)
readonly SECURITY_PACKAGE_PATTERN='^[a-zA-Z0-9][a-zA-Z0-9_@/.-]*$'

# Allowed characters for macOS preference domains
readonly SECURITY_DOMAIN_PATTERN='^[a-zA-Z0-9][a-zA-Z0-9._-]*$'

# Dangerous shell metacharacters to strip
readonly SECURITY_DANGEROUS_CHARS='`$(){}[]|;&<>!\\*?~'

# --- Input Sanitization Functions -------------------------------------------

# Sanitize a string by removing dangerous shell metacharacters
# Usage: sanitized=$(sanitize_string "$input")
sanitize_string() {
  local input="$1"
  local output
  
  # Remove backticks, $(), ${}, and other dangerous patterns
  output="${input//\`/}"
  output="${output//\$(/}"
  output="${output//)/}"
  output="${output//\${/}"
  output="${output//\}/}"
  output="${output//|/}"
  output="${output//;/}"
  output="${output//&/}"
  output="${output//>/}"
  output="${output//</}"
  output="${output//!/}"
  
  echo "$output"
}

# Escape a string for safe use in shell commands
# Usage: escaped=$(escape_for_shell "$input")
escape_for_shell() {
  local input="$1"
  # Use printf %q for proper shell escaping
  printf '%q' "$input"
}

# Validate and sanitize a macOS preference domain
# Usage: if sanitize_domain "com.apple.finder"; then ...
# Returns: 0 if valid, 1 if invalid
sanitize_domain() {
  local domain="$1"
  
  # Check for empty input
  if [[ -z "$domain" ]]; then
    return 1
  fi
  
  # Check against allowed pattern
  if [[ ! "$domain" =~ $SECURITY_DOMAIN_PATTERN ]]; then
    msg_warning "Security: Invalid domain format: $domain"
    return 1
  fi
  
  # Check for suspicious patterns
  if [[ "$domain" == *".."* ]] || [[ "$domain" == *"/"* ]]; then
    msg_warning "Security: Suspicious domain pattern: $domain"
    return 1
  fi
  
  echo "$domain"
  return 0
}

# Validate and sanitize a package name (brew, cask, mas)
# Usage: if sanitize_package_name "firefox"; then ...
# Returns: 0 if valid, 1 if invalid
sanitize_package_name() {
  local package="$1"
  
  # Check for empty input
  if [[ -z "$package" ]]; then
    return 1
  fi
  
  # Check against allowed pattern
  if [[ ! "$package" =~ $SECURITY_PACKAGE_PATTERN ]]; then
    msg_warning "Security: Invalid package name: $package"
    return 1
  fi
  
  # Additional checks for dangerous patterns
  if [[ "$package" == *".."* ]]; then
    msg_warning "Security: Suspicious package name: $package"
    return 1
  fi
  
  echo "$package"
  return 0
}

# Validate and sanitize a file path
# Usage: safe_path=$(sanitize_path "$path")
# Returns: Resolved absolute path or empty string on failure
sanitize_path() {
  local path="$1"
  local base_allowed="${2:-$HOME}"  # Optional: restrict to base directory
  
  # Check for empty input
  if [[ -z "$path" ]]; then
    return 1
  fi
  
  # Check for null bytes (attack vector)
  if [[ "$path" == *$'\0'* ]]; then
    msg_warning "Security: Null byte in path"
    return 1
  fi
  
  # Resolve to absolute path
  local resolved
  if [[ -e "$path" ]]; then
    resolved=$(cd "$(dirname "$path")" 2>/dev/null && pwd)/$(basename "$path")
  else
    # For non-existent paths, just expand ~
    resolved="${path/#\~/$HOME}"
    # Convert to absolute if relative
    if [[ "$resolved" != /* ]]; then
      resolved="$(pwd)/$resolved"
    fi
  fi
  
  # Normalize path (remove .., ., double slashes)
  resolved=$(echo "$resolved" | sed 's|/\./|/|g; s|//|/|g')
  
  # Check for path traversal attempts in the original input
  if [[ "$path" == *".."* ]]; then
    # Verify the resolved path is still within allowed base
    case "$resolved" in
      "$base_allowed"*|"$DOTFILES_ROOT"*|"/tmp"*|"/var/folders"*)
        # Allow these paths
        ;;
      *)
        msg_warning "Security: Path traversal detected: $path -> $resolved"
        return 1
        ;;
    esac
  fi
  
  echo "$resolved"
  return 0
}

# Validate a URL (HTTPS preferred)
# Usage: if validate_url "https://example.com"; then ...
validate_url() {
  local url="$1"
  local require_https="${2:-true}"
  
  # Check for empty input
  if [[ -z "$url" ]]; then
    return 1
  fi
  
  # Check for dangerous characters
  if [[ "$url" == *'`'* ]] || [[ "$url" == *'$('* ]] || [[ "$url" == *';'* ]]; then
    msg_warning "Security: Dangerous characters in URL: $url"
    return 1
  fi
  
  # Check protocol
  if [[ "$require_https" == "true" ]]; then
    if [[ "$url" != https://* ]]; then
      msg_warning "Security: HTTPS required, got: $url"
      return 1
    fi
  else
    if [[ "$url" != http://* ]] && [[ "$url" != https://* ]]; then
      msg_warning "Security: Invalid URL protocol: $url"
      return 1
    fi
  fi
  
  # Basic hostname validation
  local hostname
  hostname=$(echo "$url" | sed 's|^https\?://||; s|/.*||; s|:.*||')
  
  if [[ -z "$hostname" ]] || [[ "$hostname" == *" "* ]]; then
    msg_warning "Security: Invalid hostname in URL: $url"
    return 1
  fi
  
  return 0
}

# Check if running as root (and optionally block)
# Usage: if check_not_root; then ... (returns 1 if root)
check_not_root() {
  if [[ $EUID -eq 0 ]]; then
    msg_error "Security: This command should not be run as root."
    msg_info "Please run as a regular user. sudo will be requested when needed."
    return 1
  fi
  return 0
}

# Validate a defaults write value for safety
# Usage: safe_value=$(sanitize_defaults_value "$value" "$type")
sanitize_defaults_value() {
  local value="$1"
  local type="$2"
  
  # For boolean and numeric types, validate format
  case "$type" in
    -bool|bool|boolean)
      if [[ "$value" != "true" ]] && [[ "$value" != "false" ]] && \
         [[ "$value" != "1" ]] && [[ "$value" != "0" ]] && \
         [[ "$value" != "YES" ]] && [[ "$value" != "NO" ]]; then
        msg_warning "Security: Invalid boolean value: $value"
        return 1
      fi
      echo "$value"
      ;;
    -int|int|integer)
      if [[ ! "$value" =~ ^-?[0-9]+$ ]]; then
        msg_warning "Security: Invalid integer value: $value"
        return 1
      fi
      echo "$value"
      ;;
    -float|float)
      if [[ ! "$value" =~ ^-?[0-9]*\.?[0-9]+$ ]]; then
        msg_warning "Security: Invalid float value: $value"
        return 1
      fi
      echo "$value"
      ;;
    -string|string|*)
      # For strings, sanitize dangerous characters
      sanitize_string "$value"
      ;;
  esac
  
  return 0
}

# Comprehensive input check combining multiple validations
# Usage: if security_check_input "$input" "package"; then ...
security_check_input() {
  local input="$1"
  local type="$2"
  
  case "$type" in
    package)
      sanitize_package_name "$input"
      ;;
    domain)
      sanitize_domain "$input"
      ;;
    path)
      sanitize_path "$input"
      ;;
    url)
      validate_url "$input"
      ;;
    string)
      sanitize_string "$input"
      ;;
    *)
      # Default: basic string sanitization
      sanitize_string "$input"
      ;;
  esac
}

# Log security events (for audit trail)
# Usage: security_log "warning" "Blocked malicious input" "$input"
security_log() {
  local level="$1"
  local message="$2"
  local context="$3"
  
  local log_file="${CIRCUS_SECURITY_LOG:-$HOME/.circus/security.log}"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  # Create log directory if needed
  mkdir -p "$(dirname "$log_file")" 2>/dev/null
  
  # Append to log
  echo "[$timestamp] [$level] $message${context:+ | context: $context}" >> "$log_file"
}

# --- Exports ----------------------------------------------------------------

export -f sanitize_string escape_for_shell sanitize_domain
export -f sanitize_package_name sanitize_path validate_url
export -f check_not_root sanitize_defaults_value security_check_input
export -f security_log
