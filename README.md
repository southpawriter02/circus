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

The installer will guide you through the rest of the process. To see all available options, such as performing a dry run, use the `--help` flag:

```sh
./init.sh --help
```

## Documentation

This project is extensively documented. Please see the following guides for more information:

-   **[Dotfiles Guide](docs/DOTFILES.md):** An explanation of the Zsh startup sequence and the purpose of each dotfile.
-   **[Custom Commands Guide (`fc`)](docs/COMMANDS.md):** A detailed user manual for the custom `fc` command-line interface.
-   **[Architecture Guide](docs/ARCHITECTURE.md):** A deep dive into the design philosophy and technical architecture of the installer.
-   **[Testing Guide](docs/TESTING.md):** Instructions on how to run and write tests for the project using the Bats framework.

## Inspiration and Resources

This repository stands on the shoulders of giants. It draws inspiration from many excellent dotfiles projects and uses powerful built-in macOS tools.

### Inspired by

-   [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles): One of the most popular and comprehensive dotfiles repositories, serving as a canonical source for macOS `defaults` commands.
-   [Zach Holman's dotfiles](https://github.com/holman/dotfiles): A project that popularized a topic-based, modular approach to dotfiles management.

### Key macOS Commands

-   [`defaults`](https://ss64.com/osx/defaults.html): The primary tool for modifying macOS user preferences.
-   [`pmset`](https://ss64.com/osx/pmset.html): A powerful command for managing power settings.
-   [`spctl`](https://ss64.com/osx/spctl.html): The command-line interface for managing Gatekeeper and security policies.
