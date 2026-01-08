# macOS Defaults Documentation Status

Last Updated: January 8, 2026

## Coverage Summary

| Metric | Count |
|--------|-------|
| **Total documentation files (.mdx)** | ~364 |
| **Total unique settings in defaults scripts** | ~400 |
| **Documented settings** | ~252 (63%) |
| **Undocumented settings** | ~148 (37%) |

## Recent Documentation Added (January 8, 2026)

### Accessibility Settings (NEW - 9 files)
- [hovertext.mdx](accessibility/hovertext.mdx) - Magnify text under pointer with Command key
- [zoommode.mdx](accessibility/zoommode.mdx) - Zoom style (full screen, split, picture-in-picture)
- [slowkeys.mdx](accessibility/slowkeys.mdx) - Require key hold duration before registering
- [stereoasmono.mdx](accessibility/stereoasmono.mdx) - Combine stereo channels for hearing accessibility
- [zoomsmoothimages.mdx](accessibility/zoomsmoothimages.mdx) - Anti-alias images when zoomed
- [zoomhotkeys.mdx](accessibility/zoomhotkeys.mdx) - Keyboard shortcuts for zoom control
- [hearingaidmode.mdx](accessibility/hearingaidmode.mdx) - MFi hearing aid support
- [audiobalance.mdx](accessibility/audiobalance.mdx) - Left/right audio balance adjustment

### Trackpad Settings (NEW - 6 files)
- [pinchtozoom.mdx](trackpad/pinchtozoom.mdx) - Pinch gesture to zoom in/out
- [rotate.mdx](trackpad/rotate.mdx) - Two-finger rotation gesture
- [smartzoom.mdx](trackpad/smartzoom.mdx) - Two-finger double-tap to zoom
- [fourfingerhorizswipe.mdx](trackpad/fourfingerhorizswipe.mdx) - Switch between Spaces
- [fourfingervertswipe.mdx](trackpad/fourfingervertswipe.mdx) - Mission Control and App Exposé
- [fivefingerpinch.mdx](trackpad/fivefingerpinch.mdx) - Launchpad and Show Desktop

### Safari Settings (NEW - 1 file)
- [autofillcreditcard.mdx](applications/safari/autofillcreditcard.mdx) - Credit card AutoFill security

### Siri Settings (NEW - 2 files)
- [voicetrigger.mdx](siri/voicetrigger.mdx) - "Hey Siri" voice activation
- [statusmenuvisible.mdx](siri/statusmenuvisible.mdx) - Show Siri in menu bar

### Dock Settings (NEW - 2 files)
- [springloading.mdx](dock/springloading.mdx) - Spring-load folders/apps when dragging
- [scrolltoopen.mdx](dock/scrolltoopen.mdx) - Scroll to open folder stacks

### Siri Settings (4 files)
- [assistant-enabled.mdx](siri/assistant-enabled.mdx) - Master Siri toggle
- [type-to-siri.mdx](siri/type-to-siri.mdx) - Type queries instead of speaking
- [suggestions.mdx](siri/suggestions.mdx) - Siri Suggestions in apps/Spotlight
- [voice-feedback.mdx](siri/voice-feedback.mdx) - Silent vs spoken responses

### Stage Manager Settings (4 files)
- [globally-enabled.mdx](stage-manager/globally-enabled.mdx) - Enable/disable Stage Manager
- [app-window-grouping.mdx](stage-manager/app-window-grouping.mdx) - Window grouping behavior
- [hide-desktop.mdx](stage-manager/hide-desktop.mdx) - Desktop icons visibility
- [autohide.mdx](stage-manager/autohide.mdx) - Recent apps strip visibility

### Podcasts Settings (2 files)
- [autodownload.mdx](applications/podcasts/autodownload.mdx) - Automatic episode downloads
- [playback.mdx](applications/podcasts/playback.mdx) - Skip times and continuous playback

## Coverage by Category

| Category | Documented | Undocumented | Total | Coverage |
|----------|------------|--------------|-------|----------|
| **Accessibility** | **20** | **11** | **31** | **65%** |
| **Applications/Safari** | **13** | **13** | **26** | **50%** |
| **Input/Trackpad** | **13** | **5** | **18** | **72%** |
| **System/Siri** | **7** | **4** | **11** | **64%** |
| System/Global | 32 | 8 | 40 | 80% |
| **Interface/Dock** | **13** | **5** | **18** | **72%** |
| Applications/Podcasts | 3 | 6 | 9 | 33% |
| Applications/Mail | 8 | 8 | 16 | 50% |
| Applications/Calendar | 5 | 8 | 13 | 38% |
| Applications/Xcode | 5 | 7 | 12 | 42% |
| Applications/Books | 2 | 7 | 9 | 22% |
| Interface/WindowManager | 4 | 2 | 6 | 67% |
| Applications/Numbers | 1 | 5 | 6 | 17% |
| Applications/Pages | 1 | 5 | 6 | 17% |
| Interface/Notifications | 1 | 3 | 4 | 25% |

