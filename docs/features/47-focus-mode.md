# Feature Proposal: 47 - Focus Mode

## 1. Feature Overview

This feature introduces a "focus mode" command, `fc focus`, that helps the user concentrate by temporarily blocking distracting websites and closing specific applications.

**User Benefit:** Provides a simple way to create a distraction-free work environment. It's a tool for self-discipline, making it easier to avoid common time-wasters like social media and news sites during a work session.

## 2. Design & Modularity

*   **Website Blocking:** The primary mechanism for blocking websites will be to modify the `/etc/hosts` file, redirecting distracting domain names to `127.0.0.1`.
*   **Application Quitting:** The command will also be able to quit a user-defined list of applications (e.g., Slack, Mail, Twitter).
*   **Command Structure:**
    *   `fc focus start <duration>`: Starts a focus session for a specified duration (e.g., `fc focus start 30m`). The command will automatically end the session after the time is up.
    *   `fc focus stop`: Manually stops the focus session, restoring the hosts file and allowing apps to be launched.
*   **Configuration:** A configuration file, `~/.config/circus/focus.conf`, will allow the user to define:
    *   The list of websites to block.
    *   The list of applications to quit.

## 3. Security Considerations

*   **`sudo` Usage:** Modifying the `/etc/hosts` file requires `sudo` privileges. The `fc focus` command will need to manage this. It will use a temporary file and `sudo cp` to safely update the hosts file.
*   **Restoration:** It is critical that the original `/etc/hosts` file is restored correctly when the session ends. The command will create a backup of the original file before making any changes. It will also use a `trap` to ensure the restoration happens even if the script is interrupted.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc focus` command will be documented, with a clear explanation of what it does and that it requires `sudo`.
*   **New Guide:** A `docs/FOCUS_MODE.md` guide will explain how to configure the lists of websites and applications.
*   **Inline Comments:** The script will be heavily commented, especially the parts that handle the `/etc/hosts` file and the `trap` for cleanup.

## 5. Implementation Plan

1.  **Create `fc-focus` script:** Develop the new command in `lib/commands/`.
2.  **Implement Hosts File Logic:** Write the functions to back up, modify, and restore the `/etc/hosts` file.
3.  **Implement Application Quitting:** Use `osascript` or `pkill` to quit the configured applications.
4.  **Implement Timer:** Write the logic for the timed session, which will likely involve running the "stop" logic in a `sleep` and `at` job or a backgrounded sub-shell.
5.  **Implement `trap` for Cleanup:** Add a `trap` to ensure the `stop` logic is always executed, even if the user presses `Ctrl+C`.
6.  **Testing:** This is difficult to test automatically. It will require careful manual testing to ensure the `/etc/hosts` file is always restored correctly.
7.  **Documentation:** Create the `docs/FOCUS_MODE.md` guide and update `COMMANDS.md`.
