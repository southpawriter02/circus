# Feature Proposal: 04 - Application Cleaner

## 1. Feature Overview

This feature will add an `fc clean` command to help users free up disk space by removing unused applications, outdated Homebrew formulas, old cache files, and other system cruft.

**User Benefit:** Provides a simple, unified command to perform common system maintenance tasks that are often forgotten. This helps to keep the system running smoothly and reclaims disk space.

## 2. Design & Modularity

*   **Wrapper Command:** The `fc-clean` command will primarily act as a smart wrapper around existing system and Homebrew tools. This avoids reinventing the wheel.
*   **Categorized Cleaning:** The command will be structured with subcommands for different cleaning tasks, allowing users to target specific areas.
*   **Interactive by Default:** To prevent accidental data loss, the command will run in an interactive "dry run" mode by default, showing what it *would* delete. The user must pass a `--force` flag to actually perform the deletion.
*   **Command Structure:**
    *   `fc clean brew`: Runs `brew cleanup` and lists any installed formulas that are no longer in any `Brewfile`.
    *   `fc clean cache`: Clears common user and system cache directories.
    *   `fc clean logs`: Truncates or removes old log files.
    *   `fc clean all`: Runs all cleaning tasks.

## 3. Security Considerations

*   **Destructive Operation:** This command is inherently destructive. The interactive-by-default design is a key security measure. Clear, unambiguous warnings will be printed before any files are deleted.
*   **Permissions:** The command will run with user-level permissions. It will not attempt to delete files that require `sudo` unless explicitly designed to do so for a specific task, in which case it will use `sudo` in a limited and safe way.
*   **File Paths:** The paths to directories to be cleaned will be hardcoded in the script to avoid any risk of accidentally deleting the wrong directory.

## 4. Documentation Plan

*   **`COMMANDS.md`:** A new section for the `fc clean` command will be added, with clear warnings about its destructive nature.
*   **Inline Comments:** The `fc-clean` script will be commented to explain what each cleaning task does.

## 5. Implementation Plan

1.  **Command Script:** Create the `lib/commands/fc-clean` script.
2.  **Implement `brew` subcommand:**
    *   Logic to run `brew cleanup`.
    *   Logic to compare `brew list` with the contents of all `Brewfile`s to find "orphaned" packages.
3.  **Implement `cache` subcommand:**
    *   Identify a safe list of cache directories to clear (e.g., `~/Library/Caches/*`).
4.  **Implement `all` subcommand:**
    *   Logic to call the other subcommands in a sensible order.
5.  **Add Interactive Prompts:** Implement the "dry run" and `--force` flag logic.
6.  **Testing:** Add `bats` tests. This will involve creating dummy files and directories and verifying that the `clean` command removes them correctly.
7.  **Documentation:** Update `COMMANDS.md`.
