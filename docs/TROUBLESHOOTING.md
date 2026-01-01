# Troubleshooting Guide

This document provides guidance for diagnosing and resolving issues with the Dotfiles Flying Circus installer and command-line tools.

## The Log File: Your First Stop

The most powerful tool for troubleshooting is the log file. The installer is designed to create a detailed, timestamped record of every action it takes.

### How to Enable File Logging

To enable file logging, use the `--log-file` flag when you run the installer. It is highly recommended to use this whenever you are troubleshooting an issue.

```bash
./install.sh --log-file ~/circus_install.log
```

This will create a `circus_install.log` file in your home directory. You can now inspect this file to see the full, unabridged output of the installation process, which may contain error messages or warnings that were not printed to the console.

### Important: Log File Contains Everything

When file logging is enabled with `--log-file`, the log file captures **all** messages at every log level, regardless of the `--log-level` setting. The `--log-level` flag only controls what appears on the console.

This means even if you run with `--log-level ERROR`, your log file will still contain DEBUG, INFO, SUCCESS, and WARN messages. This is intentional - it ensures you have complete diagnostic information when troubleshooting.

### Log Rotation

To prevent log files from growing indefinitely, the logging system supports automatic rotation. When a log file exceeds the maximum size (default: 10MB), it is rotated:

- `logfile.log` becomes `logfile.log.1`
- `logfile.log.1` becomes `logfile.log.2`
- And so on, up to the configured limit (default: 3 rotated files)

You can configure rotation behavior with environment variables:

```bash
# Set max file size to 5MB
export LOG_MAX_SIZE=5242880

# Keep up to 5 rotated files
export LOG_ROTATE_COUNT=5
```

### Understanding Log Levels

The logging system uses several levels of severity:

*   **DEBUG:** The most verbose level, used for deep diagnostics.
*   **INFO:** The default level, showing the main steps of the process.
*   **SUCCESS:** Indicates that a major step was completed successfully.
*   **WARN:** Indicates a potential issue that does not prevent the process from continuing.
*   **ERROR:** Indicates a problem that has caused the current script to fail.
*   **CRITICAL:** Indicates a fatal error that has caused the entire system to halt.

### Adjusting Console Verbosity

If you want to see more (or less) detail in your console output, you can use the `--log-level` flag.

```bash
# Show every single debug message
./install.sh --log-level DEBUG

# Only show warnings and errors
./install.sh --log-level WARN
```

## Common Issues

### "Command not found: brew"

This error indicates that Homebrew is not correctly installed or is not available in your system's `PATH`. This is often the root cause of many other failures.

**Solution:**
1.  Ensure you have run the main `./install.sh` script, as this is what installs Homebrew.
2.  If you have run the installer, check your `.zshrc` file to ensure that the Homebrew directory (`/opt/homebrew/bin`) is being added to your `PATH`.

### "Permission denied"

This error usually indicates that a script does not have execute permissions.

**Solution:**
1.  The installer should handle this automatically, but you can manually fix it with the `chmod +x` command.
2.  For `fc` plugins, ensure all files in `lib/plugins/` are executable.

### Sharing Logs for Help

If you are asking for help, please include the relevant sections of your log file. Before you post the log in a public place like a GitHub issue, be sure to **review and sanitize it** to remove any personal or sensitive information (e.g., usernames, private directory paths).
