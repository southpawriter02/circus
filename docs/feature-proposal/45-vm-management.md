# Feature Proposal: 45 - VM Management

## 1. Feature Overview

This feature introduces a new command, `fc vm`, for managing virtual machines from the command line. Initially, it will target a single provider (like VirtualBox or Parallels), with the potential to expand to others in the future.

**User Benefit:** For developers who regularly work with virtual machines, this provides a quick and scriptable way to perform common tasks like starting, stopping, and listing VMs without needing to open the provider's GUI application.

## 2. Design & Modularity

*   **Provider Abstraction:** The command will be designed with a provider abstraction layer, even if it only supports one provider at first. This will make it easier to add support for other VM providers later.
*   **Initial Provider:** The first implementation will target a free and popular provider, such as VirtualBox, using its `VBoxManage` command-line tool.
*   **Command Structure:**
    *   `fc vm list`: Lists all available virtual machines.
    *   `fc vm start <vm_name>`: Starts a VM.
    *   `fc vm stop <vm_name>`: Stops a VM (graceful shutdown).
    *   `fc vm kill <vm_name>`: Forcibly powers off a VM.
    *   `fc vm status <vm_name>`: Shows the current status of a VM.
    *   `fc vm ip <vm_name>`: Attempts to find and display the IP address of a running VM.
*   **Configuration:** A `~/.config/circus/vm.conf` file will allow the user to specify the default provider.

## 3. Security Considerations

*   **Command-line Tools:** The feature is a wrapper around the VM provider's own command-line tools (e.g., `VBoxManage`). It relies on the security of these tools.
*   **No `sudo` Required:** Typically, managing user-owned VMs does not require `sudo`.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc vm` command and its sub-commands will be documented.
*   **New Guide:** A `docs/VIRTUAL_MACHINES.md` guide will explain how to use the command and which providers are supported.
*   **Inline Comments:** The `fc-vm` script will be commented to explain the underlying provider commands.

## 5. Implementation Plan

1.  **Dependency:** Add the chosen VM provider's command-line tools to the installation process (if they are not already bundled). For VirtualBox, this is part of the main application install.
2.  **Create `fc-vm` script:** Develop the new command in `lib/commands/`.
3.  **Implement Provider Logic:** Write the functions for the initial provider (e.g., VirtualBox) that call `VBoxManage` to perform the `start`, `stop`, `list` actions.
4.  **IP Address Discovery:** This is a complex task. The implementation might involve inspecting DHCP leases or using the VM provider's guest additions.
5.  **Testing:** Add `bats` tests that mock the `VBoxManage` command to test the VM management logic.
6.  **Documentation:** Create the `docs/VIRTUAL_MACHINES.md` guide and update `COMMANDS.md`.
