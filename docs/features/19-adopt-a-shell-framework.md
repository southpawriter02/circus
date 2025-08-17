# Change Proposal: 19 - Adopt a Shell Framework

## 1. Feature Overview

This change proposes adopting a well-supported shell framework like Oh My Zsh or Prezto as the base for the shell configuration. The project's custom aliases, functions, and prompt would then be refactored to be a custom plugin for that framework.

**User Benefit:** Users get access to the vast ecosystem of themes and plugins provided by the chosen framework, with very little effort. It also future-proofs the shell setup, as the framework will be maintained by a larger community.

## 2. Design & Modularity

*   **Framework Choice:** The first step is to choose a framework. Oh My Zsh is the most popular and has the largest community.
*   **Installer Integration:** The main `install.sh` script will be updated to automatically install the chosen framework if it is not already present.
*   **Custom Plugin:** All the existing shell configuration from the `profiles/` directory (aliases, functions, prompt, options) will be consolidated into a single custom plugin (e.g., `~/.oh-my-zsh/custom/plugins/circus/`).
*   **`.zshrc` Simplification:** The user's `.zshrc` file will be greatly simplified. It will mostly just contain the logic to load the framework and enable the desired plugins (including the custom `circus` plugin).

## 3. Security Considerations

*   **Third-Party Code:** This change introduces a large new dependency on an external project. The framework must be chosen carefully, and the installer should clone it from the official repository over HTTPS.
*   **Update Strategy:** The framework will have its own update mechanism. The documentation should explain how this works. The project could also provide a command (`fc shell update`) to simplify this.

## 4. Documentation Plan

*   **`ARCHITECTURE.md`:** The section on shell configuration will be rewritten.
*   **`README.md`:** The main readme will be updated to mention that the project now uses and is built upon the chosen framework.

## 5. Implementation Plan

1.  **Choose Framework:** Select a framework (e.g., Oh My Zsh).
2.  **Update Installer:** Add logic to `install.sh` to clone the framework's repository into the user's home directory.
3.  **Create Custom Plugin:**
    *   Create the directory structure for the new `circus` plugin.
    *   Move all the existing `.sh` files from `profiles/aliases`, `profiles/env`, `profiles/zsh`, etc., into the new plugin directory.
    *   Create a main `circus.plugin.zsh` file that sources all the other files in the correct order.
4.  **Refactor `.zshrc`:**
    *   Replace the existing `.zshrc` with a new, simpler version that just loads the framework and the `circus` plugin.
5.  **Testing:** The `bats` tests for aliases and shell functions will need to be updated to work with the new plugin structure.
6.  **Documentation:** Rewrite the relevant documentation.
