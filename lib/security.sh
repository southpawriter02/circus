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

# --- S13: Config File Permissions Check -------------------------------------

# Check if file has insecure permissions (S13)
# Usage: if is_world_writable "/path/to/file"; then ...
is_world_writable() {
  local file="$1"
  
  if [[ ! -e "$file" ]]; then
    return 1
  fi
  
  # Get permissions - macOS uses stat -f, Linux uses stat -c
  local perms
  perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
  
  # Check if world-writable (last digit is 2, 3, 6, or 7)
  local world_perm="${perms: -1}"
  [[ "$world_perm" =~ [2367] ]]
}

# Check if file is group-writable (S13)
# Usage: if is_group_writable "/path/to/file"; then ...
is_group_writable() {
  local file="$1"
  
  if [[ ! -e "$file" ]]; then
    return 1
  fi
  
  local perms
  perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
  
  # Check if group-writable (middle digit is 2, 3, 6, or 7)
  local group_perm="${perms:1:1}"
  [[ "$group_perm" =~ [2367] ]]
}

# Check config file permissions and warn if insecure (S13)
# Usage: check_config_permissions "/path/to/config.yaml"
# Returns 0 if secure, 1 if warnings found
check_config_permissions() {
  local file="$1"
  local warnings=0
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 2
  fi
  
  local perms
  perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
  
  # Check world-writable
  if is_world_writable "$file"; then
    msg_warning "⚠️  Config file is WORLD-WRITABLE: $file (perms: $perms)"
    security_log "warning" "World-writable config file" "$file ($perms)"
    ((warnings++))
  fi
  
  # Check group-writable
  if is_group_writable "$file"; then
    msg_warning "⚠️  Config file is group-writable: $file (perms: $perms)"
    security_log "info" "Group-writable config file" "$file ($perms)"
    ((warnings++))
  fi
  
  # Check for recommended permissions (600 or 644)
  if [[ ! "$perms" =~ ^(600|644|640)$ ]]; then
    msg_info "   Recommended: chmod 600 or 644 for config files"
  fi
  
  [[ $warnings -eq 0 ]]
}

# Scan directory for insecure config files (S13)
# Usage: scan_config_permissions "/path/to/configs" [extension]
scan_config_permissions() {
  local dir="$1"
  local ext="${2:-yaml}"
  local issues=0
  
  if [[ ! -d "$dir" ]]; then
    msg_error "Directory not found: $dir"
    return 2
  fi
  
  msg_info "Scanning for insecure config permissions in: $dir"
  echo ""
  
  while IFS= read -r -d '' file; do
    if ! check_config_permissions "$file"; then
      ((issues++))
    fi
  done < <(find "$dir" -name "*.$ext" -print0 2>/dev/null)
  
  echo ""
  if [[ $issues -gt 0 ]]; then
    msg_warning "Found $issues file(s) with insecure permissions."
    return 1
  else
    msg_success "All config files have secure permissions."
    return 0
  fi
}

# Fix insecure permissions on config file (S13)
# Usage: fix_config_permissions "/path/to/config.yaml" [mode]
fix_config_permissions() {
  local file="$1"
  local mode="${2:-600}"
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  local old_perms
  old_perms=$(stat -f "%Lp" "$file" 2>/dev/null || stat -c "%a" "$file" 2>/dev/null)
  
  chmod "$mode" "$file" || {
    msg_error "Failed to change permissions on: $file"
    return 1
  }
  
  msg_success "Fixed permissions: $file ($old_perms -> $mode)"
  security_log "info" "Fixed config permissions" "$file ($old_perms -> $mode)"
}

# Verify config file is owned by current user (S13)
# Usage: if check_config_owner "/path/to/config"; then ...
check_config_owner() {
  local file="$1"
  
  if [[ ! -e "$file" ]]; then
    return 1
  fi
  
  local file_owner
  file_owner=$(stat -f "%Su" "$file" 2>/dev/null || stat -c "%U" "$file" 2>/dev/null)
  local current_user
  current_user=$(get_real_user)
  
  if [[ "$file_owner" != "$current_user" ]]; then
    msg_warning "Config file owned by '$file_owner', not '$current_user': $file"
    security_log "warning" "Config file ownership mismatch" "$file (owner: $file_owner)"
    return 1
  fi
  
  return 0
}

# --- S14: Backup Encryption -------------------------------------------------

# Check if GPG is available
# Usage: if has_gpg; then ...
has_gpg() {
  command -v gpg &>/dev/null
}

# Encrypt a file using GPG symmetric encryption (S14)
# Usage: encrypt_backup "/path/to/file" [output_path]
# Creates .gpg encrypted file, removes original by default
encrypt_backup() {
  local input="$1"
  local output="${2:-${input}.gpg}"
  
  if [[ ! -f "$input" ]]; then
    msg_error "File not found: $input"
    return 1
  fi
  
  if ! has_gpg; then
    msg_error "GPG not found. Install with: brew install gnupg"
    return 1
  fi
  
  # Use symmetric encryption with AES256
  if gpg --symmetric --cipher-algo AES256 --batch --yes -o "$output" "$input"; then
    chmod 600 "$output"
    msg_success "Encrypted: $input -> $output"
    security_log "info" "Backup encrypted" "$input"
    return 0
  else
    msg_error "Encryption failed: $input"
    security_log "error" "Backup encryption failed" "$input"
    return 1
  fi
}

# Decrypt a GPG-encrypted backup file (S14)
# Usage: decrypt_backup "/path/to/file.gpg" [output_path]
decrypt_backup() {
  local input="$1"
  local output="${2:-${input%.gpg}}"
  
  if [[ ! -f "$input" ]]; then
    msg_error "Encrypted file not found: $input"
    return 1
  fi
  
  if ! has_gpg; then
    msg_error "GPG not found. Install with: brew install gnupg"
    return 1
  fi
  
  if gpg --decrypt --batch --yes -o "$output" "$input"; then
    chmod 600 "$output"
    msg_success "Decrypted: $input -> $output"
    security_log "info" "Backup decrypted" "$input"
    return 0
  else
    msg_error "Decryption failed: $input"
    security_log "error" "Backup decryption failed" "$input"
    return 1
  fi
}

# Encrypt a backup and securely delete original (S14)
# Usage: encrypt_and_shred "/path/to/sensitive_file"
encrypt_and_shred() {
  local input="$1"
  local output="${2:-${input}.gpg}"
  
  if encrypt_backup "$input" "$output"; then
    # Securely delete original
    if command -v srm &>/dev/null; then
      srm -z "$input"
    elif command -v shred &>/dev/null; then
      shred -u -z "$input"
    else
      # Fallback: overwrite with zeros, then delete
      dd if=/dev/zero of="$input" bs=1k count=$(( $(stat -f%z "$input" 2>/dev/null || stat -c%s "$input" 2>/dev/null) / 1024 + 1 )) 2>/dev/null
      rm -f "$input"
    fi
    msg_success "Original securely deleted: $input"
    security_log "info" "Encrypted and shredded" "$input"
    return 0
  else
    return 1
  fi
}

# Create encrypted backup archive (S14)
# Usage: create_encrypted_backup "/path/to/dir_or_file" "/path/to/output.tar.gpg"
create_encrypted_backup() {
  local source="$1"
  local output="$2"
  
  if [[ ! -e "$source" ]]; then
    msg_error "Source not found: $source"
    return 1
  fi
  
  if ! has_gpg; then
    msg_error "GPG not found. Install with: brew install gnupg"
    return 1
  fi
  
  local tmpfile
  tmpfile=$(secure_mktemp "backup")
  
  # Create tar archive
  if tar -czf "$tmpfile" -C "$(dirname "$source")" "$(basename "$source")"; then
    # Encrypt the archive
    if encrypt_backup "$tmpfile" "$output"; then
      rm -f "$tmpfile"
      msg_success "Created encrypted backup: $output"
      return 0
    fi
  fi
  
  rm -f "$tmpfile"
  msg_error "Failed to create encrypted backup"
  return 1
}

