# Feature: 05 - System Health Check

## 1. Feature Overview

This feature will create an `fc healthcheck` command that runs a series of checks for common system issues, such as broken symlinks, missing dependencies, insecure configurations, and other potential problems.

**User Benefit:** Provides a quick and easy way to diagnose the health of the user's setup. It can catch small problems before they become big ones and give users confidence that their system is configured correctly and securely.

## 2. Design & Modularity

*   **Check-Based Architecture:** The command will be built around a series of individual check functions. Each function will be responsible for a single, specific test. This makes it easy to add new checks in the future.
*   **Clear Output:** The output will be clear and concise, with a simple `[PASS]` or `[FAIL]` status for each check, followed by a brief explanation.
*   **Fixer Integration (Future):** The architecture will allow for an optional "fixer" function to be associated with each check. In the future, an `fc healthcheck --fix` command could be added to automatically resolve failed checks.
*   **Command Structure:**
    *   `fc healthcheck`: Runs all available checks.
    *   `fc healthcheck <check-name>`: Runs a specific, named check.

## 3. Security Considerations

*   **Read-Only by Default:** The health check command will be read-only by default. It will inspect system state but will not make any changes.
*   **Sensitive File Checks:** When checking the permissions of sensitive files (e.g., `~/.ssh/id_rsa`), the command will only check the metadata (permissions) and will not read the content of the files.
*   **No `sudo`:** The command will not require `sudo` to run. All checks will be performed within the user's own context.

## 4. Documentation Plan

*   **`COMMANDS.md`:** A new section for `fc healthcheck` will be added, explaining what each check does.
*   **Inline Comments:** The `fc-healthcheck` script will be commented to explain the purpose and logic of each individual check function.

## 5. Implementation Plan

1.  **Command Script:** Create the `lib/commands/fc-healthcheck` script.
2.  **Create Check Runner:** Implement the main loop that iterates through and runs all defined check functions.
3.  **Implement Initial Checks:**
    *   `check_broken_symlinks`: Scan the home directory for broken symlinks.
    *   `check_missing_deps`: Check if all dependencies from the `Brewfile`s are installed.
    *   `check_ssh_perms`: Verify that `~/.ssh` and its contents have secure permissions.
    *   `check_git_config`: Ensure that user name and email are configured in git.
4.  **Testing:** Add `bats` tests. This will involve setting up "broken" states (e.g., creating a broken symlink) and verifying that the health check correctly identifies them.
5.  **Documentation:** Update `COMMANDS.md`.
