# Reference Documentation

This directory contains **technical reference documentation** for configuration files, system settings, and developer tools used by the Dotfiles Flying Circus project.

---

## Overview

Reference documentation provides in-depth technical details about:

- **Configuration file syntax** — What each option does and how to use it
- **System defaults** — macOS `defaults` commands and their effects
- **Best practices** — Recommended settings and patterns
- **Load order** — When and how configuration files are processed

Unlike guides (which teach concepts) or specifications (which define commands), reference docs are meant to be consulted when you need specific details about a setting or option.

---

## Documentation Categories

### Shells

Shell configuration files for Bash and Zsh.

| Document | Description |
|----------|-------------|
| [Shell Overview](shells/index.mdx) | Comparison of Bash vs Zsh startup files and load order |

#### Zsh Configuration

| File | Description |
|------|-------------|
| [.zshenv](shells/zsh/zshenv.mdx) | Environment variables for all shells |
| [.zprofile](shells/zsh/zprofile.mdx) | Login shell setup (early) |
| [.zshrc](shells/zsh/zshrc.mdx) | Interactive shell configuration |
| [.zlogin](shells/zsh/zlogin.mdx) | Login shell setup (late) |
| [.zlogout](shells/zsh/zlogout.mdx) | Login shell cleanup |

#### Bash Configuration

| File | Description |
|------|-------------|
| [.bash_profile](shells/bash/bash_profile.mdx) | Login shell initialization |
| [.bashrc](shells/bash/bashrc.mdx) | Interactive shell configuration |
| [.bash_login](shells/bash/bash_login.mdx) | Alternative login setup |
| [.bash_logout](shells/bash/bash_logout.mdx) | Login shell cleanup |
| [.profile](shells/bash/profile.mdx) | POSIX-compatible fallback |

---

### Editors

Editor configuration files.

| Document | Description |
|----------|-------------|
| [.editorconfig](editors/editorconfig.mdx) | Cross-editor formatting rules |
| [.vimrc](editors/vimrc.mdx) | Vim configuration and key bindings |

---

### Git

Git configuration and ignore patterns.

| Document | Description |
|----------|-------------|
| [.gitconfig](git/gitconfig.mdx) | Git settings, aliases, and behaviors |
| [.gitignore_global](git/gitignore_global.mdx) | Global ignore patterns |

---

### Terminal

Terminal input and behavior configuration.

| Document | Description |
|----------|-------------|
| [.inputrc](terminal/inputrc.mdx) | Readline library configuration for command-line input |

---

### macOS Defaults

Comprehensive reference for macOS `defaults` commands organized by system area.

#### Accessibility

| Setting | Description |
|---------|-------------|
| [Autoplay Animated Images](macos-defaults/accessibility/autoplayanimatedimages.mdx) | Control animated image playback |
| [Color Filters](macos-defaults/accessibility/colorfilters.mdx) | Color adjustment filters |
| [Cursor Size](macos-defaults/accessibility/cursorsize.mdx) | Mouse cursor size adjustment |
| [Flash Screen](macos-defaults/accessibility/flashscreen.mdx) | Visual alert for hearing accessibility |
| [Increase Contrast](macos-defaults/accessibility/increasecontrast.mdx) | Enhanced UI contrast |
| [Invert Colors](macos-defaults/accessibility/invertcolors.mdx) | Display color inversion |
| [Mouse Keys](macos-defaults/accessibility/mousekeys.mdx) | Control mouse via keyboard |
| [Reduce Motion](macos-defaults/accessibility/reducemotion.mdx) | Minimize interface animations |
| [Reduce Transparency](macos-defaults/accessibility/reducetransparency.mdx) | Disable transparency effects |
| [Shake to Locate](macos-defaults/accessibility/shaketolocate.mdx) | Enlarge cursor when shaking |
| [Show Window Titlebar Icons](macos-defaults/accessibility/showwindowtitlebaricons.mdx) | Display proxy icons in titlebars |
| [Sticky Keys](macos-defaults/accessibility/stickykeys.mdx) | Hold modifier keys |

#### Appearance

| Setting | Description |
|---------|-------------|
| [Show Scrollbars](macos-defaults/appearance/appleshowscrollbars.mdx) | Scrollbar visibility settings |

#### Control Center

| Setting | Description |
|---------|-------------|
| [AirDrop](macos-defaults/control-center/airdrop.mdx) | AirDrop menu bar visibility |
| [Battery](macos-defaults/control-center/battery.mdx) | Battery indicator settings |
| [Bluetooth](macos-defaults/control-center/bluetooth.mdx) | Bluetooth menu bar icon |
| [Display](macos-defaults/control-center/display.mdx) | Display settings in Control Center |
| [Focus Modes](macos-defaults/control-center/focusmodes.mdx) | Focus mode indicator |
| [Now Playing](macos-defaults/control-center/nowplaying.mdx) | Media playback indicator |
| [Screen Mirroring](macos-defaults/control-center/screenmirroring.mdx) | Screen mirroring indicator |
| [Sound](macos-defaults/control-center/sound.mdx) | Sound control visibility |
| [WiFi](macos-defaults/control-center/wifi.mdx) | WiFi menu bar icon |

