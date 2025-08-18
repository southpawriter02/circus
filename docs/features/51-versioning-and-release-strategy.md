# Feature Proposal: 51 - Versioning and Release Strategy

## 1. Feature Overview

This proposal outlines a formal versioning and release strategy for the Dotfiles Flying Circus project. Adopting a structured versioning scheme will provide a clear way to track changes, manage releases, and communicate the impact of updates to users. This is a foundational feature that will enable other key functionalities, such as the [Self-Update Mechanism](42-self-update-mechanism.md) and clearer dependency management.

**User Benefit:** Users will be able to understand the significance of updates at a glance (e.g., distinguishing between a bug fix and a major breaking change). It provides a stable frame of reference when reporting issues or seeking support.

## 2. Design & Modularity

*   **Versioning Scheme:** We will adopt **Semantic Versioning 2.0.0 (SemVer)**.
    *   **MAJOR** version (e.g., `1.0.0` -> `2.0.0`) for incompatible API changes.
    *   **MINOR** version (e.g., `1.1.0` -> `1.2.0`) for adding functionality in a backward-compatible manner.
    *   **PATCH** version (e.g., `1.1.1` -> `1.1.2`) for backward-compatible bug fixes.
*   **Release Workflow:** Releases will be managed using Git tags.
    1.  Create a new branch for the release (e.g., `release/v1.1.0`).
    2.  Update the `CHANGELOG.md` with the changes for the new version.
    3.  Commit the changelog update.
    4.  Create an annotated Git tag for the version (e.g., `git tag -a v1.1.0 -m "Release version 1.1.0"`).
    5.  Push the tag to the remote repository (`git push --tags`).
    6.  Merge the release branch back into `main`.
*   **Version Storage:** A `VERSION` file will be created in the root of the repository. This file will contain the single source of truth for the current version of the project. The `fc info` command will be updated to display this version.

## 3. System Implications

*   **`fc` command:** The `fc info` command will be updated to read and display the version from the `VERSION` file.
*   **Self-Update Mechanism:** The proposed `fc self-update` command will rely on this versioning scheme to check for new versions and determine if migrations are needed.
*   **Installer:** The installer can display the version number at the beginning of the installation process.

## 4. Documentation Plan

*   **`CHANGELOG.md`:** A new `CHANGELOG.md` file will be created in the root directory to document all notable changes for each release. It will follow the "Keep a Changelog" format.
*   **`README.md`:** The `README.md` will be updated to include a badge showing the latest version.
*   **`docs/RELEASING.md`:** A new guide will be created to document the release process for maintainers.

## 5. Implementation Plan

1.  **Create `VERSION` file:** Add a `VERSION` file to the repository root with an initial version (e.g., `1.0.0`).
2.  **Create `CHANGELOG.md`:** Create the initial `CHANGELOG.md` file.
3.  **Update `fc-info`:** Modify the `lib/commands/fc-info` script to read and display the version from the `VERSION` file.
4.  **Create `RELEASING.md`:** Write the documentation for the release process.
5.  **Tag Initial Release:** Follow the release workflow to tag the first official version.
6.  **Testing:** Update tests for `fc info` to assert that the version is displayed.
