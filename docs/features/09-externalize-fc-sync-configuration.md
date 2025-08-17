# Improvement Proposal: 09 - Externalize `fc-sync` Configuration

## 1. Feature Overview

This improvement will refactor the `fc-sync` command to move its hardcoded configuration (GPG Key ID, list of directories to back up) into a dedicated, user-managed configuration file.

**User Benefit:** Users can easily customize what gets backed up without having to modify the core `fc-sync` script. This makes the feature more flexible and avoids the risk of users breaking the script or having their changes overwritten by a future `git pull`.

## 2. Design & Modularity

*   **Configuration File:** A new configuration file, `~/.config/circus/sync.conf`, will be introduced. It will use a simple `KEY="value"` shell script format so it can be easily sourced.
*   **Template:** A template file, `sync.conf.template`, will be provided in the repository to show users what options are available and how to format the file.
*   **Sourcing Logic:** The `fc-sync` script will be updated to check for the existence of `~/.config/circus/sync.conf` and source it at runtime. If the file doesn't exist, the script will fall back to sensible defaults or print a helpful error message prompting the user to create one.
*   **Configuration Variables:**
    *   `GPG_RECIPIENT_ID`: The GPG key ID for encryption.
    *   `BACKUP_TARGETS`: An array of files and directories to back up.

## 3. Security Considerations

*   **File Sourcing:** Since the configuration file is a shell script that will be sourced, it could potentially contain malicious code. The documentation must clearly warn users to only put configuration variables in this file and not to run code from untrusted sources.
*   **Permissions:** The script could optionally check the permissions on the config file to ensure it is not world-writable.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc sync` section will be updated to explain the new configuration file.
*   **Inline Comments:** The `fc-sync` script will be updated to explain the new configuration loading logic.
*   **Template Comments:** The `sync.conf.template` file itself will be heavily commented to serve as documentation.

## 5. Implementation Plan

1.  **Create Template:** Create the `sync.conf.template` file with commented-out examples.
2.  **Refactor `fc-sync`:**
    *   Add logic at the top of the script to check for and source `~/.config/circus/sync.conf`.
    *   Replace the hardcoded `GPG_RECIPIENT_ID` and `BACKUP_TARGETS` variables with the ones loaded from the config file.
    *   Add error handling for when the GPG key is not configured.
3.  **Installer Integration:** The main `install.sh` script could be updated to copy the template to `~/.config/circus/sync.conf` if it doesn't already exist, making setup easier for new users.
4.  **Testing:** Update the `bats` tests for `fc-sync` to test the new configuration file logic. This will involve creating a dummy config file as part of the test setup.
5.  **Documentation:** Update `COMMANDS.md`.
