#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         notify.sh
#
# DESCRIPTION:  macOS notification helpers for long-running tasks.
#               Uses osascript to display native notifications.
#
# CROSS-PLATFORM:
#   - macOS: Uses osascript for native notifications
#   - Linux: Uses notify-send if available
#
# ==============================================================================

# Notification sound names (macOS) - guard against re-sourcing
if [[ -z "${NOTIFY_SOUND_SUCCESS:-}" ]]; then
  readonly NOTIFY_SOUND_SUCCESS="Glass"
  readonly NOTIFY_SOUND_ERROR="Basso"
  readonly NOTIFY_SOUND_INFO="Pop"
fi

#
# @description Send a notification with optional sound
# @param $1 title - The notification title
# @param $2 message - The notification body
# @param $3 sound - Optional sound name (macOS only)
#
notify() {
  local title="$1"
  local message="$2"
  local sound="${3:-}"
  
  if is_macos; then
    local sound_arg=""
    if [[ -n "$sound" ]]; then
      sound_arg="sound name \"$sound\""
    fi
    
    osascript -e "display notification \"$message\" with title \"$title\" $sound_arg" 2>/dev/null
  elif is_linux; then
    if command -v notify-send &>/dev/null; then
      notify-send "$title" "$message" 2>/dev/null
    fi
  fi
}

#
# @description Send a success notification
# @param $1 message - The notification message
#
notify_success() {
  local message="$1"
  notify "✅ Circus" "$message" "$NOTIFY_SOUND_SUCCESS"
}

#
# @description Send an error notification
# @param $1 message - The notification message
#
notify_error() {
  local message="$1"
  notify "❌ Circus" "$message" "$NOTIFY_SOUND_ERROR"
}

#
# @description Send an info notification
# @param $1 message - The notification message
#
notify_info() {
  local message="$1"
  notify "ℹ️ Circus" "$message" "$NOTIFY_SOUND_INFO"
}

#
# @description Run a command and notify on completion
# @param $@ command - The command to run
#
run_with_notification() {
  local cmd_display="${*:1:3}..."  # First 3 words for display
  
  if "$@"; then
    notify_success "Command completed: $cmd_display"
    return 0
  else
    local exit_code=$?
    notify_error "Command failed: $cmd_display"
    return $exit_code
  fi
}

#
# @description Wrapper to notify after long-running operations
# @param $1 operation_name - Name of the operation
# @param $2 start_time - Start time (from `date +%s`)
#
notify_duration() {
  local operation_name="$1"
  local start_time="$2"
  local end_time
  end_time=$(date +%s)
  
  local duration=$((end_time - start_time))
  
  if [[ $duration -ge 10 ]]; then
    # Only notify for operations that took 10+ seconds
    notify_success "$operation_name completed in ${duration}s"
  fi
}