#### Date & Time

| Setting | Description |
|---------|-------------|
| [Clock Format](macos-defaults/date-time/clockformat.mdx) | Menu bar clock format |
| [Show 24 Hour](macos-defaults/date-time/show24hour.mdx) | 24-hour time display |

#### Dialogs

| Setting | Description |
|---------|-------------|
| [Save Panel Expanded](macos-defaults/dialogs/nsnavpanelexpandedstateforsavemode.mdx) | Expanded save dialog by default |
| [Print Panel Expanded](macos-defaults/dialogs/printpanelexpanded.mdx) | Expanded print dialog by default |

#### Dock

| Setting | Description |
|---------|-------------|
| [Auto-hide](macos-defaults/dock/autohide.mdx) | Automatically hide the Dock |
| [Auto-hide Delay](macos-defaults/dock/autohide-delay.mdx) | Delay before Dock appears |
| [Magnification](macos-defaults/dock/magnification.mdx) | Icon magnification on hover |
| [Minimize Effect](macos-defaults/dock/mineffect.mdx) | Window minimize animation style |
| [Minimize to Application](macos-defaults/dock/minimize-to-application.mdx) | Minimize windows into app icon |
| [Orientation](macos-defaults/dock/orientation.mdx) | Dock position (left, bottom, right) |
| [Show Recents](macos-defaults/dock/show-recents.mdx) | Show recent applications section |
| [Tile Size](macos-defaults/dock/tilesize.mdx) | Dock icon size |

#### Energy

| Setting | Description |
|---------|-------------|
| [Display Sleep](macos-defaults/energy/displaysleep.mdx) | Display sleep timeout |
| [GPU Switch](macos-defaults/energy/gpuswitch.mdx) | Automatic graphics switching |
| [Hibernate Mode](macos-defaults/energy/hibernatemode.mdx) | Sleep/hibernate behavior |
| [Lid Wake](macos-defaults/energy/lidwake.mdx) | Wake on lid open |
| [Power Nap](macos-defaults/energy/powernap.mdx) | Background tasks during sleep |

#### Finder

| Setting | Description |
|---------|-------------|
| [Default Search Scope](macos-defaults/finder/fxdefaultsearchscope.mdx) | Default search location |
| [Default View Style](macos-defaults/finder/defaultviewstyle.mdx) | Default folder view mode |
| [Desktop Icons](macos-defaults/finder/desktopicons.mdx) | Show icons on desktop |
| [Extension Change Warning](macos-defaults/finder/fxenableextensionchangewarning.mdx) | Warn when changing extensions |
| [Hide Desktop](macos-defaults/finder/createdesktop.mdx) | Show/hide desktop icons |
| [Preferred View Style](macos-defaults/finder/fxpreferredviewstyle.mdx) | Preferred view mode |
| [Quick Look Text Selection](macos-defaults/finder/qlenabletextselection.mdx) | Select text in Quick Look |
| [Show All Extensions](macos-defaults/finder/appleshowallextensions.mdx) | Display all file extensions |
| [Show All Files](macos-defaults/finder/appleshowallfiles.mdx) | Show hidden files (dotfiles) |
| [Show Hidden Files](macos-defaults/finder/showhiddenfiles.mdx) | Display hidden files and folders |
| [Show Path Bar](macos-defaults/finder/showpathbar.mdx) | Display path bar at bottom |
| [Show Status Bar](macos-defaults/finder/showstatusbar.mdx) | Display status bar |
| [Sort Folders First](macos-defaults/finder/fxsortfoldersfirst.mdx) | Folders appear before files |

#### Firewall

| Setting | Description |
|---------|-------------|
| [Global State](macos-defaults/firewall/globalstate.mdx) | Enable/disable firewall |
| [Stealth Enabled](macos-defaults/firewall/stealthenabled.mdx) | Stealth mode settings |

#### Interface

| Setting | Description |
|---------|-------------|
| [Desktop Widgets](macos-defaults/interface/desktop-widgets.mdx) | Desktop widget settings |
| [Notification Previews](macos-defaults/interface/notification-previews.mdx) | Notification preview display |
| [Stage Manager](macos-defaults/interface/stagemanager.mdx) | Stage Manager window organization |
| [Titlebar Double-click](macos-defaults/interface/titlebar-doubleclick.mdx) | Titlebar double-click action |
| [Window Animations](macos-defaults/interface/window-animations.mdx) | Window animation effects |
| [Window Restore](macos-defaults/interface/window-restore.mdx) | Restore windows on app reopen |
| [Window Tabbing Mode](macos-defaults/interface/window-tabbingmode.mdx) | Prefer tabs when opening documents |

#### Keyboard

