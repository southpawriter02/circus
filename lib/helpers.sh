#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/helpers.sh
#
# DESCRIPTION:  This script contains shared helper functions for logging,
#               error handling, and user interaction. It is sourced by all
#               major scripts in the project.
#
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION: SCRIPT SETUP & ROBUSTNESS
# ------------------------------------------------------------------------------

# `-E` (errtrace) is required for the ERR trap below to be inherited by shell
# functions. Without it every stage failure inside `main()` exits silently.
set -Eeo pipefail

# ------------------------------------------------------------------------------
# SECTION: LOGGING CONFIGURATION & SETUP
# ------------------------------------------------------------------------------

# Define log levels as numerical values. This allows us to easily compare them.
# We check if the variable is already defined to prevent "readonly" errors
# when this script is sourced multiple times in the test environment.
if [ -z "$LOG_LEVEL_DEBUG" ]; then
  readonly LOG_LEVEL_DEBUG=0
  readonly LOG_LEVEL_INFO=1
  readonly LOG_LEVEL_SUCCESS=2
  readonly LOG_LEVEL_WARN=3
  readonly LOG_LEVEL_ERROR=4
  readonly LOG_LEVEL_CRITICAL=5
fi

# Set the default log level for console output. Can be overridden by flags.
# For example, if set to WARN, only WARN, ERROR, and CRITICAL messages will be shown.
CONSOLE_LOG_LEVEL=${CONSOLE_LOG_LEVEL:-$LOG_LEVEL_INFO}

# The global path to the log file. If this is set, all messages will be written to it.
LOG_FILE_PATH="${LOG_FILE_PATH:-}"

# Maximum log file size in bytes (default 10MB)
LOG_MAX_SIZE=${LOG_MAX_SIZE:-10485760}

# Number of rotated logs to keep (default 3)
LOG_ROTATE_COUNT=${LOG_ROTATE_COUNT:-3}

# ------------------------------------------------------------------------------
# SECTION: LOG ROTATION
# ------------------------------------------------------------------------------

#
# @description
#   Rotates the log file if it exceeds LOG_MAX_SIZE. Called automatically
#   by log() when LOG_FILE_PATH is set.
#
# @param $1 The path to the log file.
#
rotate_log_if_needed() {
  local log_file="$1"

  # Skip if file doesn't exist or rotation is disabled
  [ -f "$log_file" ] || return 0
  [ "$LOG_MAX_SIZE" -gt 0 ] || return 0

  # Get file size (macOS uses -f%z, Linux uses -c%s)
  local file_size
  if [[ "$(uname)" == "Darwin" ]]; then
    file_size=$(stat -f%z "$log_file" 2>/dev/null || echo 0)
  else
    file_size=$(stat -c%s "$log_file" 2>/dev/null || echo 0)
  fi

  # Rotate if file exceeds max size
  if [ "$file_size" -ge "$LOG_MAX_SIZE" ]; then
    # Shift existing rotated logs
    local i=$LOG_ROTATE_COUNT
    while [ $i -gt 1 ]; do
      local prev=$((i - 1))
      [ -f "${log_file}.${prev}" ] && mv "${log_file}.${prev}" "${log_file}.${i}"
      i=$prev
    done

    # Rotate current log to .1
    mv "$log_file" "${log_file}.1"
  fi
}

# ------------------------------------------------------------------------------
# SECTION: ERROR HANDLING
# ------------------------------------------------------------------------------

error_handler() {
  local line_number="$1"
  local script_name="$2"
  local error_message="An unexpected error occurred in '$script_name' on line $line_number."
  log "$LOG_LEVEL_CRITICAL" "$error_message"
  log "$LOG_LEVEL_CRITICAL" "Aborting execution."
  exit 1
}

trap 'error_handler ${LINENO} ${BASH_SOURCE[0]}' ERR

die() {
  # Call sites write "\n" inside the message to mean a line break, e.g.
  #   die "Profile not found: $p\n\nRun 'fc profile list' to see available."
  # log() emits its argument verbatim, so those reached the user as the two
  # literal characters \n. Log the first line at ERROR, then print the rest
  # unprefixed -- the remainder is follow-up guidance, not additional errors,
  # and tagging every hint line [ERROR] misrepresents what went wrong.
  #
  # Only the \n sequence is translated. Using printf '%b' would also expand
  # \t and \\ anywhere in the string, including inside interpolated paths.
  local msg="$1"
  local first="${msg%%\\n*}"
  log "$LOG_LEVEL_ERROR" "$first"
  if [ "$first" != "$msg" ]; then
    local rest="${msg#*\\n}"
    printf '%s\n' "${rest//\\n/$'\n'}" >&2
  fi
  exit 1
}

