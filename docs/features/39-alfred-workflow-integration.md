# Feature Proposal: 39 - Alfred Workflow Integration

## 1. Feature Overview

This feature involves creating and distributing a dedicated Alfred workflow that provides a deep integration with the `fc` command-line framework. This allows users to trigger `fc` commands and view system information directly from the Alfred search bar.

**User Benefit:** For users of Alfred, this provides an extremely fast and convenient way to interact with the framework. It bridges the gap between the command line and a GUI-like experience, improving workflow efficiency.

## 2. Design & Modularity

*   **Workflow Keywords:** The Alfred workflow will be triggered by a main keyword, `fc`.
*   **Workflow Features:**
    *   `fc <command>`: The workflow will list available `fc` commands and allow the user to execute them in a terminal window.
    *   `fc info`: Displays key system information from `fc-info` directly in the Alfred results.
    *   `fc search <pattern>`: A file filter to quickly search within the dotfiles repository itself.
    *   `fc notes <query>`: Integrates with `fc-note` to search and display notes.
*   **Script Filters:** The workflow will be built using Alfred's "Script Filter" objects, which will call the underlying `fc` commands with appropriate flags (e.g., `fc-info --json`).
*   **Distribution:** The workflow file (`.alfredworkflow`) will be included in the repository, and a command `fc alfred-install` will be created to symlink it to the user's Alfred workflow directory.

## 3. Security Considerations

*   **Command Execution:** The workflow executes the same `fc` commands a user would run in the terminal. The security model is therefore the same as the rest of the framework.
*   **Dependencies:** The workflow relies on Alfred and its Powerpack. The user must have these installed.

## 4. Documentation Plan

*   **New Guide:** A `docs/ALFRED.md` guide will be created to explain how to install and use the Alfred workflow, with screenshots of the various features.
*   **`COMMANDS.md`:** The `fc alfred-install` command will be documented.
*   **Workflow README:** The workflow itself will have a description inside Alfred's preferences pane.

## 5. Implementation Plan

1.  **Design Workflow in Alfred:** Create the new workflow in the Alfred editor, adding the keywords, script filters, and actions.
2.  **Develop Wrapper Scripts:** The script filters will call small wrapper scripts that in turn call the `fc` commands and format the output as Alfred expects (in XML or JSON).
3.  **Enhance `fc` commands:** Ensure that commands used by the workflow (like `fc-info` and `fc-note`) have a machine-readable output format (e.g., `--json`).
4.  **Create `fc-alfred-install` command:** Develop the command to automate the installation of the workflow.
5.  **Export and Commit Workflow:** Export the final `.alfredworkflow` file and commit it to the repository.
6.  **Testing:** Testing will be primarily manual, by using the workflow in Alfred.
7.  **Documentation:** Create the `docs/ALFRED.md` guide.
