# Feature Proposal: 23 - Interactive `fc` Command

## 1. Feature Overview

This feature introduces an interactive mode for the `fc` command, triggered by `fc --interactive` or `fc -i`. This mode will present the user with a menu of available commands, making the framework more approachable for new users and easier to explore for experienced users.

**User Benefit:** Lowers the barrier to entry for using the framework. Users no longer need to remember all the specific commands; they can instead navigate through a user-friendly interactive menu to find and execute the command they need.

## 2. Design & Modularity

*   **Interactive Menu:** The interactive mode will use a tool like `gum` or a custom shell script using `select` to create a professional-looking and navigable menu.
*   **Command Discovery:** The menu will be dynamically populated by parsing the available `fc` command scripts in the `lib/commands/` directory. This ensures that new commands are automatically included in the interactive menu.
*   **Sub-menus:** For commands with sub-commands (like `fc sync`), the interactive mode will present nested sub-menus for a more organized experience.

## 3. Security Considerations

*   **Command Execution:** The interactive mode is simply a wrapper around the existing `fc` commands. It does not introduce any new security risks, as it only executes the same underlying scripts.
*   **Dependency:** If a third-party tool like `gum` is used, it will be vetted and installed from a trusted source (Homebrew).

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `--interactive` flag will be documented.
*   **`README.md`:** The interactive mode will be highlighted in the main `README.md` as a key feature for new users.
*   **Inline Comments:** The script for the interactive mode will be well-commented.

## 5. Implementation Plan

1.  **Dependency:** Add `gum` or another suitable menu-building tool to the `Brewfile`.
2.  **Create `fc-interactive` script:** Develop a new script that generates and handles the interactive menu.
3.  **Modify `fc` dispatcher:** Add logic to the main `fc` script to launch the interactive mode when the `--interactive` or `-i` flag is used.
4.  **Command Parsing:** Implement logic to scan the `lib/commands/` directory and generate a list of available commands for the menu.
5.  **Testing:** Create `bats` tests for the interactive mode's logic.
6.  **Documentation:** Update `COMMANDS.md` and `README.md`.
