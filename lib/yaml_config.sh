#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/yaml_config.sh
#
# DESCRIPTION:  YAML configuration engine for declarative dotfiles management.
#               Provides functions to parse and apply YAML configuration files,
#               enabling a shift from imperative shell scripts to declarative
#               configuration.
#
# REQUIRES:
#   - yq (YAML processor) - install with: brew install yq
#
# USAGE:
#   source "$DOTFILES_ROOT/lib/yaml_config.sh"
#   apply_role_config "$DOTFILES_ROOT/roles/personal/config.yaml"
#
# ==============================================================================

# --- Dependency Check -------------------------------------------------------

# Check if yq is installed
check_yq_installed() {
  if ! command -v yq &>/dev/null; then
    msg_error "yq is required for YAML configuration but not installed."
    msg_info "Install with: brew install yq"
    return 1
  fi
  return 0
}

# --- YAML Parsing Helpers ---------------------------------------------------

# Read a simple value from YAML
# Usage: yaml_get file.yaml ".path.to.key"
yaml_get() {
  local file="$1"
  local path="$2"
  yq eval "$path" "$file" 2>/dev/null
}

# Get array length from YAML
# Usage: yaml_array_length file.yaml ".packages"
yaml_array_length() {
  local file="$1"
  local path="$2"
  yq eval "$path | length" "$file" 2>/dev/null || echo "0"
}

# Iterate over YAML array and call function for each item
# Usage: yaml_foreach file.yaml ".packages" callback_function
yaml_foreach() {
  local file="$1"
  local path="$2"
  local callback="$3"
  
  local length
  length=$(yaml_array_length "$file" "$path")
  
  for ((i = 0; i < length; i++)); do
    local item
    item=$(yq eval "${path}[$i]" "$file" 2>/dev/null)
    "$callback" "$item" "$i"
  done
}

# --- Package Installation ---------------------------------------------------

# Install Homebrew formulae from YAML config
apply_brew_formulae() {
  local config_file="$1"
  local count
  count=$(yaml_array_length "$config_file" ".packages.brew")
  
  if [[ "$count" -eq 0 || "$count" == "null" ]]; then
    msg_debug "No Homebrew formulae defined in config."
    return 0
  fi
  
  msg_info "Installing $count Homebrew formulae..."
  
  for ((i = 0; i < count; i++)); do
    local formula
    formula=$(yaml_get "$config_file" ".packages.brew[$i]")
    
    if [[ -n "$formula" && "$formula" != "null" ]]; then
      # Security: Validate package name (S05)
      if ! sanitize_package_name "$formula" >/dev/null 2>&1; then
        msg_warning "  ⚠ Skipping invalid package name: $formula"
        security_log "warning" "Invalid brew formula name blocked" "$formula"
        continue
      fi
      
      if brew list "$formula" &>/dev/null; then
        msg_debug "Formula already installed: $formula"
      else
        msg_info "  Installing: $formula"
        brew install "$formula" 2>/dev/null || msg_warning "Failed to install: $formula"
      fi
    fi
  done
}

# Install Homebrew casks from YAML config
apply_brew_casks() {
  local config_file="$1"
  local count
  count=$(yaml_array_length "$config_file" ".packages.cask")
  
  if [[ "$count" -eq 0 || "$count" == "null" ]]; then
    msg_debug "No Homebrew casks defined in config."
    return 0
  fi
  
  msg_info "Installing $count Homebrew casks..."
  
  for ((i = 0; i < count; i++)); do
    local cask
    cask=$(yaml_get "$config_file" ".packages.cask[$i]")
    
    if [[ -n "$cask" && "$cask" != "null" ]]; then
      # Security: Validate package name (S05)
      if ! sanitize_package_name "$cask" >/dev/null 2>&1; then
        msg_warning "  ⚠ Skipping invalid cask name: $cask"
        security_log "warning" "Invalid cask name blocked" "$cask"
        continue
      fi
      
      if brew list --cask "$cask" &>/dev/null; then
        msg_debug "Cask already installed: $cask"
      else
        msg_info "  Installing: $cask"
        brew install --cask "$cask" 2>/dev/null || msg_warning "Failed to install: $cask"
      fi
    fi
  done
}

