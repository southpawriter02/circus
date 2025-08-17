# Feature Proposal: 43 - macOS Notification Integration

## 1. Feature Overview

This feature integrates macOS's native notification system into the framework. This will allow long-running commands to notify the user when they are complete, or to report on their status.

**User Benefit:** Improves the user experience for asynchronous tasks. A user can start a long process (like a backup or a system update), switch to another task, and receive a notification when the process is finished, instead of having to constantly check the terminal.

## 2. Design & Modularity

*   **Notification Helper Function:** A new helper function, `fc-notify`, will be created. This function will be a wrapper around a command-line tool that can send macOS notifications.
*   **Dependency:** The implementation will likely use a third-party tool like `terminal-notifier`, which is specifically designed for this purpose and offers more flexibility than trying to use AppleScript.
*   **Command Integration:** The `fc-notify` function will be integrated into existing long-running commands:
    *   `fc-sync`: "Backup complete" or "Backup failed".
    *   `fc-update`: "System update complete".
    *   `fc bootstrap`: "New machine setup complete".
*   **Notification Content:** Notifications will include the framework's icon, a clear title, and a message indicating the result of the operation.

## 3. Security Considerations

*   **Dependency Trust:** The `terminal-notifier` tool is widely used and trusted. It will be installed from Homebrew.
*   **User Annoyance:** The feature will be designed to be helpful, not annoying. Notifications will only be used for tasks that are genuinely long-running and where a notification is useful. The feature can be disabled with a configuration setting.

## 4. Documentation Plan

*   **New Guide:** A `docs/NOTIFICATIONS.md` guide will explain how the notification system works and how to enable or disable it.
*   **Inline Comments:** The `fc-notify` helper function will be well-commented.

## 5. Implementation Plan

1.  **Dependency:** Add `terminal-notifier` to the `Brewfile`.
2.  **Create `fc-notify` helper:** Develop the wrapper function in `lib/helpers.sh`. It will take the notification title and message as arguments.
3.  **Integrate with Commands:** Add calls to `fc-notify` at the end of long-running commands like `fc-sync` and `fc-update`.
4.  **Add Configuration:** Add a setting in `~/.config/circus/config.sh` to enable or disable notifications globally.
5.  **Testing:** Add `bats` tests that mock the `terminal-notifier` command to verify that notifications are being sent with the correct content.
6.  **Documentation:** Create the `docs/NOTIFICATIONS.md` guide.