| Setting | Description |
|---------|-------------|
| [Auto-capitalization](macos-defaults/keyboard/autocapitalization.mdx) | Automatic capitalization |
| [Auto-correct](macos-defaults/keyboard/autocorrect.mdx) | Automatic spelling correction |
| [Auto-period](macos-defaults/keyboard/autoperiod.mdx) | Double-space to period |
| [Full Keyboard Access](macos-defaults/keyboard/fullkeyboardaccess.mdx) | Tab through all controls |
| [Initial Key Repeat](macos-defaults/keyboard/initialkeyrepeat.mdx) | Delay before key repeat starts |
| [Key Repeat](macos-defaults/keyboard/keyrepeat.mdx) | Key repeat rate |
| [Keyboard UI Mode](macos-defaults/keyboard/applekeyboarduimode.mdx) | Full keyboard access mode |
| [NS Auto-capitalization](macos-defaults/keyboard/nsautomaticcapitalizationenabled.mdx) | System auto-capitalization |
| [NS Auto-correction](macos-defaults/keyboard/nsautomaticspellingcorrectionenabled.mdx) | System auto-correction |
| [Press and Hold](macos-defaults/keyboard/pressandhold.mdx) | Character picker vs key repeat |
| [Press and Hold Enabled](macos-defaults/keyboard/applepressandholdenabled.mdx) | Enable press and hold |
| [Smart Dashes](macos-defaults/keyboard/smartdashes.mdx) | Automatic dash substitution |
| [Smart Quotes](macos-defaults/keyboard/smartquotes.mdx) | Automatic quote substitution |

#### Login

| Setting | Description |
|---------|-------------|
| [Guest Enabled](macos-defaults/login/guestenabled.mdx) | Guest user account |
| [Input Menu](macos-defaults/login/inputmenu.mdx) | Input menu at login |
| [Login Window Text](macos-defaults/login/loginwindowtext.mdx) | Custom login window message |
| [Password Hints](macos-defaults/login/passwordhints.mdx) | Show password hints |
| [Show Full Name](macos-defaults/login/showfullname.mdx) | Display full name at login |

#### Menu Bar

| Setting | Description |
|---------|-------------|
| [Auto-hide](macos-defaults/menu-bar/autohide.mdx) | Automatically hide menu bar |
| [Battery Percentage](macos-defaults/menu-bar/batterypercentage.mdx) | Show battery percentage |
| [Clock Format](macos-defaults/menu-bar/clockformat.mdx) | Menu bar clock format |
| [Date Format](macos-defaults/menu-bar/dateformat.mdx) | Menu bar date display |
| [Show Percent](macos-defaults/menu-bar/showpercent.mdx) | Show percentage indicator |

#### Mission Control

| Setting | Description |
|---------|-------------|
| [Expose Group Apps](macos-defaults/mission-control/expose-group-apps.mdx) | Group windows by application |
| [Hot Corners](macos-defaults/mission-control/hot-corners.mdx) | Screen corner actions |
| [MRU Spaces](macos-defaults/mission-control/mru-spaces.mdx) | Rearrange Spaces based on recent use |
| [Spaces Switch Activate](macos-defaults/mission-control/spaces-switch-activate.mdx) | Switch to Space with open window |
| [Spans Displays](macos-defaults/mission-control/spans-displays.mdx) | Displays have separate Spaces |

#### Mouse

| Setting | Description |
|---------|-------------|
| [Double-click Speed](macos-defaults/mouse/doubleclickspeed.mdx) | Double-click timing |
| [Tracking Speed](macos-defaults/mouse/trackingspeed.mdx) | Mouse cursor speed |

#### Pointer

| Setting | Description |
|---------|-------------|
| [Spring Loading](macos-defaults/pointer/springloading.mdx) | Drag-hover folder opening |

#### Safari (System)

| Setting | Description |
|---------|-------------|
| [Include Develop Menu](macos-defaults/safari/includedevelopmenu.mdx) | Enable Developer menu |
| [Show Full URL](macos-defaults/safari/showfullurlinsmartfield.mdx) | Display complete URL |

#### Screen Capture

| Setting | Description |
|---------|-------------|
| [Disable Shadow](macos-defaults/screencapture/disable-shadow.mdx) | Remove window shadow from screenshots |
| [Format](macos-defaults/screencapture/format.mdx) | Screenshot file format |
| [Location](macos-defaults/screencapture/location.mdx) | Screenshot save location |
| [Show Thumbnail](macos-defaults/screencapture/showthumbnail.mdx) | Show floating thumbnail |

#### Screensaver

| Setting | Description |
|---------|-------------|
| [Ask for Password](macos-defaults/screensaver/askforpassword.mdx) | Require password after screensaver |
| [Ask for Password Delay](macos-defaults/screensaver/askforpassworddelay.mdx) | Password delay timer |
| [Idle Time](macos-defaults/screensaver/idletime.mdx) | Time before screensaver activates |
| [Show Clock](macos-defaults/screensaver/showclock.mdx) | Display clock on screensaver |

#### Security

| Setting | Description |
|---------|-------------|
| [FileVault](macos-defaults/security/filevault.mdx) | Disk encryption |
| [Firewall Enable](macos-defaults/security/firewall-enable.mdx) | Enable application firewall |
| [Firewall Logging](macos-defaults/security/firewall-logging.mdx) | Firewall log settings |
| [Firewall Signed Apps](macos-defaults/security/firewall-signedapps.mdx) | Allow signed apps through firewall |
| [Firewall Stealth](macos-defaults/security/firewall-stealth.mdx) | Stealth mode |
| [Firewall Stealth Mode](macos-defaults/security/firewall-stealthmode.mdx) | Additional stealth settings |
| [Gatekeeper Quarantine](macos-defaults/security/gatekeeper-quarantine.mdx) | Downloaded app quarantine |

