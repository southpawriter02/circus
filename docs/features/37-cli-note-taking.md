# Feature Proposal: 37 - CLI Note-Taking

## 1. Feature Overview

This feature introduces a simple command-line note-taking utility, `fc note`. It will allow users to quickly create, view, and manage short, plain-text notes without leaving the terminal.

**User Benefit:** Provides a frictionless way to jot down quick thoughts, reminders, or snippets of code. It's faster than opening a full-fledged notes application and keeps the user in their terminal workflow.

## 2. Design & Modularity

*   **Storage:** Notes will be stored as individual plain-text or markdown files in a dedicated directory, `~/.config/circus/notes/`.
*   **Command Structure:**
    *   `fc note new "My new note"`: Creates a new note with the given text. The filename will be a timestamp.
    *   `fc note edit`: Opens the notes directory in the user's default `$EDITOR` for more complex editing.
    *   `fc note list`: Lists all existing notes with their creation date and a preview.
    *   `fc note show <id>`: Displays the full content of a specific note.
    *   `fc note search <pattern>`: Searches the content of all notes for a given pattern.
*   **Simplicity:** The focus is on simplicity and speed. The tool will not try to compete with more complex note-management systems.

## 3. Security Considerations

*   **Plain Text Storage:** Notes are stored in plain text. Users should be advised not to store sensitive information using this tool. For sensitive data, a secrets manager is the appropriate tool.
*   **Permissions:** The notes directory will be created with restricted permissions (`700`) so that only the user can access it.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc note` command and its sub-commands will be fully documented.
*   **Inline Comments:** The script will be commented to explain the file management logic.

## 5. Implementation Plan

1.  **Create `fc-note` script:** Develop the new command in `lib/commands/`.
2.  **Implement `new` command:** Write the logic to create a new note file with the given content.
3.  **Implement `list`, `show`, and `search` commands:** Write the logic to read and display the note files. The `search` command will use `grep`.
4.  **Implement `edit` command:** Write the logic to open the notes directory in the user's `$EDITOR`.
5.  **Setup Notes Directory:** The script should ensure the `~/.config/circus/notes/` directory exists when it's first run.
6.  **Testing:** Add `bats` tests to verify that notes are created, listed, and searched correctly.
7.  **Documentation:** Update `COMMANDS.md` with the new command's documentation.
