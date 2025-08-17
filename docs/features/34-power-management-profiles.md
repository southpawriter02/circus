# Feature Proposal: 34 - Power Management Profiles

## 1. Feature Overview

This feature introduces a new command, `fc power`, for quickly switching between different power management profiles on a MacBook. This will allow users to easily optimize their system for either performance or battery life.

**User Benefit:** Provides a simple way to manage the trade-off between performance and battery life without digging into System Settings. A user could switch to a "battery-saver" mode during a long flight, or a "max-performance" mode when doing computationally intensive work.

## 2. Design & Modularity

*   **Wrapper around `pmset`:** The command will be a user-friendly wrapper around the `pmset` command-line tool, which controls power management settings in macOS.
*   **Pre-defined Profiles:** The feature will come with a few pre-defined profiles:
    *   `default`: The standard macOS power settings.
    *   `battery-saver`: A profile that aggressively saves power by, for example, sleeping the display and hard disk more quickly and reducing processor performance.
    *   `max-performance`: A profile that prioritizes performance by, for example, preventing the system from sleeping and keeping the processor at a higher speed.
*   **Command Structure:**
    *   `fc power switch <profile_name>`: Switches to the specified profile.
    *   `fc power status`: Shows the current power management settings.
*   **Custom Profiles:** Users will be able to define their own custom profiles in a configuration file (`~/.config/circus/power.conf`).

## 3. Security Considerations

*   **`sudo` Usage:** Modifying power settings with `pmset` requires `sudo` privileges. The `fc power` command will handle this securely.
*   **System Stability:** The pre-defined profiles will use safe and tested `pmset` configurations. Users will be warned that creating custom profiles with extreme settings could potentially impact system stability.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc power` command and the available profiles will be documented.
*   **New Guide:** A `docs/POWER_MANAGEMENT.md` guide will explain what each profile does and how to create custom profiles.
*   **Inline Comments:** The `fc-power` script will be commented to explain the `pmset` commands being used.

## 5. Implementation Plan

1.  **Create `fc-power` script:** Develop the new command in `lib/commands/`.
2.  **Define Profiles:** Research and define the `pmset` settings for the `battery-saver` and `max-performance` profiles.
3.  **Implement Switch Logic:** Write the logic to apply the settings for a given profile using `pmset`.
4.  **Implement Custom Profiles:** Add the ability to load and apply custom profiles from the configuration file.
5.  **Testing:** Add `bats` tests that mock the `pmset` command to test the profile switching logic.
6.  **Documentation:** Create the `docs/POWER_MANAGEMENT.md` guide and update `COMMANDS.md`.
