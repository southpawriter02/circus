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
cp lib/plugins/template lib/plugins/my-new-command
```

### 2. Make it Executable

The `fc` dispatcher will only recognize plugins that have execute permissions. You must make your new plugin script executable.

```bash
chmod +x lib/plugins/my-new-command
```

### 3. Customize the Script

Open your new `lib/plugins/my-new-command` file in a text editor. The template provides a basic structure with a `usage` function and a `main` function containing a `case` statement. You can now fill in the logic for your new command.

### 4. Run Your New Command

That's it! Your new command is now part of the `fc` ecosystem. You can run it like any other command.

```bash
fc my-new-command --help
fc my-new-command on
```

## Best Practices

*   **Provide a `usage` function:** Every plugin should have a `usage` function that explains what it does and what arguments it accepts. The template provides a good example.
*   **Handle the `--help` flag:** Your plugin should check for a `--help` flag and call your `usage` function if it's present.
*   **Use `set -e`:** For safety, it's recommended to use `set -e` at the top of your script. This will cause the script to exit immediately if any command fails.
*   **Source Helpers (Optional):** If you need access to the logging functions (`msg_info`, etc.), you can source the main helper library. Note that the path is relative to the plugin's location.

    ```bash
    source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"
    ```
