# Feature Proposal: 46 - Cloud CLI Config Management

## 1. Feature Overview

This feature introduces a new command, `fc cloud-config`, to help manage configuration for various cloud command-line interfaces (CLIs), such as `aws`, `gcloud`, and `az`. It will focus on switching between different configuration profiles.

**User Benefit:** Many developers work with multiple cloud accounts (e.g., personal, work-dev, work-prod). Switching between these accounts can be cumbersome and error-prone. This command provides a single, unified way to manage and switch profiles across different cloud CLIs.

## 2. Design & Modularity

*   **Profile Switching:** The core functionality is profile switching. The command will manage the environment variables (e.g., `AWS_PROFILE`, `CLOUDSDK_CONFIG`) that control which profile is active.
*   **Command Structure:**
    *   `fc cloud-config use <provider> <profile_name>`: Sets the specified profile as the active one for the current shell session.
    *   `fc cloud-config list <provider>`: Lists the available profiles for a given provider.
    *   `fc cloud-config current`: Shows the currently active profiles for all providers.
*   **Shell Integration:** This command needs to modify the environment of the current shell. It will be implemented as a shell function that users can call, rather than a script that runs in a sub-shell.
*   **Provider Abstraction:** The logic for each provider (`aws`, `gcloud`, `az`) will be in its own separate function to keep the code clean.

## 3. Security Considerations

*   **Credential Storage:** This command does not manage the cloud credentials themselves. It only manages the switching between profiles, assuming that the user has already configured their credentials securely using the provider's recommended methods.
*   **Environment Variables:** The command works by setting environment variables. These variables are scoped to the current shell session and are not persisted.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc cloud-config` command will be documented, with a clear explanation that it must be used as a shell function.
*   **New Guide:** A `docs/CLOUD_CONFIG.md` guide will provide examples of how to set up and switch between profiles for the supported cloud providers.

## 5. Implementation Plan

1.  **Create Shell Function:** Develop the `fc-cloud-config` shell function in a file that is sourced by the user's shell (e.g., `profiles/sh/.shell_functions`).
2.  **Implement Provider Logic:** Write the logic for each provider to list profiles and set the appropriate environment variables. For `aws`, this involves parsing `~/.aws/config`. For `gcloud`, it involves `gcloud config configurations list`.
3.  **Implement `use` command:** Write the logic to export the correct environment variables for the chosen profile.
4.  **Testing:** Add `bats` tests to verify the profile listing logic. Testing the environment variable setting will be more complex and may require manual testing.
5.  **Documentation:** Create the `docs/CLOUD_CONFIG.md` guide and update `COMMANDS.md`.
