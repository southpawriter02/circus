# Feature Proposal: 50 - Display Management

## 1. Feature Overview

This feature introduces a new command, `fc display`, for managing display settings from the command line. This includes changing screen resolution and managing the arrangement of multiple displays.

**User Benefit:** For users with multiple monitors or those who frequently connect to external displays (like projectors), this provides a scriptable way to manage display layouts. A user could have a script to instantly arrange their monitors into their preferred "work" or "presentation" layout.

## 2. Design & Modularity

*   **Dependency:** This is a complex area of macOS. The implementation will rely on a well-maintained third-party command-line tool, such as `displayplacer` or `m-cli`.
*   **Command Structure:**
    *   `fc display list`: Lists all connected displays and their current resolutions and arrangements.
    *   `fc display set-resolution <display_id> <resolution>`: Sets the resolution for a specific display.
    *   `fc display save-layout <layout_name>`: Saves the current arrangement of monitors (positions and resolutions) as a named profile.
    *   `fc display apply-layout <layout_name>`: Applies a previously saved layout.
*   **Layout Profiles:** The named layouts will be stored in a configuration file, `~/.config/circus/displays.conf`, which will store the output of the display management tool.

## 3. Security Considerations

*   **Dependency Trust:** The chosen third-party tool must be vetted and trusted. It will be installed from Homebrew.
*   **No `sudo` Required:** Managing display settings does not typically require `sudo`.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc display` command and its sub-commands will be documented.
*   **New Guide:** A `docs/DISPLAY_MANAGEMENT.md` guide will explain how to use the command to save and apply display layouts.
*   **Inline Comments:** The `fc-display` script will be commented to explain the underlying commands being used.

## 5. Implementation Plan

1.  **Dependency:** Choose a suitable display management tool and add it to the `Brewfile`.
2.  **Create `fc-display` script:** Develop the new command in `lib/commands/`.
3.  **Implement Wrapper Functions:** Write the functions for each sub-command (`list`, `set-resolution`, etc.) that call the underlying display management tool.
4.  **Implement Layout Profiles:** Write the logic to save the output of the tool to the configuration file and to apply it later.
5.  **Testing:** Add `bats` tests that mock the display management tool to verify that the correct commands are being called.
6.  **Documentation:** Create the `docs/DISPLAY_MANAGEMENT.md` guide and update `COMMANDS.md`.
