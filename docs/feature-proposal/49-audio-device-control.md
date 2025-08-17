# Feature Proposal: 49 - Audio Device Control

## 1. Feature Overview

This feature introduces a new command, `fc audio`, for controlling audio settings from the command line. This includes changing the volume, muting the audio, and switching between different input and output devices.

**User Benefit:** Provides a scriptable and quick way to manage audio settings. This is useful for users who frequently switch between headphones and speakers, or for automating audio setup as part of a larger script (e.g., "start my video conferencing setup").

## 2. Design & Modularity

*   **Dependency:** The implementation will rely on a third-party command-line tool designed for this purpose, such as `switchaudio-osx`.
*   **Command Structure:**
    *   `fc audio volume <level>`: Sets the system volume to a specific level (0-100).
    *   `fc audio mute` / `fc audio unmute`: Mutes or unmutes the system volume.
    *   `fc audio list-outputs`: Lists all available audio output devices.
    *   `fc audio set-output <device_name>`: Sets the default audio output device.
    *   `fc audio list-inputs`: Lists all available audio input devices.
    *   `fc audio set-input <device_name>`: Sets the default audio input device.
*   **Fuzzy Matching:** The `<device_name>` argument will use fuzzy matching to make it easier to select devices with long names.

## 3. Security Considerations

*   **Dependency Trust:** The chosen third-party tool (`switchaudio-osx` or similar) must be vetted and trusted. It will be installed from Homebrew.
*   **No `sudo` Required:** Managing audio devices does not require `sudo`.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc audio` command and its sub-commands will be fully documented.
*   **Inline Comments:** The `fc-audio` script will be commented to explain the underlying commands being used.

## 5. Implementation Plan

1.  **Dependency:** Add `switchaudio-osx` (or the chosen alternative) to the `Brewfile`.
2.  **Create `fc-audio` script:** Develop the new command in `lib/commands/`.
3.  **Implement Wrapper Functions:** Write the functions for each sub-command (`volume`, `mute`, `set-output`, etc.) that call the underlying audio control tool.
4.  **Implement Fuzzy Matching:** Add logic to the `set-output` and `set-input` commands to allow for partial device names.
5.  **Testing:** Add `bats` tests that mock the audio control tool to verify that the correct commands are being called.
6.  **Documentation:** Update `COMMANDS.md` with the new command's documentation.
