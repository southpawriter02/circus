# Improvement Proposal: 11 - Interactive Role Creation

## 1. Feature Overview

This improvement will add a new script to the `bin/` directory that interactively guides a user through the process of creating a new role. It will ask for the role name and what kinds of configuration files to create (Brewfile, aliases, etc.), and then generate the necessary directory structure and placeholder files.

**User Benefit:** Significantly lowers the barrier to entry for customizing the dotfiles repository. Instead of needing to know the directory structure by heart, users can simply run a command and answer a few questions. This makes the project more accessible to less experienced users.

## 2. Design & Modularity

*   **Standalone Script:** The tool will be a self-contained script, `bin/create-role`, that does not need to be integrated with the main `fc` command.
*   **Interactive Prompts:** The script will use simple, clear `read -p` prompts to gather information from the user.
*   **File Generation:** Based on the user's answers, the script will create the role directory and any requested subdirectories (`aliases/`, `env/`, `defaults/`) and placeholder files (`Brewfile`, `.placeholder`).
*   **Idempotent:** The script will check if a role directory with the given name already exists and will exit gracefully if it does, preventing accidental overwrites.

## 3. Security Considerations

*   **Input Sanitization:** The role name provided by the user will be sanitized to ensure it is a valid directory name and does not contain any characters that could be used for path traversal (`/`, `.`).
*   **File Permissions:** All created directories and files will be generated with standard, secure default permissions.

## 4. Documentation Plan

*   **`ROLES.md`:** The guide on creating roles will be updated to recommend using the new interactive script as the primary method.
*   **Script `usage` function:** The script itself will have a `usage()` function explaining how to run it.

## 5. Implementation Plan

1.  **Create Script:** Create the `bin/create-role` script and make it executable.
2.  **Add Prompts:**
    *   Prompt for the role name.
    *   Use yes/no prompts to ask if the user wants to create a `Brewfile`, `aliases` directory, etc.
3.  **Implement File Generation:**
    *   Add logic to create the main `roles/<role-name>` directory.
    *   Add logic to create the subdirectories and placeholder files based on the user's answers.
4.  **Add Input Validation:** Implement checks for the role name to ensure it is valid and does not already exist.
5.  **Testing:** Add `bats` tests. The tests will run the script with mocked user input and verify that the correct directory structure is created.
6.  **Documentation:** Update `ROLES.md`.
