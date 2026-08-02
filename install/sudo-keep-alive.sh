#!/usr/bin/env bash

# ==============================================================================
#
# Sudo Keep-Alive
#
# Requests sudo privileges once and keeps the cached credential alive for the
# duration of a long-running install, so the user is not prompted repeatedly.
#
# STATUS: not currently wired into install.sh. Sourcing this file only defines
#         the two functions below; nothing happens until they are called.
#
# USAGE:
#   source install/sudo-keep-alive.sh
#   sudo_keepalive_start || exit 1
#   ...                                  # long-running work
#   sudo_keepalive_stop                  # also runs automatically on exit
#
# ==============================================================================
#
# WHY THIS FILE LOOKS THE WAY IT DOES
#
# The previous implementation was a single line executed at source time:
#
#   while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
#
# Every part of that is a problem:
#
#   * It refreshed the credential BEFORE checking whether the parent was still
#     alive, and only after a 60-second sleep — so it extended passwordless root
#     at least once past the parent's exit, on an unattended machine.
#   * No trap, so Ctrl-C on the installer orphaned the loop and it kept
#     refreshing until the PID check happened to fire.
#   * `2>/dev/null` swallowed `sudo -n` failures, so once credentials genuinely
#     lapsed the loop spun forever instead of exiting.
#   * It ran on `source`, giving a file that looks like a library a side effect.
#
# The version below checks liveness first, exits the moment a refresh fails, is
# bounded by the parent's lifetime, and is torn down by a trap that composes
# with any handler already installed rather than replacing it.
#
# ==============================================================================

SUDO_KEEPALIVE_PID=""

#
# @description Acquire sudo and start the background refresher.
# @return 0 if credentials were acquired, non-zero otherwise.
#
sudo_keepalive_start() {
  # Acquire up front. If the user declines or has no sudo rights, fail here
  # rather than prompting repeatedly later.
  if ! sudo -v; then
    return 1
  fi

  # Capture the PID to watch before backgrounding: inside the subshell $$ is
  # still this shell, and $PPID is not what we want when the file is sourced.
  local target_pid=$$

  (
    while true; do
      # Liveness FIRST. Never refresh on behalf of a process that has exited.
      kill -0 "$target_pid" 2>/dev/null || exit 0
      # Stop as soon as a refresh fails instead of spinning.
      sudo -n true 2>/dev/null || exit 0
      sleep 50
    done
  ) &
  SUDO_KEEPALIVE_PID=$!

  # Compose with any existing EXIT trap rather than discarding it; bash traps
  # do not chain.
  local prev_trap prev_cmd
  prev_trap=$(trap -p EXIT)
  if [ -n "$prev_trap" ]; then
    prev_cmd=${prev_trap#trap -- \'}
    prev_cmd=${prev_cmd%\' EXIT}
    trap "sudo_keepalive_stop; ${prev_cmd}" EXIT
  else
    trap 'sudo_keepalive_stop' EXIT
  fi
  trap 'sudo_keepalive_stop' INT TERM

  return 0
}

#
# @description Stop the refresher.
#
# Deliberately does NOT run `sudo -k`: that invalidates the credential for the
# user's whole terminal session, not just this script, which is surprising when
# the installer was run interactively.
#
sudo_keepalive_stop() {
  if [ -n "$SUDO_KEEPALIVE_PID" ]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    SUDO_KEEPALIVE_PID=""
  fi
}
