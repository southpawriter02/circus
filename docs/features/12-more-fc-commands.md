# Improvement Proposal: 12 - More `fc` Commands

## 1. Feature Overview

This improvement will expand the `fc` command suite with more subcommands for common system management tasks. The goal is to make `fc` a more comprehensive "Swiss Army knife" for macOS management.

**User Benefit:** Provides simple, memorable commands for tasks that normally require looking up obscure `networksetup` or `scutil` commands. This saves time and makes managing the system from the command line more pleasant.

## 2. Design & Modularity

Following the plugin architecture from proposal #6, each new command will be a standalone script in the `lib/plugins/` directory.

*   **`fc wifi`:**
    *   `on|off`: Turn the Wi-Fi interface on or off.
    *   `status`: Show the current status and network name.
    *   `list`: List available Wi-Fi networks.
*   **`fc dns`:**
    *   `flush`: Flush the system's DNS cache.
    *   `get`: Show the currently configured DNS servers.
    *   `set <server1> [server2]`: Set the DNS servers for the primary network interface.
*   **`fc firewall`:**
    *   `on|off`: Enable or disable the macOS application firewall.
    *   `status`: Show the current firewall status.
    *   `add <path-to-app>`: Add an application to the firewall's "allow" list.

## 3. Security Considerations

*   **`sudo` Usage:** Commands that modify system settings (like setting DNS or turning on the firewall) will require `sudo`. The scripts will be written to call `sudo` only for the specific command that needs it, minimizing the scope of elevated privileges.
*   **Input Sanitization:** Any user input (like DNS server IP addresses) will be validated to ensure it is in the correct format before being used in a command.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc` command reference will be updated with new sections for each new command.
*   **Inline Comments:** Each new command script will be well-commented.

## 5. Implementation Plan

1.  **Create `fc-wifi` Script:**
    *   Implement subcommands by wrapping the `networksetup` command.
2.  **Create `fc-dns` Script:**
    *   Implement `flush` by wrapping `sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder`.
    *   Implement `get`/`set` by wrapping `networksetup`.
3.  **Create `fc-firewall` Script:**
    *   Implement subcommands by wrapping `/usr/libexec/ApplicationFirewall/socketfilterfw`.
4.  **Testing:** Add `bats` tests for each new command. This will involve mocking the underlying macOS commands and verifying that the `fc` subcommands call them with the correct arguments.
5.  **Documentation:** Update `COMMANDS.md`.
