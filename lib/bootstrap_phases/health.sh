#!/usr/bin/env bash

# ==============================================================================
#
# PHASE:        health
#
# DESCRIPTION:  Run final health checks and generate a bootstrap report.
#               Verifies that the system is properly configured.
#
# ==============================================================================

# --- Run Health Check ---
run_health_check() {
  msg_info "Running health check..."
  echo ""

  if [ -x "$DOTFILES_ROOT/bin/fc" ]; then
    "$DOTFILES_ROOT/bin/fc" healthcheck 2>/dev/null || {
      msg_warning "Health check reported some issues."
      msg_info "Review the output above and address any warnings."
    }
  else
    msg_warning "fc command not available. Skipping health check."
  fi
}

# --- Run Quick Security Audit ---
run_security_audit() {
  msg_info "Running quick security audit..."
  echo ""

  if [ -x "$DOTFILES_ROOT/bin/fc" ]; then
    # Try running audit if available
    "$DOTFILES_ROOT/bin/fc" audit quick 2>/dev/null || {
      # Audit command might not exist yet
      msg_info "Security audit not available or reported issues."
    }
  fi
}

# --- Check Critical Components ---
check_critical_components() {
  msg_info "Verifying critical components..."
  echo ""

  local issues=0

  # Check Homebrew
  if command -v brew >/dev/null 2>&1; then
    msg_success "Homebrew: Installed"
  else
    msg_error "Homebrew: Not found"
    ((issues++))
  fi

  # Check Git
  if command -v git >/dev/null 2>&1; then
    local git_version
    git_version=$(git --version 2>/dev/null | awk '{print $3}')
    msg_success "Git: $git_version"
  else
    msg_error "Git: Not found"
    ((issues++))
  fi

  # Check Git configuration
  local git_name git_email
  git_name=$(git config --global user.name 2>/dev/null || echo "")
  git_email=$(git config --global user.email 2>/dev/null || echo "")

  if [ -n "$git_name" ] && [ -n "$git_email" ]; then
    msg_success "Git identity: $git_name <$git_email>"
  else
    msg_warning "Git identity: Not fully configured"
    ((issues++))
  fi

  # Check SSH key
  if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
    msg_success "SSH key: Found"
  else
    msg_warning "SSH key: Not found"
    ((issues++))
  fi

  # Check shell configuration
  if [ -f "$HOME/.zshrc" ] || [ -f "$HOME/.bashrc" ]; then
    msg_success "Shell config: Found"
  else
    msg_warning "Shell config: Not found"
    ((issues++))
  fi

  # Check circus config directory
  if [ -d "$HOME/.config/circus" ]; then
    msg_success "Circus config: Found"
  else
    msg_warning "Circus config: Not found"
    ((issues++))
  fi

  echo ""

  if [ "$issues" -eq 0 ]; then
    msg_success "All critical components verified."
  else
    msg_warning "$issues issue(s) found. Review the output above."
  fi

  return "$issues"
}

# --- Generate Bootstrap Report ---
generate_report() {
  local report_file="$HOME/.circus/bootstrap/report.txt"
  mkdir -p "$(dirname "$report_file")"

  msg_info "Generating bootstrap report..."

  {
    echo "=============================================="
    echo "fc bootstrap Report"
    echo "=============================================="
    echo ""
    echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Role: ${BOOTSTRAP_ROLE:-not set}"
    echo "Privacy Profile: ${BOOTSTRAP_PRIVACY_PROFILE:-standard}"
    echo "Restored from Backup: ${AUTO_RESTORE:-false}"
    echo ""
    echo "--- System Information ---"
    echo "macOS Version: $(sw_vers -productVersion 2>/dev/null || echo 'Unknown')"
    echo "Architecture: $(uname -m)"
    echo "Hostname: $(hostname)"
    echo ""
    echo "--- Installed Components ---"
    echo "Homebrew: $(brew --version 2>/dev/null | head -1 || echo 'Not installed')"
    echo "Git: $(git --version 2>/dev/null || echo 'Not installed')"
    echo "Zsh: $(zsh --version 2>/dev/null || echo 'Not installed')"
    echo ""
    echo "--- Configuration ---"
    echo "Git Name: $(git config --global user.name 2>/dev/null || echo 'Not set')"
    echo "Git Email: $(git config --global user.email 2>/dev/null || echo 'Not set')"
    echo "SSH Key: $([ -f "$HOME/.ssh/id_ed25519" ] && echo 'id_ed25519' || ([ -f "$HOME/.ssh/id_rsa" ] && echo 'id_rsa' || echo 'None'))"
    echo ""
    echo "--- Completed Phases ---"

    local state_dir="$HOME/.circus/bootstrap"
    if [ -d "$state_dir" ]; then
      for done_file in "$state_dir"/*.done; do
        if [ -f "$done_file" ]; then
          local phase_name
          phase_name=$(basename "$done_file" .done)
          local completed_time
          completed_time=$(cat "$done_file")
          echo "  ✓ $phase_name ($completed_time)"
        fi
      done
    fi

    echo ""
    echo "=============================================="
    echo "Bootstrap completed successfully!"
    echo "=============================================="
  } > "$report_file"

  msg_success "Report saved to: $report_file"
}

# --- Main Health Phase ---
msg_info "Running final health checks..."
echo ""

# Check critical components first
check_critical_components
echo ""

# Run fc healthcheck if available
run_health_check
echo ""

# Run quick audit if available
run_security_audit
echo ""

# Generate report
generate_report
echo ""

msg_success "Health phase complete."
