# ==============================================================================
#
# FILE:         macos.aliases.sh
#
# DESCRIPTION:  Aliases for common macOS commands.
#
# ==============================================================================

# Show/hide hidden files in Finder
alias showhiddenfiles='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hidehiddenfiles='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'

# Lock the screen
alias lock='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'

# Flush DNS cache
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
