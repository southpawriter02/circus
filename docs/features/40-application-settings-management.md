# Feature Proposal: 40 - Application Settings Management

## 1. Feature Overview

This feature introduces a new command, `fc app-settings`, to manage application-specific settings using the `defaults` command-line tool. It will allow users to apply and back up `.plist` files or individual settings for macOS and other applications.

**User Benefit:** Provides a structured and version-controllable way to manage application preferences. Users can codify their preferred settings for the Finder, Dock, and other apps, and then apply them consistently on any machine. This is an extension of the existing `set-macos-defaults.sh` script, making it more modular and user-facing.

## 2. Design & Modularity

*   **Settings Repository:** Application settings will be stored in a dedicated directory, `system/macos/defaults/`, as a collection of shell scripts. Each script will contain the `defaults write` commands for a specific application (e.g., `finder.sh`, `dock.sh`).
*   **Command Structure:**
    *   `fc app-settings apply`: Applies all available settings.
    *   `fc app-settings apply <app_name>`: Applies the settings for a specific application (e.g., `fc app-settings apply finder`).
    *   `fc app-settings list`: Lists all the available application settings scripts.
*   **Backup and Restore (Future):** In a future iteration, the command could be extended to back up the current settings from an application into a script file.

## 3. Security Considerations

*   **`defaults` command:** The feature is a wrapper around the `defaults` command. While generally safe, incorrect settings could potentially cause an application to behave unexpectedly.
*   **No `sudo` required:** Managing user-level application settings does not require `sudo`.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc app-settings` command will be documented.
*   **New Guide:** A `docs/APP_SETTINGS.md` guide will explain how the system works and how users can add their own scripts to manage settings for other applications.
*   **Inline Comments:** The settings scripts themselves will be well-commented to explain what each `defaults write` command does.

## 5. Implementation Plan

1.  **Refactor existing scripts:** Move the logic from `set-macos-defaults.sh` and other similar scripts into the new `system/macos/defaults/` directory structure.
2.  **Create `fc-app-settings` command:** Develop the new command in `lib/commands/`.
3.  **Implement `apply` and `list` logic:** Write the logic to find and execute the settings scripts.
4.  **Create more settings scripts:** Expand the collection of settings scripts to cover more applications and macOS features.
5.  **Testing:** Add `bats` tests that mock the `defaults` command to verify that the correct commands are being called for a given application.
6.  **Documentation:** Create the `docs/APP_SETTINGS.md` guide and update `COMMANDS.md`.
