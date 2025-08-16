# Dotfiles Flying Circus

This repository contains my personal dotfiles and a comprehensive, automated installer for setting up a new macOS device. The installer is designed to be modular, idempotent, and safe.

## Getting Started

To set up a new machine using this repository, follow these steps. The process has been designed to be as safe as possible, preventing accidental runs.

### 1. Clone the Repository

First, clone this repository to your local machine. A common location is `$HOME/Projects/dotfiles`.

```sh
git clone https://github.com/southpawriter02/dotfiles.git
```

### 2. Make the Initializer Executable

To prevent the main installer from being run by accident, it is kept non-executable. You must first enable the safe `init.sh` wrapper script. This is a **one-time action**.

```sh
# Navigate into the repository directory
cd dotfiles

# Make the init script executable
chmod +x init.sh
```

### 3. Run the Installer

Now, you can run the main installer via the `init.sh` script. This script will handle making the main installer executable, running it, and then safely returning it to a non-executable state when it's finished.

```sh
./init.sh
```

The installer will guide you through the rest of the process.

## Custom Commands (`fc`)

This repository also includes a custom command-line interface, `fc` (Flying Circus), for managing common system tasks. For detailed usage instructions, please see the [Custom Commands Guide](COMMANDS.md).

## Testing

This project uses the Bats (Bash Automated Testing System) framework to ensure the reliability of its scripts. For more information on how to run or write tests, please see the [Testing Guide](TESTING.md).
