#!/usr/bin/env bash

# ==============================================================================
#
# Stage 17: Secrets Management
#
# This script handles the deployment of sensitive information, such as API
# tokens and license keys, by fetching them from a secure password manager.
#
# This example uses the 1Password CLI (`op`).
#
# ==============================================================================

#
# @description Fetches a GitHub token from 1Password and securely stores it in
#              the macOS Keychain for Git to use.
#
configure_git_with_token() {
  # --- Configuration ---
  # Define the 1Password secret reference URI for your GitHub Personal Access Token.
  local github_token_uri="op://Personal/github.com/token"

  msg_info "Attempting to fetch GitHub token from 1Password..."

  # Fetch the token using the 1Password CLI.
  local github_token
  if ! github_token=$(op read "$github_token_uri" 2>/dev/null); then
    msg_warning "Could not find GitHub token at: $github_token_uri"
    msg_info "Please ensure you have created the item in 1Password and that the URI is correct."
    msg_info "Skipping Git token configuration."
    return
  fi

  if [ -z "$github_token" ]; then
    msg_warning "GitHub token at '$github_token_uri' is empty. Skipping."
    return
  fi

  # --- Secure Token Storage ---

  # 1. Configure Git to use the macOS Keychain for credential storage.
  #    This is a one-time setup that makes Git use the helper.
  git config --global credential.helper osxkeychain
  msg_info "Configured Git to use the macOS Keychain for credential storage."

  # 2. Securely store the fetched token in the Keychain.
  #    We pipe the credentials to the `git credential-osxkeychain` helper.
  #    This avoids having the token appear in process lists or shell history.
  #    The username 'oauth2' is standard for GitHub token authentication.
  printf "protocol=https
host=github.com
username=oauth2
password=%s" "$github_token" | git credential-osxkeychain store

  msg_success "Successfully and securely stored GitHub token in the macOS Keychain."
  msg_info "Git will now use this token for authentication with github.com."
}

main() {
  msg_info "Stage 17: Secrets Management"

  # --- 1Password CLI Check ---
  if ! command -v op >/dev/null 2>&1; then
    msg_info "1Password CLI ('op') not found. Skipping secrets management."
    msg_info "To enable this feature, install the 1Password CLI and ensure you are signed in."
    return 0
  fi

  if ! op user get --me >/dev/null 2>&1; then
    msg_warning "You are not signed in to the 1Password CLI. Skipping secrets management."
    return 0
  fi

  msg_info "1Password CLI is installed and you are signed in. Proceeding with secrets deployment..."

  # --- Secrets Deployment ---
  configure_git_with_token

  msg_success "Secrets management stage complete."
}

main
