#!/usr/bin/env bash

# ==============================================================================
#
# Security Config: Firewall & Gatekeeper
#
# This script configures fundamental security settings for macOS, including
# the application firewall and Gatekeeper. It is sourced by Stage 12 of the
# main installer. It supports Dry Run mode.
#
# ==============================================================================

msg_info "Configuring Firewall and Gatekeeper settings..."

# --- Application Firewall ---------------------------------------------------
msg_info "Ensuring the application firewall is enabled..."

if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would run: fc firewall on"
else
  # We use our existing `fc` command to enable the firewall.
  # The `fc-firewall` script already handles sudo and messaging.
  "$DOTFILES_DIR/bin/fc" firewall on
fi

# --- Gatekeeper -------------------------------------------------------------
msg_info "Ensuring Gatekeeper is enabled..."

if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would run: sudo spctl --master-enable"
else
  # The `spctl --master-enable` command ensures that Gatekeeper is active
  # and enforcing the standard policy (allow apps from App Store and
  # identified developers).
  sudo spctl --master-enable
  msg_success "Gatekeeper is enabled."
fi

msg_success "Firewall and Gatekeeper settings applied."
