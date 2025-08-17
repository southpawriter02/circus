# Change Proposal: 20 - Secrets Management Integration

## 1. Feature Overview

This change will formalize and improve the integration with a secrets manager like 1Password. The `README.md` mentions this as a feature, but the implementation is not clear. This proposal is to create a dedicated `fc secrets` command to manage the process of fetching secrets and making them available to the system in a secure way.

**User Benefit:** Provides a secure, standardized, and documented way to manage API tokens, credentials, and other sensitive data. This is a critical feature for any developer who needs to work with protected resources.

## 2. Design & Modularity

*   **CLI Tool Wrapper:** The `fc secrets` command will be a wrapper around the official command-line tool for the chosen secrets manager (e.g., the 1Password CLI, `op`).
*   **Configuration File:** A new configuration file, `~/.config/circus/secrets.conf`, will define which secrets to fetch and where to put them.
    ```
    # secrets.conf
    # <secret-path-in-vault> <destination> [permissions]
    "op://vault/github_token/password" "env:GITHUB_TOKEN"
    "op://vault/aws_keys/credential" "~/.aws/credentials" "600"
    ```
*   **Destination Handlers:** The `fc secrets` command will support different kinds of destinations:
    *   `env:<VAR_NAME>`: The secret will be injected into a shell environment file (e.g., `~/.zshenv.local`).
    *   `<path>`: The secret will be written to the specified file path.
*   **Command Structure:**
    *   `fc secrets sync`: Reads the `secrets.conf` file and syncs all defined secrets.
    *   `fc secrets get <op-url>`: Fetches and prints a single secret to standard output.

## 3. Security Considerations

*   **Secrets Manager as Source of Truth:** The user's secrets manager (e.g., 1Password) remains the secure source of truth. The local files are just a cache.
*   **File Permissions:** When syncing secrets to files, the command will use the permissions specified in the config file, defaulting to a secure `600`.
*   **Environment Variables:** Secrets stored in environment files are less secure than those in protected files. The documentation will clearly explain the trade-offs.
*   **Authentication:** The `fc secrets` command will rely on the underlying CLI tool (`op`) to handle authentication with the secrets manager.

## 4. Documentation Plan

*   **`COMMANDS.md`:** A new section for `fc secrets` will be added.
*   **New Guide:** A new `docs/SECRETS.md` guide will be created to explain the entire secrets management workflow, including how to set up the 1Password CLI and how to write the `secrets.conf` file.

## 5. Implementation Plan

1.  **Dependency:** Add the `1password-cli` package to the `Brewfile`.
2.  **Command Script:** Create the `lib/commands/fc-secrets` script.
3.  **Implement `sync`:**
    *   Logic to parse the `secrets.conf` file.
    *   A loop that iterates through the defined secrets.
    *   Inside the loop, call `op read` to fetch the secret.
    *   Logic to write the secret to the correct destination (environment file or path).
4.  **Implement `get`:**
    *   A simple wrapper around `op read`.
5.  **Testing:** This is difficult to test in a CI environment. The `bats` tests will focus on testing the parsing of the config file and the logic for the different destination types, likely by mocking the `op` command.
6.  **Documentation:** Update `COMMANDS.md` and create `docs/SECRETS.md`.
