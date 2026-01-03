# ==============================================================================
# Security Agent Configuration
#
# Environment variables for security tools like GPG and SSH.
# ==============================================================================

# --- GPG Configuration --------------------------------------------------------

# GPG TTY for passphrase prompts
# Required for GPG to display pinentry dialogs in the terminal
export GPG_TTY=$(tty)

# GnuPG home directory
# Can be overridden to use a custom keyring location
export GNUPGHOME="${GNUPGHOME:-$HOME/.gnupg}"

# --- SSH Agent Configuration --------------------------------------------------

# Note: macOS uses the built-in SSH agent with Keychain integration.
# The settings below are for custom SSH agent configurations.

# Uncomment to use a custom SSH agent socket (e.g., for 1Password SSH agent)
# export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Uncomment to use gpg-agent for SSH authentication
# export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
