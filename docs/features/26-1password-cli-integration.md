# Feature Proposal: 26 - 1Password CLI Integration

## 1. Feature Overview

This feature integrates the 1Password CLI (`op`) into the framework, allowing for secure retrieval of secrets (API keys, tokens, passwords) directly from a user's 1Password vault. This provides a more secure alternative to storing secrets in plaintext configuration files.

**User Benefit:** Greatly enhances security by allowing users to manage their secrets in a dedicated secrets manager. Scripts can fetch credentials on-the-fly, avoiding the need to store them on disk.

## 2. Design & Modularity

*   **Helper Functions:** A new set of helper functions, likely in `lib/secrets.sh`, will be created to wrap the `op` command. For example, `get_secret <vault> <item> <field>`.
*   **Configuration:** The `~/.config/circus/secrets.conf` file will be updated to allow specifying `1password` as a backend. Users will configure the vault and item names in this file.
*   **Command Integration:** Existing commands that require secrets (like `fc-sync` for remote storage) will be updated to use the new secret-fetching helper functions if 1Password is configured as the backend.
*   **Authentication:** The user will be responsible for authenticating with the `op` CLI. The scripts will check if the user is authenticated and provide instructions if not.

## 3. Security Considerations

*   **1Password CLI:** The feature relies entirely on the security of the official 1Password CLI. The tool will be installed from Homebrew.
*   **Authentication State:** The scripts must never cache the master password. They will rely on the `op` tool's own session management.
*   **Error Handling:** The scripts will need to handle cases where a secret cannot be retrieved (e.g., user not logged in, secret not found) gracefully and without leaking any information.

## 4. Documentation Plan

*   **`SECRETS_MANAGEMENT.md`:** This existing document will be updated with a new section on how to configure and use the 1Password integration.
*   **`COMMANDS.md`:** Commands that can use this integration will be updated to mention it.
*   **Inline Comments:** The new helper functions will be well-commented.

## 5. Implementation Plan

1.  **Dependency:** Add the `1password-cli` package to the `Brewfile`.
2.  **Helper Functions:** Create the `get_secret` and other wrapper functions for the `op` command.
3.  **Configuration:** Update the secrets configuration to support `1password` as a backend.
4.  **Refactor Commands:** Modify existing commands (e.g., `fc-sync`) to use the new secret-fetching functions.
5.  **Authentication Check:** Add a function to check the `op` authentication status and guide the user if they need to sign in.
6.  **Testing:** Add `bats` tests that mock the `op` CLI calls to test the secret retrieval logic.
7.  **Documentation:** Update the documentation with instructions for the 1Password integration.