#### Software Update

| Setting | Description |
|---------|-------------|
| [App Store Auto Update](macos-defaults/software-update/appstoreautoupdate.mdx) | Auto-update App Store apps |
| [Automatic Check](macos-defaults/software-update/automaticheckenabled.mdx) | Check for updates automatically |
| [Automatic Download](macos-defaults/software-update/automaticdownload.mdx) | Download updates automatically |
| [Automatic Install macOS](macos-defaults/software-update/automaticinstallmacos.mdx) | Install macOS updates automatically |
| [Config Data Install](macos-defaults/software-update/configdatainstall.mdx) | Install system data files |
| [Critical Update Install](macos-defaults/software-update/criticalupdateinstall.mdx) | Install critical security updates |

#### Sound

| Setting | Description |
|---------|-------------|
| [Alert Volume](macos-defaults/sound/alertvolume.mdx) | System alert volume |
| [Beep Feedback](macos-defaults/sound/beepfeedback.mdx) | Audio feedback for volume changes |
| [Beep Volume](macos-defaults/sound/beepvolume.mdx) | System beep volume |
| [UI Sound Effects](macos-defaults/sound/uisoundeffects.mdx) | Interface sound effects |
| [Volume Feedback](macos-defaults/sound/volumefeedback.mdx) | Volume change feedback sound |

#### Spotlight

| Setting | Description |
|---------|-------------|
| [External Volumes](macos-defaults/spotlight/external-volumes.mdx) | Index external drives |
| [Suggestions Disabled](macos-defaults/spotlight/suggestions-disabled.mdx) | Disable Spotlight suggestions |

#### System

| Setting | Description |
|---------|-------------|
| [AirDrop](macos-defaults/system/airdrop.mdx) | AirDrop discoverability |
| [Bluetooth Audio](macos-defaults/system/bluetoothaudio.mdx) | Bluetooth audio codec settings |
| [Crash Reporter](macos-defaults/system/crashreporter.mdx) | Crash report behavior |
| [Energy](macos-defaults/system/energy.mdx) | System energy settings |
| [Firewall](macos-defaults/system/firewall.mdx) | System firewall settings |
| [Gatekeeper](macos-defaults/system/gatekeeper.mdx) | App security settings |
| [Login Window](macos-defaults/system/loginwindow.mdx) | Login window configuration |
| [Personalized Ads](macos-defaults/system/personalizedads.mdx) | Apple advertising settings |
| [Screen Capture](macos-defaults/system/screencapture.mdx) | Screenshot configuration |
| [Screen Sharing](macos-defaults/system/screensharing.mdx) | Remote screen sharing |
| [Siri](macos-defaults/system/siri.mdx) | Siri settings |
| [Spotlight](macos-defaults/system/spotlight.mdx) | Spotlight search settings |
| [Time Machine](macos-defaults/system/timemachine.mdx) | Backup configuration |
| [Time Machine Exclusions](macos-defaults/system/timemachine-exclusions.mdx) | Backup exclusion paths |

#### Terminal (System)

| Setting | Description |
|---------|-------------|
| [New Tab Working Directory](macos-defaults/terminal/newtabworkingdirectorybehavior.mdx) | New tab directory behavior |
| [Secure Keyboard Entry](macos-defaults/terminal/securekeyboardentry.mdx) | Secure keyboard input mode |

#### TextEdit (System)

| Setting | Description |
|---------|-------------|
| [Rich Text](macos-defaults/textedit/richtext.mdx) | Default to rich text format |
| [Smart Quotes](macos-defaults/textedit/smartquotes.mdx) | Automatic quote substitution |

#### Time Machine

| Setting | Description |
|---------|-------------|
| [Automatic Backups](macos-defaults/time-machine/automatic-backups.mdx) | Enable automatic backups |
| [Developer Exclusions](macos-defaults/time-machine/developer-exclusions.mdx) | Exclude development files |

#### Trackpad

| Setting | Description |
|---------|-------------|
| [Actuation Strength](macos-defaults/trackpad/actuationstrength.mdx) | Force Touch sensitivity |
| [Clicking](macos-defaults/trackpad/clicking.mdx) | Tap to click |
| [Natural Scrolling](macos-defaults/trackpad/naturalscrolling.mdx) | Natural scroll direction |
| [Right Click](macos-defaults/trackpad/rightclick.mdx) | Secondary click configuration |
| [Swipe Between Spaces](macos-defaults/trackpad/swipebetweenspaces.mdx) | Swipe gesture for Spaces |
| [Swipe Scroll Direction](macos-defaults/trackpad/swipescrolldirection.mdx) | Scroll direction setting |
| [Tap to Click](macos-defaults/trackpad/taptoclick.mdx) | Enable tap clicking |
| [Three Finger Drag](macos-defaults/trackpad/threefingerdrag.mdx) | Drag with three fingers |
| [Tracking Speed](macos-defaults/trackpad/trackingspeed.mdx) | Cursor tracking speed |

---

### Application Settings

