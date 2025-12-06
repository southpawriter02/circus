# GUI/UX Enhancement Backlog

This document tracks planned GUI/UX improvements for the Dotfiles Flying Circus installer.

## Priority Legend

- **P1** - High priority, high impact
- **P2** - Medium priority, should be done
- **P3** - Nice to have
- **P4** - Future consideration

---

## P1 - High Priority

### 1. Stage Progress Tracking
**Status:** Completed
**Impact:** High | **Effort:** Medium

The UI library has a powerful `ui_stages_init()` and `ui_stages_print()` system that's not currently used.

**Enhancement:**
- Add stage tracking initialization in `install.sh` before executing stages
- Display a visual progress tracker showing all 12 stages with current status
- Update stage status (`ui_stage_complete/fail/skip`) as each stage finishes
- Show a persistent mini progress bar at the top of each stage

**Files affected:** `install.sh`, all stage scripts

---

### 2. Preflight Checks Integration
**Status:** Completed
**Impact:** High | **Effort:** Medium

There are 21 preflight checks in `install/preflight/` that are completely unused.

**Enhancement:**
- Create a new Stage 0 that runs all preflight checks
- Display a checklist-style UI showing each check with spinners
- Use `ui_spinner_start/stop` for each check with success/warning/error icons
- Aggregate results into a summary table before proceeding
- Allow user to skip non-critical failures

**Files affected:** New stage script, `install.sh`

---

### 3. Interactive Role Selection
**Status:** Completed
**Impact:** High | **Effort:** Low

Currently, roles are specified via `--role` flag only.

**Enhancement:**
- Use `ui_select()` to present an interactive role selection menu in Stage 1
- Display role descriptions and what each role includes
- Show a preview of role-specific packages before confirmation
- Use `ui_multiselect()` to allow optional feature selection

**Files affected:** `install/01-introduction-and-user-interaction.sh`

---

## P2 - Medium Priority

### 4. Progress Bars for Long Operations
**Status:** Completed
**Impact:** Medium | **Effort:** Low

Operations like `brew bundle` can take several minutes with no visual feedback.

**Enhancement:**
- Add `ui_progress_bar()` during Homebrew bundle installation
- Show package count progress (e.g., "Installing 45 packages: [████░░░░░░] 12/45")
- Use spinners for individual package installations
- Display estimated time remaining

**Files affected:** `install/03-homebrew-installation.sh`

---

### 5. Spinners for All Long-Running Operations
**Status:** Planned
**Impact:** Medium | **Effort:** Low

Currently, operations just print "Installing..." and wait silently.

**Enhancement:**
- Wrap long operations with `ui_spinner_start/stop`
- Operations to enhance:
  - Homebrew installation/update
  - Oh-My-Zsh installation
  - XCode CLI tools installation
  - Git configuration
  - File deployments

**Files affected:** Multiple stage scripts

---

### 6. Standardize Stage Headers
**Status:** Planned
**Impact:** Medium | **Effort:** Low

Stage scripts use inconsistent header formatting.

**Enhancement:**
- Create a `ui_stage_header()` function that displays:
  - Current stage number/total (e.g., "Stage 3 of 12")
  - Stage title in a bordered box
  - Brief description
- Use consistent styling across all stages

**Files affected:** `lib/ui.sh`, all stage scripts

---

### 7. Error Recovery and Help Dialogs
**Status:** Planned
**Impact:** Medium | **Effort:** Medium

When errors occur, users get basic error messages with no guidance.

**Enhancement:**
- Create `ui_error_dialog()` for showing errors with:
  - Error description
  - Possible causes
  - Suggested fixes
  - Options: Retry / Skip / Abort
- Add contextual help for common failures

**Files affected:** `lib/ui.sh`, stage scripts

---

### 8. Summary Table Improvements
**Status:** Planned
**Impact:** Medium | **Effort:** Low

The current summary table shows generic completion status.

**Enhancement:**
- Show actual metrics:
  - Packages installed (number)
  - Files deployed (count)
  - Settings changed (count)
  - Time taken per stage
- Add success rate percentage
- Show any warnings/skipped items clearly

**Files affected:** `install/15-finalization-and-reporting.sh`

---

## P3 - Nice to Have