---

## Undocumented Settings

### Accessibility (11 settings remaining)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.universalaccess` | `closeViewZoomFollowsFocus` | int | accessibility/zoom.sh |
| `com.apple.universalaccess` | `closeViewScrollWheelModifiersInt` | int | accessibility/zoom.sh |
| `com.apple.universalaccess` | `closeViewMaxZoom` | float | accessibility/zoom.sh |
| `com.apple.universalaccess` | `closeViewMinZoom` | float | accessibility/zoom.sh |
| `com.apple.universalaccess` | `hoverTextFontSize` | int | accessibility/display.sh |
| `com.apple.universalaccess` | `hoverTextFontName` | string | accessibility/display.sh |
| `com.apple.universalaccess` | `slowKeyDelay` | float | accessibility/keyboard.sh |
| `com.apple.universalaccess` | `stickyKeyShowWindow` | bool | accessibility/keyboard.sh |
| `com.apple.universalaccess` | `mouseDriverCursorSize` | float | accessibility/pointer.sh |
| `com.apple.universalaccess` | `mouseDriver` | bool | accessibility/pointer.sh |
| `com.apple.universalaccess` | `voiceOverOnOrOff` | bool | accessibility/voiceover.sh |

**Documented**: `hoverTextEnabled`, `closeViewZoomMode`, `slowKey`, `stereoAsMono`, `closeViewSmoothImages`, `closeViewHotKeysEnabled`, `HearingAidMode`, `audioBalance`

### Applications/Safari (13 settings remaining)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.Safari` | `AutoFillFromAddressBook` | bool | applications/safari.sh |
| `com.apple.Safari` | `AutoFillMiscellaneousForms` | bool | applications/safari.sh |
| `com.apple.Safari` | `BlockStoragePolicy` | int | applications/safari.sh |
| `com.apple.Safari` | `PreloadTopHit` | bool | applications/safari.sh |
| `com.apple.Safari` | `UniversalSearchEnabled` | bool | applications/safari.sh |
| `com.apple.Safari` | `WebKitDeveloperExtrasEnabledPreferenceKey` | bool | applications/safari.sh |
| `com.apple.Safari` | `WebKitJavaEnabled` | bool | applications/safari.sh |
| `com.apple.Safari` | `WebKitJavaScriptCanOpenWindowsAutomatically` | bool | applications/safari.sh |
| `com.apple.Safari` | `WebKitPluginsEnabled` | bool | applications/safari.sh |
| `com.apple.Safari` | `com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled` | bool | applications/safari.sh |
| `com.apple.Safari` | `com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled` | bool | applications/safari.sh |
| `com.apple.Safari` | `WarnAboutFraudulentWebsites` | bool | applications/safari.sh |
| `com.apple.Safari` | `WebContinuousSpellCheckingEnabled` | bool | applications/safari.sh |

**Documented**: `AutoFillCreditCardData`

### Input/Trackpad (5 settings remaining)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.AppleMultitouchTrackpad` | `ActuateDetents` | int | input/trackpad.sh |
| `com.apple.AppleMultitouchTrackpad` | `SecondClickThreshold` | int | input/trackpad.sh |
| `com.apple.AppleMultitouchTrackpad` | `Dragging` | int | input/trackpad.sh |
| `com.apple.AppleMultitouchTrackpad` | `DragLock` | int | input/trackpad.sh |
| `com.apple.AppleMultitouchTrackpad` | `TrackpadTwoFingerFromRightEdgeSwipeGesture` | int | input/trackpad.sh |

**Documented**: `TrackpadPinchToZoom`, `TrackpadRotate`, `TrackpadTwoFingerDoubleTapGesture`, `TrackpadFourFingerHorizSwipeGesture`, `TrackpadFourFingerVertSwipeGesture`, `TrackpadFiveFingerPinchGesture`

