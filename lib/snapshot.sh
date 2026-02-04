#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/snapshot.sh
#
# DESCRIPTION:  APFS snapshot management library for the Circus framework.
#               Provides functions for creating, listing, and managing
#               local snapshots before major system operations.
#
# REQUIRES:     macOS with APFS filesystem, tmutil
#
# ==============================================================================

# --- Configuration ----------------------------------------------------------
readonly SNAPSHOT_CONFIG="$HOME/.config/circus/snapshot.conf"
readonly SNAPSHOT_METADATA="$HOME/.config/circus/snapshots.json"
readonly SNAPSHOT_PREFIX="circus"

# Default settings
SNAPSHOT_AUTO_ENABLED="${SNAPSHOT_AUTO_ENABLED:-true}"
SNAPSHOT_MAX_COUNT="${SNAPSHOT_MAX_COUNT:-5}"

# Load config if exists
if [[ -f "$SNAPSHOT_CONFIG" ]]; then
  # shellcheck source=/dev/null
  source "$SNAPSHOT_CONFIG"
fi

# --- Helper Functions -------------------------------------------------------

# Check if we're on an APFS volume
_is_apfs_volume() {
  local volume="${1:-/}"
  local fs_type
  fs_type=$(diskutil info "$volume" 2>/dev/null | grep "Type (Bundle)" | awk '{print $NF}')
  [[ "$fs_type" == "apfs" ]]
}

# Get current timestamp in tmutil format
_snapshot_timestamp() {
  date +"%Y-%m-%d-%H%M%S"
}

# Initialize metadata file if needed
_init_metadata() {
  if [[ ! -f "$SNAPSHOT_METADATA" ]]; then
    mkdir -p "$(dirname "$SNAPSHOT_METADATA")"
    echo '{"snapshots": []}' > "$SNAPSHOT_METADATA"
  fi
}