# ------------------------------------------------------------------------------
# SECTION: CORE LOGGING ENGINE
# ------------------------------------------------------------------------------

#
# @description
#   The new, centralized logging function. This is the single point of control
#   for all logging output. It decides whether to print to the console and/or
#   write to a file based on the global configuration.
#
# @param $1 The numerical log level of the message.
# @param $2 The message to log.
#
log() {
  local level_num="$1"
  local message="$2"
  local level_name
  local color_code

  # --- Determine Level Name and Color ---
  case "$level_num" in
    "$LOG_LEVEL_DEBUG")   level_name="DEBUG";   color_code="${UI_MUTED}" ;;
    "$LOG_LEVEL_INFO")    level_name="INFO";    color_code="${UI_INFO}" ;;
    "$LOG_LEVEL_SUCCESS") level_name="SUCCESS"; color_code="${UI_SUCCESS}" ;;
    "$LOG_LEVEL_WARN")    level_name="WARN";    color_code="${UI_WARNING}" ;;
    "$LOG_LEVEL_ERROR")   level_name="ERROR";   color_code="${UI_ERROR}" ;;
    "$LOG_LEVEL_CRITICAL")level_name="CRITICAL";color_code="${UI_BG_RED}${UI_WHITE}" ;;
    *) level_name="UNKNOWN"; color_code="" ;;
  esac

  # --- Log to File (if configured) ---
  if [ -n "$LOG_FILE_PATH" ]; then
    # Check if rotation is needed before writing
    rotate_log_if_needed "$LOG_FILE_PATH"

    # Format with a timestamp for the log file.
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "[$timestamp] [$level_name] $message" >> "$LOG_FILE_PATH"
  fi

  # --- Log to Console (if level is high enough) ---
  if [ "$level_num" -ge "$CONSOLE_LOG_LEVEL" ]; then
    if [ "${PARANOID_MODE:-false}" = true ]; then
      return 0
    fi
    local color_reset="${UI_RESET}"

    # Use UI variables if available, otherwise fallback is handled by ui.sh loaded before or after.
    # But note: helpers.sh is often loaded BEFORE ui.sh in init.sh.
    # However, init.sh sources helpers, then ui.sh.
    # So when log() is CALLED, ui.sh should be loaded.

    # Using direct format string in printf to avoid SC2059 shellcheck warning about dynamic format strings
    if [ "$level_num" -ge "$LOG_LEVEL_ERROR" ]; then
      printf "${color_code}[%-8s]${color_reset} %s\n" "$level_name" "$message" >&2
    else
      printf "${color_code}[%-8s]${color_reset} %s\n" "$level_name" "$message"
    fi
  fi
}

# ------------------------------------------------------------------------------
# SECTION: CONVENIENCE WRAPPER FUNCTIONS
# ------------------------------------------------------------------------------
# These functions provide a simple, readable interface for the logging engine.
# They maintain backwards compatibility with the old `msg_*` functions.

msg_debug()   { log "$LOG_LEVEL_DEBUG"   "$1"; }
msg_info()    { log "$LOG_LEVEL_INFO"    "$1"; }
msg_success() { log "$LOG_LEVEL_SUCCESS" "$1"; }
msg_warning() { log "$LOG_LEVEL_WARN"    "$1"; }
msg_error()   { log "$LOG_LEVEL_ERROR"   "$1"; }
msg_critical(){ log "$LOG_LEVEL_CRITICAL" "$1"; }

export -f log msg_debug msg_info msg_success msg_warning msg_error msg_critical die

# ------------------------------------------------------------------------------
# SECTION: USER INTERACTION FUNCTIONS
# ------------------------------------------------------------------------------

prompt_for_confirmation() {
  if [ "$INTERACTIVE_MODE" = true ] && [ "${PARANOID_MODE:-false}" = false ]; then
    msg_info "$1"
    # `|| true`: at EOF (stdin closed, a pipe, cron) `read` returns non-zero,
    # and helpers.sh runs with set -e plus an ERR trap — so this prompt aborted
    # with "An unexpected error occurred" instead of cancelling cleanly. An
    # empty answer is already treated as "no" below, which is the safe default.
    read -p "Press Enter to continue..." || true
  fi
}

export -f prompt_for_confirmation