### System/Siri (4 settings remaining)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.Siri` | `UserHasDeclinedEnable` | bool | system/siri.sh |
| `com.apple.Siri` | `HotkeyTag` | int | system/siri.sh |
| `com.apple.Siri` | `LockscreenEnabled` | bool | system/siri.sh |
| `com.apple.assistant.backedup` | `Cloud Sync Enabled` | bool | system/siri.sh |

**Documented**: `Assistant Enabled`, `TypeToSiriEnabled`, `SiriSuggestionsEnabled`, `ShowSiriSuggestionsInSpotlight`, `VoiceFeedback`, `VoiceTriggerUserEnabled`, `StatusMenuVisible`

### Interface/Dock (5 settings remaining)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.dock` | `minimize-to-application` | bool | interface/dock.sh |
| `com.apple.dock` | `expose-group-apps` | bool | interface/dock.sh |
| `com.apple.dock` | `showAppExposeGestureEnabled` | bool | interface/dock.sh |
| `com.apple.dock` | `dashboard-in-overlay` | bool | interface/dock.sh |
| `com.apple.dock` | `wvous-*` (hot corners) | int | interface/dock.sh |

**Documented**: `enable-spring-load-actions-on-all-items`, `scroll-to-open`, `mineffect`

### Applications/Podcasts (6 settings remaining)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.podcasts` | `EpisodeDeleteBehavior` | int | applications/podcasts.sh |
| `com.apple.podcasts` | `NotificationsEnabled` | bool | applications/podcasts.sh |
| `com.apple.podcasts` | `PlaybackSpeed` | float | applications/podcasts.sh |
| `com.apple.podcasts` | `TrimSilence` | bool | applications/podcasts.sh |
| `com.apple.podcasts` | `episodeLimit` | int | applications/podcasts.sh |
| `com.apple.podcasts` | `syncPodcasts` | bool | applications/podcasts.sh |

**Documented**: `downloadNewEpisodes`, `skipForwardTime`, `skipBackTime`, `continuousPlaybackEnabled`, `headphoneControlsNextEpisode`

### Applications/Mail (8 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.mail` | `AddressesIncludeNameOnPasteboard` | bool | applications/mail.sh |
| `com.apple.mail` | `DraftsViewerAttributes` | dict | applications/mail.sh |
| `com.apple.mail` | `DisableInlineAttachmentViewing` | bool | applications/mail.sh |
| `com.apple.mail` | `SpellCheckingBehavior` | string | applications/mail.sh |
| `com.apple.mail` | `DisableURLLoading` | bool | applications/mail.sh |
| `com.apple.mail` | `NumberOfSnippetLines` | int | applications/mail.sh |
| `com.apple.mail` | `ShouldShowUnreadMessagesInBold` | bool | applications/mail.sh |
| `com.apple.mail` | `SwipeAction` | int | applications/mail.sh |

### Applications/Calendar (8 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.iCal` | `TimeZone support enabled` | bool | applications/calendar.sh |
| `com.apple.iCal` | `Show Week Numbers` | bool | applications/calendar.sh |
| `com.apple.iCal` | `first day of week` | int | applications/calendar.sh |
| `com.apple.iCal` | `first minute of work hours` | int | applications/calendar.sh |
| `com.apple.iCal` | `last minute of work hours` | int | applications/calendar.sh |
| `com.apple.iCal` | `number of days to show` | int | applications/calendar.sh |
| `com.apple.iCal` | `Default duration in minutes for new event` | int | applications/calendar.sh |
| `com.apple.iCal` | `TimeToLeaveEnabled` | bool | applications/calendar.sh |

### Applications/Xcode (7 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.dt.Xcode` | `DVTTextShowFoldingSidebar` | bool | applications/xcode.sh |
| `com.apple.dt.Xcode` | `DVTTextShowMinimap` | bool | applications/xcode.sh |
| `com.apple.dt.Xcode` | `DVTTextUsesSyntaxAwareIndenting` | bool | applications/xcode.sh |
| `com.apple.dt.Xcode` | `IDEDocViewerInitialSelection` | string | applications/xcode.sh |
| `com.apple.dt.Xcode` | `IDEWorkspaceTabBarShowsTabNames` | bool | applications/xcode.sh |
| `com.apple.dt.Xcode` | `IDEKeyBindingCurrentPreferenceSet` | string | applications/xcode.sh |
| `com.apple.dt.Xcode` | `DVTSourceControlAutomaticallyAddNewFiles` | bool | applications/xcode.sh |

