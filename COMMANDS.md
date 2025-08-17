# Custom Commands (`fc`)

This document provides an overview of the custom command-line utility, `fc` (Dotfiles Flying Circus), included in this repository. This tool provides a suite of helpful commands for system inspection, management, and state synchronization.

## Usage

The `fc` command is the main entry point for all subcommands.

```bash
fc <command> [options]
```

To see a list of all available commands, simply run `fc` with no arguments.

---

## `fc info`

Displays a detailed report of your system's hardware, software, and network configuration.

**Usage:**

```bash
fc info
```

---

## `fc bluetooth`

Provides simple commands for managing your system's Bluetooth adapter.

**Usage:**

```bash
fc bluetooth <subcommand>
```

**Subcommands:**
*   `status`: Shows whether Bluetooth is currently on or off.
*   `on`: Turns Bluetooth on.
*   `off`: Turns Bluetooth off.

---

## `fc sync`

This is a powerful command for managing the full lifecycle of your machine's state. It allows you to create a complete backup of your applications and data and then restore that state to a new machine.

This provides a robust workflow for migrating to a new computer with minimal manual intervention.

### The Migration Workflow

Here is the recommended workflow for using `fc sync` to migrate to a new machine:

**1. On Your OLD Machine:**

Run the `backup` command. This will create a `~/CircusBackups` directory containing a complete inventory of your installed applications (`Brewfile.dump`) and a copy of all critical files and directories defined in the `BACKUP_TARGETS` array in the script.

```bash
fc sync backup
```

Once complete, copy the `~/CircusBackups` directory to an external drive or cloud storage service.

**2. On Your NEW Machine:**

First, run the main `./install.sh` script to lay down the foundational scaffolding for your chosen role. Then, copy your `CircusBackups` directory to your new machine's home folder.

Finally, run the `restore` command. This will read the `Brewfile.dump` and install every application from your old machine. It will then use `rsync` to restore all your backed-up files and directories.

```bash
fc sync restore
```

The result is a new machine that is a near-perfect mirror of your old environment.