# ------------------------------------------------------------------------------
# SECTION: SYSTEM MUTATION WRAPPERS
# ------------------------------------------------------------------------------
# Canonical definitions of the two wrappers that scripts across `system/`,
# `defaults/` and `roles/` call to change machine state. Both honor DRY_RUN_MODE
# so that dry-run coverage lives in one place rather than being re-implemented
# (and forgotten) per file.
#
# Individual `defaults/**` scripts still define their own local `run_defaults`,
# which shadows this one for the remainder of the sourcing shell. These
# definitions exist so that the ~24 files calling the helpers WITHOUT defining
# them — notably everything under `system/macos/`, which aborts stage 4 of the
# installer — have something to call.

#
# @description
#   Writes a macOS user preference, honoring dry-run mode.
#
#   Accepts an optional leading `write` verb and an optional `-currentHost`
#   flag, both of which appear at existing call sites:
#
#     run_defaults <domain> <key> <type> <value>
#     run_defaults write <domain> <key> <type> <value>
#     run_defaults -currentHost <domain> <key> <type> <value>
#
run_defaults() {
  local host_args=()

  # Strip the optional verb / flag prefixes in any order.
  while [ "$#" -gt 0 ]; do
    case "$1" in
      write)        shift ;;
      -currentHost) host_args=(-currentHost); shift ;;
      *)            break ;;
    esac
  done

  if [ "$#" -lt 4 ]; then
    msg_error "run_defaults: expected <domain> <key> <type> <value>, got: $*"
    return 1
  fi

  local domain="$1" key="$2" type="$3" value="$4"

  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Would set ${domain} '${key}' to '${value}'"
    return 0
  fi

  defaults "${host_args[@]}" write "$domain" "$key" "$type" "$value"
}

#
# @description
#   Runs a command under sudo, honoring dry-run mode. Returns the command's
#   exit status so callers can branch on success.
#
# @param $@ The command and arguments to run.
#
run_sudo() {
  if [ "$#" -eq 0 ]; then
    msg_error "run_sudo: no command given"
    return 1
  fi

  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Would run: sudo $*"
    return 0
  fi

  sudo "$@"
}

#
# @description
#   Download an installer script over hardened HTTPS into a file, optionally
#   verifying its SHA-256, so the caller can run it from disk instead of piping
#   it straight into a shell.
#
#   Transport hardening: --proto '=https' and --proto-redir '=https' stop a
#   redirect from downgrading to plain HTTP; -f turns a 404 or captive-portal
#   page into a failure rather than saving the error body as if it were the
#   script; --tlsv1.2 sets a floor on the negotiated protocol.
#
#   Note on scope: HTTPS authenticates the host, not the content. Upstream can
#   still change what lives at that URL at any time. Pinning a checksum is what
#   actually fixes that, so when no pin is supplied this prints the observed
#   digest and says plainly that it is running unverified.
#
# @param $1 URL to fetch.
# @param $2 Output path (caller owns creation and cleanup).
# @param $3 Optional expected SHA-256. When set, a mismatch fails closed.
#
fetch_verified_script() {
  local url="$1"
  local out="$2"
  local expected="${3:-}"

  # Domain allowlist (S26) and request logging (S28).
  #
  # These live in lib/security.sh, which init.sh sources AFTER this file, so
  # they are resolved at call time rather than at definition time — and guarded
  # with `declare -F` so helpers.sh stays usable on its own.
  #
  # Both controls existed and had no caller: is_allowed_domain gated nothing,
  # and the network log that `fc audit network` reads was never written to. This
  # is the one place in the repository that downloads code and then executes it,
  # so it is exactly where they belong.
  #
  # Fails closed. CIRCUS_ALLOWED_DOMAINS extends the list for legitimate hosts.
  if declare -F is_allowed_domain >/dev/null 2>&1; then
    if ! is_allowed_domain "$url"; then
      msg_error "Refusing to download from a domain that is not on the allowlist:"
      msg_error "  $url"
      msg_info  "Allowed: ${ALLOWED_DOMAINS:-<unset>}"
      msg_info  "Extend with: CIRCUS_ALLOWED_DOMAINS=\"\$CIRCUS_ALLOWED_DOMAINS example.com\""
      if declare -F security_event >/dev/null 2>&1; then
        security_event "network" "blocked_download" "$url" "warning"
      fi
      return 1
    fi
  fi

  if declare -F log_network_request >/dev/null 2>&1; then
    log_network_request "download" "$url" || true
  fi

  if ! curl --proto '=https' --proto-redir '=https' --tlsv1.2 -fsSL -o "$out" "$url"; then
    msg_error "Failed to download: $url"
    if declare -F log_network_request >/dev/null 2>&1; then
      log_network_request "download-failed" "$url" || true
    fi
    # S23. log_failed_operation had no caller anywhere, so the failed-operations
    # log that `fc audit failures` reads was never written to — the viewer and
    # the recorder were both dead, each making the other pointless. A failed
    # download of code that is about to be executed is exactly the kind of event
    # worth being able to review after the fact.
    if declare -F log_failed_operation >/dev/null 2>&1; then
      log_failed_operation "network" "download failed: $url" || true
    fi
    return 1
  fi

  if [ ! -s "$out" ]; then
    msg_error "Downloaded an empty file from: $url"
    return 1
  fi

  local actual
  actual=$(shasum -a 256 "$out" | awk '{print $1}')

  if [ -n "$expected" ]; then
    if [ "$actual" != "$expected" ]; then
      msg_error "Checksum mismatch for $url"
      msg_error "  expected: $expected"
      msg_error "  actual:   $actual"
      if declare -F log_failed_operation >/dev/null 2>&1; then
        log_failed_operation "integrity" "checksum mismatch: $url" || true
      fi
      if declare -F security_event >/dev/null 2>&1; then
        security_event "integrity" "checksum_mismatch" "$url" "critical"
      fi
      return 1
    fi
    msg_success "Checksum verified: $(basename "$url")"
  else
    msg_warning "No checksum pinned for $(basename "$url") — running it unverified."
    msg_info "  sha256: $actual"
  fi

  return 0
}