# Restore from encrypted backup archive (S14)
# Usage: restore_encrypted_backup "/path/to/backup.tar.gpg" "/path/to/restore_dir"
restore_encrypted_backup() {
  local input="$1"
  local dest="$2"
  
  if [[ ! -f "$input" ]]; then
    msg_error "Backup file not found: $input"
    return 1
  fi
  
  if ! has_gpg; then
    msg_error "GPG not found"
    return 1
  fi
  
  local tmpfile
  tmpfile=$(secure_mktemp "restore")
  
  # Decrypt the archive
  if decrypt_backup "$input" "$tmpfile"; then
    # Extract to destination
    mkdir -p "$dest"
    if tar -xzf "$tmpfile" -C "$dest"; then
      rm -f "$tmpfile"
      msg_success "Restored backup to: $dest"
      security_log "info" "Backup restored" "$input -> $dest"
      return 0
    fi
  fi
  
  rm -f "$tmpfile"
  msg_error "Failed to restore backup"
  return 1
}

# Check if a file is GPG encrypted (S14)
# Usage: if is_encrypted "/path/to/file"; then ...
is_encrypted() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  
  # Check file magic bytes for GPG
  local magic
  magic=$(head -c 3 "$file" 2>/dev/null | od -A n -t x1 | tr -d ' ')
  
  # GPG encrypted files start with specific bytes
  [[ "$magic" == "8c0d04" ]] || [[ "$magic" == "850104" ]] || [[ "${file##*.}" == "gpg" ]]
}

# --- S15: Secure Delete for Secrets -----------------------------------------

# Check which secure delete tool is available
# Usage: tool=$(get_secure_delete_tool)
get_secure_delete_tool() {
  if command -v srm &>/dev/null; then
    echo "srm"
  elif command -v shred &>/dev/null; then
    echo "shred"
  elif command -v gshred &>/dev/null; then
    echo "gshred"
  else
    echo "fallback"
  fi
}

# Securely delete a file (S15)
# Usage: secure_delete "/path/to/secret_file"
# Overwrites file content before deletion
secure_delete() {
  local file="$1"
  local passes="${2:-3}"
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  local tool
  tool=$(get_secure_delete_tool)
  
  case "$tool" in
    srm)
      # macOS secure remove (if installed via brew)
      srm -z "$file" && {
        msg_success "Securely deleted (srm): $file"
        security_log "info" "Secure delete (srm)" "$file"
        return 0
      }
      ;;
    shred|gshred)
      # GNU shred
      "$tool" -u -z -n "$passes" "$file" && {
        msg_success "Securely deleted (shred): $file"
        security_log "info" "Secure delete (shred)" "$file"
        return 0
      }
      ;;
    fallback)
      # Manual overwrite fallback
      _secure_delete_fallback "$file" "$passes" && {
        msg_success "Securely deleted (fallback): $file"
        security_log "info" "Secure delete (fallback)" "$file"
        return 0
      }
      ;;
  esac
  
  msg_error "Secure delete failed: $file"
  security_log "error" "Secure delete failed" "$file"
  return 1
}

# Fallback secure delete implementation (S15)
# Overwrites with random data, zeros, then deletes
_secure_delete_fallback() {
  local file="$1"
  local passes="${2:-3}"
  
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  
  local size
  size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
  
  if [[ -z "$size" || "$size" -eq 0 ]]; then
    rm -f "$file"
    return 0
  fi
  
  # Multiple overwrite passes
  for ((i = 1; i <= passes; i++)); do
    # Overwrite with random data
    dd if=/dev/urandom of="$file" bs=1 count="$size" conv=notrunc 2>/dev/null
  done
  
  # Final zero pass
  dd if=/dev/zero of="$file" bs=1 count="$size" conv=notrunc 2>/dev/null
  
  # Delete the file
  rm -f "$file"
}

# Securely delete a directory recursively (S15)
# Usage: secure_delete_dir "/path/to/secret_dir"
secure_delete_dir() {
  local dir="$1"
  local passes="${2:-3}"
  
  if [[ ! -d "$dir" ]]; then
    msg_error "Directory not found: $dir"
    return 1
  fi
  
  local errors=0
  
  # First, securely delete all files
  while IFS= read -r -d '' file; do
    if ! secure_delete "$file" "$passes"; then
      ((errors++))
    fi
  done < <(find "$dir" -type f -print0 2>/dev/null)
  
  # Then remove empty directories
  rm -rf "$dir" 2>/dev/null
  
  if [[ $errors -eq 0 ]]; then
    msg_success "Securely deleted directory: $dir"
    security_log "info" "Secure delete directory" "$dir"
    return 0
  else
    msg_warning "Deleted with $errors errors: $dir"
    return 1
  fi
}

# Securely clear file contents without deleting (S15)
# Usage: secure_clear "/path/to/secret_file"
secure_clear() {
  local file="$1"
  local passes="${2:-3}"
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  local size
  size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
  
  if [[ -z "$size" || "$size" -eq 0 ]]; then
    return 0
  fi
  
  # Overwrite passes
  for ((i = 1; i <= passes; i++)); do
    dd if=/dev/urandom of="$file" bs=1 count="$size" conv=notrunc 2>/dev/null
  done
  
  # Truncate to zero
  : > "$file"
  
  msg_success "Securely cleared: $file"
  security_log "info" "Secure clear" "$file"
}

