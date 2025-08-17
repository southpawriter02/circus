# Feature Proposal: 08 - SSH Key Management

## 1. Feature Overview

This feature will add an `fc ssh` command to simplify and standardize SSH key management. It will provide subcommands for generating new keys with recommended settings, adding them to the ssh-agent, and copying public keys to the clipboard for easy use with services like GitHub or GitLab.

**User Benefit:** Abstracts away the complexities of `ssh-keygen` and `ssh-add`. Provides a simple, memorable command for common SSH key operations, reducing errors and encouraging good security practices (like using modern key algorithms).

## 2. Design & Modularity

*   **Wrapper with Best Practices:** The command will be a smart wrapper around the native `ssh-keygen` and `ssh-add` commands. It will enforce best practices by default, such as using the `ed25519` algorithm and prompting for a strong passphrase.
*   **Configuration Integration:** The command will be aware of the `~/.ssh/config` file and could in the future be extended to help manage it.
*   **Command Structure:**
    *   `fc ssh generate <key-name>`: Generates a new SSH key pair with a given name.
    *   `fc ssh add <key-name>`: Adds an existing key to the `ssh-agent` and macOS Keychain.
    *   `fc ssh copy <key-name>`: Copies the public key to the system clipboard.
    *   `fc ssh list`: Lists all available SSH key pairs in `~/.ssh`.

## 3. Security Considerations

*   **Passphrases:** The `generate` command will strongly recommend and facilitate the use of a strong passphrase for all new keys.
*   **Keychain Integration:** The `add` command will use the `-K` flag on macOS to store the passphrase in the user's keychain, so they don't have to type it repeatedly. This is a secure way to manage passphrases.
*   **Permissions:** The command will ensure that any generated private keys have strict file permissions (`600`).
*   **No Private Key Exposure:** The `copy` command will only ever interact with the public key (`.pub`) file. Private keys will not be read or exposed.

## 4. Documentation Plan

*   **`COMMANDS.md`:** A new section for `fc ssh` will be added, explaining the subcommands and the recommended workflow.
*   **Security Guide:** A section could be added to a security-focused guide explaining the importance of using strong SSH keys.
*   **Inline Comments:** The `fc-ssh` script will be well-commented.

## 5. Implementation Plan

1.  **Command Script:** Create the `lib/commands/fc-ssh` script.
2.  **Implement `generate`:**
    *   Wrap `ssh-keygen -t ed25519 -C "user@hostname"`.
    *   Prompt for a passphrase.
3.  **Implement `add`:**
    *   Wrap `ssh-add -K ~/.ssh/<key-name>`.
4.  **Implement `copy`:**
    *   Logic to read the `.pub` file and pipe it to `pbcopy`.
5.  **Implement `list`:**
    *   Logic to scan the `~/.ssh` directory for key pairs.
6.  **Testing:** Add `bats` tests. This will involve generating dummy key files and verifying that the commands perform the correct actions.
7.  **Documentation:** Update `COMMANDS.md`.
