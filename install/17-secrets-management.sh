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
# @description Fetches a GitHub token from 1Password and configures Git to use it
#              for secure authentication over HTTPS.
#
configure_git_with_token() {
  # --- Configuration ---
  # Define the 1Password secret reference URI for your GitHub Personal Access Token.
  #
  # How to set this up in 1Password:
  # 1. Create a new item of type "Password".
  # 2. Name it something descriptive, like "GitHub PAT".
  # 3. Save your Personal Access Token in the "password" field of this item.
  # 4. Update the URI below to point to your vault, the item name, and the field.
  #    Example: op://<YourVault>/<ItemName>/password
  local github_token_uri="op://Personal/github.com/token"

  msg_info "Attempting to fetch GitHub token from 1Password..."

  # Fetch the token using the 1Password CLI.
  # The `op read` command will return a non-zero exit code if the secret is not found.
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

  # Configure Git to use the token for all HTTPS operations with github.com.
  # This replaces any `https://github.com/` URL with a URL that includes the
  # OAuth token for authentication.
  git config --global "url.https://oauth2:$github_token@github.com/.insteadOf" "https://github.com/"

  msg_success "Successfully configured Git to use the secure token from 1Password."
}

main() {
  msg_info "Stage 17: Secrets Management"

  # --- 1Password CLI Check ---
  if ! command -v op >/dev/null 2>&1; then
    msg_info "1Password CLI ('op') not found. Skipping secrets management."
    msg_info "To enable this feature, install the 1Password CLI and ensure you are signed in."
    return 0
  fi

  # Check if the user is signed in to the 1Password CLI
  # We use `op user get --me` as a more reliable check for a signed-in session.
  if ! op user get --me >/dev/null 2>&1; then
    msg_warning "You are not signed in to the 1Password CLI. Skipping secrets management."
    return 0
  fi

  msg_info "1Password CLI is installed and you are signed in. Proceeding with secrets deployment..."

  # --- Secrets Deployment ---
  configure_git_with_token

  # You can add more functions here to deploy other secrets.
  # For example:
  #   configure_npm_with_token
  #   deploy_license_keys

  msg_success "Secrets management stage complete."
}

main