### 9. System Requirements Check Display
**Status:** Planned
**Impact:** Medium | **Effort:** Low

Show system requirements before starting.

**Enhancement:**
- Display minimum requirements in a table:
  - macOS version (required vs detected)
  - Disk space (required vs available)
  - Internet connection status
  - Admin privileges
- Use green check / red X for pass/fail

**Files affected:** `install/01-introduction-and-user-interaction.sh`

---

### 10. Configuration Preview Before Deployment
**Status:** Planned
**Impact:** Medium | **Effort:** Medium

Show users what will change before making changes.

**Enhancement:**
- Display a diff preview of dotfiles before deployment
- Show macOS defaults that will be changed
- Use `ui_multiselect()` to let users opt-out of specific changes

**Files affected:** `install/09-dotfiles-deployment.sh`, `install/04-macos-system-settings.sh`

---

### 11. Animated Stage Transitions
**Status:** Planned
**Impact:** Low | **Effort:** Low

Stage transitions are abrupt.

**Enhancement:**
- Add brief animated transitions between stages
- Clear screen and redraw progress tracker at stage boundaries
- Show a "Stage Complete" animation with icon before moving on

**Files affected:** `install.sh`, stage scripts

---

### 12. Verbose Mode Toggle
**Status:** Planned
**Impact:** Medium | **Effort:** Medium

Users may want to see detailed output or hide it.

**Enhancement:**
- Add `--verbose` and `--quiet` modes
- In quiet mode: Show only spinners and progress bars
- In verbose mode: Show all command output with syntax highlighting
- Add a toggle prompt: "Show detailed output? [y/N]"

**Files affected:** `install.sh`, `lib/helpers.sh`

---

## P4 - Future Consideration

### 13. Keyboard Shortcut Hints
**Status:** Planned
**Impact:** Low | **Effort:** Low

Help users navigate interactive prompts.

**Enhancement:**
- Display keyboard shortcuts in prompts:
  - "Press [Enter] to continue, [Ctrl+C] to abort"
  - "Use arrow keys to select, [Space] to toggle"
- Add a help hint: "Press [?] for help"

**Files affected:** `lib/ui.sh`

---

### 14. Installation Timeline/Log Viewer
**Status:** Planned
**Impact:** Low | **Effort:** Medium

Users may want to review what happened.

**Enhancement:**
- Create a `--review` mode that displays a timestamped log
- Use `ui_table()` to show a timeline of all actions
- Color-code by action type (install, configure, deploy)

**Files affected:** New feature in `install.sh`

---

### 15. Theme/Color Scheme Selection
**Status:** Planned
**Impact:** Low | **Effort:** Medium

Allow users to customize the installer appearance.

**Enhancement:**
- Add `--theme` option (e.g., `--theme=light`, `--theme=dark`, `--theme=minimal`)
- Create 2-3 color scheme presets
- Remember preference for future runs

**Files affected:** `lib/ui.sh`

---

## Implementation Progress

| # | Enhancement | Priority | Status |
|---|-------------|----------|--------|
| 1 | Stage Progress Tracking | P1 | **Completed** |
| 2 | Preflight Checks Integration | P1 | **Completed** |
| 3 | Interactive Role Selection | P1 | **Completed** |
| 4 | Progress Bars for Long Ops | P2 | **Completed** |
| 5 | Spinners for All Operations | P2 | Planned |
| 6 | Standardize Stage Headers | P2 | Planned |
| 7 | Error Recovery Dialogs | P2 | Planned |
| 8 | Summary Table Improvements | P2 | Planned |
| 9 | System Requirements Display | P3 | Planned |
| 10 | Configuration Preview | P3 | Planned |
| 11 | Animated Transitions | P3 | Planned |
| 12 | Verbose Mode Toggle | P3 | Planned |
| 13 | Keyboard Shortcut Hints | P4 | Planned |
| 14 | Installation Timeline | P4 | Planned |
| 15 | Theme Selection | P4 | Planned |

---

## Notes

- The existing `lib/ui.sh` library provides most of the components needed
- Priority should be given to items that leverage existing UI components
- All enhancements should maintain compatibility with non-interactive mode
- Consider `gum` availability for enhanced experiences with graceful fallbacks