### Applications/Books (7 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.iBooksX` | `BKDefaultPageTurnAnimation` | int | applications/books.sh |
| `com.apple.iBooksX` | `BKForceLegacyBrightnessControl` | bool | applications/books.sh |
| `com.apple.iBooksX` | `BKShowScrollIndicator` | bool | applications/books.sh |
| `com.apple.iBooksX` | `BKHighlightColorIndex` | int | applications/books.sh |
| `com.apple.iBooksX` | `BKLastUsedFontFamilyName` | string | applications/books.sh |
| `com.apple.iBooksX` | `BKLastUsedFontSize` | int | applications/books.sh |
| `com.apple.iBooksX` | `BKReaderTheme` | int | applications/books.sh |

### Interface/WindowManager (Stage Manager) (2 settings remaining)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.WindowManager` | `EnableStandardClickToShowDesktop` | bool | interface/stage_manager.sh |
| `com.apple.WindowManager` | `StageManagerHideWidgets` | bool | interface/stage_manager.sh |

**Documented**: `GloballyEnabled`, `AutoHide`, `HideDesktop`, `AppWindowGroupingBehavior`

### Applications/Numbers (5 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.iWork.Numbers` | `TSDefaultZoom` | int | applications/numbers.sh |
| `com.apple.iWork.Numbers` | `TSShowsAutoCorrection` | bool | applications/numbers.sh |
| `com.apple.iWork.Numbers` | `TSShowsRuler` | bool | applications/numbers.sh |
| `com.apple.iWork.Numbers` | `TSShowsComments` | bool | applications/numbers.sh |
| `com.apple.iWork.Numbers` | `TSTableDefaultRowCount` | int | applications/numbers.sh |

### Applications/Pages (5 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.iWork.Pages` | `TSDefaultZoom` | int | applications/pages.sh |
| `com.apple.iWork.Pages` | `TSShowsAutoCorrection` | bool | applications/pages.sh |
| `com.apple.iWork.Pages` | `TSShowsRuler` | bool | applications/pages.sh |
| `com.apple.iWork.Pages` | `TSShowsComments` | bool | applications/pages.sh |
| `com.apple.iWork.Pages` | `TSShowSizeAndPositionWhenMoving` | bool | applications/pages.sh |

### System/Global (8 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `NSGlobalDomain` | `AppleMenuBarFontSize` | int | system/global.sh |
| `NSGlobalDomain` | `AppleReduceDesktopTinting` | bool | system/global.sh |
| `NSGlobalDomain` | `NSDocumentSaveNewDocumentsToCloud` | bool | system/global.sh |
| `NSGlobalDomain` | `NSRecentDocumentsLimit` | int | system/global.sh |
| `NSGlobalDomain` | `NSStatusItemSelectionPadding` | int | system/global.sh |
| `NSGlobalDomain` | `NSStatusItemSpacing` | int | system/global.sh |
| `NSGlobalDomain` | `com.apple.sound.beep.sound` | string | system/sound.sh |
| `NSGlobalDomain` | `com.apple.sound.beep.flash` | bool | system/sound.sh |

### Interface/Notifications (3 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.notificationcenterui` | `shouldPlaySound` | bool | interface/notifications.sh |
| `com.apple.ncprefs` | `dnd_prefs` | dict | interface/notifications.sh |
| `com.apple.ncprefs` | `apps` | array | interface/notifications.sh |

### Applications/Keynote (5 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.iWork.Keynote` | `TSDefaultZoom` | int | applications/keynote.sh |
| `com.apple.iWork.Keynote` | `TSShowsAutoCorrection` | bool | applications/keynote.sh |
| `com.apple.iWork.Keynote` | `TSShowsRuler` | bool | applications/keynote.sh |
| `com.apple.iWork.Keynote` | `TSShowsComments` | bool | applications/keynote.sh |
| `com.apple.iWork.Keynote` | `TSShowsPresenterNotes` | bool | applications/keynote.sh |

### Finder (5 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.finder` | `DesktopViewSettings` | dict | finder/desktop.sh |
| `com.apple.finder` | `StandardViewSettings` | dict | finder/views.sh |
| `com.apple.finder` | `WarnOnEmptyTrash` | bool | finder/behavior.sh |
| `com.apple.finder` | `EmptyTrashSecurely` | bool | finder/behavior.sh |
| `com.apple.finder` | `DisableAllAnimations` | bool | finder/behavior.sh |

