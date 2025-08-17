# Change Proposal: 17 - Configuration Management

## 1. Feature Overview

This change proposes a shift from the current system of imperative shell scripts for configuration to a more declarative approach. This would involve adopting a structured data format like YAML or TOML for defining roles, settings, and packages.

**User Benefit:** This is a developer-focused architectural change. The primary benefit is a more robust, readable, and maintainable codebase. It separates the "what" (the configuration data) from the "how" (the installer logic), making the system easier to reason about.

## 2. Design & Modularity

*   **Declarative Configuration:** Instead of shell scripts in the `roles/` and `defaults/` directories, the configuration would be defined in YAML files.
    *   `roles/developer.yaml`:
        ```yaml
        description: "Role for software development."
        packages:
          - docker
          - nvm
        settings:
          - key: com.apple.finder.AppleShowAllFiles
            type: bool
            value: true
        ```
*   **YAML Parser:** The installer would use a command-line YAML parser like `yq` to read these configuration files.
*   **Installer Engine:** The installer logic would be rewritten to become an "engine" that reads the YAML data and translates it into actions (e.g., installing packages, running `defaults write` commands).

## 3. Security Considerations

*   **No Arbitrary Code Execution:** A major security benefit of this change is that the configuration files would contain only data, not executable code. This eliminates the risk of a malicious or poorly written configuration script causing damage.
*   **Dependency:** This change introduces a new dependency on a YAML parser (`yq`). This tool would need to be vetted and installed securely.

## 4. Documentation Plan

*   **`ARCHITECTURE.md`:** This would require a major rewrite of the architecture documentation.
*   **`ROLES.md`:** The guide to creating roles would be completely rewritten to explain the new YAML format.

## 5. Implementation Plan

This is a very large, foundational change that would need to be implemented carefully.

1.  **Dependency:** Add `yq` to the `Brewfile`.
2.  **Proof of Concept:** Start with a small proof of concept. Convert a single role (e.g., `personal`) to the new YAML format.
3.  **Rewrite Installer Engine:** Rewrite a portion of the installer to read the `personal.yaml` file and correctly install the packages and settings defined within it.
4.  **Incremental Conversion:** Once the proof of concept is successful, incrementally convert the other roles and default settings to the new format.
5.  **Testing:** The test suite would need to be significantly refactored to support the new architecture.
6.  **Documentation:** Rewrite the developer documentation (`ARCHITECTURE.md`, `ROLES.md`).
