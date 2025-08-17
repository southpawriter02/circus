# Feature Proposal: 36 - Desktop Organizer

## 1. Feature Overview

This feature introduces a new command, `fc organize-desktop`, that cleans up the user's desktop by moving files into organized, date-stamped folders.

**User Benefit:** Many users use their desktop as a temporary storage area, which can quickly become cluttered. This command provides a one-step way to tidy up the desktop without deleting anything, improving organization and reducing visual noise.

## 2. Design & Modularity

*   **Default Behavior:** By default, the command will move all files and folders on the desktop (except for aliases/symlinks) into a new folder inside `~/Desktop/Archive/`, named with the current date (e.g., `2023-10-27`).
*   **Command Structure:**
    *   `fc organize-desktop`: Performs the default cleanup.
    *   `fc organize-desktop --dry-run`: Shows which files would be moved without actually moving them.
    *   `fc organize-desktop --group-by-type`: Instead of a single date-stamped folder, it creates sub-folders for different file types (e.g., `Images`, `Documents`, `Screenshots`).
*   **Configuration:** A configuration file, `~/.config/circus/desktop.conf`, will allow users to:
    *   Specify a different archive folder.
    *   Define a list of filenames or patterns to ignore (e.g., `"*.nosync"`).
    *   Customize the file type groupings.

## 3. Security Considerations

*   **File Moves, Not Deletes:** The command will only move files; it will never delete them. This makes it a safe operation.
*   **Permissions:** The command will ensure that all moved files retain their original permissions.
*   **Dry Run Mode:** The inclusion of a `--dry-run` mode allows users to verify the command's actions before it makes any changes.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The new `fc organize-desktop` command will be documented.
*   **Inline Comments:** The script will be commented to explain the file organization logic.

## 5. Implementation Plan

1.  **Create `fc-organize-desktop` script:** Develop the new command in `lib/commands/`.
2.  **Implement Core Logic:** Write the shell script logic to iterate through files on the desktop and move them to the archive folder.
3.  **Implement Dry Run Mode:** Add the logic for the `--dry-run` flag.
4.  **Implement Grouping Logic:** Add the logic for the `--group-by-type` flag, which will involve inspecting file extensions.
5.  **Add Configuration:** Implement the logic to read the configuration file and apply the custom settings.
6.  **Testing:** Add `bats` tests that create dummy files on a temporary desktop and verify that the command organizes them correctly.
7.  **Documentation:** Update `COMMANDS.md` with the new command's documentation.
