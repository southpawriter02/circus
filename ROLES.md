# Role-Based Installation System

This document provides an overview of the role-based installation system used in the Dotfiles Flying Circus. This system allows for a highly customized and modular setup tailored to specific use cases like "developer," "personal," or "work."

## What Are Roles?

A "role" is a self-contained set of configurations that defines a specific machine setup. Instead of a one-size-fits-all installation, roles allow you to layer configurations, installing different applications, dotfiles, and setup scripts based on the intended purpose of the machine.

The installer applies a set of **base configurations** first and then layers any **role-specific configurations** on top.

## How to Use a Role

To use a role, simply pass the `--role <name>` flag to the main `install.sh` script.

**Example:**

```bash
./install.sh --role developer
```

This command will run the standard installation and then apply the additional configurations defined in the `roles/developer/` directory.

## Existing Roles

Here is a summary of the currently available roles:

### `developer`

This role is designed for a software development machine. It includes:

*   **Applications:** `rider`, `warp`, `docker`, `dotnet-sdk`, `nvm`, `postgresql`, `mariadb`.
*   **Aliases:** Docker and web development aliases.
*   **Environment:** .NET SDK path configuration.
*   **Configuration Scripts:** Programmatically configures the macOS Dock with developer-centric applications.

### `personal`

This role is designed for a personal-use machine. It includes:

*   **Applications:** `spotify`, `vlc`.
*   **Aliases:** A `media.aliases.sh` file with shortcuts for controlling Spotify from the command line.
*   **Configuration Scripts:** Programmatically configures the macOS Dock with media applications.

### `work`

This role is designed for a corporate or work-from-home machine. It includes:

*   **Applications:** `slack`, `zoom`.
*   **Configuration Scripts:** Programmatically configures the macOS Dock with communication applications.

## How to Create a New Role

Creating a new role is simple and is the primary way to extend the functionality of this dotfiles repository.

1.  **Create a New Role Directory:**
    Create a new directory inside the top-level `roles/` directory. The name of the directory will be the name of your role. For example, to create a `designer` role:

    ```bash
    mkdir roles/designer
    ```

2.  **Add a `Brewfile` (Optional):**
    If your role requires specific applications, create a `Brewfile` inside your new role directory (`roles/designer/Brewfile`). Add the Homebrew formulae and casks you want to install.

3.  **Add Aliases (Optional):**
    If your role needs specific aliases, create an `aliases` subdirectory (`roles/designer/aliases/`) and add one or more `.aliases.sh` files inside it. The installer will automatically symlink them.

4.  **Add Environment Variables (Optional):**
    If your role needs specific environment variables, create an `env` subdirectory (`roles/designer/env/`) and add one or more `.env.sh` files inside it. The installer will automatically source them.

5.  **Add Configuration Scripts (Optional):**
    If your role requires complex setup tasks (like configuring software or system settings), create a `defaults` subdirectory (`roles/designer/defaults/`) and add one or more `.sh` scripts inside it. The installer will automatically execute them.

    **Example:** You could create a `roles/designer/defaults/configure-dock.sh` script that uses `dockutil` to add applications like Figma and Sketch to the Dock, providing a tailored user experience for that role.

That's it! The installer will automatically detect the new role directory and its contents. You can then run `./install.sh --role designer` to use your new role.