Detailed configuration for individual applications.

#### 1Password

| Setting | Description |
|---------|-------------|
| [Security](macos-defaults/applications/1password/security.mdx) | Security and lock settings |

#### Activity Monitor

| Setting | Description |
|---------|-------------|
| [Icon Type](macos-defaults/applications/activity-monitor/icontype.mdx) | Dock icon display mode |

#### Alfred

| Setting | Description |
|---------|-------------|
| [Sync](macos-defaults/applications/alfred/sync.mdx) | Sync settings location |

#### App Store

| Setting | Description |
|---------|-------------|
| [Auto Play Video](macos-defaults/applications/appstore/autoplayvideo.mdx) | Auto-play preview videos |

#### Archive Utility

| Setting | Description |
|---------|-------------|
| [Behavior](macos-defaults/applications/archive-utility/behavior.mdx) | Archive extraction behavior |

#### Books

| Setting | Description |
|---------|-------------|
| [Audiobook Skip Intervals](macos-defaults/applications/books/audiobookskipintervals.mdx) | Skip forward/back duration |
| [Auto Night Theme](macos-defaults/applications/books/autonighttheme.mdx) | Automatic dark mode for reading |
| [BK Auto Night Theme Enabled](macos-defaults/applications/books/bkautonightthemeenabled.mdx) | Enable auto night theme |
| [Sync Position](macos-defaults/applications/books/syncposition.mdx) | Sync reading position across devices |
| [Sync Settings](macos-defaults/applications/books/syncsettings.mdx) | Sync preferences across devices |

#### Calculator

| Setting | Description |
|---------|-------------|
| [Separators](macos-defaults/applications/calculator/separators.mdx) | Thousands separator display |

#### Calendar

| Setting | Description |
|---------|-------------|
| [Default Event Duration](macos-defaults/applications/calendar/defaulteventduration.mdx) | Default length for new events |
| [First Day of Week](macos-defaults/applications/calendar/firstdayofweek.mdx) | Week start day |
| [Show Week Numbers](macos-defaults/applications/calendar/showweeknumbers.mdx) | Display week numbers |
| [Time Zone Support](macos-defaults/applications/calendar/timezonesupport.mdx) | Multiple time zone support |
| [Week Numbers](macos-defaults/applications/calendar/weeknumbers.mdx) | Week number display |
| [Week Start](macos-defaults/applications/calendar/weekstart.mdx) | First day of week |
| [Work Hours](macos-defaults/applications/calendar/workhours.mdx) | Working hours configuration |

#### Chrome

| Setting | Description |
|---------|-------------|
| [Confirm Before Quitting](macos-defaults/applications/chrome/confirmbeforequitting.mdx) | Quit confirmation dialog |
| [Confirm Quit](macos-defaults/applications/chrome/confirmquit.mdx) | Require confirmation to quit |
| [Disable Print Preview](macos-defaults/applications/chrome/disableprintpreview.mdx) | Skip print preview |
| [Native Print Dialog](macos-defaults/applications/chrome/nativeprintdialog.mdx) | Use system print dialog |
| [Swipe Navigation](macos-defaults/applications/chrome/swipenavigation.mdx) | Two-finger swipe navigation |

#### Console

| Setting | Description |
|---------|-------------|
| [Log Level](macos-defaults/applications/console/loglevel.mdx) | Default log verbosity |

#### Contacts

| Setting | Description |
|---------|-------------|
| [AB Name Sorting Format](macos-defaults/applications/contacts/abnamesortingformat.mdx) | Name sort order |
| [AB Show Nickname](macos-defaults/applications/contacts/abshownickname.mdx) | Display nicknames |
| [Name Sort Order](macos-defaults/applications/contacts/namesortorder.mdx) | Contact sorting preference |
| [Show Nickname](macos-defaults/applications/contacts/shownickname.mdx) | Show nickname field |
| [vCard Export](macos-defaults/applications/contacts/vcardexport.mdx) | vCard export settings |

#### Disk Utility

| Setting | Description |
|---------|-------------|
| [Advanced Image Options](macos-defaults/applications/disk-utility/advancedimageoptions.mdx) | Advanced disk image options |
| [Debug Menu](macos-defaults/applications/disk-utility/debugmenu.mdx) | Enable debug menu |
| [Show All Devices](macos-defaults/applications/disk-utility/showalldevices.mdx) | Display all disk devices |

#### Docker

| Setting | Description |
|---------|-------------|
| [Settings](macos-defaults/applications/docker/settings.mdx) | Docker Desktop settings |

#### Dropbox

| Setting | Description |
|---------|-------------|
| [Preferences](macos-defaults/applications/dropbox/preferences.mdx) | Dropbox preferences |

#### Firefox

| Setting | Description |
|---------|-------------|
| [Privacy](macos-defaults/applications/firefox/privacy.mdx) | Privacy and tracking settings |

#### Font Book

| Setting | Description |
|---------|-------------|
| [Preview Size](macos-defaults/applications/fontbook/previewsize.mdx) | Font preview size |

#### iTerm2

| Setting | Description |
|---------|-------------|
| [Custom Prefs](macos-defaults/applications/iterm2/customprefs.mdx) | Custom preferences location |

