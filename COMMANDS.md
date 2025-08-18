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

## `fc doctor`

Runs a series of diagnostic checks to ensure your system is healthy and correctly configured. This includes checking Homebrew status and verifying that critical command-line tools are installed.

**Usage:**

```bash
fc doctor
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

This is a powerful command for managing the full lifecycle of your machine's state. It allows you to create a complete, end-to-end encrypted backup of your applications and data and then restore that state to a new machine.

### The Migration Workflow

Here is the recommended workflow for using `fc sync` to migrate to a new machine:

**1. On Your OLD Machine:**

Run the `backup` command. This will create an encrypted `circus_backup.tar.gz.gpg` file in your home directory.

```bash
fc sync backup
```

Once complete, copy this encrypted archive to an external drive or cloud storage service.

**2. On Your NEW Machine:**

First, run the main `./install.sh` script to lay down the foundational scaffolding for your chosen role. Then, copy your encrypted backup archive to your new machine's home folder.

Finally, run the `restore` command. This will prompt for your GPG passphrase, decrypt the archive, and then restore your applications and data.

```bash
fc sync restore
```

The result is a new machine that is a near-perfect mirror of your old environment.
