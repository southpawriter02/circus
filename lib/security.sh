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

# --- Enhanced Path Validation (S01) -----------------------------------------

# Allowed base directories for path operations
# These are the only directories where file operations are permitted
SECURITY_ALLOWED_PATHS=(
  "$HOME"
  "${DOTFILES_ROOT:-$HOME/.dotfiles}"
  "/tmp"
  "/var/folders"
  "/usr/local"
  "/opt/homebrew"
)

# Strict path validator with comprehensive security checks
# Usage: if validate_path "/path/to/file"; then ...
# Returns: 0 if path is safe, 1 if blocked
validate_path() {
  local path="$1"
  local operation="${2:-access}"  # Optional: operation type for logging
  
  # Check for empty input
  if [[ -z "$path" ]]; then
    security_log "error" "Empty path provided" "$operation"
    return 1
  fi
  
  # Check for null bytes (can bypass extension checks)
  if [[ "$path" == *$'\0'* ]]; then
    security_log "critical" "Null byte injection attempt" "$path"
    msg_error "Security: Null byte detected in path"
    return 1
  fi
  
  # Check for shell metacharacters in path
  if [[ "$path" =~ [\`\$\(\)\{\}\|\;\&\<\>] ]]; then
    security_log "critical" "Shell metacharacters in path" "$path"
    msg_error "Security: Invalid characters in path"
    return 1
  fi
  
  # Resolve to absolute path
  local resolved
  resolved=$(resolve_path_secure "$path")
  if [[ $? -ne 0 ]] || [[ -z "$resolved" ]]; then
    security_log "warning" "Failed to resolve path" "$path"
    return 1
  fi
  
  # Check if resolved path is within allowed directories
  if ! is_within_allowed_paths "$resolved"; then
    security_log "critical" "Path outside allowed directories" "$path -> $resolved"
    msg_error "Security: Path not in allowed directories: $resolved"
    return 1
  fi
  
  # If path exists and is a symlink, validate the target
  if [[ -L "$resolved" ]]; then
    if ! check_symlink_target "$resolved"; then
      security_log "critical" "Symlink target outside allowed paths" "$resolved"
      msg_error "Security: Symlink target not allowed"
      return 1
    fi
  fi
  
  echo "$resolved"
  return 0
}

# Securely resolve a path to its absolute form
# Usage: resolved=$(resolve_path_secure "$path")
resolve_path_secure() {
  local path="$1"
  local resolved
  
  # Expand tilde
  path="${path/#\~/$HOME}"
  
  # Convert to absolute if relative
  if [[ "$path" != /* ]]; then
    path="$(pwd)/$path"
  fi
  
  # Normalize: remove /./, //, and resolve parent refs carefully
  # Use a loop to resolve .. safely
  local -a parts=()
  local IFS='/'
  read -ra segments <<< "$path"
  
  for segment in "${segments[@]}"; do
    case "$segment" in
      ''|'.')
        # Skip empty and current dir
        ;;
      '..')
        # Go up one level (remove last element)
        if [[ ${#parts[@]} -gt 0 ]]; then
          unset 'parts[-1]'
        fi
        ;;
      *)
        # Add segment
        parts+=("$segment")
        ;;
    esac
  done
  
  # Reconstruct path
  resolved="/${parts[*]}"
  resolved="${resolved// //}"  # Remove spaces from IFS join
  
  # Fix: properly join with /
  printf -v resolved '/%s' "${parts[@]}"
  
  echo "$resolved"
}

# Check if a path is within allowed directories
# Usage: if is_within_allowed_paths "/path/to/check"; then ...
is_within_allowed_paths() {
  local path="$1"
  
  for allowed in "${SECURITY_ALLOWED_PATHS[@]}"; do
    # Expand any variables in allowed path
    allowed=$(eval echo "$allowed" 2>/dev/null)
    
    if [[ -n "$allowed" ]] && [[ "$path" == "$allowed"* ]]; then
      return 0
    fi
  done
  
  return 1
}

# Validate that a symlink's target is within allowed paths
# Usage: if check_symlink_target "/path/to/symlink"; then ...
check_symlink_target() {
  local symlink="$1"
  
  # Not a symlink? OK
  if [[ ! -L "$symlink" ]]; then
    return 0
  fi
  
  # Resolve the symlink target
  local target
  target=$(readlink -f "$symlink" 2>/dev/null)
  
  if [[ -z "$target" ]]; then
    # Broken symlink - allow (let other checks handle)
    return 0
  fi
  
  # Check if target is within allowed paths
  if is_within_allowed_paths "$target"; then
    return 0
  fi
  
  msg_warning "Security: Symlink $symlink points to disallowed location: $target"
  return 1
}

# Quick boolean check for path safety
# Usage: if is_path_safe "/path/to/check"; then ...
is_path_safe() {
  validate_path "$1" >/dev/null 2>&1
}

# Validate a config file path specifically
# Usage: if validate_config_path "$config_file"; then ...
validate_config_path() {
  local config_file="$1"
  
  # Must have valid extension
  case "$config_file" in
    *.yaml|*.yml|*.conf|*.json|*.sh)
      # Valid config extension
      ;;
    *)
      msg_warning "Security: Invalid config file extension: $config_file"
      security_log "warning" "Invalid config extension" "$config_file"
      return 1
      ;;
  esac
  
  # Run standard path validation
  validate_path "$config_file" "config"
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
export -f validate_path resolve_path_secure is_within_allowed_paths
export -f check_symlink_target is_path_safe validate_config_path
