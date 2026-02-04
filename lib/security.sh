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

# --- S10: Root Execution Block ----------------------------------------------

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

# Block execution if running as root - exits immediately (S10)
# Usage: die_if_root (call at script start)
die_if_root() {
  if [[ $EUID -eq 0 ]]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║  ⛔ ERROR: Running as root is not allowed                     ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║  This framework should NEVER be run as root or with sudo.    ║"
    echo "║                                                               ║"
    echo "║  Running as root:                                             ║"
    echo "║  • Bypasses important security checks                         ║"
    echo "║  • Could damage system files                                  ║"
    echo "║  • Violates principle of least privilege                      ║"
    echo "║                                                               ║"
    echo "║  Please run as a regular user:                                ║"
    echo "║  $ fc <command>                                               ║"
    echo "║                                                               ║"
    echo "║  sudo will be requested only when absolutely necessary.       ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    security_log "critical" "Blocked root execution attempt" "EUID=0"
    
    exit 1
  fi
}

# Check if running as root (silent, for conditionals)
# Usage: if is_root; then ...
is_root() {
  [[ $EUID -eq 0 ]]
}

# Require non-root with custom message
# Usage: require_non_root "Custom error message"
require_non_root() {
  local message="${1:-This operation cannot be run as root.}"
  
  if is_root; then
    msg_error "$message"
    security_log "warning" "Root execution blocked" "$message"
    return 1
  fi
  return 0
}

