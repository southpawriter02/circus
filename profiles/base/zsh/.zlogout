#!/usr/bin/env zsh

# ==============================================================================
#
# FILE:         .zlogout
#
# DESCRIPTION:  This file is sourced when a login shell exits. It is useful
#               for running cleanup tasks.
#
# ==============================================================================

# ==============================================================================
# Security Cleanup
#
# Clear sensitive environment variables to prevent credential leakage.
# This is especially important on shared systems or when using SSH.
# ==============================================================================

# Cloud provider credentials
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_ACCESS_KEY_ID

# API tokens
unset GITHUB_TOKEN
unset GITLAB_TOKEN
unset NPM_TOKEN
unset HOMEBREW_GITHUB_API_TOKEN

# Database credentials
unset DATABASE_PASSWORD
unset REDIS_PASSWORD
unset MONGO_PASSWORD

# ==============================================================================
# Terminal Cleanup
# ==============================================================================

#
# Clear the terminal screen on logout.
#
clear
