# Feature Proposal: 02 - Scheduled Backups

## 1. Feature Overview

This feature will provide a simple, robust way to automatically run `fc sync backup` on a schedule. It will use macOS's native `launchd` service for reliability and efficiency. A new `fc schedule` command will be created to manage the backup schedule (e.g., install, uninstall, and view status).

**User Benefit:** Automates the backup process, ensuring that users always have a recent backup without needing to remember to run the command manually. This "set it and forget it" approach significantly improves data protection.

## 2. Design & Modularity

*   **`launchd` Integration:** The system will leverage `launchd`, the standard way to run background tasks on macOS. This avoids the need for a custom daemon or third-party scheduler.
*   **`.plist` Template:** A template for the `launchd` property list (`.plist`) file will be stored in `etc/launchd/`. This template will define the job's schedule (e.g., daily) and the command to run.
*   **Dynamic Generation:** The `fc schedule install` command will read this template, substitute the correct path to the `fc` command, and save the generated `.plist` to `~/Library/LaunchAgents/`.
*   **Command Structure:** The new `fc schedule` command will have a clear, simple interface:
    *   `fc schedule install [--frequency daily|weekly]`: Installs and loads the backup job.
    *   `fc schedule uninstall`: Unloads and removes the backup job.
    *   `fc schedule status`: Reports whether the job is currently loaded and when it last ran.

## 3. Security Considerations

*   **Execution Context:** The backup job will run with the user's own permissions, ensuring it has access to the necessary files without requiring elevated privileges.
*   **Command Injection:** The `fc-schedule` script will be carefully written to avoid command injection vulnerabilities when generating the `.plist` file. The path to the `fc` command will be sanitized.
*   **Scope:** The `launchd` job will be installed in `~/Library/LaunchAgents/`, which is the standard, user-specific location. It will not touch system-wide directories like `/Library/LaunchDaemons/`.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc` command reference will be updated with a new section for `fc schedule`.
*   **New Guide:** A small section in a new or existing guide will explain the benefits of scheduled backups and how to use the command.
*   **Inline Comments:** The `fc-schedule` script and the `.plist` template will be well-commented.

## 5. Implementation Plan

1.  **`.plist` Template:** Create a `.plist` template file in `etc/launchd/com.southpawriter02.circus.backup.plist.template`.
2.  **Command Script:** Create the `lib/commands/fc-schedule` script.
3.  **Implement Subcommands:**
    *   `install`: Logic to generate, install, and load the `.plist`.
    *   `uninstall`: Logic to unload and remove the `.plist`.
    *   `status`: Logic to check the status of the `launchd` job.
4.  **Testing:** Add `bats` tests for the `fc-schedule` command. The tests will need to check for file creation and interact with `launchctl` to verify loading/unloading.
5.  **Documentation:** Update `COMMANDS.md`.
