# Improvement Proposal: 10 - Multiple Backup Backends

## 1. Feature Overview

This improvement will extend `fc-sync` to support other backup tools besides the default `tar` and `gpg`. This would allow users to choose a more powerful, modern backup tool like `restic` or `borg` if they have it installed.

**User Benefit:** Gives users the flexibility to use more advanced backup solutions that offer features like deduplication, compression, and more efficient incremental backups, while still using the simple `fc sync` interface.

## 2. Design & Modularity

*   **Backend Abstraction:** The core `fc-sync` script will be refactored to act as a dispatcher that calls a "backend" script to do the actual work.
*   **Backend Directory:** A new `lib/backup_backends/` directory will be created. It will contain scripts for each supported backend (e.g., `gpg.sh`, `restic.sh`).
*   **Common Interface:** Each backend script will implement a common interface, with functions like `do_backup()` and `do_restore()`.
*   **Configuration:** The user will be able to select their preferred backend in the `sync.conf` file (from proposal #9) with a `BACKUP_BACKEND="gpg"` variable. The `fc-sync` dispatcher will read this variable and call the appropriate backend script.

## 3. Security Considerations

*   **Dependencies:** The use of each backend will depend on the user having the corresponding tool installed and in their `PATH`. The script will check for the existence of the required command before attempting to use a backend.
*   **Backend Security:** Each backend has its own security model. The documentation will need to clearly explain the security implications of each choice (e.g., how `restic` manages its repository password).

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc sync` section will be updated to explain the concept of backends and how to choose one.
*   **New Guide:** A new guide, `docs/BACKUP_BACKENDS.md`, will be created to provide detailed information on each backend, including its pros and cons and how to configure it.
*   **Inline Comments:** The `fc-sync` dispatcher and the backend scripts will be well-commented.

## 5. Implementation Plan

1.  **Refactor `fc-sync`:**
    *   Turn the main script into a dispatcher that reads the `BACKUP_BACKEND` config variable.
    *   Move the existing `tar` and `gpg` logic into `lib/backup_backends/gpg.sh`.
2.  **Create `restic` Backend:**
    *   Create a new `lib/backup_backends/restic.sh` script.
    *   Implement the `do_backup()` and `do_restore()` functions using `restic` commands.
    *   This will require new config variables for `restic` (e.g., `RESTIC_REPOSITORY`, `RESTIC_PASSWORD_FILE`).
3.  **Dependency Checks:** Add logic to the dispatcher to check if the required command (e.g., `restic`) is installed before proceeding.
4.  **Testing:** Add new `bats` tests for the new backend. This will likely require creating a temporary, local `restic` repository for testing.
5.  **Documentation:** Update `COMMANDS.md` and create `docs/BACKUP_BACKENDS.md`.