# Secure delete with confirmation (S15)
# Usage: secure_delete_confirm "/path/to/file"
secure_delete_confirm() {
  local file="$1"
  
  if [[ ! -e "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  echo ""
  msg_warning "⚠️  SECURE DELETE"
  echo ""
  echo "   Target: $file"
  echo "   This will permanently and irrecoverably delete this file."
  echo ""
  
  read -r -p "Type 'DELETE' to confirm: " confirm
  
  if [[ "$confirm" != "DELETE" ]]; then
    msg_info "Operation cancelled."
    return 1
  fi
  
  if [[ -d "$file" ]]; then
    secure_delete_dir "$file"
  else
    secure_delete "$file"
  fi
}

# --- S16: Config File Signing -----------------------------------------------

# Default trusted key ID for signing (can be overridden)
CIRCUS_SIGNING_KEY="${CIRCUS_SIGNING_KEY:-}"

# Sign a config file with GPG (S16)
# Usage: sign_config "/path/to/config.yaml"
# Creates a detached signature file: config.yaml.sig
sign_config() {
  local file="$1"
  local key="${2:-$CIRCUS_SIGNING_KEY}"
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  if ! has_gpg; then
    msg_error "GPG not found. Install with: brew install gnupg"
    return 1
  fi
  
  local sig_file="${file}.sig"
  local gpg_args=(--detach-sign --armor -o "$sig_file")
  
  # Use specific key if provided
  if [[ -n "$key" ]]; then
    gpg_args+=(--local-user "$key")
  fi
  
  if gpg "${gpg_args[@]}" "$file"; then
    chmod 644 "$sig_file"
    msg_success "Signed: $file -> $sig_file"
    security_log "info" "Config file signed" "$file"
    return 0
  else
    msg_error "Signing failed: $file"
    security_log "error" "Config signing failed" "$file"
    return 1
  fi
}

# Verify a config file signature (S16)
# Usage: if verify_config_signature "/path/to/config.yaml"; then ...
# Looks for config.yaml.sig in same directory
verify_config_signature() {
  local file="$1"
  local sig_file="${2:-${file}.sig}"
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  if [[ ! -f "$sig_file" ]]; then
    msg_warning "No signature file found: $sig_file"
    return 2
  fi
  
  if ! has_gpg; then
    msg_error "GPG not found"
    return 1
  fi
  
  if gpg --verify "$sig_file" "$file" 2>/dev/null; then
    msg_success "✅ Signature valid: $file"
    security_log "info" "Config signature verified" "$file"
    return 0
  else
    msg_error "❌ INVALID SIGNATURE: $file"
    security_log "critical" "Config signature INVALID" "$file"
    return 1
  fi
}

# Verify signature before applying config (S16)
# Usage: verify_before_apply "/path/to/config.yaml" apply_function
# Aborts if signature is missing or invalid (unless bypassed)
verify_before_apply() {
  local file="$1"
  shift
  
  local sig_file="${file}.sig"
  
  # Check if signature exists
  if [[ ! -f "$sig_file" ]]; then
    msg_warning "⚠️  No signature found for: $file"
    echo ""
    echo "   This config file is not signed."
    echo "   To sign: sign_config \"$file\""
    echo ""
    
    read -r -p "Apply unsigned config? [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      msg_info "Operation cancelled."
      return 1
    fi
    
    security_log "warning" "Applied unsigned config" "$file"
    "$@"
    return $?
  fi
  
  # Verify signature
  if verify_config_signature "$file" "$sig_file"; then
    "$@"
    return $?
  else
    echo ""
    msg_error "SIGNATURE VERIFICATION FAILED"
    echo ""
    echo "   File: $file"
    echo "   The signature is invalid or the file has been modified."
    echo "   This could indicate tampering."
    echo ""
    
    read -r -p "Apply anyway? (DANGEROUS) [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      security_log "critical" "Applied config with INVALID signature" "$file"
      "$@"
      return $?
    else
      msg_info "Operation cancelled."
      return 1
    fi
  fi
}

# List GPG keys available for signing (S16)
# Usage: list_signing_keys
list_signing_keys() {
  if ! has_gpg; then
    msg_error "GPG not found"
    return 1
  fi
  
  msg_info "Available signing keys:"
  echo ""
  gpg --list-secret-keys --keyid-format LONG 2>/dev/null
}

# Check if a config file is signed (S16)
# Usage: if is_config_signed "/path/to/config.yaml"; then ...
is_config_signed() {
  local file="$1"
  [[ -f "${file}.sig" ]]
}

# Sign all config files in a directory (S16)
# Usage: sign_all_configs "/path/to/configs" [key_id]
sign_all_configs() {
  local dir="$1"
  local key="${2:-$CIRCUS_SIGNING_KEY}"
  
  if [[ ! -d "$dir" ]]; then
    msg_error "Directory not found: $dir"
    return 1
  fi
  
  local signed=0
  local failed=0
  
  while IFS= read -r -d '' file; do
    if sign_config "$file" "$key"; then
      ((signed++))
    else
      ((failed++))
    fi
  done < <(find "$dir" -name "*.yaml" -o -name "*.yml" | tr '\n' '\0')
  
  echo ""
  msg_info "Signed $signed config file(s), $failed failed."
}

# Verify all config signatures in a directory (S16)
# Usage: verify_all_configs "/path/to/configs"
verify_all_configs() {
  local dir="$1"
  
  if [[ ! -d "$dir" ]]; then
    msg_error "Directory not found: $dir"
    return 1
  fi
  
  local verified=0
  local unsigned=0
  local invalid=0
  
  while IFS= read -r -d '' file; do
    if [[ -f "${file}.sig" ]]; then
      if verify_config_signature "$file" "${file}.sig"; then
        ((verified++))
      else
        ((invalid++))
      fi
    else
      msg_info "Unsigned: $file"
      ((unsigned++))
    fi
  done < <(find "$dir" -name "*.yaml" -o -name "*.yml" | tr '\n' '\0')
  
  echo ""
  msg_info "Results: $verified verified, $unsigned unsigned, $invalid invalid"
  
  [[ $invalid -eq 0 ]]
}

# --- S17: Script Integrity Hashes -------------------------------------------

# Default hash manifest file location
SCRIPT_HASH_MANIFEST="${CIRCUS_HASH_MANIFEST:-$HOME/.circus/script_hashes.sha256}"

# Calculate SHA256 hash of a file (S17)
# Usage: hash=$(file_hash "/path/to/script.sh")
file_hash() {
  local file="$1"
  
  if [[ ! -f "$file" ]]; then
    return 1
  fi
  
  shasum -a 256 "$file" 2>/dev/null | awk '{print $1}'
}

# Generate hash manifest for all scripts (S17)
# Usage: generate_hash_manifest "/path/to/scripts" [output_file]
generate_hash_manifest() {
  local dir="${1:-$DOTFILES_ROOT}"
  local output="${2:-$SCRIPT_HASH_MANIFEST}"
  
  if [[ ! -d "$dir" ]]; then
    msg_error "Directory not found: $dir"
    return 1
  fi
  
  mkdir -p "$(dirname "$output")"
  
  {
    echo "# Script Integrity Manifest"
    echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "# Directory: $dir"
    echo "#"
    
    # Hash all shell scripts
    find "$dir" -type f \( -name "*.sh" -o -name "fc-*" \) -not -path "*/.git/*" | sort | while read -r file; do
      local hash
      hash=$(file_hash "$file")
      if [[ -n "$hash" ]]; then
        # Store relative path from dir
        local rel_path="${file#$dir/}"
        echo "$hash  $rel_path"
      fi
    done
  } > "$output"
  
  chmod 600 "$output"
  
  local count
  count=$(grep -v "^#" "$output" | wc -l | tr -d ' ')
  
  msg_success "Generated hash manifest: $output ($count files)"
  security_log "info" "Hash manifest generated" "$output ($count files)"
}

# Verify scripts against hash manifest (S17)
# Usage: if verify_script_integrity; then ...
verify_script_integrity() {
  local dir="${1:-$DOTFILES_ROOT}"
  local manifest="${2:-$SCRIPT_HASH_MANIFEST}"
  
  if [[ ! -f "$manifest" ]]; then
    msg_warning "No hash manifest found: $manifest"
    msg_info "Generate one with: generate_hash_manifest"
    return 2
  fi
  
  local modified=0
  local missing=0
  local verified=0
  
  msg_info "Verifying script integrity..."
  
  while IFS= read -r line; do
    # Skip comments
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue
    
    local stored_hash file_path
    stored_hash=$(echo "$line" | awk '{print $1}')
    file_path=$(echo "$line" | awk '{print $2}')
    
    local full_path="$dir/$file_path"
    
    if [[ ! -f "$full_path" ]]; then
      msg_warning "  MISSING: $file_path"
      ((missing++))
      continue
    fi
    
    local current_hash
    current_hash=$(file_hash "$full_path")
    
    if [[ "$current_hash" == "$stored_hash" ]]; then
      ((verified++))
    else
      msg_error "  MODIFIED: $file_path"
      ((modified++))
    fi
  done < "$manifest"
  
  echo ""
  msg_info "Results: $verified verified, $modified modified, $missing missing"
  
  if [[ $modified -gt 0 ]]; then
    security_log "critical" "Script integrity check FAILED" "$modified modified files"
    return 1
  elif [[ $missing -gt 0 ]]; then
    security_log "warning" "Script integrity check incomplete" "$missing missing files"
    return 1
  else
    security_log "info" "Script integrity verified" "$verified files OK"
    return 0
  fi
}

# Verify a single script against manifest (S17)
# Usage: if verify_single_script "/path/to/script.sh"; then ...
verify_single_script() {
  local file="$1"
  local manifest="${2:-$SCRIPT_HASH_MANIFEST}"
  local dir="${3:-$DOTFILES_ROOT}"
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  if [[ ! -f "$manifest" ]]; then
    return 2  # No manifest
  fi
  
  local rel_path="${file#$dir/}"
  local stored_hash
  stored_hash=$(grep "  $rel_path$" "$manifest" | awk '{print $1}')
  
  if [[ -z "$stored_hash" ]]; then
    msg_warning "Script not in manifest: $file"
    return 2
  fi
  
  local current_hash
  current_hash=$(file_hash "$file")
  
  if [[ "$current_hash" == "$stored_hash" ]]; then
    return 0
  else
    msg_error "Script integrity FAILED: $file"
    security_log "critical" "Single script integrity FAILED" "$file"
    return 1
  fi
}

# Show manifest info (S17)
# Usage: show_hash_manifest
show_hash_manifest() {
  local manifest="${1:-$SCRIPT_HASH_MANIFEST}"
  
  if [[ ! -f "$manifest" ]]; then
    msg_info "No hash manifest found."
    echo "   Generate with: generate_hash_manifest"
    return 0
  fi
  
  echo ""
  msg_info "📋 Script Hash Manifest"
  echo ""
  grep "^#" "$manifest" | sed 's/^# /   /'
  echo ""
  
  local count
  count=$(grep -v "^#" "$manifest" | wc -l | tr -d ' ')
  echo "   Total files: $count"
  echo "   Location: $manifest"
}

# Update hash for a single modified script (S17)
# Usage: update_script_hash "/path/to/script.sh"
update_script_hash() {
  local file="$1"
  local manifest="${2:-$SCRIPT_HASH_MANIFEST}"
  local dir="${3:-$DOTFILES_ROOT}"
  
  if [[ ! -f "$file" ]]; then
    msg_error "File not found: $file"
    return 1
  fi
  
  if [[ ! -f "$manifest" ]]; then
    msg_error "No manifest found. Generate one first."
    return 1
  fi
  
  local rel_path="${file#$dir/}"
  local new_hash
  new_hash=$(file_hash "$file")
  
  # Check if entry exists
  if grep -q "  $rel_path$" "$manifest"; then
    # Update existing entry
    sed -i '' "s|^[a-f0-9]*  $rel_path$|$new_hash  $rel_path|" "$manifest"
    msg_success "Updated hash: $rel_path"
  else
    # Add new entry
    echo "$new_hash  $rel_path" >> "$manifest"
    msg_success "Added hash: $rel_path"
  fi
  
  security_log "info" "Script hash updated" "$rel_path"
}

# --- S18: Homebrew Tap Verification -----------------------------------------

# Default trusted taps (official Homebrew taps)
TRUSTED_BREW_TAPS="${TRUSTED_BREW_TAPS:-homebrew/core homebrew/cask homebrew/bundle homebrew/services}"

# Check if a tap is trusted (S18)
# Usage: if is_trusted_tap "user/tap"; then ...
is_trusted_tap() {
  local tap="$1"
  
  for trusted in $TRUSTED_BREW_TAPS; do
    [[ "$tap" == "$trusted" ]] && return 0
  done
  
  return 1
}

# Verify a package comes from trusted tap (S18)
# Usage: if verify_brew_package "package-name"; then ...
verify_brew_package() {
  local package="$1"
  
  if ! command -v brew &>/dev/null; then
    msg_error "Homebrew not found"
    return 1
  fi
  
  # Get package info
  local tap
  tap=$(brew info --json=v2 "$package" 2>/dev/null | grep -o '"tap":"[^"]*"' | head -1 | cut -d'"' -f4)
  
  if [[ -z "$tap" ]]; then
    msg_warning "Cannot determine tap for: $package"
    return 2
  fi
  
  if is_trusted_tap "$tap"; then
    msg_success "✅ Trusted tap: $package ($tap)"
    return 0
  else
    msg_warning "⚠️  Untrusted tap: $package ($tap)"
    security_log "warning" "Untrusted Homebrew tap" "$package from $tap"
    return 1
  fi
}

# Add a tap to trusted list (S18)
# Usage: add_trusted_tap "user/tap"
add_trusted_tap() {
  local tap="$1"
  
  if is_trusted_tap "$tap"; then
    msg_info "Tap already trusted: $tap"
    return 0
  fi
  
  TRUSTED_BREW_TAPS="$TRUSTED_BREW_TAPS $tap"
  export TRUSTED_BREW_TAPS
  
  msg_success "Added trusted tap: $tap"
  security_log "info" "Added trusted tap" "$tap"
}

# List all taps and their trust status (S18)
# Usage: list_brew_taps
list_brew_taps() {
  if ! command -v brew &>/dev/null; then
    msg_error "Homebrew not found"
    return 1
  fi
  
  msg_info "Homebrew Taps:"
  echo ""
  
  brew tap | while read -r tap; do
    if is_trusted_tap "$tap"; then
      echo "  ✅ $tap (trusted)"
    else
      echo "  ⚠️  $tap (untrusted)"
    fi
  done
  
  echo ""
  msg_info "Trusted: $TRUSTED_BREW_TAPS"
}

# Scan Brewfile for untrusted taps (S18)
# Usage: scan_brewfile_taps "/path/to/Brewfile"
scan_brewfile_taps() {
  local brewfile="${1:-Brewfile}"
  
  if [[ ! -f "$brewfile" ]]; then
    msg_error "Brewfile not found: $brewfile"
    return 1
  fi
  
  local untrusted=0
  
  msg_info "Scanning Brewfile for taps: $brewfile"
  echo ""
  
  grep "^tap " "$brewfile" | while read -r line; do
    local tap
    tap=$(echo "$line" | awk '{print $2}' | tr -d '"'"'")
    
    if is_trusted_tap "$tap"; then
      echo "  ✅ $tap"
    else
      echo "  ⚠️  $tap (untrusted)"
      ((untrusted++))
    fi
  done
  
  echo ""
  [[ $untrusted -eq 0 ]]
}

# --- S19: Self-Update Signature Check ---------------------------------------

# Check if a git commit is signed (S19)
# Usage: if is_commit_signed "abc123"; then ...
is_commit_signed() {
  local commit="${1:-HEAD}"
  local repo="${2:-.}"
  
  git -C "$repo" log -1 --show-signature "$commit" 2>/dev/null | grep -q "Good signature"
}

# Verify git commit signature before update (S19)
# Usage: if verify_update_signature; then ...
verify_update_signature() {
  local repo="${1:-$DOTFILES_ROOT}"
  
  if [[ ! -d "$repo/.git" ]]; then
    msg_error "Not a git repository: $repo"
    return 1
  fi
  
  # Fetch latest
  git -C "$repo" fetch origin 2>/dev/null || {
    msg_error "Failed to fetch from origin"
    return 1
  }
  
  local local_head remote_head
  local_head=$(git -C "$repo" rev-parse HEAD 2>/dev/null)
  remote_head=$(git -C "$repo" rev-parse origin/main 2>/dev/null || git -C "$repo" rev-parse origin/master 2>/dev/null)
  
  if [[ "$local_head" == "$remote_head" ]]; then
    msg_info "Already up to date."
    return 0
  fi
  
  msg_info "Checking signature for: ${remote_head:0:8}"
  
  if is_commit_signed "$remote_head" "$repo"; then
    msg_success "✅ Commit is signed and verified"
    security_log "info" "Update signature verified" "$remote_head"
    return 0
  else
    msg_error "❌ Commit is NOT signed or signature is invalid"
    security_log "critical" "Update signature FAILED" "$remote_head"
    
    echo ""
    echo "   The remote commit is not GPG signed."
    echo "   This could indicate unauthorized changes."
    echo ""
    
    read -r -p "Apply update anyway? (DANGEROUS) [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      security_log "critical" "Applied unsigned update" "$remote_head"
      return 0
    else
      return 1
    fi
  fi
}

# Safe self-update with signature verification (S19)
# Usage: safe_self_update
safe_self_update() {
  local repo="${1:-$DOTFILES_ROOT}"
  
  msg_info "Checking for updates..."
  
  if verify_update_signature "$repo"; then
    msg_info "Pulling updates..."
    git -C "$repo" pull origin main 2>/dev/null || git -C "$repo" pull origin master 2>/dev/null
    msg_success "Update complete."
  else
    msg_error "Update aborted."
    return 1
  fi
}

# Get signature status of recent commits (S19)
# Usage: show_commit_signatures [count]
show_commit_signatures() {
  local count="${1:-10}"
  local repo="${2:-$DOTFILES_ROOT}"
  
  msg_info "Last $count commits:"
  echo ""
  
  git -C "$repo" log -n "$count" --format="%h %G? %s" 2>/dev/null | while read -r line; do
    local hash sig_status msg
    hash=$(echo "$line" | awk '{print $1}')
    sig_status=$(echo "$line" | awk '{print $2}')
    msg=$(echo "$line" | cut -d' ' -f3-)
    
    case "$sig_status" in
      G) echo "  ✅ $hash $msg" ;;
      B) echo "  ❌ $hash $msg (bad sig)" ;;
      U) echo "  ⚠️  $hash $msg (untrusted key)" ;;
      X) echo "  ⏰ $hash $msg (expired sig)" ;;
      Y) echo "  🔑 $hash $msg (expired key)" ;;
      R) echo "  🚫 $hash $msg (revoked key)" ;;
      E) echo "  ❓ $hash $msg (cannot verify)" ;;
      N|*) echo "  ⚪ $hash $msg (unsigned)" ;;
    esac
  done
}

