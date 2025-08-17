# Feature Proposal: 31 - VS Code Settings Sync

## 1. Feature Overview

This feature provides a new command, `fc vscode-sync`, to automate the backup and synchronization of Visual Studio Code settings, extensions, and keybindings. It will use a private GitHub Gist or a dedicated repository as the backend for storing the configuration.

**User Benefit:** Ensures a consistent VS Code setup across multiple machines. Users can easily restore their full IDE configuration on a new machine or keep their work and personal laptops in sync. This is a more robust solution than relying on the built-in settings sync, as it can be version-controlled and managed alongside the rest of the dotfiles.

## 2. Design & Modularity

*   **Backend Options:** The user can choose between using a GitHub Gist or a Git repository as the storage backend. This will be configured in `~/.config/circus/vscode.conf`.
*   **Command Structure:**
    *   `fc vscode-sync up`: Pushes the local VS Code settings to the remote backend.
    *   `fc vscode-sync down`: Pulls the remote settings and applies them locally.
    *   `fc vscode-sync status`: Shows the difference between the local and remote settings.
*   **VS Code CLI:** The implementation will leverage the `code` command-line interface provided by VS Code to manage extensions.
*   **File Management:** The script will handle the copying of `settings.json`, `keybindings.json`, and other relevant configuration files.

## 3. Security Considerations

*   **GitHub Token:** To use a private Gist or repository, a GitHub personal access token will be required. The script will retrieve this token securely from the configured secrets manager (e.g., 1Password, macOS Keychain).
*   **Sensitive Information in Settings:** Users will be warned against storing sensitive information directly in their `settings.json` file.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc vscode-sync` command and its sub-commands will be documented.
*   **New Guide:** A `docs/VSCODE_SYNC.md` guide will provide step-by-step instructions on how to set up the GitHub Gist/repository and configure the command.
*   **Inline Comments:** The `fc-vscode-sync` script will be well-commented.

## 5. Implementation Plan

1.  **Create `fc-vscode-sync` script:** Develop the new command in `lib/commands/`.
2.  **Implement Backend Logic:** Write functions to handle the interaction with both the GitHub Gist API and a standard Git repository.
3.  **VS Code CLI Integration:** Use `code --list-extensions` and `code --install-extension` to manage the list of installed extensions.
4.  **File Sync Logic:** Implement the logic to copy the relevant VS Code configuration files to and from a temporary local clone of the backend.
5.  **Secret Management:** Integrate with the secrets management system to retrieve the GitHub token.
6.  **Testing:** Add `bats` tests that mock the `code` CLI and the `git` commands.
7.  **Documentation:** Create the `docs/VSCODE_SYNC.md` guide and update `COMMANDS.md`.
