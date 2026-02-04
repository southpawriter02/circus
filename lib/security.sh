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
export SUDO_AUDIT_LOG SUDO_SCOPE_DEPTH SUDOERS_BASELINE SECURE_TEMP_FILES CIRCUS_SIGNING_KEY