# --- S20: Rollback Verification ---------------------------------------------

# Get APFS snapshot hash (S20)
# Usage: hash=$(snapshot_hash "com.apple.TimeMachine.2024-01-01")
snapshot_hash() {
  local snapshot="$1"
  
  # Get snapshot metadata for verification
  tmutil listlocalsnapshots / 2>/dev/null | grep "$snapshot" | shasum -a 256 | awk '{print $1}'
}

# List available snapshots with dates (S20)
# Usage: list_rollback_snapshots
list_rollback_snapshots() {
  msg_info "📸 Available APFS Snapshots:"
  echo ""
  
  tmutil listlocalsnapshots / 2>/dev/null | while read -r snapshot; do
    local snap_name="${snapshot#com.apple.TimeMachine.}"
    echo "  • $snap_name"
  done
  
  echo ""
}

# Verify snapshot exists before restore (S20)
# Usage: if verify_snapshot_exists "snapshot-name"; then ...
verify_snapshot_exists() {
  local snapshot="$1"
  
  tmutil listlocalsnapshots / 2>/dev/null | grep -q "$snapshot"
}

# Safe rollback with verification and confirmation (S20)
# Usage: safe_rollback "snapshot-name"
safe_rollback() {
  local snapshot="$1"
  
  if [[ -z "$snapshot" ]]; then
    msg_error "Snapshot name required"
    list_rollback_snapshots
    return 1
  fi
  
  # Verify snapshot exists
  if ! verify_snapshot_exists "$snapshot"; then
    msg_error "Snapshot not found: $snapshot"
    list_rollback_snapshots
    return 1
  fi
  
  echo ""
  msg_warning "⚠️  APFS ROLLBACK"
  echo ""
  echo "   Snapshot: $snapshot"
  echo "   This will restore your system to a previous state."
  echo "   All changes made after this snapshot will be LOST."
  echo ""
  
  read -r -p "Type 'ROLLBACK' to confirm: " confirm
  
  if [[ "$confirm" != "ROLLBACK" ]]; then
    msg_info "Operation cancelled."
    return 1
  fi
  
  security_log "critical" "APFS rollback initiated" "$snapshot"
  
  # Create a pre-rollback snapshot first
  local pre_rollback_name="pre-rollback-$(date +%Y%m%d-%H%M%S)"
  msg_info "Creating pre-rollback snapshot: $pre_rollback_name"
  
  tmutil localsnapshot 2>/dev/null
  
  msg_info "Starting rollback to: $snapshot"
  msg_warning "System restart may be required."
  
  # Note: Actual restore requires root and specific syntax
  echo ""
  echo "   To complete the rollback, run:"
  echo "   sudo tmutil restore -d / \"$snapshot\""
  echo ""
  
  security_log "info" "Rollback prepared" "$snapshot"
}

