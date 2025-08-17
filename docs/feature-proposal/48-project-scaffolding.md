# Feature Proposal: 48 - Project Scaffolding

## 1. Feature Overview

This feature introduces a command, `fc project new`, for scaffolding new software projects from a set of predefined templates. This will automate the creation of the directory structure and boilerplate files for common project types.

**User Benefit:** Speeds up the initial phase of a new project. Instead of manually creating directories and files like `.gitignore`, `README.md`, and a basic source file, the user can generate a best-practice starting point with a single command.

## 2. Design & Modularity

*   **Template Repository:** Project templates will be stored in a dedicated directory within the framework, `templates/projects/`. Each sub-directory will represent a template (e.g., `templates/projects/python-cli/`, `templates/projects/react-app/`).
*   **Command Structure:**
    *   `fc project new <template_name> <project_name>`: Creates a new project in a directory with the given name, using the specified template.
    *   `fc project list-templates`: Lists all available project templates.
*   **Template Variables:** Templates can include variables (e.g., `{{PROJECT_NAME}}`, `{{AUTHOR_NAME}}`) that will be automatically replaced with the correct values when a new project is created.
*   **Custom Templates:** Users can create their own custom templates in `~/.config/circus/project-templates/`.

## 3. Security Considerations

*   **Template Content:** The user is trusting the templates to be safe and correct. The default templates provided with the framework will follow standard best practices.
*   **No Remote Execution:** The scaffolding command will only copy files and replace variables. It will not execute any code from the templates.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc project` command will be documented.
*   **New Guide:** A `docs/PROJECT_SCAFFOLDING.md` guide will explain how to use the command and how to create custom project templates.
*   **Template READMEs:** Each template directory will contain its own `README.md` explaining the structure of that template.

## 5. Implementation Plan

1.  **Create `fc-project` command:** Develop the new command in `lib/commands/`.
2.  **Implement Template Engine:** Write the logic to copy a template directory and replace the variables in the file content and filenames.
3.  **Create Initial Templates:** Develop a few useful default templates, for example, for a Python library and a simple web app.
4.  **Implement Custom Template Discovery:** Add logic to look for and use templates from the user's custom template directory.
5.  **Testing:** Add `bats` tests that generate a project from a test template and verify that the resulting directory structure and file content are correct.
6.  **Documentation:** Create the `docs/PROJECT_SCAFFOLDING.md` guide and update `COMMANDS.md`.