### Mission Control (5 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.dock` | `expose-animation-duration` | float | interface/mission_control.sh |
| `com.apple.dock` | `showLaunchpadGestureEnabled` | bool | interface/mission_control.sh |
| `com.apple.dock` | `showMissionControlGestureEnabled` | bool | interface/mission_control.sh |
| `com.apple.spaces` | `app-bindings` | dict | interface/mission_control.sh |
| `com.apple.symbolichotkeys` | `AppleSymbolicHotKeys` | dict | interface/mission_control.sh |

### Bluetooth (3 settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.BluetoothAudioAgent` | `Apple Bitpool Min (editable)` | int | system/bluetooth.sh |
| `com.apple.BluetoothAudioAgent` | `Apple Bitpool Max (editable)` | int | system/bluetooth.sh |
| `com.apple.BluetoothAudioAgent` | `Apple Initial Bitpool (editable)` | int | system/bluetooth.sh |

### Other Miscellaneous (20+ settings)

| Domain | Key | Type | Source File |
|--------|-----|------|-------------|
| `com.apple.DiskUtility` | `DUAskBeforeErase` | bool | applications/disk_utility.sh |
| `com.apple.DiskUtility` | `DUDebugMenuEnabled` | bool | applications/disk_utility.sh |
| `com.apple.DiskUtility` | `DUShowAPFSSnapshots` | bool | applications/disk_utility.sh |
| `com.apple.TimeMachine` | `DoNotOfferNewDisksForBackup` | bool | system/time_machine.sh |
| `com.apple.TimeMachine` | `AutoBackup` | bool | system/time_machine.sh |
| `com.apple.CrashReporter` | `UseUNC` | bool | system/crash_reporter.sh |
| `com.apple.LaunchServices` | `LSQuarantine` | bool | system/security.sh |
| `com.apple.TextEdit` | `SmartLinks` | bool | applications/textedit.sh |
| `com.apple.TextEdit` | `SmartCopyPaste` | bool | applications/textedit.sh |
| `com.apple.Preview` | `PVAntiAliasImages` | bool | applications/preview.sh |
| `com.apple.Photos` | `IPXPrefsMetadataAlwaysShow` | bool | applications/photos.sh |
| `com.apple.Notes` | `IndentUsingTabs` | bool | applications/notes.sh |
| `com.apple.reminders` | `DefaultListID` | string | applications/reminders.sh |
| `com.apple.messages` | `NotificationSoundsEnabled` | bool | applications/messages.sh |
| `com.apple.ActivityMonitor` | `UpdatePeriod` | int | applications/activity_monitor.sh |
| `com.apple.ActivityMonitor` | `ShowCategory` | int | applications/activity_monitor.sh |
| `com.apple.screencapture` | `include-date` | bool | system/screenshot.sh |
| `com.apple.menuextra.clock` | `IsAnalog` | bool | interface/menu_bar.sh |
| `com.apple.menuextra.clock` | `FlashDateSeparators` | bool | interface/menu_bar.sh |
| `com.apple.Terminal` | `NSQuitAlwaysKeepsWindows` | bool | applications/terminal.sh |

---

## Priority Documentation Roadmap

### Phase 1: Critical Gaps (0% Coverage) - COMPLETED
**Status: ✓ Done**

1. ~~**Siri** (10 settings)~~ - ✓ 4 documented, 40% coverage
2. ~~**WindowManager/Stage Manager** (6 settings)~~ - ✓ 4 documented, 67% coverage
3. **Interface/Notifications** (3 settings) - Still pending

### Phase 2: Low Coverage (<40%)
**Estimated: 50 settings**

1. **Accessibility** (19 settings) - Important for users
2. **Trackpad** (11 settings) - Common customization
3. **Books** (7 settings)
4. **Numbers** (5 settings)
5. **Pages** (5 settings)

### Phase 3: Medium Coverage (40-60%)
**Estimated: 50 settings**

1. **Safari** (14 settings) - Security-relevant
2. **Calendar** (8 settings)
3. **Mail** (8 settings)
4. **Dock** (8 settings)
5. **Xcode** (7 settings)

### Phase 4: Polish
**Estimated: 40+ settings**

- Remaining miscellaneous settings
- Global system settings
- Application-specific edge cases

---

## File Locations

- **Documentation**: `docs/reference/macos-defaults/`
- **Implementation Scripts**: `defaults/`
- **This Status File**: `docs/reference/macos-defaults/DOCUMENTATION-STATUS.md`

---

## Notes

- Settings marked with `dict` or `array` types may require special handling
- Some settings are macOS version-specific
- Hot corner settings (`wvous-*`) have multiple variants (tl, tr, bl, br + modifiers)
- WebKit settings often have both legacy and WebKit2 variants
