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

### AirDrop

Manages AirDrop visibility using the `defaults` command.

**Usage:** `fc airdrop <action>`

**Actions:**

-   `on`: Enable AirDrop for everyone.
-   `off`: Disable AirDrop.
-   `contacts`: Enable AirDrop for contacts only.
-   `status`: Show the current AirDrop visibility status.

### Backup

Creates a timestamped backup of essential dotfiles to a cloud or local directory.

**Usage:** `fc backup`

**Description:**

This command uses `rsync` to create a new backup of key configuration files in a timestamped directory (e.g., `dotfiles-backup-YYYY-MM-DD-HHMMSS`). This provides an easy way to save a snapshot of your configuration before making significant changes.

**Customization:**

You can customize the backup location and the list of files to be backed up by editing the `lib/commands/fc-backup` script directly.

### Bluetooth

Manages the system's Bluetooth adapter using the `blueutil` command-line tool.

**Usage:** `fc bluetooth <action>`

**Actions:**

-   `on`: Turn Bluetooth on.
-   `off`: Turn Bluetooth off.
-   `status`: Show the current Bluetooth status.

*Note: This command depends on `blueutil`, which is automatically installed by the main installer via Homebrew.*

### DNS

Manages the DNS settings for the active network service using the built-in `networksetup` command.

**Usage:** `fc dns <action> [dns_servers...]`

**Actions:**

-   `get`: Show the current DNS servers.
-   `set <ip>...`: Set one or more custom DNS servers (e.g., 8.8.8.8 1.1.1.1).
-   `clear`: Clear custom DNS servers, reverting to the default.
-   `status`: Alias for 'get'.

*Note: This command requires administrator privileges (`sudo`) to change DNS settings.*

### Firewall

Manages the macOS application firewall using the built-in `socketfilterfw` command.

**Usage:** `fc firewall <action>`

**Actions:**

-   `on`: Turn the firewall on.
-   `off`: Turn the firewall off.
-   `status`: Show the current firewall status.

*Note: This command requires administrator privileges (`sudo`) to change the firewall state.*

### Info

Displays a summary of the system's hardware and software configuration.

**Usage:** `fc info`

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
3.  **Customize the Logic:** Edit the new file to implement the desired functionality, updating the `usage()` message and the `case` statement in the `main()` function.
4.  **Update the Installer:** This is a crucial step. Add the full path to your new script to the `FILES_TO_MAKE_EXECUTABLE` array in the `install/10-dotfiles-deployment.sh` script. This ensures the installer will automatically make your new command executable.

Your new command will be automatically available the next time you run `fc` after running the main installer.
