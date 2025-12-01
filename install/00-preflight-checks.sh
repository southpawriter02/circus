#!/usr/bin/env bash

# ==============================================================================
#
# Stage 0: Preflight Checks
#
# This script runs all preflight checks to ensure the system is ready for
# installation. It provides a visual checklist UI with spinners and aggregates
# results into a summary before proceeding.
#
# ==============================================================================

# --- Preflight Check Definitions ----------------------------------------------
# Each check is defined as: "script_name|display_name|critical"
# critical: "yes" = must pass, "no" = warning only
declare -a PREFLIGHT_CHECKS=(
  "preflight-01-macos-check.sh|macOS Detection|yes"
  "preflight-02-root-check.sh|Not Running as Root|yes"
  "preflight-03-admin-rights-check.sh|Admin Privileges|yes"
  "preflight-04-file-permissions-check.sh|File Permissions|no"
  "preflight-05-unset-vars-check.sh|Environment Variables|no"
  "preflight-06-shell-type-version-check.sh|Shell Version|no"
  "preflight-07-locale-encoding-check.sh|Locale & Encoding|no"
  "preflight-08-battery-check.sh|Battery & Power|no"
  "preflight-09-wifi-check.sh|Network Connectivity|no"
  "preflight-10-xcode-cli-check.sh|Xcode CLI Tools|yes"
  "preflight-11-homebrew-check.sh|Homebrew Status|no"
  "preflight-12-dependency-check.sh|Dependencies|no"
  "preflight-13-install-integrity-check.sh|Install Integrity|yes"
  "preflight-14-update-check.sh|Update Status|no"
  "preflight-15-existing-install-check.sh|Existing Installation|no"
  "preflight-16-backed-up-dotfiles-check.sh|Dotfiles Backup|no"
  "preflight-17-existing-dotfiles-check.sh|Existing Dotfiles|no"
  "preflight-18-icloud-check.sh|iCloud Sync|no"
  "preflight-19-terminal-type-check.sh|Terminal Type|no"
  "preflight-20-conflicting-processes-check.sh|Conflicting Processes|no"
  "preflight-21-install-sanity-check.sh|Installation Sanity|yes"
)

# --- Result Tracking ----------------------------------------------------------
declare -a CHECK_RESULTS=()
declare -a CHECK_NAMES=()
declare -a CHECK_CRITICAL=()
CHECKS_PASSED=0
CHECKS_WARNED=0
CHECKS_FAILED=0
CRITICAL_FAILURES=0

#
# Run a single preflight check with spinner UI
#
# @param $1 Script filename
# @param $2 Display name
# @param $3 Critical flag (yes/no)
#
run_preflight_check() {
  local script_name="$1"
  local display_name="$2"
  local is_critical="$3"
  local script_path="$DOTFILES_ROOT/install/preflight/$script_name"

  CHECK_NAMES+=("$display_name")
  CHECK_CRITICAL+=("$is_critical")

  # Check if script exists
  if [[ ! -f "$script_path" ]]; then
    CHECK_RESULTS+=("skipped")
    printf "  ${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} ${UI_MUTED}%-40s${UI_RESET} ${UI_WARNING}Skipped (not found)${UI_RESET}\n" "$display_name"
    ((CHECKS_WARNED++))
    return 0
  fi

  # Show spinner while running check
  printf "  ${UI_PRIMARY}${UI_ICON_PENDING}${UI_RESET} %-40s ${UI_MUTED}Checking...${UI_RESET}" "$display_name"

  # Run the check, capturing output
  local check_output
  local check_result

  # Source the script in a subshell to capture the result
  # Redirect output to suppress msg_* output during check
  check_output=$(
    # Override msg functions to be silent during check
    msg_info() { :; }
    msg_success() { :; }
    msg_warning() { :; }
    msg_error() { :; }
    msg_debug() { :; }
    export -f msg_info msg_success msg_warning msg_error msg_debug
    source "$script_path" 2>&1
    echo "EXIT_CODE:$?"
  )

  # Extract exit code from output
  check_result=$(echo "$check_output" | grep "EXIT_CODE:" | cut -d: -f2)
  [[ -z "$check_result" ]] && check_result=1

  # Clear the "Checking..." line
  printf "\r"

  # Display result
  if [[ "$check_result" -eq 0 ]]; then
    CHECK_RESULTS+=("passed")
    printf "  ${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} %-40s ${UI_SUCCESS}Passed${UI_RESET}\n" "$display_name"
    ((CHECKS_PASSED++))
  else
    if [[ "$is_critical" == "yes" ]]; then
      CHECK_RESULTS+=("failed")
      printf "  ${UI_ERROR}${UI_ICON_ERROR}${UI_RESET} %-40s ${UI_ERROR}Failed (Critical)${UI_RESET}\n" "$display_name"
      ((CHECKS_FAILED++))
      ((CRITICAL_FAILURES++))
    else
      CHECK_RESULTS+=("warned")
      printf "  ${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} %-40s ${UI_WARNING}Warning${UI_RESET}\n" "$display_name"
      ((CHECKS_WARNED++))
    fi
  fi

  return "$check_result"
}

