#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/vscode_backends/gist.sh
#
# DESCRIPTION:  GitHub Gist backend for fc-vscode-sync. Stores VS Code settings
#               in a private GitHub Gist using the GitHub API.
#
# REQUIRES:
#   - curl (for API calls)
#   - jq (for JSON parsing)
#   - GitHub token with 'gist' scope
#
# ==============================================================================

# --- Backend Interface Functions ----------------------------------------------

# Returns the display name of this backend
vscode_backend_get_name() {
  echo "GitHub Gist"
}

# Check if backend dependencies are installed
# Returns 0 if all dependencies are available, 1 otherwise
vscode_backend_check_dependencies() {
  local missing=()

  if ! command -v curl >/dev/null 2>&1; then
    missing+=("curl")
  fi

  if ! command -v jq >/dev/null 2>&1; then
    missing+=("jq")
  fi

  if [ ${#missing[@]} -gt 0 ]; then
    msg_error "Missing dependencies for gist backend: ${missing[*]}"
    msg_info "Install with: brew install ${missing[*]}"
    return 1
  fi

  return 0
}

# Validate backend-specific configuration
# Returns 0 if valid, exits with error otherwise
vscode_backend_validate_config() {
  # Token is validated in main plugin via get_github_token
  # VSCODE_GIST_ID can be empty (auto-create on first push)
  return 0
}

# Push local files to gist
# Arguments: temp_dir containing files to push
vscode_backend_push() {
  local temp_dir="$1"
  local token
  token=$(get_github_token) || die "GitHub token required for gist backend."

  # Build JSON payload from files in temp_dir
  local files_json
  files_json=$(build_gist_files_json "$temp_dir")

  if [ -z "$VSCODE_GIST_ID" ]; then
    # Create new gist
    msg_info "Creating new private gist..."

    local response
    response=$(curl -s -X POST \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json" \
      -d "{\"description\":\"$VSCODE_GIST_DESCRIPTION\",\"public\":false,\"files\":$files_json}" \
      "https://api.github.com/gists")

    local gist_id
    gist_id=$(echo "$response" | jq -r '.id // empty')

    if [ -z "$gist_id" ]; then
      local error_msg
      error_msg=$(echo "$response" | jq -r '.message // "Unknown error"')
      die "Failed to create gist: $error_msg"
    fi

    # Save gist ID to config file
    save_gist_id_to_config "$gist_id"
    VSCODE_GIST_ID="$gist_id"

    msg_success "Created gist: $gist_id"
    msg_info "Gist URL: https://gist.github.com/$gist_id"
  else
    # Update existing gist
    msg_info "Updating gist $VSCODE_GIST_ID..."

    local response
    response=$(curl -s -X PATCH \
      -H "Authorization: Bearer $token" \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Content-Type: application/json" \
      -d "{\"files\":$files_json}" \
      "https://api.github.com/gists/$VSCODE_GIST_ID")

    local updated_id
    updated_id=$(echo "$response" | jq -r '.id // empty')

    if [ -z "$updated_id" ]; then
      local error_msg
      error_msg=$(echo "$response" | jq -r '.message // "Unknown error"')
      die "Failed to update gist: $error_msg"
    fi

    msg_success "Updated gist: $VSCODE_GIST_ID"
  fi
}

# Pull files from gist to temp directory
# Arguments: temp_dir to store pulled files
# Returns: 0 on success, 1 on failure
vscode_backend_pull() {
  local temp_dir="$1"
  local token
  token=$(get_github_token) || die "GitHub token required for gist backend."

  if [ -z "$VSCODE_GIST_ID" ]; then
    die "No gist ID configured. Run 'fc vscode-sync up' first or set VSCODE_GIST_ID in config."
  fi

  msg_info "Fetching gist $VSCODE_GIST_ID..."

  local response
  response=$(curl -s \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/gists/$VSCODE_GIST_ID")

  local gist_id
  gist_id=$(echo "$response" | jq -r '.id // empty')

  if [ -z "$gist_id" ]; then
    local error_msg
    error_msg=$(echo "$response" | jq -r '.message // "Unknown error"')
    die "Failed to fetch gist: $error_msg"
  fi

  # Extract files from response
  extract_gist_files "$response" "$temp_dir"

  msg_success "Fetched settings from gist"
}

# Get remote state for status comparison
# Arguments: temp_dir to store fetched files
vscode_backend_get_status() {
  vscode_backend_pull "$@"
}

# --- Helper Functions ---------------------------------------------------------

# Build JSON object for gist files from directory contents
# Arguments: directory containing files
# Output: JSON object suitable for gist API
build_gist_files_json() {
  local dir="$1"
  local json="{"
  local first=true

  for file in "$dir"/*; do
    [ -f "$file" ] || continue

    local filename
    filename=$(basename "$file")

    # Read file content and escape for JSON
    local content
    content=$(cat "$file")

    if [ "$first" = true ]; then
      first=false
    else
      json+=","
    fi

    # Use jq to properly escape the content
    local escaped_content
    escaped_content=$(echo "$content" | jq -Rs '.')

    json+="\"$filename\":{\"content\":$escaped_content}"
  done

  json+="}"
  echo "$json"
}

# Extract files from gist API response to directory
# Arguments: response JSON, target directory
extract_gist_files() {
  local response="$1"
  local target_dir="$2"

  # Get list of files
  local files
  files=$(echo "$response" | jq -r '.files | keys[]')

  while IFS= read -r filename; do
    [ -z "$filename" ] && continue

    local content
    content=$(echo "$response" | jq -r ".files[\"$filename\"].content // empty")

    if [ -n "$content" ]; then
      echo "$content" > "$target_dir/$filename"
    fi
  done <<< "$files"
}

# Save gist ID to config file
# Arguments: gist_id
save_gist_id_to_config() {
  local gist_id="$1"

  if [ -f "$VSCODE_CONFIG_FILE" ]; then
    # Check if VSCODE_GIST_ID line exists
    if grep -q "^VSCODE_GIST_ID=" "$VSCODE_CONFIG_FILE"; then
      # Update existing line
      if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' "s|^VSCODE_GIST_ID=.*|VSCODE_GIST_ID=\"$gist_id\"|" "$VSCODE_CONFIG_FILE"
      else
        sed -i "s|^VSCODE_GIST_ID=.*|VSCODE_GIST_ID=\"$gist_id\"|" "$VSCODE_CONFIG_FILE"
      fi
    else
      # Append new line
      echo "VSCODE_GIST_ID=\"$gist_id\"" >> "$VSCODE_CONFIG_FILE"
    fi
  fi

  msg_info "Saved gist ID to config file"
}
