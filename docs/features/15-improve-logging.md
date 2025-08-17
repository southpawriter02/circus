# Improvement Proposal: 15 - Improve Logging

## 1. Feature Overview

This improvement will enhance the logging capabilities of the installer and other long-running scripts. This includes logging output to a file for later inspection and supporting different log levels (e.g., debug, info, warn, error).

**User Benefit:** Makes debugging much easier. If an installation fails, the user can inspect the detailed log file to understand what went wrong. It also allows for a "silent" mode that only logs to the file, providing a cleaner terminal experience.

## 2. Design & Modularity

*   **Centralized Logging Functions:** The existing `msg_*` functions in `lib/helpers.sh` will be enhanced to handle log levels and file logging.
*   **Log Levels:** The functions will support standard log levels: `DEBUG`, `INFO`, `WARN`, `ERROR`.
*   **Command-Line Flags:** The `install.sh` script will get new flags:
    *   `--log-file <path>`: Specify a file to log to.
    *   `--log-level <level>`: Specify the minimum log level to print to the console (e.g., `WARN` would show warnings and errors, but not info or debug messages).
*   **Global Configuration:** The chosen log level and log file path will be stored in global environment variables that are respected by all helper functions.

## 3. Security Considerations

*   **Log File Permissions:** The log file will be created with standard user permissions (`644`).
*   **Information Disclosure:** The `DEBUG` log level might record sensitive information. The documentation will warn users to review and sanitize logs before sharing them publicly (e.g., in a GitHub issue). The default log level will be `INFO` to avoid this.

## 4. Documentation Plan

*   **`TESTING.md` / `TROUBLESHOOTING.md`:** A guide on troubleshooting will be created or updated to explain how to find and read the log files to diagnose issues.
*   **`install.sh` Usage:** The `usage()` function in `install.sh` will be updated to document the new logging flags.
*   **Inline Comments:** The logging functions in `lib/helpers.sh` will be well-commented.

## 5. Implementation Plan

1.  **Refactor `lib/helpers.sh`:**
    *   Rewrite the `msg_*` functions to accept a log level as the first argument.
    *   Add a central `log_message` function that handles the logic of whether to print to the console and/or write to the log file based on the global settings.
2.  **Update `install.sh`:**
    *   Add the `--log-file` and `--log-level` flags to the argument parsing logic.
    *   Set the global logging environment variables.
3.  **Refactor Scripts:** Go through all scripts and update calls to the `msg_*` functions to include a log level.
4.  **Testing:** Add `bats` tests to verify that the logging system works correctly. For example, a test could run the installer with `--log-level WARN` and assert that `INFO` messages are not printed to standard output.
5.  **Documentation:** Update the troubleshooting guides and the installer's usage information.
