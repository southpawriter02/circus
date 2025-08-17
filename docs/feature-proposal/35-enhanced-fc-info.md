# Feature Proposal: 35 - Enhanced `fc-info`

## 1. Feature Overview

This feature proposes a significant enhancement of the existing `fc-info` command. The goal is to make it a comprehensive, "at-a-glance" system information tool, similar to `neofetch` or `screenfetch`, but tailored to the needs of a developer using this framework.

**User Benefit:** Provides a single command to get a detailed overview of the system's hardware, software, and configuration state. This is useful for debugging, sharing system information, or just getting a quick sense of the machine's status.

## 2. Design & Modularity

*   **Information Sections:** The new `fc-info` will be organized into clear sections:
    *   **Hardware:** CPU model, core count, memory, disk usage, battery health.
    *   **Software:** macOS version, kernel version, shell version, Homebrew package count.
    *   **Framework:** Current dotfile profile, last sync time, installed roles.
    *   **Network:** Local IP address, public IP address, hostname.
*   **ASCII Art:** The command will display a stylish ASCII logo for the framework.
*   **Command-line Tools:** It will gather information from a variety of command-line tools, such as `system_profiler`, `df`, `top`, `ifconfig`, and others.
*   **Configuration:** Users can configure which sections to display in `~/.config/circus/info.conf`.
*   **`--json` flag:** A `--json` flag will be added to output the information in a machine-readable JSON format, which can be used by other scripts or the Web UI Dashboard.

## 3. Security Considerations

*   **Public IP Address:** The command will make a request to an external service (like `ifconfig.me`) to determine the public IP address. Users will be informed of this.
*   **No Sensitive Data:** The command will be careful not to display any sensitive information, such as serial numbers or MAC addresses, by default.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc-info` section will be updated to reflect the new information sections and the `--json` flag.
*   **Inline Comments:** The `fc-info` script will be heavily commented to document the source of each piece of information.

## 5. Implementation Plan

1.  **Refactor `fc-info`:** Reorganize the existing `fc-info` script to support the new section-based layout.
2.  **Add Information Gathering Functions:** Create functions to gather each new piece of information (e.g., `get_cpu_info`, `get_disk_usage`).
3.  **Implement JSON Output:** Add the logic for the `--json` flag.
4.  **Add ASCII Art:** Choose and add an ASCII logo.
5.  **Add Configuration:** Implement the logic to read from `~/.config/circus/info.conf` and customize the output.
6.  **Testing:** Add `bats` tests that mock the various system information commands to test the output formatting.
7.  **Documentation:** Update the `fc-info` documentation in `COMMANDS.md`.
