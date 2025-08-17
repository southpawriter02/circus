# Feature Proposal: 38 - Launchd Agent Management

## 1. Feature Overview

This feature introduces a new command, `fc launchd`, to simplify the management of `launchd` agents and daemons on macOS. It will provide a user-friendly wrapper around the `launchctl` command.

**User Benefit:** `launchd` is the standard way to manage background services on macOS, but `launchctl` can be unintuitive. This command will make it easier for users to list, start, stop, and manage their own custom services, such as background sync scripts or development servers.

## 2. Design & Modularity

*   **Wrapper around `launchctl`:** The command will translate simple, intuitive sub-commands into the more complex `launchctl` syntax.
*   **Command Structure:**
    *   `fc launchd list`: Lists all `launchd` agents owned by the current user.
    *   `fc launchd start <service_name>`: Loads and starts a service.
    *   `fc launchd stop <service_name>`: Stops and unloads a service.
    *   `fc launchd restart <service_name>`: Restarts a service.
    *   `fc launchd status <service_name>`: Shows the status of a service, including its PID if it's running.
*   **Service File Location:** The command will look for service `.plist` files in `~/Library/LaunchAgents/` by default.
*   **Managed Services:** The framework can ship with its own set of optional `launchd` services (e.g., for scheduled backups), which can be managed by this command.

## 3. Security Considerations

*   **Scope:** This command will be designed to manage user-level agents (`~/Library/LaunchAgents/`) only, not system-level daemons that require `sudo`. This limits the potential for misuse.
*   **Service Definition:** The user is responsible for the content of the `.plist` files they create. The `fc launchd` command only manages the loading and unloading of these files.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc launchd` command and its sub-commands will be documented.
*   **New Guide:** A `docs/BACKGROUND_SERVICES.md` guide will be created to explain the basics of `launchd` and how to create `.plist` files for use with this command.
*   **Inline Comments:** The `fc-launchd` script will be commented to explain the `launchctl` commands being used.

## 5. Implementation Plan

1.  **Create `fc-launchd` script:** Develop the new command in `lib/commands/`.
2.  **Implement Sub-commands:** Write the functions for `list`, `start`, `stop`, `restart`, and `status`, which will call the appropriate `launchctl` commands.
3.  **Service Name to File Path:** Implement logic to translate a service name (e.g., `com.mydomain.myservice`) into the full path to the `.plist` file.
4.  **Error Handling:** Add robust error handling to provide clear messages when `launchctl` fails.
5.  **Testing:** Add `bats` tests that mock the `launchctl` command to test the service management logic.
6.  **Documentation:** Create the `docs/BACKGROUND_SERVICES.md` guide and update `COMMANDS.md`.