#### JetBrains

| Setting | Description |
|---------|-------------|
| [Settings](macos-defaults/applications/jetbrains/settings.mdx) | IDE settings |

#### Keynote

| Setting | Description |
|---------|-------------|
| [Alignment Guides](macos-defaults/applications/keynote/alignmentguides.mdx) | Show alignment guides |
| [Presenter Notes](macos-defaults/applications/keynote/presenternotes.mdx) | Presenter notes display |
| [Remote Control](macos-defaults/applications/keynote/remotecontrol.mdx) | Remote control settings |
| [Show Presenter Notes](macos-defaults/applications/keynote/showpresenternotes.mdx) | Display presenter notes |

#### Mail

| Setting | Description |
|---------|-------------|
| [Conversation Sort](macos-defaults/applications/mail/conversationsort.mdx) | Conversation sort order |
| [Conversation View](macos-defaults/applications/mail/conversationview.mdx) | Group messages by conversation |
| [Disable Inline Attachment Viewing](macos-defaults/applications/mail/disableinlineattachmentviewing.mdx) | Don't preview attachments inline |
| [Junk Filter](macos-defaults/applications/mail/junkfilter.mdx) | Spam filtering settings |
| [Junk Mail Behavior](macos-defaults/applications/mail/junkmailbehavior.mdx) | Junk mail handling |
| [Play Mail Sounds](macos-defaults/applications/mail/playmailsounds.mdx) | Email notification sounds |
| [Privacy Protection](macos-defaults/applications/mail/privacyprotection.mdx) | Mail privacy protection |
| [Protect Mail Activity](macos-defaults/applications/mail/protectmailactivity.mdx) | Hide IP and activity |

#### Messages

| Setting | Description |
|---------|-------------|
| [Play Sound Effects](macos-defaults/applications/messages/playsoundeffects.mdx) | Message sound effects |
| [Save History](macos-defaults/applications/messages/savehistory.mdx) | Save message history |
| [Sound Effects](macos-defaults/applications/messages/soundeffects.mdx) | Sound effect settings |

#### Music

| Setting | Description |
|---------|-------------|
| [Dolby Atmos Enabled](macos-defaults/applications/music/dolbyatmosenabled.mdx) | Spatial Audio with Dolby Atmos |
| [Lossless](macos-defaults/applications/music/lossless.mdx) | Lossless audio quality |
| [Lossless Enabled](macos-defaults/applications/music/losslessenabled.mdx) | Enable lossless playback |
| [Normalize Volume](macos-defaults/applications/music/normalizevolume.mdx) | Sound Check volume normalization |
| [Show Star Ratings](macos-defaults/applications/music/showstarratings.mdx) | Display star ratings |
| [Sound Check](macos-defaults/applications/music/soundcheck.mdx) | Volume normalization |
| [Star Ratings](macos-defaults/applications/music/starratings.mdx) | Star rating display |
| [User Wants Notifications](macos-defaults/applications/music/userwantsnotifications.mdx) | Now Playing notifications |

#### Notes

| Setting | Description |
|---------|-------------|
| [Default Font Size](macos-defaults/applications/notes/defaultfontsize.mdx) | Default note font size |
| [Font Size](macos-defaults/applications/notes/fontsize.mdx) | Note font size |
| [Notes Sort Order](macos-defaults/applications/notes/notessortorder.mdx) | Note sorting preference |
| [Sort Order](macos-defaults/applications/notes/sortorder.mdx) | Sort order setting |

#### Pages

| Setting | Description |
|---------|-------------|
| [Default Zoom](macos-defaults/applications/pages/defaultzoom.mdx) | Default document zoom level |
| [Word Count](macos-defaults/applications/pages/wordcount.mdx) | Show word count |

#### Photos

| Setting | Description |
|---------|-------------|
| [Auto Open](macos-defaults/applications/photos/autoopen.mdx) | Open Photos when device connects |
| [Hidden Album](macos-defaults/applications/photos/hiddenalbum.mdx) | Show Hidden album |
| [IPX Defaults Open Photos](macos-defaults/applications/photos/ipxdefaultsopenphotosforrdevice.mdx) | Auto-open for devices |
| [Metadata Info](macos-defaults/applications/photos/metadatainfo.mdx) | Show photo metadata |

#### Podcasts

| Setting | Description |
|---------|-------------|
| [Continuous Playback](macos-defaults/applications/podcasts/continuousplayback.mdx) | Auto-play next episode |
| [Episode Management](macos-defaults/applications/podcasts/episodemanagement.mdx) | Episode download and deletion |
| [Skip Intervals](macos-defaults/applications/podcasts/skipintervals.mdx) | Skip forward/back duration |
| [Sync Settings](macos-defaults/applications/podcasts/syncsettings.mdx) | Sync across devices |

#### Preview

