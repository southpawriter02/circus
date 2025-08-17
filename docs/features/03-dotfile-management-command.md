# Feature: 03 - Dotfile Management Command

## 1. Feature Overview

This feature will introduce a new `fc dotfiles` command to simplify the management of dotfiles within the repository. It will provide subcommands for common operations like adding a new dotfile to be tracked, listing all tracked dotfiles, and opening a dotfile for editing.

**User Benefit:** Lowers the friction of managing a large collection of dotfiles. Instead of manually moving files and creating symlinks, users can use a single, simple command. This encourages good organization and makes it easier to add new configurations to the repository.

## 2. Design & Modularity

*   **Single Responsibility:** The `fc-dotfiles` command will be a standalone script in `lib/commands/`, focused exclusively on dotfile operations.
*   **Symlink-Based:** The command will use the same symlinking approach as the main installer, ensuring consistency.
*   **Intelligent Home Directory Handling:** The command will correctly handle paths with `~` and `$HOME`, expanding them to the correct user's home directory.
*   **Command Structure:**
    *   `fc dotfiles add <path-to-file>`: Moves the specified file into the appropriate `profiles/` subdirectory and creates a symlink from the original location.
    *   `fc dotfiles list`: Displays a list of all dotfiles currently being managed and their symlink status.
    *   `fc dotfiles edit <dotfile-name>`: Opens a managed dotfile in the user's default editor (`$EDITOR`).

## 3. Security Considerations

*   **File Overwrites:** The `add` command will check if a file with the same name already exists in the `profiles/` directory and will prompt the user for confirmation before overwriting.
*   **Permissions:** When moving files, the original file permissions will be preserved.
*   **Path Manipulation:** Input paths will be carefully sanitized to prevent any malicious path traversal attacks (e.g., `../../...`).

## 4. Documentation Plan

*   **`COMMANDS.md`:** A new section for the `fc dotfiles` command will be added.
*   **`DOTFILES.md`:** The main guide on dotfiles will be updated to recommend using the new command for managing dotfiles.
*   **Inline Comments:** The `fc-dotfiles` script will be well-commented.

## 5. Implementation Plan

1.  **Command Script:** Create the `lib/commands/fc-dotfiles` script.
2.  **Implement `add`:**
    *   Logic to parse the input file path.
    *   Determine the correct subdirectory within `profiles/`.
    *   Move the file and create the symlink.
3.  **Implement `list`:**
    *   Logic to scan the `profiles/` directory and check the status of corresponding symlinks in the home directory.
4.  **Implement `edit`:**
    *   Logic to find the specified dotfile in the repository and open it with `$EDITOR`.
5.  **Testing:** Add `bats` tests for all subcommands, verifying file movements, symlink creation, and correct output.
6.  **Documentation:** Update `COMMANDS.md` and `DOTFILES.md`.