# Create a named snapshot before major changes (S20)
# Usage: create_safety_snapshot "pre-config-change"
create_safety_snapshot() {
  local name="${1:-pre-change}"
  local full_name="circus-$name-$(date +%Y%m%d-%H%M%S)"
  
  msg_info "Creating safety snapshot: $full_name"
  
  if tmutil localsnapshot 2>/dev/null; then
    msg_success "Snapshot created."
    security_log "info" "Safety snapshot created" "$full_name"
    return 0
  else
    msg_warning "Could not create snapshot (may require Full Disk Access)"
    return 1
  fi
}

# --- S21: Security Event Logging --------------------------------------------

# Security audit log path
SECURITY_AUDIT_LOG="${CIRCUS_SECURITY_LOG:-$HOME/.circus/security_audit.log}"

# Log a security event with structured format (S21)
# Usage: security_event "category" "action" "details" [severity]
security_event() {
  local category="$1"
  local action="$2"
  local details="$3"
  local severity="${4:-info}"
  
  mkdir -p "$(dirname "$SECURITY_AUDIT_LOG")"
  
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local user
  user=$(get_real_user 2>/dev/null || whoami)
  
  # JSON-like structured log entry
  printf '[%s] [%s] [%s] user=%s category=%s action=%s details="%s"\n' \
    "$timestamp" "$severity" "$$" "$user" "$category" "$action" "$details" \
    >> "$SECURITY_AUDIT_LOG"
  
  # Also log critical events to system log on macOS
  if [[ "$severity" == "critical" ]] && command -v logger &>/dev/null; then
    logger -t "circus-security" "[$severity] $category: $action - $details"
  fi
}

# View security audit log (S21)
# Usage: security_audit_view [lines]
security_audit_view() {
  local lines="${1:-50}"
  
  if [[ ! -f "$SECURITY_AUDIT_LOG" ]]; then
    msg_info "No security audit log found."
    return 0
  fi
  
  msg_info "📜 Security Audit Log (last $lines entries):"
  echo ""
  tail -n "$lines" "$SECURITY_AUDIT_LOG"
}

# Filter security events by severity (S21)
# Usage: security_events_by_severity "critical"
security_events_by_severity() {
  local severity="$1"
  
  if [[ ! -f "$SECURITY_AUDIT_LOG" ]]; then
    return 0
  fi
  
  grep "\[$severity\]" "$SECURITY_AUDIT_LOG"
}

# Get security event statistics (S21)
# Usage: security_event_stats
security_event_stats() {
  if [[ ! -f "$SECURITY_AUDIT_LOG" ]]; then
    msg_info "No security audit log found."
    return 0
  fi
  
  msg_info "📊 Security Event Statistics:"
  echo ""
  echo "   Critical: $(grep -c '\[critical\]' "$SECURITY_AUDIT_LOG" 2>/dev/null || echo 0)"
  echo "   Warning:  $(grep -c '\[warning\]' "$SECURITY_AUDIT_LOG" 2>/dev/null || echo 0)"
  echo "   Info:     $(grep -c '\[info\]' "$SECURITY_AUDIT_LOG" 2>/dev/null || echo 0)"
  echo ""
  echo "   Total:    $(wc -l < "$SECURITY_AUDIT_LOG" | tr -d ' ')"
  echo "   Log file: $SECURITY_AUDIT_LOG"
}

# --- S22: Config Change Detection -------------------------------------------

# Config hash baseline file
CONFIG_HASH_BASELINE="${CIRCUS_CONFIG_BASELINE:-$HOME/.circus/config_baseline.sha256}"

# Generate baseline hashes for config files (S22)
# Usage: config_baseline_save [dir]
config_baseline_save() {
  local dir="${1:-$DOTFILES_ROOT}"
  
  mkdir -p "$(dirname "$CONFIG_HASH_BASELINE")"
  
  {
    echo "# Config Baseline"
    echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "#"
    
    find "$dir" -name "*.yaml" -o -name "*.yml" -o -name "config" 2>/dev/null | \
      grep -v ".git" | sort | while read -r file; do
      local hash
      hash=$(file_hash "$file")
      if [[ -n "$hash" ]]; then
        local rel_path="${file#$dir/}"
        echo "$hash  $rel_path"
      fi
    done
  } > "$CONFIG_HASH_BASELINE"
  
  chmod 600 "$CONFIG_HASH_BASELINE"
  
  local count
  count=$(grep -v "^#" "$CONFIG_HASH_BASELINE" | wc -l | tr -d ' ')
  
  msg_success "Config baseline saved: $count files"
  security_event "config" "baseline_saved" "$count files"
}

