# Feature: 06 - Plugin System for `fc` command

## 1. Feature Overview

This feature will refactor the main `fc` command to support a plugin architecture. This will allow new commands to be added by simply dropping an executable script into a specific directory, making the tool more extensible and easier to maintain.

**User Benefit:** Decouples the core `fc` command from its subcommands. This makes it trivial for users to add their own custom commands without needing to modify the core repository scripts. It also simplifies the project structure.

## 2. Design & Modularity

*   **Directory-Based Plugins:** The system will define a plugin directory (e.g., `lib/plugins/`). Any executable file in this directory will be treated as a subcommand. For example, `lib/plugins/foo` would be available as `fc foo`.
*   **Dispatcher Logic:** The main `fc` script will be simplified to become a dispatcher. Its primary job will be to:
    1.  Scan the plugin directory.
    2.  Validate the incoming command against the list of available plugins.
    3.  Execute the corresponding plugin script, passing along any arguments.
*   **Core Commands as Plugins:** All existing `fc` commands (`info`, `sync`, `bluetooth`, etc.) will be refactored to become plugins and moved into the new directory.

## 3. Security Considerations

*   **Execution Path:** The dispatcher will execute plugin scripts using their full, absolute path. This prevents any PATH hijacking attacks.
*   **Permissions:** Plugins must have execute permissions (`+x`) to be recognized. The dispatcher will ignore any non-executable files.
*   **Plugin Vetting:** The documentation will advise users to only install plugins from trusted sources, as they are arbitrary code that will be executed on their machine.

## 4. Documentation Plan

*   **`ARCHITECTURE.md`:** The documentation on the project's architecture will be updated to describe the new plugin system.
*   **New Developer Guide:** A new guide, `docs/CREATING_PLUGINS.md`, will be created to explain how to develop and install new plugins for the `fc` command.
*   **Inline Comments:** The main `fc` dispatcher script will be heavily commented to explain the plugin loading and execution logic.

## 5. Implementation Plan

1.  **Create Plugin Directory:** Create the new `lib/plugins/` directory.
2.  **Refactor `fc` Dispatcher:**
    *   Rewrite the main `fc` script to scan the `lib/plugins/` directory.
    *   Implement the logic to dynamically build the list of available commands.
    *   Implement the logic to execute the correct plugin script.
3.  **Migrate Existing Commands:** Move all existing command scripts from `lib/commands/` to `lib/plugins/`.
4.  **Update Help Output:** The main `fc --help` output will need to be dynamically generated based on the available plugins.
5.  **Testing:** Update the `bats` tests to reflect the new command structure. Add tests specifically for the dispatcher logic (e.g., it correctly finds plugins, it rejects unknown commands).
6.  **Documentation:** Update `ARCHITECTURE.md` and create `docs/CREATING_PLUGINS.md`.
