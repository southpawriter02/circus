# Feature Proposal: 29 - Granular Firewall Rule Management

## 1. Feature Overview

This feature enhances the existing `fc-firewall` command to provide more granular control over the macOS application firewall. It will allow users to add, remove, and list specific rules for individual applications from the command line.

**User Benefit:** Gives users advanced control over their firewall settings without needing to navigate the GUI. This is particularly useful for developers and system administrators who need to script firewall changes or manage rules for non-standard applications.

## 2. Design & Modularity

*   **Wrapper around `socketfilterfw`:** The macOS firewall is managed by `/usr/libexec/ApplicationFirewall/socketfilterfw`. The enhanced `fc-firewall` command will be a user-friendly wrapper around this tool.
*   **Enhanced Command Structure:**
    *   `fc-firewall list-apps`: Lists all applications with firewall rules.
    *   `fc-firewall add <path_to_app>`: Adds a new application to the firewall and blocks incoming connections.
    *   `fc-firewall allow <path_to_app>`: Modifies the rule for an application to allow incoming connections.
    *   `fc-firewall block <path_to_app>`: Modifies the rule for an application to block incoming connections.
    *   `fc-firewall remove <path_to_app>`: Removes an application and its rule from the firewall.
*   **Configuration-driven Rules:** Users can define a set of desired firewall rules in a configuration file (`~/.config/circus/firewall.conf`), and a new command `fc-firewall apply-rules` will enforce that state.

## 3. Security Considerations

*   **`sudo` Usage:** Managing firewall rules requires `sudo` privileges. The `fc-firewall` command will handle this securely.
*   **Default Deny:** The feature will encourage a "default deny" posture, where applications are blocked by default and only explicitly allowed if necessary.
*   **Rule Validation:** The script will perform basic validation on application paths to ensure that rules are not created for non-existent applications.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc-firewall` section will be significantly expanded to document the new sub-commands.
*   **New Guide:** A `docs/ADVANCED_FIREWALL.md` guide will be created to explain firewall concepts and provide examples of how to use the new commands.
*   **Inline Comments:** The `fc-firewall` script will be updated with comments explaining the `socketfilterfw` commands.

## 5. Implementation Plan

1.  **Refactor `fc-firewall`:** Reorganize the existing `fc-firewall` script to support the new command structure.
2.  **Implement Sub-commands:** Add functions for each of the new sub-commands (`list-apps`, `add`, `allow`, etc.) that call the appropriate `socketfilterfw` commands.
3.  **Configuration Loading:** Implement the logic for the `fc-firewall apply-rules` command to read the configuration file and apply the defined rules.
4.  **Error Handling:** Improve error handling to provide clear messages when `socketfilterfw` fails.
5.  **Testing:** Create `bats` tests that mock the `socketfilterfw` command to test the rule management logic.
6.  **Documentation:** Update `COMMANDS.md` and create the new `docs/ADVANCED_FIREWALL.md` guide.