| Setting | Description |
|---------|-------------|
| [PDF Display Mode](macos-defaults/applications/preview/pdfdisplaymode.mdx) | PDF view mode |
| [PV Anti-alias Images](macos-defaults/applications/preview/pvantialiasimages.mdx) | Image anti-aliasing |
| [PV Image Open Mode](macos-defaults/applications/preview/pvimageopenmode.mdx) | Image opening behavior |
| [PV PDF Display Mode](macos-defaults/applications/preview/pvpdfdisplaymode.mdx) | PDF display settings |
| [PV PDF Remember Current Page](macos-defaults/applications/preview/pvpdfremembercurrentpage.mdx) | Remember last viewed page |
| [PV Sidebar View Mode](macos-defaults/applications/preview/pvsidebarviewmode.mdx) | Sidebar display mode |
| [Remember Page](macos-defaults/applications/preview/rememberpage.mdx) | Remember PDF page position |
| [Sidebar](macos-defaults/applications/preview/sidebar.mdx) | Sidebar visibility |

#### QuickTime

| Setting | Description |
|---------|-------------|
| [Auto Play](macos-defaults/applications/quicktime/autoplay.mdx) | Auto-play videos |

#### Reminders

| Setting | Description |
|---------|-------------|
| [Sidebar](macos-defaults/applications/reminders/sidebar.mdx) | Sidebar visibility |
| [Sidebar Shown](macos-defaults/applications/reminders/sidebarshown.mdx) | Show sidebar by default |

#### Safari

| Setting | Description |
|---------|-------------|
| [Auto Fill](macos-defaults/applications/safari/autofill.mdx) | AutoFill settings |
| [Auto Open Safe Downloads](macos-defaults/applications/safari/autoopensafedownloads.mdx) | Open safe files after download |
| [Background Tabs](macos-defaults/applications/safari/backgroundtabs.mdx) | Open links in background |
| [Default Zoom](macos-defaults/applications/safari/defaultzoom.mdx) | Default page zoom level |
| [Develop Menu](macos-defaults/applications/safari/developmenu.mdx) | Show Develop menu |
| [Downloads Path](macos-defaults/applications/safari/downloadspath.mdx) | Download location |
| [Fraud Warning](macos-defaults/applications/safari/fraudwarning.mdx) | Fraudulent website warning |
| [Include Develop Menu](macos-defaults/applications/safari/includedevelopmenu.mdx) | Enable Develop menu |
| [Search Privacy](macos-defaults/applications/safari/searchprivacy.mdx) | Private search settings |
| [Send Do Not Track](macos-defaults/applications/safari/senddonottrack.mdx) | Do Not Track header |
| [Show Full URL](macos-defaults/applications/safari/showfullurl.mdx) | Display complete URL |
| [Warn About Fraudulent Websites](macos-defaults/applications/safari/warnaboutfraudulentwebsites.mdx) | Fraud protection |

#### Slack

| Setting | Description |
|---------|-------------|
| [Auto Launch](macos-defaults/applications/slack/autolaunch.mdx) | Launch at login |
| [Bounce](macos-defaults/applications/slack/bounce.mdx) | Dock icon bounce |
| [Close to Tray](macos-defaults/applications/slack/closetotray.mdx) | Minimize to menu bar |
| [Hardware Acceleration](macos-defaults/applications/slack/hardwareacceleration.mdx) | GPU acceleration |
| [Slack Auto Launch](macos-defaults/applications/slack/slackautolaunch.mdx) | Auto-launch setting |
| [Slack Bounce Enabled](macos-defaults/applications/slack/slackbounceenabled.mdx) | Dock bounce setting |
| [Spellcheck](macos-defaults/applications/slack/spellcheck.mdx) | Spell checking |

#### Spotify

| Setting | Description |
|---------|-------------|
| [Settings](macos-defaults/applications/spotify/settings.mdx) | Spotify preferences |

#### Terminal

| Setting | Description |
|---------|-------------|
| [Focus Follows Mouse](macos-defaults/applications/terminal/focusfollowsmouse.mdx) | Focus window under cursor |
| [New Tab Directory](macos-defaults/applications/terminal/newtabdirectory.mdx) | New tab working directory |
| [Scrollback](macos-defaults/applications/terminal/scrollback.mdx) | Scrollback buffer size |
| [Secure Keyboard](macos-defaults/applications/terminal/securekeyboard.mdx) | Secure keyboard entry |
| [String Encodings](macos-defaults/applications/terminal/stringencodings.mdx) | Text encoding settings |

#### TextEdit

| Setting | Description |
|---------|-------------|
| [NS Fixed Pitch Font](macos-defaults/applications/textedit/nsfixedpitchfont.mdx) | Monospace font setting |
| [Plain Text](macos-defaults/applications/textedit/plaintext.mdx) | Default to plain text |
| [Plain Text Font](macos-defaults/applications/textedit/plaintextfont.mdx) | Plain text font |
| [Smart Dashes](macos-defaults/applications/textedit/smartdashes.mdx) | Automatic dash substitution |

#### VS Code

| Setting | Description |
|---------|-------------|
| [Extensions](macos-defaults/applications/vscode/extensions.mdx) | Extension settings |
| [Settings](macos-defaults/applications/vscode/settings.mdx) | VS Code preferences |

#### Xcode

