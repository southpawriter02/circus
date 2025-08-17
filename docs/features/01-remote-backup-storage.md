# Feature: 01 - Remote Backup Storage

## 1. Feature Overview

This feature will extend the `fc sync` command to support uploading encrypted backup archives to remote cloud storage providers (e.g., Amazon S3, Google Drive, Dropbox, Backblaze B2). It will also update `fc sync restore` to fetch backups from these remote locations.

**User Benefit:** This provides a resilient, off-site backup strategy, protecting users from local data loss events like hardware failure or theft. It automates the "copy to external drive" step, making the backup process seamless and reliable.

## 2. Design & Modularity

The implementation will be highly modular to accommodate various storage providers easily in the future.

*   **Configuration:** A new configuration file, `~/.config/circus/storage.conf`, will store provider-specific settings (e.g., S3 bucket name, API keys, region). This keeps credentials and sensitive information out of the main script and version control.
*   **Provider Abstraction:** The core logic of `fc-sync` will be decoupled from the storage provider implementation. A new `lib/storage_providers/` directory will contain individual scripts for each provider (e.g., `s3.sh`, `rclone.sh`). Each script will implement a common interface with functions like `push`, `pull`, and `list`.
*   **Command Structure:** The `fc sync` command will gain new subcommands for clear user interaction:
    *   `fc sync push`: Pushes the latest local backup to the configured remote provider.
    *   `fc sync pull`: Pulls the latest backup from the remote provider to the local machine.
    *   `fc sync list-remote`: Lists available backups on the remote provider.

## 3. Security Considerations

*   **Credential Management:** Cloud provider credentials will be stored in `~/.config/circus/storage.conf`. The script will enforce strict file permissions (`600`) on this file. Users will be warned about storing sensitive credentials and advised to use environment variables or a secrets manager where possible.
*   **End-to-End Encryption:** The backup archives are already encrypted using GPG before they leave the user's machine. The remote storage provider will only ever have access to encrypted data, ensuring data privacy and confidentiality.
*   **Dependency Trust:** The implementation will rely on official and well-vetted command-line tools for each provider (e.g., `aws-cli`, `rclone`). These will be installed via Homebrew from trusted sources.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc sync` section will be updated to document the new `push`, `pull`, and `list-remote` subcommands.
*   **New Guide:** A new document, `docs/REMOTE_STORAGE.md`, will be created. It will provide detailed, step-by-step instructions on how to configure each supported cloud provider, including how to generate API keys and fill out the `storage.conf` file.
*   **Inline Comments:** The `fc-sync` script and new provider scripts will be thoroughly commented to explain the implementation details for future maintainers.

## 5. Implementation Plan

1.  **Dependency:** Select an initial provider (e.g., Amazon S3) and add its CLI tool (`aws-cli`) to the base `Brewfile`.
2.  **Configuration:** Create a `storage.conf.template` file to guide users.
3.  **Refactor `fc-sync`:** Modify `fc-sync` to read from `storage.conf` and to call provider-specific scripts based on the configuration.
4.  **Provider Script:** Create the first provider script, `lib/storage_providers/s3.sh`, implementing the `push` and `pull` logic.
5.  **Update `fc-sync` Commands:** Add the `push`, `pull`, and `list-remote` subcommands to the `fc-sync` dispatcher.
6.  **Testing:** Add new `bats` tests for the remote storage functionality, mocking the CLI calls where appropriate.
7.  **Documentation:** Update `COMMANDS.md` and create the new `docs/REMOTE_STORAGE.md` guide.
