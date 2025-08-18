# Dotfiles Flying Circus

This repository contains my personal dotfiles and a comprehensive, automated installer for setting up a new macOS device. It is built upon the **Oh My Zsh** framework to provide a powerful, extensible, and community-maintained shell experience.

## Features

*   **Framework-Based Shell:** Built on Oh My Zsh and features a custom `circus` plugin that cleanly encapsulates all custom aliases, functions, and environment variables.
*   **Extensible CLI Platform:** Includes a custom `fc` command built on a clean plugin architecture. Adding new commands is as simple as creating a new executable file.
*   **Role-Based Installation:** Use roles (`developer`, `personal`, `work`) to install different sets of applications and configurations for different machines.
*   **Deep System Configuration:** Automates the configuration of the Finder, Dock, keyboard, and other system-level preferences.
*   **Automated Security Hardening:** Automatically configures the macOS firewall, screen saver security, and other security settings for a safer default environment.
*   **Secure Secrets Management:** Integrates with 1Password to securely fetch and deploy API tokens into the macOS Keychain.
*   **Encrypted Backup & Restore System:** A powerful `fc sync` command to create an end-to-end encrypted backup of your applications and data.
*   **Comprehensive Testing:** A full test suite using `bats-core` and `shellcheck` to ensure the reliability and security of the entire codebase.

## Getting Started

Setting up a new machine is a simple, guided process.

1.  **Clone the Repository:**
    ```sh
    git clone https://github.com/southpawriter02/circus.git
    cd circus
    ```

2.  **Run the Installer:**
    The installer is interactive and will prompt for confirmation before taking any action. To install a specific role, use the `--role` flag.
    ```sh
    # Run the default installation
    ./install.sh

    # Or, install the developer role
    ./install.sh --role developer
    ```

## Documentation

This project is extensively documented. Please see the following guides for more information:

-   **[Architecture Guide](docs/ARCHITECTURE.md):** A deep dive into the design philosophy and technical architecture of the installer, shell, and CLI.
-   **[Roles Guide](ROLES.md):** An explanation of the role-based installation system and how to create new roles.
-   **[Commands Guide](COMMANDS.md):** A detailed user manual for the custom `fc` command-line interface.
-   **[Creating Plugins Guide](docs/CREATING_PLUGINS.md):** A guide for developers who want to create their own plugins for the `fc` command.

## Inspiration and Resources

This repository stands on the shoulders of giants. It draws inspiration from many excellent dotfiles projects and uses powerful built-in macOS tools.

### Inspired by

-   [Oh My Zsh](https://ohmyz.sh/): The framework that now powers our shell environment.
-   [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles): One of the most popular and comprehensive dotfiles repositories, serving as a canonical source for macOS `defaults` commands.
-   [Zach Holman's dotfiles](https://github.com/holman/dotfiles): A project that popularized a topic-based, modular approach to dotfiles management.