| Setting | Description |
|---------|-------------|
| [Build Duration](macos-defaults/applications/xcode/buildduration.mdx) | Show build time in toolbar |
| [Continue Building](macos-defaults/applications/xcode/continuebuilding.mdx) | Continue after errors |
| [DVT Text Editor Trim Trailing Whitespace](macos-defaults/applications/xcode/dvttexteditortrimtrailingwhitespace.mdx) | Trim whitespace on save |
| [DVT Text Page Guide](macos-defaults/applications/xcode/dvttextpageguide.mdx) | Page guide column |
| [DVT Text Show Line Numbers](macos-defaults/applications/xcode/dvttextshowlinenumbers.mdx) | Display line numbers |
| [IDE Building Continue After Errors](macos-defaults/applications/xcode/idebuildingcontinuebuildingaftererrors.mdx) | Build continuation setting |
| [Line Numbers](macos-defaults/applications/xcode/linenumbers.mdx) | Show line numbers |
| [Show Build Operation Duration](macos-defaults/applications/xcode/showbuildoperationduration.mdx) | Build time display |
| [Trim Whitespace](macos-defaults/applications/xcode/trimwhitespace.mdx) | Remove trailing whitespace |

#### Zoom

| Setting | Description |
|---------|-------------|
| [Dual Monitor](macos-defaults/applications/zoom/dualmonitor.mdx) | Dual monitor support |
| [HD Video](macos-defaults/applications/zoom/hdvideo.mdx) | HD video quality |
| [Join Muted](macos-defaults/applications/zoom/joinmuted.mdx) | Mute on join |
| [Join Video Off](macos-defaults/applications/zoom/joinvideooff.mdx) | Video off on join |
| [Meeting Controls](macos-defaults/applications/zoom/meetingcontrols.mdx) | Always show controls |
| [ZM Always Show Meeting Controls](macos-defaults/applications/zoom/zmalwaysshowmeetingcontrols.mdx) | Persistent meeting controls |
| [ZM Enable Auto Join VOIP](macos-defaults/applications/zoom/zmenableautojoinvoip.mdx) | Auto-join audio |
| [ZM Enable HD Video](macos-defaults/applications/zoom/zmenablehdvideo.mdx) | HD video setting |
| [ZM Enable Mute When Join](macos-defaults/applications/zoom/zmenablemutewhenjoin.mdx) | Mute setting |
| [ZM Enable Stop Video When Join](macos-defaults/applications/zoom/zmenablestopvideowhenjoin.mdx) | Video stop setting |

---

## Document Format

Reference documentation in this directory uses the `.mdx` format (Markdown with JSX) to support:

- **Interactive examples** — Copy-to-clipboard buttons
- **Tabbed content** — Multiple options in one view
- **Diagrams** — ASCII art for visual demonstrations
- **Callouts** — Tips, warnings, and notes

### Standard Sections

Each macOS defaults reference document includes:

1. **Title & Description** — Setting name and brief purpose
2. **Overview Table** — Domain, Key, Type, Default Value, Our Setting
3. **Description** — Detailed explanation of the setting
4. **Values** — Table of possible values and their effects
5. **Visual Demonstration** — ASCII diagrams showing behavior
6. **Our Configuration** — Recommended setting with reasoning
7. **Code Examples** — Bash commands for read/write/delete
8. **UI Location** — System Settings navigation path
9. **Troubleshooting** — Common issues and solutions
10. **Compatibility** — macOS version requirements
11. **Source File** — Link to implementation script
12. **References** — Links to Apple documentation

---

## Quick Links by Topic

### For New Users

- [Shell Overview](shells/index.mdx) — Understand how shell configs work
- [.zshrc](shells/zsh/zshrc.mdx) — Most commonly edited shell file
- [.gitconfig](git/gitconfig.mdx) — Essential Git configuration

### For Power Users

- [macOS Defaults](macos-defaults/) — Customize every aspect of macOS
- [.vimrc](editors/vimrc.mdx) — Advanced Vim configuration
- [.inputrc](terminal/inputrc.mdx) — Fine-tune command-line input

### For Developers

- [Finder: Show Hidden Files](macos-defaults/finder/showhiddenfiles.mdx) — Essential for dotfiles
- [Keyboard: Disable Auto-correct](macos-defaults/keyboard/autocorrect.mdx) — Prevent code mangling
- [Xcode Settings](macos-defaults/applications/xcode/) — IDE configuration
- [Terminal Settings](macos-defaults/applications/terminal/) — Terminal.app customization

### For Contributors

- [.editorconfig](editors/editorconfig.mdx) — Ensure consistent formatting
- [.gitignore_global](git/gitignore_global.mdx) — Ignore generated files

---

## Statistics

| Category | Count |
|----------|-------|
| Shell Configuration | 17 files |
| Editor Configuration | 2 files |
| Git Configuration | 2 files |
| Terminal Configuration | 1 file |
| macOS Defaults (System) | ~140 settings |
| macOS Defaults (Applications) | ~140 settings |
| **Total** | **~300 reference documents** |

---

## Contributing

To add new reference documentation:

1. Choose the appropriate category directory (or create a new one)
2. Use the `.mdx` format for rich content support
3. Follow the standard sections format (see any existing file as template)
4. Include practical code examples with read/write/delete commands
5. Add visual demonstrations where helpful
6. Link to related documentation and official references

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for general guidelines.
