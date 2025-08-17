# Dotfiles Flying Circus

This repository contains my personal dotfiles and a comprehensive, automated installer for setting up a new macOS device. The installer is designed to be modular, idempotent, and safe.

## Features

*   **Role-Based Installation:** Use roles (`developer`, `personal`, `work`) to install different sets of applications and configurations for different machines.
*   **Deep System Configuration:** Automates the configuration of the Finder, Dock, keyboard, and other system-level preferences.
*   **Automated Security Hardening:** Automatically configures the macOS firewall, screen saver security, and other security settings for a safer default environment.
*   **Secure Secrets Management:** Integrates with 1Password to securely fetch and deploy API tokens and other sensitive credentials into the macOS Keychain.
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

## Usage (`fc` command)

This repository includes a custom command-line utility, `fc`, for system management. For detailed usage instructions, please see the [Commands Guide](COMMANDS.md).

```sh
# Display system information
fc info

# Create an encrypted backup of your system state
fc sync backup
```

## Testing

The project includes a full test suite. To run the tests, first ensure you have installed the base dependencies with `./install.sh`, then run:

```sh
bats tests/
```

## Documentation

This project is extensively documented. Please see the following guides for more information:

-   **[Roles Guide](ROLES.md):** An explanation of the role-based installation system and how to create new roles.
-   **[Commands Guide](COMMANDS.md):** A detailed user manual for the custom `fc` command-line interface.

## Inspiration and Resources

This repository stands on the shoulders of giants. It draws inspiration from many excellent dotfiles projects and uses powerful built-in macOS tools.

### Inspired by

-   [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles): One of the most popular and comprehensive dotfiles repositories, serving as a canonical source for macOS `defaults` commands.
-   [Zach Holman's dotfiles](https://github.com/holman/dotfiles): A project that popularized a topic-based, modular approach to dotfiles management.

### Key macOS Commands

-   [`defaults`](https://ss64.com/osx/defaults.html): The primary tool for modifying macOS user preferences.
-   [`pmset`](https://ss64.com/osx/pmset.html): A powerful command for managing power settings.
-   [`spctl`](https://ss64.com/osx/spctl.html): The command-line interface for managing Gatekeeper and security policies.