# Get effective user (even when running under sudo)
# Usage: real_user=$(get_real_user)
get_real_user() {
  if [[ -n "${SUDO_USER:-}" ]]; then
    echo "$SUDO_USER"
  elif [[ -n "${USER:-}" ]]; then
    echo "$USER"
  else
    whoami
  fi
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

# --- YAML Injection Prevention (S02) ----------------------------------------

# YAML injection patterns to detect
readonly YAML_INJECTION_PATTERNS=(
  '!!python'     # Python execution
  '!!ruby'       # Ruby execution
  '!!bash'       # Bash execution
  '!!perl'       # Perl execution
  '!include'     # File inclusion
  '!ruby/object' # Ruby object instantiation
  '{{.*}}'       # Template injection
  '{%.*%}'       # Jinja2/template injection
)

# Check YAML value for injection attempts
# Usage: if is_yaml_safe "$value"; then ...
is_yaml_safe() {
  local value="$1"
  
  # Check for empty
  if [[ -z "$value" ]]; then
    return 0
  fi
  
  # Check for YAML-specific injection patterns
  for pattern in "${YAML_INJECTION_PATTERNS[@]}"; do
    if [[ "$value" =~ $pattern ]]; then
      security_log "critical" "YAML injection pattern detected" "$pattern in: $value"
      msg_error "Security: YAML injection attempt blocked"
      return 1
    fi
  done
  
  # Check for shell command injection patterns
  if [[ "$value" =~ \$\( ]] || [[ "$value" =~ \`.*\` ]]; then
    security_log "critical" "Shell injection in YAML value" "$value"
    msg_error "Security: Shell command injection blocked"
    return 1
  fi
  
  # Check for environment variable expansion attempts
  if [[ "$value" =~ \$\{[A-Z_]+\} ]] && [[ "$value" != *'$HOME'* ]] && [[ "$value" != *'$USER'* ]]; then
    security_log "warning" "Suspicious env var in YAML" "$value"
    # Allow but warn - some env vars are legitimate
  fi
  
  return 0
}

# Sanitize a YAML value for safe use
# Usage: safe=$(sanitize_yaml_value "$value")
sanitize_yaml_value() {
  local value="$1"
  
  # Check for injection first
  if ! is_yaml_safe "$value"; then
    return 1
  fi
  
  # Remove dangerous patterns
  local safe="$value"
  
  # Remove backticks
  safe="${safe//\`/}"
  
  # Remove $() command substitution
  safe=$(echo "$safe" | sed 's/\$([^)]*)//g')
  
  # Remove ${} variable expansion (except safe ones)
  safe=$(echo "$safe" | sed 's/\${[^}]*}//g')
  
  # Remove semicolons (command chaining)
  safe="${safe//;/}"
  
  # Remove pipes (command piping)
  safe="${safe//|/}"
  
  # Remove redirections
  safe="${safe//>/}"
  safe="${safe//</}"
  
  echo "$safe"
}

# Validate a YAML config file for security issues
# Usage: if validate_yaml_security "$config_file"; then ...
validate_yaml_security() {
  local config_file="$1"
  local issues=0
  
  # Check file exists
  if [[ ! -f "$config_file" ]]; then
    return 1
  fi
  
  # Check for dangerous YAML constructs in the raw file
  for pattern in "${YAML_INJECTION_PATTERNS[@]}"; do
    if grep -q "$pattern" "$config_file" 2>/dev/null; then
      msg_error "Security: Dangerous YAML pattern found: $pattern"
      security_log "critical" "Dangerous YAML pattern in config" "$pattern in $config_file"
      ((issues++))
    fi
  done
  
  # Check for shell injection in values
  if grep -E '\$\(|`.*`' "$config_file" 2>/dev/null | grep -v '^#' | grep -q .; then
    msg_error "Security: Shell command found in YAML values"
    security_log "critical" "Shell commands in YAML config" "$config_file"
    ((issues++))
  fi
  
  if [[ $issues -gt 0 ]]; then
    msg_error "Security: $issues security issue(s) found in $config_file"
    return 1
  fi
  
  return 0
}

# Safe wrapper for yq that validates output
# Usage: value=$(safe_yaml_get "$file" ".path.to.key")
safe_yaml_get() {
  local file="$1"
  local path="$2"
  local value
  
  value=$(yq eval "$path" "$file" 2>/dev/null)
  
  # Null or empty is OK
  if [[ -z "$value" ]] || [[ "$value" == "null" ]]; then
    echo "$value"
    return 0
  fi
  
  # Validate the value
  if ! is_yaml_safe "$value"; then
    security_log "warning" "Unsafe YAML value blocked" "$path in $file"
    echo ""
    return 1
  fi
  
  echo "$value"
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

# --- Privilege Escalation Protection (S06-S10) ------------------------------

# Sudo audit log file
SUDO_AUDIT_LOG="${CIRCUS_SUDO_LOG:-$HOME/.circus/sudo_audit.log}"

# Run a command with sudo and log the invocation (S06)
# Usage: sudo_audit "description" command [args...]
# Example: sudo_audit "Enabling firewall" /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo_audit() {
  local description="$1"
  shift
  local cmd="$*"
  
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local user="${USER:-$(whoami)}"
  local pwd_dir="${PWD:-unknown}"
  
  # Create log directory if needed
  mkdir -p "$(dirname "$SUDO_AUDIT_LOG")" 2>/dev/null
  
  # Log the sudo invocation BEFORE executing
  {
    echo "============================================================"
    echo "Timestamp:   $timestamp"
    echo "User:        $user"
    echo "Directory:   $pwd_dir"
    echo "Description: $description"
    echo "Command:     sudo $cmd"
    echo "------------------------------------------------------------"
  } >> "$SUDO_AUDIT_LOG"
  
  # Execute the sudo command
  local exit_code
  if sudo "$@"; then
    exit_code=0
    echo "Result:      SUCCESS (exit code: 0)" >> "$SUDO_AUDIT_LOG"
  else
    exit_code=$?
    echo "Result:      FAILED (exit code: $exit_code)" >> "$SUDO_AUDIT_LOG"
  fi
  
  echo "" >> "$SUDO_AUDIT_LOG"
  
  return $exit_code
}

# Run sudo without audit logging (for non-sensitive operations)
# Usage: sudo_quiet command [args...]
sudo_quiet() {
  sudo "$@"
}

# View sudo audit log
# Usage: sudo_audit_view [lines]
sudo_audit_view() {
  local lines="${1:-50}"
  
  if [[ -f "$SUDO_AUDIT_LOG" ]]; then
    msg_info "Last $lines lines of sudo audit log:"
    tail -n "$lines" "$SUDO_AUDIT_LOG"
  else
    msg_warning "No sudo audit log found at: $SUDO_AUDIT_LOG"
  fi
}

# Clear sudo audit log (with confirmation)
# Usage: sudo_audit_clear
sudo_audit_clear() {
  if [[ -f "$SUDO_AUDIT_LOG" ]]; then
    local count
    count=$(grep -c "^Timestamp:" "$SUDO_AUDIT_LOG" 2>/dev/null || echo "0")
    
    msg_warning "This will clear $count sudo audit entries."
    read -r -p "Are you sure? [y/N] " confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      # Archive before clearing
      local archive="${SUDO_AUDIT_LOG}.$(date +%Y%m%d_%H%M%S).bak"
      cp "$SUDO_AUDIT_LOG" "$archive"
      > "$SUDO_AUDIT_LOG"
      msg_success "Audit log cleared. Backup: $archive"
    else
      msg_info "Cancelled."
    fi
  else
    msg_info "No audit log to clear."
  fi
}

# Get sudo audit statistics
# Usage: sudo_audit_stats
sudo_audit_stats() {
  if [[ ! -f "$SUDO_AUDIT_LOG" ]]; then
    msg_info "No sudo audit log found."
    return 0
  fi
  
  local total success failed
  total=$(grep -c "^Timestamp:" "$SUDO_AUDIT_LOG" 2>/dev/null || echo "0")
  success=$(grep -c "Result:.*SUCCESS" "$SUDO_AUDIT_LOG" 2>/dev/null || echo "0")
  failed=$(grep -c "Result:.*FAILED" "$SUDO_AUDIT_LOG" 2>/dev/null || echo "0")
  
  echo ""
  msg_info "📊 Sudo Audit Statistics"
  echo "   Total invocations: $total"
  echo "   ✅ Successful:     $success"
  echo "   ❌ Failed:         $failed"
  echo ""
  echo "   Log file: $SUDO_AUDIT_LOG"
  echo "   Log size: $(du -h "$SUDO_AUDIT_LOG" 2>/dev/null | cut -f1)"
}

# --- S07: Sudo Prompt Confirmation -------------------------------------------

# Destructive operation patterns that require confirmation
SUDO_DESTRUCTIVE_PATTERNS=(
  "rm -rf"
  "rm -r"
  "mkfs"
  "dd if="
  "diskutil eraseDisk"
  "diskutil eraseVolume"
  "srm"
  "shred"
  "wipefs"
  "> /dev/"
  "chmod -R 777"
  "chown -R"
)

# Run a destructive sudo command with explicit confirmation (S07)
# Usage: sudo_confirm "description" [--yes] command [args...]
# If --yes is provided, skips confirmation. Otherwise prompts user.
sudo_confirm() {
  local description="$1"
  shift
  
  local skip_confirm=false
  if [[ "$1" == "--yes" ]] || [[ "$1" == "-y" ]]; then
    skip_confirm=true
    shift
  fi
  
  local cmd="$*"
  
  # Check if this is a destructive operation
  local is_destructive=false
  for pattern in "${SUDO_DESTRUCTIVE_PATTERNS[@]}"; do
    if [[ "$cmd" == *"$pattern"* ]]; then
      is_destructive=true
      break
    fi
  done
  
  # If destructive and no --yes flag, require confirmation
  if [[ "$is_destructive" == "true" ]] && [[ "$skip_confirm" == "false" ]]; then
    echo ""
    msg_warning "⚠️  DESTRUCTIVE OPERATION DETECTED"
    echo ""
    echo "   Description: $description"
    echo "   Command:     sudo $cmd"
    echo ""
    msg_warning "This operation may cause irreversible changes."
    echo ""
    
    # Require typing 'yes' for destructive operations
    read -r -p "Type 'yes' to confirm, or anything else to cancel: " confirm
    
    if [[ "$confirm" != "yes" ]]; then
      msg_info "Operation cancelled."
      security_log "info" "Destructive operation cancelled by user" "$cmd"
      return 1
    fi
    
    security_log "warning" "Destructive operation confirmed" "$cmd"
  fi
  
  # Execute with audit logging
  sudo_audit "$description" "$@"
}

# Check if a command is considered destructive
# Usage: if is_destructive_command "rm -rf /"; then ...
is_destructive_command() {
  local cmd="$*"
  
  for pattern in "${SUDO_DESTRUCTIVE_PATTERNS[@]}"; do
    if [[ "$cmd" == *"$pattern"* ]]; then
      return 0
    fi
  done
  
  return 1
}

# Require --yes flag for a command, or prompt
# Usage: require_confirmation "This will delete files" "$@"
require_confirmation() {
  local message="$1"
  shift
  
  # Check for --yes in remaining args
  local has_yes=false
  for arg in "$@"; do
    if [[ "$arg" == "--yes" ]] || [[ "$arg" == "-y" ]]; then
      has_yes=true
      break
    fi
  done
  
  if [[ "$has_yes" == "false" ]]; then
    echo ""
    msg_warning "$message"
    echo ""
    read -r -p "Continue? [y/N] " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      msg_info "Operation cancelled."
      return 1
    fi
  fi
  
  return 0
}

# --- S08: Privilege Drop After Use ------------------------------------------

# Drop sudo credentials immediately (S08)
# Usage: sudo_drop
# This invalidates the sudo timestamp, requiring password on next sudo
sudo_drop() {
  if sudo -n true 2>/dev/null; then
    sudo -k
    security_log "info" "Sudo credentials dropped" "manual"
    msg_debug "Sudo credentials invalidated."
  fi
}

# Check if we currently have valid sudo credentials
# Usage: if sudo_has_credentials; then ...
sudo_has_credentials() {
  sudo -n true 2>/dev/null
}

# Get sudo credential status
# Usage: sudo_status
sudo_status() {
  if sudo_has_credentials; then
    echo "active"
    return 0
  else
    echo "inactive"
    return 1
  fi
}

# Run commands with automatic privilege drop after completion (S08)
# Usage: with_sudo_scope "description" command [args...]
# Automatically drops sudo credentials when the command completes
with_sudo_scope() {
  local description="$1"
  shift
  
  local exit_code
  
  # Execute with audit logging
  sudo_audit "$description" "$@"
  exit_code=$?
  
  # Always drop privileges after
  sudo_drop
  
  return $exit_code
}

# Run a block of sudo commands with automatic cleanup
# Usage: sudo_scope_start; ..commands..; sudo_scope_end
# Tracks scope depth for nested operations
SUDO_SCOPE_DEPTH=0

sudo_scope_start() {
  ((SUDO_SCOPE_DEPTH++))
  security_log "info" "Sudo scope started" "depth=$SUDO_SCOPE_DEPTH"
}

sudo_scope_end() {
  ((SUDO_SCOPE_DEPTH--))
  
  # Only drop credentials when we exit the outermost scope
  if [[ $SUDO_SCOPE_DEPTH -le 0 ]]; then
    SUDO_SCOPE_DEPTH=0
    sudo_drop
    security_log "info" "Sudo scope ended, credentials dropped" ""
  fi
}

# Register cleanup on script exit (call once at script start)
# Usage: sudo_register_cleanup
sudo_register_cleanup() {
  trap 'sudo_drop' EXIT INT TERM
  security_log "info" "Sudo cleanup trap registered" ""
}

# --- S09: sudoers Integrity Check -------------------------------------------

# Baseline file for sudoers hash
SUDOERS_BASELINE="${CIRCUS_SUDOERS_BASELINE:-$HOME/.circus/sudoers_baseline}"

# Calculate hash of sudoers file(s)
# Usage: sudoers_hash
# Returns SHA256 hash of /etc/sudoers and /etc/sudoers.d/* combined
sudoers_hash() {
  local hash_input=""
  
  # Hash main sudoers file
  if [[ -r /etc/sudoers ]]; then
    hash_input+=$(sudo cat /etc/sudoers 2>/dev/null | shasum -a 256)
  fi
  
  # Hash sudoers.d directory contents
  if [[ -d /etc/sudoers.d ]]; then
    for file in /etc/sudoers.d/*; do
      if [[ -f "$file" && -r "$file" ]]; then
        hash_input+=$(sudo cat "$file" 2>/dev/null | shasum -a 256)
      fi
    done
  fi
  
  # Return combined hash
  echo "$hash_input" | shasum -a 256 | awk '{print $1}'
}

# Save current sudoers hash as baseline (S09)
# Usage: sudoers_baseline_save
sudoers_baseline_save() {
  mkdir -p "$(dirname "$SUDOERS_BASELINE")" 2>/dev/null
  
  local current_hash
  current_hash=$(sudoers_hash)
  
  if [[ -z "$current_hash" ]]; then
    msg_error "Failed to calculate sudoers hash"
    return 1
  fi
  
  # Save with timestamp
  {
    echo "# Sudoers baseline - DO NOT EDIT"
    echo "# Created: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "# User: ${USER:-$(whoami)}"
    echo "hash=$current_hash"
  } > "$SUDOERS_BASELINE"
  
  chmod 600 "$SUDOERS_BASELINE"
  
  msg_success "Sudoers baseline saved."
  security_log "info" "Sudoers baseline created" "hash=$current_hash"
}

# Check if sudoers has been modified since baseline (S09)
# Usage: if sudoers_check; then ... (returns 0 if unchanged, 1 if modified)
sudoers_check() {
  if [[ ! -f "$SUDOERS_BASELINE" ]]; then
    msg_warning "No sudoers baseline found. Run 'sudoers_baseline_save' first."
    return 2
  fi
  
  local baseline_hash current_hash
  baseline_hash=$(grep "^hash=" "$SUDOERS_BASELINE" 2>/dev/null | cut -d= -f2)
  current_hash=$(sudoers_hash)
  
  if [[ -z "$baseline_hash" ]]; then
    msg_error "Invalid baseline file"
    return 2
  fi
  
  if [[ "$current_hash" == "$baseline_hash" ]]; then
    return 0  # Unchanged
  else
    return 1  # Modified
  fi
}

# Verify sudoers integrity before running a privileged command (S09)
# Usage: sudoers_verify_before "description" command [args...]
# Aborts if sudoers has been modified since baseline
sudoers_verify_before() {
  local description="$1"
  shift
  
  # Skip check if no baseline exists
  if [[ ! -f "$SUDOERS_BASELINE" ]]; then
    msg_debug "No sudoers baseline - skipping integrity check"
    sudo_audit "$description" "$@"
    return $?
  fi
  
  # Check integrity
  if ! sudoers_check; then
    echo ""
    msg_error "⚠️  SUDOERS FILE MODIFIED"
    echo ""
    echo "   The /etc/sudoers file has been modified since the baseline was saved."
    echo "   This could indicate unauthorized access or tampering."
    echo ""
    echo "   Options:"
    echo "   1. Investigate the changes before proceeding"
    echo "   2. Run 'sudoers_baseline_save' to update baseline if changes are expected"
    echo ""
    
    security_log "critical" "Sudoers integrity check FAILED" "$description"
    
    read -r -p "Continue anyway? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      msg_info "Operation aborted."
      return 1
    fi
    
    security_log "warning" "User bypassed sudoers integrity check" "$description"
  fi
  
  sudo_audit "$description" "$@"
}

# Show sudoers baseline info
# Usage: sudoers_baseline_info
sudoers_baseline_info() {
  if [[ ! -f "$SUDOERS_BASELINE" ]]; then
    msg_info "No sudoers baseline found."
    echo "   Run 'sudoers_baseline_save' to create one."
    return 0
  fi
  
  echo ""
  msg_info "📋 Sudoers Baseline Info"
  echo ""
  grep -v "^#" "$SUDOERS_BASELINE" | head -5
  echo ""
  echo "   Baseline file: $SUDOERS_BASELINE"
  echo "   Created: $(grep "^# Created:" "$SUDOERS_BASELINE" | cut -d: -f2-)"
  echo ""
  
  if sudoers_check; then
    msg_success "✅ Sudoers unchanged since baseline"
  else
    msg_warning "⚠️  Sudoers has been MODIFIED since baseline"
  fi
}

# --- S11: Secure Temp Files -------------------------------------------------

# Global array to track temp files for cleanup
declare -a SECURE_TEMP_FILES=()

# Create a secure temp file with restrictive permissions (S11)
# Usage: tmpfile=$(secure_mktemp)
# Creates file with 0600 permissions (owner read/write only)
secure_mktemp() {
  local prefix="${1:-circus}"
  local tmpfile
  
  # Create temp file
  tmpfile=$(mktemp -t "${prefix}.XXXXXXXXXX") || {
    msg_error "Failed to create secure temp file"
    return 1
  }
  
  # Set restrictive permissions (owner read/write only)
  chmod 600 "$tmpfile" || {
    rm -f "$tmpfile"
    msg_error "Failed to set permissions on temp file"
    return 1
  }
  
  # Track for cleanup
  SECURE_TEMP_FILES+=("$tmpfile")
  
  echo "$tmpfile"
}

# Create a secure temp directory with restrictive permissions (S11)
# Usage: tmpdir=$(secure_mktemp_dir)
# Creates directory with 0700 permissions (owner only)
secure_mktemp_dir() {
  local prefix="${1:-circus}"
  local tmpdir
  
  # Create temp directory
  tmpdir=$(mktemp -d -t "${prefix}.XXXXXXXXXX") || {
    msg_error "Failed to create secure temp directory"
    return 1
  }
  
  # Set restrictive permissions (owner only)
  chmod 700 "$tmpdir" || {
    rm -rf "$tmpdir"
    msg_error "Failed to set permissions on temp directory"
    return 1
  }
  
  # Track for cleanup
  SECURE_TEMP_FILES+=("$tmpdir")
  
  echo "$tmpdir"
}

# Clean up all tracked temp files/directories
# Usage: secure_temp_cleanup
secure_temp_cleanup() {
  local item
  for item in "${SECURE_TEMP_FILES[@]}"; do
    if [[ -e "$item" ]]; then
      rm -rf "$item" 2>/dev/null
    fi
  done
  SECURE_TEMP_FILES=()
}

# Register automatic temp file cleanup on script exit
# Usage: secure_temp_register_cleanup (call once at script start)
secure_temp_register_cleanup() {
  trap 'secure_temp_cleanup' EXIT INT TERM
}

# Create a temp file that auto-cleans on subshell exit
# Usage: with_secure_temp varname command
# Example: with_secure_temp MYTEMP cat "$MYTEMP"
with_secure_temp() {
  local -n _var_ref="$1"
  shift
  
  _var_ref=$(secure_mktemp)
  local _tmpfile="$_var_ref"
  
  # Run command
  "$@"
  local _exit_code=$?
  
  # Cleanup
  rm -f "$_tmpfile" 2>/dev/null
  
  return $_exit_code
}

# Verify temp file has correct permissions
# Usage: if verify_temp_permissions "$file"; then ...
verify_temp_permissions() {
  local file="$1"
  local perms
  
  if [[ ! -e "$file" ]]; then
    return 1
  fi
  
  # Get permissions in octal
  if [[ -d "$file" ]]; then
    perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
    [[ "$perms" == "700" ]]
  else
    perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
    [[ "$perms" == "600" ]]
  fi
}

# --- S12: Symlink Attack Prevention -----------------------------------------

# Check if path is a symlink (S12)
# Usage: if is_symlink "/path/to/file"; then ...
is_symlink() {
  [[ -L "$1" ]]
}

# Safely check and refuse to write to symlinks (S12)
# Usage: if safe_write_check "/path/to/file"; then echo "data" > file; fi
# Returns 0 if safe to write, 1 if symlink or unsafe
safe_write_check() {
  local path="$1"
  
  # Check for symlink
  if is_symlink "$path"; then
    msg_error "Security: Refusing to write to symlink: $path"
    security_log "warning" "Blocked write to symlink" "$path"
    return 1
  fi
  
  # Check parent directory for symlink
  local parent_dir
  parent_dir=$(dirname "$path")
  if is_symlink "$parent_dir"; then
    msg_error "Security: Parent directory is a symlink: $parent_dir"
    security_log "warning" "Parent directory is symlink" "$parent_dir"
    return 1
  fi
  
  return 0
}

# Safe write to file with symlink check (S12)
# Usage: safe_write "content" "/path/to/file"
# Refuses to write if target is a symlink
safe_write() {
  local content="$1"
  local path="$2"
  
  if ! safe_write_check "$path"; then
    return 1
  fi
  
  # If file exists, check it's not a symlink
  if [[ -e "$path" ]] && is_symlink "$path"; then
    msg_error "Security: Target became a symlink (race condition detected)"
    security_log "critical" "TOCTOU race condition detected" "$path"
    return 1
  fi
  
  echo "$content" > "$path"
}

# Atomic write to file (write to temp, then move) (S12)
# Usage: atomic_write "content" "/path/to/file"
# Prevents partial writes and reduces TOCTOU window
atomic_write() {
  local content="$1"
  local path="$2"
  
  if ! safe_write_check "$path"; then
    return 1
  fi
  
  # Create temp file in same directory (for atomic rename)
  local dir
  dir=$(dirname "$path")
  local tmpfile
  tmpfile=$(mktemp "${dir}/.tmp.XXXXXXXXXX") || {
    msg_error "Failed to create temp file for atomic write"
    return 1
  }
  
  chmod 600 "$tmpfile"
  
  # Write to temp file
  echo "$content" > "$tmpfile" || {
    rm -f "$tmpfile"
    return 1
  }
  
  # Atomic move (rename is atomic on same filesystem)
  mv "$tmpfile" "$path" || {
    rm -f "$tmpfile"
    msg_error "Failed to atomically move temp file"
    return 1
  }
  
  security_log "info" "Atomic write completed" "$path"
}

# Safe append to file with symlink check (S12)
# Usage: safe_append "content" "/path/to/file"
safe_append() {
  local content="$1"
  local path="$2"
  
  if ! safe_write_check "$path"; then
    return 1
  fi
  
  echo "$content" >> "$path"
}

# Get real path (resolving all symlinks) and verify safety
# Usage: real_path=$(get_real_path "/path/with/symlinks")
get_real_path() {
  local path="$1"
  local real
  
  # Use readlink -f on Linux, or manual resolution on macOS
  if readlink -f "$path" 2>/dev/null; then
    return 0
  fi
  
  # macOS fallback
  local current="$path"
  while [[ -L "$current" ]]; do
    local link_target
    link_target=$(readlink "$current")
    if [[ "$link_target" == /* ]]; then
      current="$link_target"
    else
      current="$(dirname "$current")/$link_target"
    fi
  done
  
  # Normalize path
  echo "$(cd "$(dirname "$current")" 2>/dev/null && pwd -P)/$(basename "$current")"
}

# --- Exports ----------------------------------------------------------------

export -f sanitize_string escape_for_shell sanitize_domain
export -f sanitize_package_name sanitize_path validate_url
export -f check_not_root sanitize_defaults_value security_check_input
export -f security_log
export -f validate_path resolve_path_secure is_within_allowed_paths
export -f check_symlink_target is_path_safe validate_config_path
export -f is_yaml_safe sanitize_yaml_value validate_yaml_security safe_yaml_get
export -f sudo_audit sudo_quiet sudo_audit_view sudo_audit_clear sudo_audit_stats
export -f sudo_confirm is_destructive_command require_confirmation
export -f sudo_drop sudo_has_credentials sudo_status
export -f with_sudo_scope sudo_scope_start sudo_scope_end sudo_register_cleanup
export -f sudoers_hash sudoers_baseline_save sudoers_check sudoers_verify_before sudoers_baseline_info
export -f die_if_root is_root require_non_root get_real_user
export -f secure_mktemp secure_mktemp_dir secure_temp_cleanup secure_temp_register_cleanup
export -f with_secure_temp verify_temp_permissions
export -f is_symlink safe_write_check safe_write atomic_write safe_append get_real_path
export SUDO_AUDIT_LOG SUDO_SCOPE_DEPTH SUDOERS_BASELINE SECURE_TEMP_FILES