#
# @description
#   Apply a macOS Application Firewall setting through socketfilterfw.
#
#   Writing /Library/Preferences/com.apple.alf directly goes behind cfprefsd's
#   back: the running firewall does not pick the change up, and socketfilterfw
#   can overwrite it later — so scripts reported "firewall configured" over a
#   firewall whose state had not changed.
#
# @param $1 Human-readable description, used in the success/warning message.
# @param $2 socketfilterfw flag, e.g. --setglobalstate.
# @param $3 Value, e.g. on/off.
#
run_socketfilterfw() {
  local description="$1"
  local flag="$2"
  local value="$3"
  local fw=/usr/libexec/ApplicationFirewall/socketfilterfw

  if [ "${DRY_RUN_MODE:-false}" = true ]; then
    msg_info "[Dry Run] Would run: sudo $fw $flag $value"
    return 0
  fi

  if [ ! -x "$fw" ]; then
    msg_warning "socketfilterfw not found; cannot configure: $description"
    return 1
  fi

  if sudo "$fw" "$flag" "$value" >/dev/null 2>&1; then
    msg_success "$description"
  else
    msg_warning "Could not apply: $description"
  fi
}

#
# @description
#   Portable in-place sed.
#
#   BSD sed (what macOS ships) requires an argument to -i, so the idiom is
#   `sed -i '' 's/x/y/' file`. GNU sed (Linux) must NOT have one: it reads the
#   '' as the script and then treats the real script as a filename, failing with
#   "can't read s/x/y/: No such file or directory".
#
#   The repository claims Linux support, so every in-place edit has to go
#   through this rather than hardcoding one platform's spelling.
#
# @param $1 The sed script, e.g. 's/foo/bar/'
# @param $@ One or more files to edit in place.
#
sed_inplace() {
  local script="$1"
  shift

  # GNU sed understands --version; BSD sed does not.
  if sed --version >/dev/null 2>&1; then
    sed -i -e "$script" "$@"
  else
    sed -i '' -e "$script" "$@"
  fi
}

export -f run_defaults run_sudo run_socketfilterfw fetch_verified_script sed_inplace

# ------------------------------------------------------------------------------
# SECTION: VERSION COMPARISON FUNCTIONS
# ------------------------------------------------------------------------------