# Check configs against baseline (S22)
# Usage: if config_change_check; then ...
config_change_check() {
  local dir="${1:-$DOTFILES_ROOT}"
  
  if [[ ! -f "$CONFIG_HASH_BASELINE" ]]; then
    msg_warning "No config baseline found."
    msg_info "Create one with: config_baseline_save"
    return 2
  fi
  
  local modified=0
  local new_files=0
  
  msg_info "Checking config files for changes..."
  
  while IFS= read -r line; do
    [[ "$line" =~ ^# ]] && continue
    [[ -z "$line" ]] && continue
    
    local stored_hash file_path
    stored_hash=$(echo "$line" | awk '{print $1}')
    file_path=$(echo "$line" | awk '{print $2}')
    
    local full_path="$dir/$file_path"
    
    if [[ ! -f "$full_path" ]]; then
      continue
    fi
    
    local current_hash
    current_hash=$(file_hash "$full_path")
    
    if [[ "$current_hash" != "$stored_hash" ]]; then
      msg_warning "  ⚠️  MODIFIED: $file_path"
      security_event "config" "modified" "$file_path" "warning"
      ((modified++))
    fi
  done < "$CONFIG_HASH_BASELINE"
  
  if [[ $modified -gt 0 ]]; then
    msg_error "Detected $modified modified config file(s)!"
    security_event "config" "changes_detected" "$modified files" "critical"
    return 1
  else
    msg_success "All config files match baseline."
    return 0
  fi
}

# --- S23: Failed Operation Alerting -----------------------------------------

# Failed operations tracking file
FAILED_OPS_LOG="${CIRCUS_FAILED_OPS:-$HOME/.circus/failed_ops.log}"
FAILED_OPS_THRESHOLD="${CIRCUS_FAILED_THRESHOLD:-5}"

# Log a failed operation (S23)
# Usage: log_failed_operation "category" "details"
log_failed_operation() {
  local category="$1"
  local details="$2"
  
  mkdir -p "$(dirname "$FAILED_OPS_LOG")"
  
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  echo "[$timestamp] $category: $details" >> "$FAILED_OPS_LOG"
  
  # Check for repeated failures
  check_failure_threshold "$category"
}

# Check if failures exceed threshold (S23)
# Usage: check_failure_threshold "category"
check_failure_threshold() {
  local category="$1"
  local window_minutes="${2:-10}"
  
  if [[ ! -f "$FAILED_OPS_LOG" ]]; then
    return 0
  fi
  
  # Count recent failures in category
  local cutoff
  cutoff=$(date -v-${window_minutes}M '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date '+%Y-%m-%d %H:%M:%S')
  
  local count
  count=$(grep "$category:" "$FAILED_OPS_LOG" | tail -n 20 | wc -l | tr -d ' ')
  
  if [[ $count -ge $FAILED_OPS_THRESHOLD ]]; then
    msg_error "⚠️  ALERT: $count failed $category operations detected!"
    security_event "alert" "threshold_exceeded" "$category: $count failures" "critical"
    
    # Optional: send notification
    if command -v osascript &>/dev/null; then
      osascript -e "display notification \"$count failed $category operations\" with title \"Security Alert\" sound name \"Basso\"" 2>/dev/null
    fi
    
    return 1
  fi
  
  return 0
}

# View failed operations (S23)
# Usage: view_failed_operations [lines]
view_failed_operations() {
  local lines="${1:-20}"
  
  if [[ ! -f "$FAILED_OPS_LOG" ]]; then
    msg_info "No failed operations logged."
    return 0
  fi
  
  msg_info "📋 Recent Failed Operations:"
  echo ""
  tail -n "$lines" "$FAILED_OPS_LOG"
}

# Clear failed operations log (S23)
# Usage: clear_failed_operations
clear_failed_operations() {
  if [[ -f "$FAILED_OPS_LOG" ]]; then
    rm -f "$FAILED_OPS_LOG"
    msg_success "Failed operations log cleared."
  fi
}

# --- S24: Startup Security Checks -------------------------------------------

# Run security audit on fc initialization (S24)
# Usage: startup_security_check
startup_security_check() {
  local issues=0
  
  # Check 1: Not running as root
  if is_root; then
    msg_error "⛔ Running as root!"
    ((issues++))
  fi
  
  # Check 2: Config file permissions
  if [[ -f "$HOME/.circus/config.yaml" ]]; then
    if is_world_writable "$HOME/.circus/config.yaml"; then
      msg_warning "⚠️  Config file is world-writable"
      ((issues++))
    fi
  fi
  
  # Check 3: Script integrity (if manifest exists)
  if [[ -f "$SCRIPT_HASH_MANIFEST" ]]; then
    if ! verify_script_integrity "$DOTFILES_ROOT" "$SCRIPT_HASH_MANIFEST" 2>/dev/null; then
      msg_warning "⚠️  Script integrity check failed"
      ((issues++))
    fi
  fi
  
  # Check 4: sudoers integrity (if baseline exists)
  if [[ -f "$SUDOERS_BASELINE" ]]; then
    if ! sudoers_check 2>/dev/null; then
      msg_warning "⚠️  sudoers file has been modified"
      ((issues++))
    fi
  fi
  
  # Check 5: Config baseline (if exists)
  if [[ -f "$CONFIG_HASH_BASELINE" ]]; then
    if ! config_change_check "$DOTFILES_ROOT" 2>/dev/null; then
      msg_warning "⚠️  Config files have been modified"
      ((issues++))
    fi
  fi
  
  if [[ $issues -gt 0 ]]; then
    security_event "startup" "issues_found" "$issues issues" "warning"
    return 1
  else
    security_event "startup" "clean" "All checks passed" "info"
    return 0
  fi
}

# Quick security status (S24)
# Usage: security_status
security_status() {
  echo ""
  msg_info "🛡️  Security Status"
  echo ""
  
  # Root check
  if is_root; then
    echo "  ❌ Running as root"
  else
    echo "  ✅ Not running as root"
  fi
  
  # GPG available
  if has_gpg; then
    echo "  ✅ GPG available"
  else
    echo "  ⚪ GPG not installed"
  fi
  
  # Script integrity baseline
  if [[ -f "$SCRIPT_HASH_MANIFEST" ]]; then
    echo "  ✅ Script hash manifest exists"
  else
    echo "  ⚪ No script hash manifest"
  fi
  
  # Config baseline
  if [[ -f "$CONFIG_HASH_BASELINE" ]]; then
    echo "  ✅ Config baseline exists"
  else
    echo "  ⚪ No config baseline"
  fi
  
  # sudoers baseline
  if [[ -f "$SUDOERS_BASELINE" ]]; then
    echo "  ✅ sudoers baseline exists"
  else
    echo "  ⚪ No sudoers baseline"
  fi
  
  echo ""
}

# --- S25: Periodic Health Reports -------------------------------------------

# Generate comprehensive security health report (S25)
# Usage: security_health_report [output_file]
security_health_report() {
  local output="${1:-}"
  local report=""
  
  report+="# Security Health Report\n"
  report+="Generated: $(date '+%Y-%m-%d %H:%M:%S')\n"
  report+="Host: $(hostname)\n"
  report+="User: $(get_real_user)\n"
  report+="\n"
  
  # Section: Overview
  report+="## Overview\n\n"
  report+="| Check | Status |\n"
  report+="|-------|--------|\n"
  
  # Root check
  if is_root; then
    report+="| Root execution | ❌ Running as root |\n"
  else
    report+="| Root execution | ✅ Normal user |\n"
  fi
  
  # GPG
  if has_gpg; then
    report+="| GPG | ✅ Available |\n"
  else
    report+="| GPG | ⚪ Not installed |\n"
  fi
  
  report+="\n"
  
  # Section: Baselines
  report+="## Security Baselines\n\n"
  
  if [[ -f "$SCRIPT_HASH_MANIFEST" ]]; then
    local script_count
    script_count=$(grep -v "^#" "$SCRIPT_HASH_MANIFEST" | wc -l | tr -d ' ')
    report+="- Script hash manifest: $script_count files\n"
  else
    report+="- Script hash manifest: Not created\n"
  fi
  
  if [[ -f "$CONFIG_HASH_BASELINE" ]]; then
    local config_count
    config_count=$(grep -v "^#" "$CONFIG_HASH_BASELINE" | wc -l | tr -d ' ')
    report+="- Config baseline: $config_count files\n"
  else
    report+="- Config baseline: Not created\n"
  fi
  
  if [[ -f "$SUDOERS_BASELINE" ]]; then
    report+="- sudoers baseline: Created\n"
  else
    report+="- sudoers baseline: Not created\n"
  fi
  
  report+="\n"
  
  # Section: Recent Events
  report+="## Recent Security Events\n\n"
  
  if [[ -f "$SECURITY_AUDIT_LOG" ]]; then
    local critical_count warning_count
    critical_count=$(grep -c '\[critical\]' "$SECURITY_AUDIT_LOG" 2>/dev/null || echo 0)
    warning_count=$(grep -c '\[warning\]' "$SECURITY_AUDIT_LOG" 2>/dev/null || echo 0)
    report+="- Critical events: $critical_count\n"
    report+="- Warnings: $warning_count\n"
  else
    report+="- No security events logged\n"
  fi
  
  report+="\n"
  
  # Section: Failed Operations
  report+="## Failed Operations\n\n"
  
  if [[ -f "$FAILED_OPS_LOG" ]]; then
    local fail_count
    fail_count=$(wc -l < "$FAILED_OPS_LOG" | tr -d ' ')
    report+="- Total failed operations: $fail_count\n"
  else
    report+="- No failed operations logged\n"
  fi
  
  report+="\n"
  
  # Section: Recommendations
  report+="## Recommendations\n\n"
  
  if [[ ! -f "$SCRIPT_HASH_MANIFEST" ]]; then
    report+="- [ ] Create script hash manifest: \`generate_hash_manifest\`\n"
  fi
  
  if [[ ! -f "$CONFIG_HASH_BASELINE" ]]; then
    report+="- [ ] Create config baseline: \`config_baseline_save\`\n"
  fi
  
  if [[ ! -f "$SUDOERS_BASELINE" ]]; then
    report+="- [ ] Create sudoers baseline: \`sudoers_baseline_save\`\n"
  fi
  
  if ! has_gpg; then
    report+="- [ ] Install GPG: \`brew install gnupg\`\n"
  fi
  
  # Output
  if [[ -n "$output" ]]; then
    echo -e "$report" > "$output"
    msg_success "Health report saved to: $output"
  else
    echo -e "$report"
  fi
}

# Schedule periodic health check (S25)
# Usage: schedule_health_check [interval_hours]
schedule_health_check() {
  local interval="${1:-24}"
  local last_check_file="$HOME/.circus/.last_health_check"
  
  mkdir -p "$(dirname "$last_check_file")"
  
  # Check if enough time has passed
  if [[ -f "$last_check_file" ]]; then
    local last_check
    last_check=$(cat "$last_check_file")
    local now
    now=$(date +%s)
    local diff=$(( (now - last_check) / 3600 ))
    
    if [[ $diff -lt $interval ]]; then
      return 0  # Not time yet
    fi
  fi
  
  # Run health check
  msg_info "Running periodic security health check..."
  startup_security_check
  
  # Update last check time
  date +%s > "$last_check_file"
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
export -f is_world_writable is_group_writable check_config_permissions
export -f scan_config_permissions fix_config_permissions check_config_owner
export -f has_gpg encrypt_backup decrypt_backup encrypt_and_shred
export -f create_encrypted_backup restore_encrypted_backup is_encrypted
export -f get_secure_delete_tool secure_delete secure_delete_dir
export -f secure_clear secure_delete_confirm
export -f sign_config verify_config_signature verify_before_apply
export -f list_signing_keys is_config_signed sign_all_configs verify_all_configs
export -f file_hash generate_hash_manifest verify_script_integrity
export -f verify_single_script show_hash_manifest update_script_hash
export -f is_trusted_tap verify_brew_package add_trusted_tap list_brew_taps scan_brewfile_taps
export -f is_commit_signed verify_update_signature safe_self_update show_commit_signatures
export -f snapshot_hash list_rollback_snapshots verify_snapshot_exists safe_rollback create_safety_snapshot
export -f security_event security_audit_view security_events_by_severity security_event_stats
export -f config_baseline_save config_change_check
export -f log_failed_operation check_failure_threshold view_failed_operations clear_failed_operations
export -f startup_security_check security_status
export -f security_health_report schedule_health_check

# --- S26: Remote URL Allowlist ----------------------------------------------

# Allowed domains for remote downloads
ALLOWED_DOMAINS="${CIRCUS_ALLOWED_DOMAINS:-github.com raw.githubusercontent.com api.github.com homebrew.bintray.com}"

# Check if a URL's domain is allowed (S26)
# Usage: if is_allowed_domain "https://github.com/..."; then ...
is_allowed_domain() {
  local url="$1"
  
  # Extract domain from URL
  local domain
  domain=$(echo "$url" | sed -E 's|^https?://([^/]+).*|\1|')
  
  for allowed in $ALLOWED_DOMAINS; do
    if [[ "$domain" == "$allowed" ]] || [[ "$domain" == *".$allowed" ]]; then
      return 0
    fi
  done
  
  return 1
}

# Secure download with domain verification (S26)
# Usage: secure_download "https://allowed.com/file" "/path/to/output"
secure_download() {
  local url="$1"
  local output="$2"
  
  if ! is_allowed_domain "$url"; then
    msg_error "❌ Domain not in allowlist: $url"
    security_event "network" "blocked_download" "$url" "warning"
    
    echo ""
    echo "   Allowed domains: $ALLOWED_DOMAINS"
    echo "   Add with: add_allowed_domain \"domain.com\""
    echo ""
    
    read -r -p "Download anyway? (DANGEROUS) [y/N] " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
      return 1
    fi
    security_event "network" "bypass_allowlist" "$url" "critical"
  fi
  
  # Log the request
  log_network_request "download" "$url"
  
  # Perform download
  if command -v curl &>/dev/null; then
    curl -fsSL -o "$output" "$url"
  elif command -v wget &>/dev/null; then
    wget -q -O "$output" "$url"
  else
    msg_error "No download tool available (curl/wget)"
    return 1
  fi
}

# Add domain to allowlist (S26)
# Usage: add_allowed_domain "trusted.com"
add_allowed_domain() {
  local domain="$1"
  
  if is_allowed_domain "https://$domain"; then
    msg_info "Domain already allowed: $domain"
    return 0
  fi
  
  ALLOWED_DOMAINS="$ALLOWED_DOMAINS $domain"
  export ALLOWED_DOMAINS
  
  msg_success "Added allowed domain: $domain"
  security_event "network" "domain_added" "$domain" "info"
}

# List allowed domains (S26)
# Usage: list_allowed_domains
list_allowed_domains() {
  msg_info "🌐 Allowed Domains:"
  echo ""
  for domain in $ALLOWED_DOMAINS; do
    echo "  • $domain"
  done
  echo ""
}

# --- S27: Certificate Pinning for Updates -----------------------------------

# Expected certificate fingerprints (SHA256)
GITHUB_CERT_PIN="${CIRCUS_GITHUB_CERT:-}"

# Verify TLS certificate for a domain (S27)
# Usage: if verify_certificate "github.com"; then ...
verify_certificate() {
  local domain="$1"
  local expected_pin="$2"
  
  if ! command -v openssl &>/dev/null; then
    msg_warning "OpenSSL not available for certificate verification"
    return 0  # Continue without verification
  fi
  
  # Get the certificate fingerprint
  local cert_fingerprint
  cert_fingerprint=$(echo | openssl s_client -connect "${domain}:443" -servername "$domain" 2>/dev/null | \
    openssl x509 -fingerprint -sha256 -noout 2>/dev/null | \
    sed 's/SHA256 Fingerprint=//' | tr -d ':')
  
  if [[ -z "$cert_fingerprint" ]]; then
    msg_warning "Could not retrieve certificate for: $domain"
    return 1
  fi
  
  if [[ -n "$expected_pin" ]]; then
    if [[ "$cert_fingerprint" == "$expected_pin" ]]; then
      msg_success "✅ Certificate verified: $domain"
      return 0
    else
      msg_error "❌ Certificate mismatch for: $domain"
      security_event "network" "cert_mismatch" "$domain" "critical"
      return 1
    fi
  fi
  
  # If no pin provided, just return the fingerprint
  echo "$cert_fingerprint"
}

# Secure update with certificate verification (S27)
# Usage: secure_update_check
secure_update_check() {
  local repo="${1:-$DOTFILES_ROOT}"
  
  msg_info "Verifying update source certificates..."
  
  # Verify GitHub certificate
  if ! verify_certificate "github.com" "$GITHUB_CERT_PIN" 2>/dev/null; then
    if [[ -n "$GITHUB_CERT_PIN" ]]; then
      msg_error "GitHub certificate verification failed!"
      return 1
    fi
  fi
  
  # Proceed with signature verification
  verify_update_signature "$repo"
}

# Save current certificate as pin (S27)
# Usage: save_certificate_pin "github.com"
save_certificate_pin() {
  local domain="$1"
  local pin_file="$HOME/.circus/cert_pins/${domain}.pin"
  
  mkdir -p "$(dirname "$pin_file")"
  
  local fingerprint
  fingerprint=$(verify_certificate "$domain")
  
  if [[ -n "$fingerprint" ]]; then
    echo "$fingerprint" > "$pin_file"
    chmod 600 "$pin_file"
    msg_success "Saved certificate pin for: $domain"
    security_event "network" "cert_pin_saved" "$domain" "info"
  fi
}

# --- S28: Network Request Logging -------------------------------------------

# Network request log
NETWORK_REQUEST_LOG="${CIRCUS_NETWORK_LOG:-$HOME/.circus/network_requests.log}"

# Log a network request (S28)
# Usage: log_network_request "type" "url" [response_code]
log_network_request() {
  local request_type="$1"
  local url="$2"
  local response="${3:-}"
  
  mkdir -p "$(dirname "$NETWORK_REQUEST_LOG")"
  
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  printf '[%s] %s %s %s\n' "$timestamp" "$request_type" "$url" "$response" >> "$NETWORK_REQUEST_LOG"
}

# View network request log (S28)
# Usage: view_network_requests [lines]
view_network_requests() {
  local lines="${1:-30}"
  
  if [[ ! -f "$NETWORK_REQUEST_LOG" ]]; then
    msg_info "No network requests logged."
    return 0
  fi
  
  msg_info "🌐 Network Request Log (last $lines):"
  echo ""
  tail -n "$lines" "$NETWORK_REQUEST_LOG"
}

# Get network statistics (S28)
# Usage: network_request_stats
network_request_stats() {
  if [[ ! -f "$NETWORK_REQUEST_LOG" ]]; then
    msg_info "No network requests logged."
    return 0
  fi
  
  msg_info "📊 Network Request Statistics:"
  echo ""
  echo "   Total requests: $(wc -l < "$NETWORK_REQUEST_LOG" | tr -d ' ')"
  echo "   Downloads: $(grep -c 'download' "$NETWORK_REQUEST_LOG" 2>/dev/null || echo 0)"
  echo "   API calls: $(grep -c 'api' "$NETWORK_REQUEST_LOG" 2>/dev/null || echo 0)"
  echo ""
}

# Logged curl wrapper (S28)
# Usage: logged_curl [curl_args...]
logged_curl() {
  local url=""
  
  # Find URL in arguments
  for arg in "$@"; do
    if [[ "$arg" =~ ^https?:// ]]; then
      url="$arg"
      break
    fi
  done
  
  log_network_request "curl" "$url"
  curl "$@"
  local result=$?
  
  log_network_request "curl_complete" "$url" "$result"
  return $result
}

# --- S29: Firewall Rule Auditor ---------------------------------------------

# Baseline firewall rules file
FIREWALL_BASELINE="${CIRCUS_FIREWALL_BASELINE:-$HOME/.circus/firewall_baseline.txt}"

# Get current firewall rules (S29)
# Usage: rules=$(get_firewall_rules)
get_firewall_rules() {
  # macOS Application Firewall
  if command -v /usr/libexec/ApplicationFirewall/socketfilterfw &>/dev/null; then
    /usr/libexec/ApplicationFirewall/socketfilterfw --listapps 2>/dev/null
  fi
  
  # pf rules (if available)
  if sudo -n pfctl -sr 2>/dev/null; then
    sudo pfctl -sr 2>/dev/null
  fi
}

# Save firewall baseline (S29)
# Usage: firewall_baseline_save
firewall_baseline_save() {
  mkdir -p "$(dirname "$FIREWALL_BASELINE")"
  
  {
    echo "# Firewall Baseline"
    echo "# Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "#"
    get_firewall_rules
  } > "$FIREWALL_BASELINE"
  
  chmod 600 "$FIREWALL_BASELINE"
  msg_success "Firewall baseline saved."
  security_event "firewall" "baseline_saved" "$FIREWALL_BASELINE" "info"
}

# Check for firewall changes (S29)
# Usage: if firewall_check; then ...
firewall_check() {
  if [[ ! -f "$FIREWALL_BASELINE" ]]; then
    msg_warning "No firewall baseline found."
    return 2
  fi
  
  local current
  current=$(get_firewall_rules | grep -v "^#" | sort)
  local baseline
  baseline=$(grep -v "^#" "$FIREWALL_BASELINE" | sort)
  
  if [[ "$current" != "$baseline" ]]; then
    msg_warning "⚠️  Firewall rules have changed!"
    security_event "firewall" "rules_changed" "Differences detected" "warning"
    
    echo ""
    echo "   Run 'diff <(get_firewall_rules) $FIREWALL_BASELINE' to see changes"
    echo ""
    return 1
  fi
  
  msg_success "Firewall rules match baseline."
  return 0
}

# Show firewall status (S29)
# Usage: firewall_status
firewall_status() {
  msg_info "🔥 Firewall Status:"
  echo ""
  
  # macOS Application Firewall
  if command -v /usr/libexec/ApplicationFirewall/socketfilterfw &>/dev/null; then
    local fw_status
    fw_status=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null)
    echo "   Application Firewall: $fw_status"
    
    local stealth
    stealth=$(/usr/libexec/ApplicationFirewall/socketfilterfw --getstealthmode 2>/dev/null)
    echo "   Stealth Mode: $stealth"
  fi
  
  echo ""
}

# --- S30: DNS Leak Check ----------------------------------------------------

# Expected DNS resolvers
EXPECTED_DNS="${CIRCUS_EXPECTED_DNS:-}"

# Get current DNS servers (S30)
# Usage: servers=$(get_dns_servers)
get_dns_servers() {
  # macOS - get DNS from scutil
  scutil --dns 2>/dev/null | grep "nameserver\[" | awk '{print $3}' | sort -u
}

# Check for DNS leaks (S30)
# Usage: if dns_leak_check; then ...
dns_leak_check() {
  msg_info "🔍 Checking DNS Configuration..."
  echo ""
  
  local servers
  servers=$(get_dns_servers)
  
  if [[ -z "$servers" ]]; then
    msg_warning "Could not determine DNS servers."
    return 1
  fi
  
  echo "   Current DNS servers:"
  echo "$servers" | while read -r server; do
    echo "     • $server"
  done
  echo ""
  
  # Check against expected DNS if set
  if [[ -n "$EXPECTED_DNS" ]]; then
    local unexpected=0
    
    while read -r server; do
      local found=0
      for expected in $EXPECTED_DNS; do
        if [[ "$server" == "$expected" ]]; then
          found=1
          break
        fi
      done
      
      if [[ $found -eq 0 ]]; then
        msg_warning "   ⚠️  Unexpected DNS server: $server"
        ((unexpected++))
      fi
    done <<< "$servers"
    
    if [[ $unexpected -gt 0 ]]; then
      security_event "dns" "unexpected_servers" "$unexpected unexpected" "warning"
      return 1
    fi
  fi
  
  msg_success "DNS configuration looks OK."
  return 0
}

# Test DNS resolution (S30)
# Usage: dns_resolution_test [domain]
dns_resolution_test() {
  local domain="${1:-github.com}"
  
  msg_info "Testing DNS resolution for: $domain"
  echo ""
  
  if command -v dig &>/dev/null; then
    dig +short "$domain"
  elif command -v nslookup &>/dev/null; then
    nslookup "$domain" 2>/dev/null | grep "Address:" | tail -n +2
  elif command -v host &>/dev/null; then
    host "$domain"
  else
    # Fallback to ping
    ping -c 1 "$domain" 2>/dev/null | head -1
  fi
  
  echo ""
}

# Save expected DNS servers (S30)
# Usage: save_expected_dns
save_expected_dns() {
  local servers
  servers=$(get_dns_servers | tr '\n' ' ')
  
  EXPECTED_DNS="$servers"
  export EXPECTED_DNS
  
  # Save to file for persistence
  echo "$servers" > "$HOME/.circus/expected_dns"
  
  msg_success "Saved expected DNS servers: $servers"
  security_event "dns" "baseline_saved" "$servers" "info"
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
export -f is_world_writable is_group_writable check_config_permissions
export -f scan_config_permissions fix_config_permissions check_config_owner
export -f has_gpg encrypt_backup decrypt_backup encrypt_and_shred
export -f create_encrypted_backup restore_encrypted_backup is_encrypted
export -f get_secure_delete_tool secure_delete secure_delete_dir
export -f secure_clear secure_delete_confirm
export -f sign_config verify_config_signature verify_before_apply
export -f list_signing_keys is_config_signed sign_all_configs verify_all_configs
export -f file_hash generate_hash_manifest verify_script_integrity
export -f verify_single_script show_hash_manifest update_script_hash
export -f is_trusted_tap verify_brew_package add_trusted_tap list_brew_taps scan_brewfile_taps
export -f is_commit_signed verify_update_signature safe_self_update show_commit_signatures
export -f snapshot_hash list_rollback_snapshots verify_snapshot_exists safe_rollback create_safety_snapshot
export -f security_event security_audit_view security_events_by_severity security_event_stats
export -f config_baseline_save config_change_check
export -f log_failed_operation check_failure_threshold view_failed_operations clear_failed_operations
export -f startup_security_check security_status
export -f security_health_report schedule_health_check
export -f is_allowed_domain secure_download add_allowed_domain list_allowed_domains
export -f verify_certificate secure_update_check save_certificate_pin
export -f log_network_request view_network_requests network_request_stats logged_curl
export -f get_firewall_rules firewall_baseline_save firewall_check firewall_status
export -f get_dns_servers dns_leak_check dns_resolution_test save_expected_dns
export SUDO_AUDIT_LOG SUDO_SCOPE_DEPTH SUDOERS_BASELINE SECURE_TEMP_FILES CIRCUS_SIGNING_KEY SCRIPT_HASH_MANIFEST TRUSTED_BREW_TAPS
export SECURITY_AUDIT_LOG CONFIG_HASH_BASELINE FAILED_OPS_LOG FAILED_OPS_THRESHOLD
export ALLOWED_DOMAINS NETWORK_REQUEST_LOG FIREWALL_BASELINE EXPECTED_DNS