#
# Display the preflight summary
#
display_preflight_summary() {
  local total_checks=${#CHECK_RESULTS[@]}

  echo ""
  printf "${UI_MUTED}"
  printf '%*s' 60 '' | tr ' ' "$UI_BOX_H_S"
  printf "${UI_RESET}\n"

  # Summary statistics
  printf "${UI_BOLD}Preflight Summary${UI_RESET}\n"
  echo ""
  printf "  ${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} Passed:   ${UI_BOLD}%d${UI_RESET}\n" "$CHECKS_PASSED"
  printf "  ${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} Warnings: ${UI_BOLD}%d${UI_RESET}\n" "$CHECKS_WARNED"
  printf "  ${UI_ERROR}${UI_ICON_ERROR}${UI_RESET} Failed:   ${UI_BOLD}%d${UI_RESET}\n" "$CHECKS_FAILED"
  echo ""

  # Overall status
  if [[ $CRITICAL_FAILURES -gt 0 ]]; then
    ui_notice "error" "Critical checks failed. Installation cannot proceed safely."
    return 1
  elif [[ $CHECKS_WARNED -gt 0 ]]; then
    ui_notice "warning" "Some checks produced warnings. Installation can proceed."
    return 0
  else
    ui_notice "success" "All preflight checks passed. System is ready for installation."
    return 0
  fi
}

#
# Main preflight orchestrator
#
main() {
  msg_info "Stage 0: Preflight System Checks"

  # Header
  echo ""
  ui_box_top "System Readiness Checks" 60 "single"
  ui_box_line "" 60 "single"
  ui_box_line "  Running ${#PREFLIGHT_CHECKS[@]} preflight checks to verify" 60 "single"
  ui_box_line "  your system is ready for installation." 60 "single"
  ui_box_line "" 60 "single"
  ui_box_bottom 60 "single"
  echo ""

  # Run all checks
  printf "${UI_BOLD}Running Preflight Checks...${UI_RESET}\n"
  printf "${UI_MUTED}"
  printf '%*s' 60 '' | tr ' ' "$UI_BOX_H_S"
  printf "${UI_RESET}\n"
  echo ""

  for check_def in "${PREFLIGHT_CHECKS[@]}"; do
    IFS='|' read -r script_name display_name is_critical <<< "$check_def"
    run_preflight_check "$script_name" "$display_name" "$is_critical"
  done

  # Display summary
  display_preflight_summary
  local summary_result=$?

  # Handle critical failures
  if [[ $summary_result -ne 0 ]]; then
    echo ""
    printf "${UI_ERROR}${UI_BOLD}Cannot proceed with installation.${UI_RESET}\n"
    printf "${UI_MUTED}Please resolve the critical issues above and try again.${UI_RESET}\n"
    echo ""

    if [[ "${INTERACTIVE_MODE:-true}" == "true" ]] && [[ "${FORCE_MODE:-false}" != "true" ]]; then
      if ui_confirm "Would you like to continue anyway? (Not recommended)" "N"; then
        msg_warning "Continuing despite critical failures..."
        return 0
      else
        exit 1
      fi
    else
      exit 1
    fi
  fi

  # Ask to proceed if there were warnings
  if [[ $CHECKS_WARNED -gt 0 ]] && [[ "${INTERACTIVE_MODE:-true}" == "true" ]]; then
    echo ""
    if ! ui_confirm "Continue with installation despite warnings?" "Y"; then
      printf "${UI_INFO}${UI_ICON_INFO}${UI_RESET} Installation cancelled by user.\n"
      exit 0
    fi
  fi

  msg_success "Preflight checks complete."
}

main
