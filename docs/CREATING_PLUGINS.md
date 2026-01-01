# Creating Plugins for `fc`

This document provides a guide for developers who want to create their own plugins for the `fc` command-line utility.

## The Plugin Architecture

The `fc` command uses a simple, file-based plugin system. Any executable file placed in the `lib/plugins/` directory is automatically discovered and treated as a subcommand. For example, a script named `lib/plugins/hello` will be available to run as `fc hello`.

This makes it incredibly easy to extend the functionality of the `fc` command without modifying any of the core repository scripts.

## How to Create a New Plugin

### 1. Copy the Template

The easiest way to start is to copy the provided plugin template.

```bash
# From the root of the repository
cp lib/plugins/fc-template lib/plugins/fc-my-new-command
```

### 2. Make it Executable

The `fc` dispatcher will only recognize plugins that have execute permissions. You must make your new plugin script executable.

```bash
chmod +x lib/plugins/fc-my-new-command
```

### 3. Customize the Script

Open your new `lib/plugins/fc-my-new-command` file in a text editor. The template provides a basic structure with a `usage` function and a `main` function containing a `case` statement. You can now fill in the logic for your new command.

### 4. Run Your New Command

That's it! Your new command is now part of the `fc` ecosystem. You can run it like any other command.

```bash
fc my-new-command --help
fc my-new-command on
```

Note that while the script is named `fc-my-new-command`, you invoke it with `fc my-new-command`.

## Best Practices

*   **Provide a `usage` function:** Every plugin should have a `usage` function that explains what it does and what arguments it accepts. The template provides a good example.
*   **Handle the `--help` flag:** Your plugin should check for a `--help` flag and call your `usage` function if it's present.
*   **Use `set -e`:** For safety, it's recommended to use `set -e` at the top of your script. This will cause the script to exit immediately if any command fails.
*   **Source Helpers (Optional):** If you need access to the logging functions (`msg_info`, etc.), you can source the main initialization script. Note that the path is relative to the plugin's location.

    ```bash
    source "$(dirname "${BASH_SOURCE[0]}")/../init.sh"
    ```

## Using the Logging System

The helper library provides several logging functions for consistent output. Here are practical examples:

### Log Levels and When to Use Them

```bash
# Debug: Detailed diagnostic information (hidden by default)
msg_debug "Checking if config file exists at $CONFIG_PATH"

# Info: Normal operational messages
msg_info "Starting backup process..."

# Success: Confirm successful completion of an operation
msg_success "Backup completed successfully."

# Warning: Something unexpected but not fatal
msg_warning "Config file not found, using defaults."

# Error: Operation failed but script can continue
msg_error "Failed to backup ~/.zshrc - file not found."

# Critical: Fatal error, script will likely exit
msg_critical "Cannot proceed without required dependency."
```

### Example: A Well-Logged Plugin Function

```bash
backup_file() {
  local source="$1"
  local dest="$2"

  msg_debug "Attempting to backup: $source -> $dest"

  if [ ! -f "$source" ]; then
    msg_warning "Source file does not exist: $source"
    return 1
  fi

  if cp "$source" "$dest"; then
    msg_success "Backed up $source"
  else
    msg_error "Failed to backup $source"
    return 1
  fi
}
```

### Tip: Debug Mode for Development

While developing your plugin, run with `--log-level DEBUG` to see all messages:

```bash
fc --log-level DEBUG my-plugin action
```

You can also use `--silent` to suppress all output except critical errors:

```bash
fc --silent my-plugin action
```