#
# @description
#   Compares two semantic version strings (e.g., "1.2.3").
#   Returns 0 if v1 == v2, 1 if v1 > v2, 2 if v1 < v2.
#
# @param $1 First version string
# @param $2 Second version string
# @return 0 if equal, 1 if first > second, 2 if first < second
#
# @example
#   version_compare "1.2.0" "1.1.0"  # returns 1 (first is greater)
#   version_compare "1.0.0" "1.0.0"  # returns 0 (equal)
#   version_compare "1.0.0" "2.0.0"  # returns 2 (first is less)
#
version_compare() {
  local v1="$1"
  local v2="$2"

  # If they're equal, return 0
  if [ "$v1" = "$v2" ]; then
    return 0
  fi

  # Split versions into arrays.
  # SC2206 disabled deliberately: splitting on IFS='.' is exactly what is wanted
  # here, and the inputs are already validated as dotted version numbers.
  local IFS='.'
  # shellcheck disable=SC2206
  local -a v1_parts=($v1)
  # shellcheck disable=SC2206
  local -a v2_parts=($v2)

  # Compare each part
  local max_parts=${#v1_parts[@]}
  [ ${#v2_parts[@]} -gt $max_parts ] && max_parts=${#v2_parts[@]}

  for ((i = 0; i < max_parts; i++)); do
    local part1=${v1_parts[i]:-0}
    local part2=${v2_parts[i]:-0}

    if [ "$part1" -gt "$part2" ]; then
      return 1  # v1 > v2
    elif [ "$part1" -lt "$part2" ]; then
      return 2  # v1 < v2
    fi
  done

  return 0  # Equal
}

#
# @description
#   Checks if a migration version range applies to an upgrade path.
#   Returns 0 (true) if the migration should run, 1 (false) otherwise.
#
# @param $1 Migration "from" version (e.g., "1.0.0")
# @param $2 Migration "to" version (e.g., "1.1.0")
# @param $3 Old installed version (before update)
# @param $4 New installed version (after update)
# @return 0 if migration should run, 1 otherwise
#
# @example
#   # Upgrading from 1.0.0 to 1.2.0
#   version_in_range "1.0.0" "1.1.0" "1.0.0" "1.2.0"  # returns 0 (should run)
#   version_in_range "1.1.0" "1.2.0" "1.0.0" "1.2.0"  # returns 0 (should run)
#   version_in_range "1.2.0" "1.3.0" "1.0.0" "1.2.0"  # returns 1 (should NOT run)
#
version_in_range() {
  local migration_from="$1"
  local migration_to="$2"
  local old_version="$3"
  local new_version="$4"

  # Migration should run if:
  # 1. migration_from >= old_version (migration starts at or after where we were)
  # 2. migration_to <= new_version (migration ends at or before where we're going)

  # Check: migration_from >= old_version
  version_compare "$migration_from" "$old_version"
  local from_cmp=$?
  if [ $from_cmp -eq 2 ]; then
    # migration_from < old_version, skip this migration
    return 1
  fi

  # Check: migration_to <= new_version
  version_compare "$migration_to" "$new_version"
  local to_cmp=$?
  if [ $to_cmp -eq 1 ]; then
    # migration_to > new_version, skip this migration
    return 1
  fi

  return 0
}

#
# @description
#   Reads the current version from the .version file.
#
# @return The version string, or "0.0.0" if not found.
#
get_current_version() {
  local version_file="${DOTFILES_ROOT:-.}/.version"
  if [ -f "$version_file" ]; then
    cat "$version_file" | tr -d '[:space:]'
  else
    echo "0.0.0"
  fi
}

export -f version_compare version_in_range get_current_version

# --- Trap Composition --------------------------------------------------------

#
# @description
#   Add a handler to a trap without discarding whatever is already installed.
#
#   Bash traps do not chain: `trap foo EXIT` silently replaces any existing
#   EXIT handler. Because these libraries are sourced into other processes,
#   that has already caused real damage — a bare `trap ui_cleanup EXIT` in
#   lib/ui.sh discarded bats' own EXIT trap, so failing tests reported nothing
#   and appeared as "Executed N instead of expected M".
#
#   lib/security.sh had two independent registrars doing the same thing:
#   sudo_register_cleanup (drop sudo credentials) and
#   secure_temp_register_cleanup (remove temp files holding secrets). Whichever
#   ran second silently won, so registering both meant one of them never fired
#   — either credentials stayed cached or secrets stayed on disk.
#
# @param $1 The command to run
# @param $@ The signals to attach it to (default: EXIT)
#
# @example
#   add_exit_trap 'sudo_drop' EXIT INT TERM
#
add_exit_trap() {
  local handler="$1"
  shift
  local signals=("$@")
  [ ${#signals[@]} -eq 0 ] && signals=("EXIT")

  local sig
  for sig in "${signals[@]}"; do
    local existing prev_cmd
    existing=$(trap -p "$sig")

    if [ -n "$existing" ]; then
      # `trap -p SIG` prints: trap -- 'command' SIG
      prev_cmd=${existing#trap -- \'}
      prev_cmd=${prev_cmd%\' "$sig"}

      # Already registered: do not stack duplicates. Registering twice would
      # run the handler twice, and sudo_drop/secure_temp_cleanup are not
      # required to be idempotent.
      case "$prev_cmd" in
        *"$handler"*) continue ;;
      esac

      # SC2064 disabled deliberately: the composed command must capture the
      # CURRENT text of the previous handler, not defer expansion to trap time.
      # shellcheck disable=SC2064
      trap "${handler}; ${prev_cmd}" "$sig"
    else
      # shellcheck disable=SC2064
      trap "${handler}" "$sig"
    fi
  done
}

export -f add_exit_trap