# Install Mac App Store apps from YAML config
apply_mas_apps() {
  local config_file="$1"
  local count
  count=$(yaml_array_length "$config_file" ".packages.mas")
  
  if [[ "$count" -eq 0 || "$count" == "null" ]]; then
    msg_debug "No Mac App Store apps defined in config."
    return 0
  fi
  
  if ! command -v mas &>/dev/null; then
    msg_warning "mas-cli not installed. Skipping Mac App Store apps."
    return 0
  fi
  
  msg_info "Installing $count Mac App Store apps..."
  
  for ((i = 0; i < count; i++)); do
    local app_id
    local app_name
    app_id=$(yaml_get "$config_file" ".packages.mas[$i].id")
    app_name=$(yaml_get "$config_file" ".packages.mas[$i].name")
    
    if [[ -n "$app_id" && "$app_id" != "null" ]]; then
      # Security: Validate app ID is numeric only (S05)
      if [[ ! "$app_id" =~ ^[0-9]+$ ]]; then
        msg_warning "  ⚠ Skipping invalid MAS app ID: $app_id"
        security_log "warning" "Invalid MAS app ID blocked" "$app_id"
        continue
      fi
      
      if mas list | grep -q "^$app_id"; then
        msg_debug "App already installed: $app_name ($app_id)"
      else
        msg_info "  Installing: $app_name ($app_id)"
        mas install "$app_id" 2>/dev/null || msg_warning "Failed to install: $app_name"
      fi
    fi
  done
}

# --- macOS Defaults ---------------------------------------------------------

# Apply macOS defaults from YAML config
apply_macos_defaults() {
  local config_file="$1"
  local count
  count=$(yaml_array_length "$config_file" ".defaults")
  
  if [[ "$count" -eq 0 || "$count" == "null" ]]; then
    msg_debug "No macOS defaults defined in config."
    return 0
  fi
  
  msg_info "Applying $count macOS defaults..."
  
  for ((i = 0; i < count; i++)); do
    local domain key type value description
    domain=$(yaml_get "$config_file" ".defaults[$i].domain")
    key=$(yaml_get "$config_file" ".defaults[$i].key")
    type=$(yaml_get "$config_file" ".defaults[$i].type")
    value=$(yaml_get "$config_file" ".defaults[$i].value")
    description=$(yaml_get "$config_file" ".defaults[$i].description")
    
    if [[ -n "$domain" && "$domain" != "null" && -n "$key" && "$key" != "null" ]]; then
      # Security: Validate domain format
      if ! sanitize_domain "$domain" >/dev/null 2>&1; then
        msg_warning "  ⚠ Skipping invalid domain: $domain"
        security_log "warning" "Invalid domain in config" "$domain"
        continue
      fi
      
      # Security: Sanitize the value
      local safe_value
      safe_value=$(sanitize_defaults_value "$value" "$type")
      if [[ $? -ne 0 ]]; then
        msg_warning "  ⚠ Skipping unsafe value for: $domain.$key"
        security_log "warning" "Unsafe value blocked" "$domain.$key=$value"
        continue
      fi
      
      msg_debug "  Setting $domain $key = $safe_value"
      
      # Map YAML types to defaults types
      local defaults_type
      case "$type" in
        bool|boolean) defaults_type="-bool" ;;
        int|integer)  defaults_type="-int" ;;
        float)        defaults_type="-float" ;;
        string)       defaults_type="-string" ;;
        array)        defaults_type="-array" ;;
        dict)         defaults_type="-dict" ;;
        *)            defaults_type="-string" ;;
      esac
      
      # Apply the default with sanitized values
      if defaults write "$domain" "$key" "$defaults_type" "$safe_value" 2>/dev/null; then
        msg_debug "    ✓ Applied: $description"
      else
        msg_warning "    ✗ Failed to set: $domain $key"
      fi
    fi
  done
}

# --- Environment Variables --------------------------------------------------

# Apply environment variables from YAML config
apply_environment() {
  local config_file="$1"
  local env_file="${2:-$HOME/.zshenv.local}"
  local count
  count=$(yaml_array_length "$config_file" ".environment")
  
  if [[ "$count" -eq 0 || "$count" == "null" ]]; then
    msg_debug "No environment variables defined in config."
    return 0
  fi
  
  msg_info "Setting up $count environment variables..."
  
  # Create marker block
  local marker_start="# === CIRCUS CONFIG START ==="
  local marker_end="# === CIRCUS CONFIG END ==="
  
  # Remove existing block if present
  if [[ -f "$env_file" ]]; then
    sed -i.bak "/$marker_start/,/$marker_end/d" "$env_file" 2>/dev/null || true
  fi
  
  # Build new block
  {
    echo "$marker_start"
    for ((i = 0; i < count; i++)); do
      local name value
      name=$(yaml_get "$config_file" ".environment[$i].name")
      value=$(yaml_get "$config_file" ".environment[$i].value")
      
      if [[ -n "$name" && "$name" != "null" ]]; then
        echo "export $name=\"$value\""
      fi
    done
    echo "$marker_end"
  } >> "$env_file"
  
  msg_success "Environment variables written to $env_file"
}

