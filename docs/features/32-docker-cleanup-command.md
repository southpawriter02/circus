# Feature Proposal: 32 - Docker Cleanup Command

## 1. Feature Overview

This feature introduces a new command, `fc docker-clean`, to help developers reclaim disk space by removing unused Docker assets such as old images, stopped containers, and dangling volumes.

**User Benefit:** Docker can consume a large amount of disk space over time. This command provides a simple, safe, and convenient way to perform regular cleanup without needing to remember the specific `docker` commands.

## 2. Design & Modularity

*   **Wrapper for Docker Commands:** The `fc docker-clean` command will be a user-friendly wrapper around the `docker system prune`, `docker image prune`, `docker container prune`, and `docker volume prune` commands.
*   **Command Structure:**
    *   `fc docker-clean`: Performs a "safe" cleanup, removing only dangling and unused assets. It will show the user what will be deleted and ask for confirmation.
    *   `fc docker-clean --all`: Performs a more aggressive cleanup, removing all stopped containers and unused images.
    *   `fc docker-clean --hard`: A very aggressive option that removes all Docker assets, including volumes. This is a destructive action and will require extra confirmation.
*   **Informative Output:** The command will provide detailed output on how much space was reclaimed.

## 3. Security Considerations

*   **User Confirmation:** Destructive operations will always require user confirmation. The `--hard` option will require the user to type a confirmation phrase to prevent accidental data loss.
*   **Docker Daemon Access:** The command requires access to the Docker daemon socket. It will run with the user's standard permissions, assuming they are already in the `docker` group or have configured Docker to be accessible.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc docker-clean` command and its flags will be documented, with clear warnings about the more destructive options.
*   **Inline Comments:** The `fc-docker-clean` script will be commented to explain the underlying Docker commands being used.

## 5. Implementation Plan

1.  **Create `fc-docker-clean` script:** Develop the new command in `lib/commands/`.
2.  **Implement Cleanup Logic:** Create functions for the different cleanup levels (safe, all, hard) that execute the appropriate `docker` commands.
3.  **Add Confirmation Prompts:** Implement interactive confirmation prompts for all destructive operations.
4.  **Calculate Reclaimed Space:** Use the output of the Docker commands to calculate and display the amount of disk space that was freed.
5.  **Testing:** Add `bats` tests that mock the `docker` command to test the cleanup logic and confirmation prompts.
6.  **Documentation:** Update `COMMANDS.md` with the documentation for the new command.
