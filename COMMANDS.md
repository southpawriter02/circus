# Custom Commands Guide (`fc`)

This document provides a guide to the `fc` (Dotfiles Flying Circus) command-line interface, a suite of custom commands designed to streamline common system tasks.

## How It Works: The Dispatcher Pattern

The `fc` command works like a dispatcher. It is a single entry point that looks at the first argument you provide (the *subcommand*) and then executes a corresponding script that handles the logic for that command.

-   The main script is located at `bin/fc`.
-   All subcommand scripts are located in `lib/commands/`.
-   For a command like `fc bluetooth off`, the `fc` script simply finds and executes the `lib/commands/fc-bluetooth` script, passing `off` as an argument to it.

This pattern makes the CLI highly extensible. To add a new command, you simply create a new script in the `lib/commands/` directory.

## General Usage

To see a list of all available commands, run `fc` with no arguments:

```sh
fc
```

To get help for a specific subcommand, use the `--help` flag:

```sh
fc <subcommand> --help

# Example
fc bluetooth --help
```

## Available Commands

### Bluetooth

Manages the system's Bluetooth adapter.

**Usage:** `fc bluetooth <action>`

**Actions:**

-   `on`: Turn Bluetooth on.
-   `off`: Turn Bluetooth off.
-   `status`: Show the current Bluetooth status.

*Note: This command is currently a placeholder and requires a tool like `blueutil` to be fully functional.*

### Wi-Fi

Manages the system's Wi-Fi adapter using the built-in `networksetup` command.

**Usage:** `fc wifi <action>`

**Actions:**

-   `on`: Turn Wi-Fi on.
-   `off`: Turn Wi-Fi off.
-   `status`: Show the current Wi-Fi power status.

## How to Add New Commands

Adding a new command is simple:

1.  **Copy the Template:** Make a copy of the `lib/commands/fc-template` file.
2.  **Rename the File:** Rename your new file to `fc-<your-command-name>`. For example, to create a `firewall` command, you would name the file `fc-firewall`.
3.  **Make it Executable:** Run `chmod +x lib/commands/fc-<your-command-name>`.
4.  **Customize the Logic:** Edit the new file to implement the desired functionality, updating the `usage()` message and the `case` statement in the `main()` function.

Your new command will be automatically available the next time you run `fc`.