# Add snapshot to metadata
_add_to_metadata() {
  local timestamp="$1"
  local context="$2"
  local volume="$3"
  
  _init_metadata
  
  # Create new entry
  local entry
  entry=$(cat <<EOF
{
  "timestamp": "$timestamp",
  "context": "$context",
  "volume": "$volume",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
)
  
  # Add to metadata using jq if available, otherwise basic append
  if command -v jq &>/dev/null; then
    local temp_file
    temp_file=$(mktemp)
    jq ".snapshots += [$entry]" "$SNAPSHOT_METADATA" > "$temp_file" && mv "$temp_file" "$SNAPSHOT_METADATA"
  else
    # Fallback: simple JSON manipulation
    sed -i '' 's/\]$/,'"$(echo "$entry" | tr '\n' ' ')"']/' "$SNAPSHOT_METADATA" 2>/dev/null || true
  fi
}

# Remove snapshot from metadata
_remove_from_metadata() {
  local timestamp="$1"
  
  if [[ -f "$SNAPSHOT_METADATA" ]] && command -v jq &>/dev/null; then
    local temp_file
    temp_file=$(mktemp)
    jq "del(.snapshots[] | select(.timestamp == \"$timestamp\"))" "$SNAPSHOT_METADATA" > "$temp_file" && mv "$temp_file" "$SNAPSHOT_METADATA"
  fi
}

# --- Public Functions -------------------------------------------------------

# Check if auto-snapshot is enabled
snapshot_is_enabled() {
  [[ "$SNAPSHOT_AUTO_ENABLED" == "true" ]]
}

# Create a new APFS snapshot
# Usage: snapshot_create [context]
snapshot_create() {
  local context="${1:-manual}"
  local volume="${2:-/}"
  
  # Verify APFS
  if ! _is_apfs_volume "$volume"; then
    msg_warning "Volume $volume is not APFS. Snapshots not supported."
    return 1
  fi
  
  # Create snapshot
  local timestamp
  timestamp=$(_snapshot_timestamp)
  
  msg_info "Creating APFS snapshot (context: $context)..."
  
  if tmutil localsnapshot "$volume" 2>/dev/null; then
    # Record in metadata
    _add_to_metadata "$timestamp" "$context" "$volume"
    msg_success "Snapshot created: $timestamp"
    return 0
  else
    msg_error "Failed to create snapshot. Ensure Time Machine permissions are granted."
    return 1
  fi
}

# List all Circus-managed snapshots
# Usage: snapshot_list [volume]
snapshot_list() {
  local volume="${1:-/}"
  
  # Get all local snapshots
  local snapshots
  snapshots=$(tmutil listlocalsnapshots "$volume" 2>/dev/null)
  
  if [[ -z "$snapshots" ]]; then
    echo "No local snapshots found."
    return 0
  fi
  
  # If metadata exists, show only tracked snapshots with context
  if [[ -f "$SNAPSHOT_METADATA" ]] && command -v jq &>/dev/null; then
    echo ""
    printf "%-25s %-20s %s\n" "TIMESTAMP" "CONTEXT" "CREATED"
    echo "─────────────────────────────────────────────────────────────────"
    
    jq -r '.snapshots[] | "\(.timestamp)\t\(.context)\t\(.created)"' "$SNAPSHOT_METADATA" 2>/dev/null | \
      while IFS=$'\t' read -r ts ctx created; do
        printf "%-25s %-20s %s\n" "$ts" "$ctx" "${created:-unknown}"
      done
  else
    # Fallback: show all snapshots
    echo "$snapshots"
  fi
}

# Delete a specific snapshot
# Usage: snapshot_delete <timestamp>
snapshot_delete() {
  local timestamp="$1"
  
  if [[ -z "$timestamp" ]]; then
    msg_error "Please specify a snapshot timestamp."
    return 1
  fi
  
  msg_info "Deleting snapshot: $timestamp"
  
  if sudo tmutil deletelocalsnapshots "$timestamp" 2>/dev/null; then
    _remove_from_metadata "$timestamp"
    msg_success "Snapshot deleted."
    return 0
  else
    msg_error "Failed to delete snapshot. It may not exist or require admin privileges."
    return 1
  fi
}

# Delete all Circus-managed snapshots
snapshot_delete_all() {
  if [[ ! -f "$SNAPSHOT_METADATA" ]]; then
    msg_info "No Circus snapshots to delete."
    return 0
  fi
  
  local count=0
  
  if command -v jq &>/dev/null; then
    jq -r '.snapshots[].timestamp' "$SNAPSHOT_METADATA" 2>/dev/null | while read -r ts; do
      if sudo tmutil deletelocalsnapshots "$ts" 2>/dev/null; then
        ((count++))
      fi
    done
  fi
  
  # Clear metadata
  echo '{"snapshots": []}' > "$SNAPSHOT_METADATA"
  
  msg_success "Deleted Circus snapshots."
}

# Prune old snapshots, keeping only the N most recent
# Usage: snapshot_prune_old [max_count]
snapshot_prune_old() {
  local max_count="${1:-$SNAPSHOT_MAX_COUNT}"
  
  if [[ ! -f "$SNAPSHOT_METADATA" ]] || ! command -v jq &>/dev/null; then
    return 0
  fi
  
  local current_count
  current_count=$(jq '.snapshots | length' "$SNAPSHOT_METADATA" 2>/dev/null || echo 0)
  
  if [[ "$current_count" -le "$max_count" ]]; then
    return 0
  fi
  
  local to_delete=$((current_count - max_count))
  
  msg_info "Pruning $to_delete old snapshot(s)..."
  
  # Get oldest snapshots
  jq -r ".snapshots | sort_by(.created) | .[0:$to_delete][].timestamp" "$SNAPSHOT_METADATA" 2>/dev/null | \
    while read -r ts; do
      snapshot_delete "$ts"
    done
}

# Create snapshot before a major operation (with pruning)
# Usage: snapshot_before_operation <operation_name>
snapshot_before_operation() {
  local operation="$1"
  
  if ! snapshot_is_enabled; then
    return 0
  fi
  
  # Create snapshot with operation context
  if snapshot_create "pre-$operation"; then
    # Prune old snapshots
    snapshot_prune_old
  fi
}

# Get disk space used by local snapshots
snapshot_disk_usage() {
  local volume="${1:-/}"
  
  # Get purgeable space (includes snapshots)
  local info
  info=$(diskutil info "$volume" 2>/dev/null)
  
  local purgeable
  purgeable=$(echo "$info" | grep "Purgeable" | awk '{print $NF}')
  
  echo "${purgeable:-unknown}"
}

# Get count of Circus-managed snapshots
snapshot_count() {
  if [[ -f "$SNAPSHOT_METADATA" ]] && command -v jq &>/dev/null; then
    jq '.snapshots | length' "$SNAPSHOT_METADATA" 2>/dev/null || echo 0
  else
    echo 0
  fi
}