# --- Aliases ----------------------------------------------------------------

# Apply shell aliases from YAML config
apply_aliases() {
  local config_file="$1"
  local alias_file="${2:-$HOME/.aliases.local}"
  local count
  count=$(yaml_array_length "$config_file" ".aliases")
  
  if [[ "$count" -eq 0 || "$count" == "null" ]]; then
    msg_debug "No aliases defined in config."
    return 0
  fi
  
  msg_info "Setting up $count shell aliases..."
  
  # Create marker block
  local marker_start="# === CIRCUS ALIASES START ==="
  local marker_end="# === CIRCUS ALIASES END ==="
  
  # Remove existing block if present
  if [[ -f "$alias_file" ]]; then
    sed -i.bak "/$marker_start/,/$marker_end/d" "$alias_file" 2>/dev/null || true
  fi
  
  # Build new block
  {
    echo "$marker_start"
    for ((i = 0; i < count; i++)); do
      local name command description
      name=$(yaml_get "$config_file" ".aliases[$i].name")
      command=$(yaml_get "$config_file" ".aliases[$i].command")
      description=$(yaml_get "$config_file" ".aliases[$i].description")
      
      if [[ -n "$name" && "$name" != "null" ]]; then
        [[ -n "$description" && "$description" != "null" ]] && echo "# $description"
        echo "alias $name='$command'"
      fi
    done
    echo "$marker_end"
  } >> "$alias_file"
  
  msg_success "Aliases written to $alias_file"
}

# --- Main Entry Point -------------------------------------------------------

# Apply a complete role configuration from YAML
# Usage: apply_role_config /path/to/config.yaml [--dry-run]
apply_role_config() {
  local config_file="$1"
  local dry_run="${2:-false}"
  
  if [[ ! -f "$config_file" ]]; then
    msg_error "Configuration file not found: $config_file"
    return 1
  fi
  
  if ! check_yq_installed; then
    return 1
  fi
  
  local role_name
  role_name=$(yaml_get "$config_file" ".metadata.name")
  local role_desc
  role_desc=$(yaml_get "$config_file" ".metadata.description")
  
  msg_info "Applying configuration: $role_name"
  [[ -n "$role_desc" && "$role_desc" != "null" ]] && msg_info "  $role_desc"
  echo ""
  
  if [[ "$dry_run" == "--dry-run" ]]; then
    msg_warning "DRY RUN MODE - No changes will be made"
    echo ""
  fi
  
  # Apply each section
  apply_brew_formulae "$config_file"
  apply_brew_casks "$config_file"
  apply_mas_apps "$config_file"
  apply_macos_defaults "$config_file"
  apply_environment "$config_file"
  apply_aliases "$config_file"
  
  echo ""
  msg_success "Configuration applied: $role_name"
}

# Validate a YAML configuration file
# Usage: validate_config /path/to/config.yaml
validate_config() {
  local config_file="$1"
  
  if [[ ! -f "$config_file" ]]; then
    msg_error "File not found: $config_file"
    return 1
  fi
  
  if ! check_yq_installed; then
    return 1
  fi
  
  msg_info "Validating: $config_file"
  
  # Check YAML syntax
  if ! yq eval '.' "$config_file" &>/dev/null; then
    msg_error "Invalid YAML syntax"
    return 1
  fi
  
  # Check required fields
  local name
  name=$(yaml_get "$config_file" ".metadata.name")
  if [[ -z "$name" || "$name" == "null" ]]; then
    msg_warning "Missing: metadata.name"
  fi
  
  msg_success "Configuration is valid"
  return 0
}

# Export functions
export -f check_yq_installed yaml_get yaml_array_length yaml_foreach
export -f apply_brew_formulae apply_brew_casks apply_mas_apps
export -f apply_macos_defaults apply_environment apply_aliases
export -f apply_role_config validate_config
