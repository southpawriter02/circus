# Feature Proposal: 28 - Time Machine Management Command

## 1. Feature Overview

This feature introduces a new command, `fc timemachine`, for managing macOS's built-in Time Machine backup system from the command line. It will provide a user-friendly wrapper around the `tmutil` command-line tool.

**User Benefit:** Provides a convenient way to interact with Time Machine without needing to open System Settings. It allows for scripting and automation of Time Machine tasks, such as starting a backup before a system update.

## 2. Design & Modularity

*   **Wrapper around `tmutil`:** The `fc timemachine` command will primarily be a wrapper around the powerful but sometimes complex `tmutil` tool. It will provide simpler, more memorable sub-commands.
*   **Command Structure:**
    *   `fc timemachine status`: Shows the current status of Time Machine backups.
    *   `fc timemachine start`: Starts a new backup.
    *   `fc timemachine stop`: Stops the current backup.
    *   `fc timemachine list`: Lists all available backups.
    *   `fc timemachine latest`: Shows the path to the latest backup.
    *   `fc timemachine add-exclusion <path>`: Adds a path to the exclusion list.
    *   `fc timemachine remove-exclusion <path>`: Removes a path from the exclusion list.
*   **Configuration:** The exclusion list can be managed from a configuration file in `~/.config/circus/timemachine.conf`.

## 3. Security Considerations

*   **`sudo` usage:** Many `tmutil` commands require `sudo` privileges. The `fc timemachine` command will manage this, prompting the user for a password when necessary and explaining why it's needed.
*   **No Data Access:** The command will only manage Time Machine metadata and control the backup process. It will not have access to the actual data within the backups.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc timemachine` command and its sub-commands will be fully documented.
*   **Inline Comments:** The script will be commented to explain the usage of the underlying `tmutil` commands.

## 5. Implementation Plan

1.  **Create `fc-timemachine` script:** Develop the new command in `lib/commands/`.
2.  **Implement Sub-commands:** Create functions for each of the sub-commands (`status`, `start`, `stop`, etc.) that call the appropriate `tmutil` command.
3.  **Handle `sudo`:** Implement logic to detect when `sudo` is needed and to prompt the user.
4.  **Configuration File:** Add logic to read exclusions from `~/.config/circus/timemachine.conf` and apply them using `tmutil addexclusion`.
5.  **Testing:** Add `bats` tests that mock the `tmutil` command to test the wrapper logic.
6.  **Documentation:** Update `COMMANDS.md` with the new command's documentation.
