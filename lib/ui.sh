#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         lib/ui.sh
#
# DESCRIPTION:  Enhanced terminal UI library for the Dotfiles Flying Circus.
#               Provides colorful, professional terminal interface components
#               including ASCII art, box-drawing, progress bars, spinners,
#               and optional gum integration.
#
# ==============================================================================

# ------------------------------------------------------------------------------
# SECTION: TERMINAL CAPABILITY DETECTION
# ------------------------------------------------------------------------------

# Detect terminal capabilities
UI_TERM_COLORS=${TERM_COLORS:-$(tput colors 2>/dev/null || echo 8)}
UI_TERM_WIDTH=${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}
UI_SUPPORTS_256_COLOR=$([[ $UI_TERM_COLORS -ge 256 ]] && echo true || echo false)
UI_SUPPORTS_UNICODE=${UI_SUPPORTS_UNICODE:-true}

# Check if gum is available for enhanced UI
UI_HAS_GUM=$(command -v gum &>/dev/null && echo true || echo false)

# ------------------------------------------------------------------------------
# SECTION: EXTENDED COLOR PALETTE (256-color support)
# ------------------------------------------------------------------------------

# Reset
UI_RESET="\033[0m"

# Text styles
UI_BOLD="\033[1m"
UI_DIM="\033[2m"
UI_ITALIC="\033[3m"
UI_UNDERLINE="\033[4m"
UI_BLINK="\033[5m"
UI_REVERSE="\033[7m"

# Standard colors (foreground)
UI_BLACK="\033[30m"
UI_RED="\033[31m"
UI_GREEN="\033[32m"
UI_YELLOW="\033[33m"
UI_BLUE="\033[34m"
UI_MAGENTA="\033[35m"
UI_CYAN="\033[36m"
UI_WHITE="\033[37m"

# Bright/Bold colors
UI_BRIGHT_BLACK="\033[90m"
UI_BRIGHT_RED="\033[91m"
UI_BRIGHT_GREEN="\033[92m"
UI_BRIGHT_YELLOW="\033[93m"
UI_BRIGHT_BLUE="\033[94m"
UI_BRIGHT_MAGENTA="\033[95m"
UI_BRIGHT_CYAN="\033[96m"
UI_BRIGHT_WHITE="\033[97m"

# Background colors
UI_BG_BLACK="\033[40m"
UI_BG_RED="\033[41m"
UI_BG_GREEN="\033[42m"
UI_BG_YELLOW="\033[43m"
UI_BG_BLUE="\033[44m"
UI_BG_MAGENTA="\033[45m"
UI_BG_CYAN="\033[46m"
UI_BG_WHITE="\033[47m"

# 256-color support (use fallback if not supported)
ui_color_256() {
  local fg="${1:-}"
  local bg="${2:-}"
  local result=""
  [[ -n "$fg" ]] && result+="\033[38;5;${fg}m"
  [[ -n "$bg" ]] && result+="\033[48;5;${bg}m"
  echo -e "$result"
}

# Theme colors (using 256-color palette with fallbacks)
if [[ "$UI_SUPPORTS_256_COLOR" == "true" ]]; then
  UI_PRIMARY="\033[38;5;39m"      # Bright blue
  UI_SECONDARY="\033[38;5;213m"   # Pink/magenta
  UI_ACCENT="\033[38;5;208m"      # Orange
  UI_SUCCESS="\033[38;5;82m"      # Bright green
  UI_WARNING="\033[38;5;220m"     # Gold/yellow
  UI_ERROR="\033[38;5;196m"       # Bright red
  UI_INFO="\033[38;5;117m"        # Light blue
  UI_MUTED="\033[38;5;245m"       # Gray
  UI_HIGHLIGHT_BG="\033[48;5;236m" # Dark gray background
else
  UI_PRIMARY="$UI_BRIGHT_BLUE"
  UI_SECONDARY="$UI_BRIGHT_MAGENTA"
  UI_ACCENT="$UI_YELLOW"
  UI_SUCCESS="$UI_BRIGHT_GREEN"
  UI_WARNING="$UI_YELLOW"
  UI_ERROR="$UI_BRIGHT_RED"
  UI_INFO="$UI_CYAN"
  UI_MUTED="$UI_BRIGHT_BLACK"
  UI_HIGHLIGHT_BG="$UI_BG_BLACK"
fi

# ------------------------------------------------------------------------------
# SECTION: UNICODE BOX-DRAWING CHARACTERS
# ------------------------------------------------------------------------------

if [[ "$UI_SUPPORTS_UNICODE" == "true" ]]; then
  # Double-line box (for headers)
  UI_BOX_TL="╔"
  UI_BOX_TR="╗"
  UI_BOX_BL="╚"
  UI_BOX_BR="╝"
  UI_BOX_H="═"
  UI_BOX_V="║"

  # Single-line box (for content)
  UI_BOX_TL_S="┌"
  UI_BOX_TR_S="┐"
  UI_BOX_BL_S="└"
  UI_BOX_BR_S="┘"
  UI_BOX_H_S="─"
  UI_BOX_V_S="│"
  UI_BOX_CROSS="┼"
  UI_BOX_T_DOWN="┬"
  UI_BOX_T_UP="┴"
  UI_BOX_T_RIGHT="├"
  UI_BOX_T_LEFT="┤"

  # Status icons
  UI_ICON_SUCCESS="✓"
  UI_ICON_ERROR="✗"
  UI_ICON_WARNING="⚠"
  UI_ICON_INFO="ℹ"
  UI_ICON_PENDING="○"
  UI_ICON_ACTIVE="●"
  UI_ICON_ARROW="→"
  UI_ICON_BULLET="•"
  UI_ICON_STAR="★"

  # Progress bar characters
  UI_PROGRESS_FULL="█"
  UI_PROGRESS_PARTIAL="▓"
  UI_PROGRESS_LIGHT="░"
  UI_PROGRESS_EMPTY="░"

  # Spinner frames
  UI_SPINNER_FRAMES=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
else
  # ASCII fallbacks
  UI_BOX_TL="+"
  UI_BOX_TR="+"
  UI_BOX_BL="+"
  UI_BOX_BR="+"
  UI_BOX_H="="
  UI_BOX_V="|"

  UI_BOX_TL_S="+"
  UI_BOX_TR_S="+"
  UI_BOX_BL_S="+"
  UI_BOX_BR_S="+"
  UI_BOX_H_S="-"
  UI_BOX_V_S="|"
  UI_BOX_CROSS="+"
  UI_BOX_T_DOWN="+"
  UI_BOX_T_UP="+"
  UI_BOX_T_RIGHT="+"
  UI_BOX_T_LEFT="+"

  UI_ICON_SUCCESS="[OK]"
  UI_ICON_ERROR="[X]"
  UI_ICON_WARNING="[!]"
  UI_ICON_INFO="[i]"
  UI_ICON_PENDING="[ ]"
  UI_ICON_ACTIVE="[*]"
  UI_ICON_ARROW="->"
  UI_ICON_BULLET="*"
  UI_ICON_STAR="*"

  UI_PROGRESS_FULL="#"
  UI_PROGRESS_PARTIAL="="
  UI_PROGRESS_LIGHT="-"
  UI_PROGRESS_EMPTY=" "

  UI_SPINNER_FRAMES=("-" "\\" "|" "/")
fi

# ------------------------------------------------------------------------------
# SECTION: ASCII ART BANNER
# ------------------------------------------------------------------------------

ui_print_banner() {
  local width=${1:-$UI_TERM_WIDTH}
  [[ $width -gt 80 ]] && width=80

  echo ""
  if [[ $width -ge 70 ]]; then
    # Full ASCII art banner
    printf "${UI_PRIMARY}${UI_BOLD}"
    cat << 'EOF'
    ____        __  _____ __              ________
   / __ \____  / /_/ __(_) /__  _____    / ____(_)________  __  _______
  / / / / __ \/ __/ /_/ / / _ \/ ___/   / /   / / ___/ __ \/ / / / ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  )   / /___/ / /  / /_/ / /_/ (__  )
/_____/\____/\__/_/ /_/_/\___/____/    \____/_/_/   \___\_\__,_/____/
EOF
    printf "${UI_RESET}"
    printf "${UI_SECONDARY}${UI_BOLD}"
    cat << 'EOF'
                          _____ _       _
                         |  ___| |_   _(_)_ __   __ _
                         | |_  | | | | | | '_ \ / _` |
                         |  _| | | |_| | | | | | (_| |
                         |_|   |_|\__, |_|_| |_|\__, |
                                  |___/         |___/
EOF
    printf "${UI_RESET}\n"
  else
    # Compact banner for narrow terminals
    printf "${UI_PRIMARY}${UI_BOLD}"
    echo "╔═══════════════════════════════════════╗"
    echo "║   DOTFILES FLYING CIRCUS              ║"
    printf "${UI_RESET}${UI_SECONDARY}${UI_BOLD}"
    echo "║         Installation Wizard           ║"
    printf "${UI_RESET}${UI_PRIMARY}${UI_BOLD}"
    echo "╚═══════════════════════════════════════╝"
    printf "${UI_RESET}\n"
  fi
}

ui_print_banner_mini() {
  printf "${UI_PRIMARY}${UI_BOLD}${UI_BOX_H}${UI_BOX_H}${UI_BOX_H} ${UI_RESET}"
  printf "${UI_BOLD}DOTFILES FLYING CIRCUS${UI_RESET}"
  printf "${UI_PRIMARY}${UI_BOLD} ${UI_BOX_H}${UI_BOX_H}${UI_BOX_H}${UI_RESET}\n"
}

# ------------------------------------------------------------------------------
# SECTION: BOX DRAWING FUNCTIONS
# ------------------------------------------------------------------------------

#
# Draws a box with a title
#
# @param $1 Title text
# @param $2 Width (optional, defaults to terminal width)
# @param $3 Style: "double" or "single" (optional, defaults to double)
#
ui_box_top() {
  local title="${1:-}"
  local width="${2:-$UI_TERM_WIDTH}"
  local style="${3:-double}"

  [[ $width -gt 80 ]] && width=80

  local tl tr h
  if [[ "$style" == "single" ]]; then
    tl="$UI_BOX_TL_S"; tr="$UI_BOX_TR_S"; h="$UI_BOX_H_S"
  else
    tl="$UI_BOX_TL"; tr="$UI_BOX_TR"; h="$UI_BOX_H"
  fi

  local title_len=${#title}
  local padding=$(( (width - title_len - 4) / 2 ))
  local padding_right=$(( width - title_len - 4 - padding ))

  printf "${UI_PRIMARY}${tl}"
  local pad_str
  printf -v pad_str '%*s' "$padding" ''
  printf "%s" "${pad_str// /$h}"
  if [[ -n "$title" ]]; then
    printf "${UI_RESET}${UI_BOLD} %s ${UI_RESET}${UI_PRIMARY}" "$title"
  fi
  printf -v pad_str '%*s' "$padding_right" ''
  printf "%s" "${pad_str// /$h}"
  printf "${tr}${UI_RESET}\n"
}

ui_box_line() {
  local text="${1:-}"
  local width="${2:-$UI_TERM_WIDTH}"
  local style="${3:-double}"
  local align="${4:-left}"

  [[ $width -gt 80 ]] && width=80

  local v
  [[ "$style" == "single" ]] && v="$UI_BOX_V_S" || v="$UI_BOX_V"

  local text_width=$(( width - 4 ))
  local text_len=${#text}

  printf "${UI_PRIMARY}${v}${UI_RESET} "

  case "$align" in
    center)
      local pad_left=$(( (text_width - text_len) / 2 ))
      local pad_right=$(( text_width - text_len - pad_left ))
      printf '%*s%s%*s' "$pad_left" '' "$text" "$pad_right" ''
      ;;
    right)
      printf '%*s' "$text_width" "$text"
      ;;
    *)
      printf '%-*s' "$text_width" "$text"
      ;;
  esac

  printf " ${UI_PRIMARY}${v}${UI_RESET}\n"
}

ui_box_bottom() {
  local width="${1:-$UI_TERM_WIDTH}"
  local style="${2:-double}"

  [[ $width -gt 80 ]] && width=80

  local bl br h
  if [[ "$style" == "single" ]]; then
    bl="$UI_BOX_BL_S"; br="$UI_BOX_BR_S"; h="$UI_BOX_H_S"
  else
    bl="$UI_BOX_BL"; br="$UI_BOX_BR"; h="$UI_BOX_H"
  fi

  printf "${UI_PRIMARY}${bl}"
  local pad_str
  printf -v pad_str '%*s' "$(( width - 2 ))" ''
  printf "%s" "${pad_str// /$h}"
  printf "${br}${UI_RESET}\n"
}

ui_box_separator() {
  local width="${1:-$UI_TERM_WIDTH}"
  local style="${2:-single}"

  [[ $width -gt 80 ]] && width=80

  local tl tr h
  if [[ "$style" == "single" ]]; then
    tl="$UI_BOX_T_RIGHT"; tr="$UI_BOX_T_LEFT"; h="$UI_BOX_H_S"
  else
    tl="├"; tr="┤"; h="$UI_BOX_H"
  fi

  printf "${UI_PRIMARY}${tl}"
  local pad_str
  printf -v pad_str '%*s' "$(( width - 2 ))" ''
  printf "%s" "${pad_str// /$h}"
  printf "${tr}${UI_RESET}\n"
}

#
# Convenience function to draw a complete box
#
ui_box() {
  local title="${1:-}"
  local width="${2:-$UI_TERM_WIDTH}"
  local style="${3:-double}"

  ui_box_top "$title" "$width" "$style"

  # Read lines from stdin and add them to the box
  while IFS= read -r line; do
    ui_box_line "$line" "$width" "$style"
  done

  ui_box_bottom "$width" "$style"
}

# ------------------------------------------------------------------------------
# SECTION: PROGRESS BAR
# ------------------------------------------------------------------------------

#
# Draws a progress bar
#
# @param $1 Current value
# @param $2 Maximum value
# @param $3 Width (optional, defaults to 40)
# @param $4 Label (optional)
#
ui_progress_bar() {
  local current="${1:-0}"
  local max="${2:-100}"
  local width="${3:-40}"
  local label="${4:-}"

  local percent=$(( current * 100 / max ))
  local filled=$(( current * width / max ))
  local empty=$(( width - filled ))

  printf "\r${UI_RESET}"

  if [[ -n "$label" ]]; then
    printf "${UI_INFO}%s ${UI_RESET}" "$label"
  fi

  printf "${UI_MUTED}[${UI_RESET}"

  # Filled portion with gradient effect
  if [[ $filled -gt 0 ]]; then
    printf "${UI_SUCCESS}"
    local fill_str
    printf -v fill_str '%*s' "$filled" ''
    printf "%s" "${fill_str// /$UI_PROGRESS_FULL}"
  fi

  # Empty portion
  if [[ $empty -gt 0 ]]; then
    printf "${UI_MUTED}"
    local empty_str
    printf -v empty_str '%*s' "$empty" ''
    printf "%s" "${empty_str// /$UI_PROGRESS_EMPTY}"
  fi

  printf "${UI_MUTED}]${UI_RESET} "
  printf "${UI_BOLD}%3d%%${UI_RESET}" "$percent"

  if [[ $max -gt 0 ]]; then
    printf " ${UI_MUTED}(%d/%d)${UI_RESET}" "$current" "$max"
  fi
}

ui_progress_bar_done() {
  echo ""
}

# ------------------------------------------------------------------------------
# SECTION: SPINNER
# ------------------------------------------------------------------------------

# Global spinner state
_UI_SPINNER_PID=""
_UI_SPINNER_MSG=""

#
# Starts a spinner animation in the background
#
# @param $1 Message to display
#
ui_spinner_start() {
  local message="${1:-Loading...}"
  _UI_SPINNER_MSG="$message"

  # If gum is available and we're in interactive mode, use it
  if [[ "$UI_HAS_GUM" == "true" ]] && [[ -t 1 ]]; then
    gum spin --spinner dot --title "$message" -- sleep infinity &
    _UI_SPINNER_PID=$!
    return
  fi

  # Pure bash spinner
  (
    local i=0
    local frames_count=${#UI_SPINNER_FRAMES[@]}
    while true; do
      printf "\r${UI_PRIMARY}${UI_SPINNER_FRAMES[$i]}${UI_RESET} ${UI_INFO}%s${UI_RESET}   " "$message"
      i=$(( (i + 1) % frames_count ))
      sleep 0.1
    done
  ) &
  _UI_SPINNER_PID=$!
}

#
# Stops the spinner and shows a result
#
# @param $1 Status: "success", "error", "warning", or "info"
# @param $2 Optional message override
#
ui_spinner_stop() {
  local status="${1:-success}"
  local message="${2:-$_UI_SPINNER_MSG}"

  if [[ -n "$_UI_SPINNER_PID" ]]; then
    kill "$_UI_SPINNER_PID" 2>/dev/null
    wait "$_UI_SPINNER_PID" 2>/dev/null
    _UI_SPINNER_PID=""
  fi

  printf "\r"

  case "$status" in
    success)
      printf "${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} ${UI_SUCCESS}%s${UI_RESET}\n" "$message"
      ;;
    error)
      printf "${UI_ERROR}${UI_ICON_ERROR}${UI_RESET} ${UI_ERROR}%s${UI_RESET}\n" "$message"
      ;;
    warning)
      printf "${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} ${UI_WARNING}%s${UI_RESET}\n" "$message"
      ;;
    info)
      printf "${UI_INFO}${UI_ICON_INFO}${UI_RESET} ${UI_INFO}%s${UI_RESET}\n" "$message"
      ;;
    *)
      printf "%s\n" "$message"
      ;;
  esac

  # Clear any remaining characters
  printf "\033[K"
}

# ------------------------------------------------------------------------------
# SECTION: STAGE PROGRESS TRACKER
# ------------------------------------------------------------------------------

# Global stage tracking
declare -a UI_STAGES=()
declare -a UI_STAGE_STATUS=()
UI_CURRENT_STAGE=0

#
# Initialize stages for tracking
#
# @param ... List of stage names
#
ui_stages_init() {
  UI_STAGES=("$@")
  UI_STAGE_STATUS=()
  UI_CURRENT_STAGE=0
  for _ in "${UI_STAGES[@]}"; do
    UI_STAGE_STATUS+=("pending")
  done
}

#
# Mark a stage as complete and move to next
#
ui_stage_complete() {
  if [[ $UI_CURRENT_STAGE -lt ${#UI_STAGES[@]} ]]; then
    UI_STAGE_STATUS[$UI_CURRENT_STAGE]="complete"
    UI_CURRENT_STAGE=$(( UI_CURRENT_STAGE + 1 ))
    if [[ $UI_CURRENT_STAGE -lt ${#UI_STAGES[@]} ]]; then
      UI_STAGE_STATUS[$UI_CURRENT_STAGE]="active"
    fi
  fi
}

#
# Mark current stage as skipped
#
ui_stage_skip() {
  if [[ $UI_CURRENT_STAGE -lt ${#UI_STAGES[@]} ]]; then
    UI_STAGE_STATUS[$UI_CURRENT_STAGE]="skipped"
    UI_CURRENT_STAGE=$(( UI_CURRENT_STAGE + 1 ))
    if [[ $UI_CURRENT_STAGE -lt ${#UI_STAGES[@]} ]]; then
      UI_STAGE_STATUS[$UI_CURRENT_STAGE]="active"
    fi
  fi
}

#
# Mark current stage as failed
#
ui_stage_fail() {
  if [[ $UI_CURRENT_STAGE -lt ${#UI_STAGES[@]} ]]; then
    UI_STAGE_STATUS[$UI_CURRENT_STAGE]="failed"
  fi
}

#
# Start the current stage (mark as active)
#
ui_stage_start() {
  if [[ $UI_CURRENT_STAGE -lt ${#UI_STAGES[@]} ]]; then
    UI_STAGE_STATUS[$UI_CURRENT_STAGE]="active"
  fi
}

#
# Print the stage progress tracker
#
ui_stages_print() {
  local width="${1:-$UI_TERM_WIDTH}"
  [[ $width -gt 80 ]] && width=80

  local total=${#UI_STAGES[@]}
  local completed=0

  echo ""
  printf "${UI_BOLD}${UI_PRIMARY}INSTALLATION PROGRESS${UI_RESET}\n"
  printf "${UI_MUTED}"
  local border_str
  printf -v border_str '%*s' "$width" ''
  printf "%s" "${border_str// /$UI_BOX_H_S}"
  printf -v border_str '%*s' "$width" ''
  printf "%s" "${border_str// /$UI_BOX_H_S}"
  printf "${UI_RESET}\n"

  # Calculate how many stages per row (aim for 3 per row)
  local cols=3
  local col_width=$(( (width - 2) / cols ))

  local i=0
  while [[ $i -lt $total ]]; do
    for (( c=0; c<cols && i<total; c++, i++ )); do
      local status="${UI_STAGE_STATUS[$i]}"
      local name="${UI_STAGES[$i]}"
      local icon color

      case "$status" in
        complete)
          icon="$UI_ICON_SUCCESS"
          color="$UI_SUCCESS"
          ((completed++))
          ;;
        active)
          icon="$UI_ICON_ACTIVE"
          color="$UI_PRIMARY"
          ;;
        failed)
          icon="$UI_ICON_ERROR"
          color="$UI_ERROR"
          ;;
        skipped)
          icon="$UI_ICON_WARNING"
          color="$UI_WARNING"
          ((completed++))
          ;;
        *)
          icon="$UI_ICON_PENDING"
          color="$UI_MUTED"
          ;;
      esac

      # Truncate name if too long
      local max_name_len=$(( col_width - 4 ))
      if [[ ${#name} -gt $max_name_len ]]; then
        name="${name:0:$(( max_name_len - 2 ))}.."
      fi

      printf " ${color}%s %-*s${UI_RESET}" "$icon" "$max_name_len" "$name"
    done
    echo ""
  done

  printf "${UI_MUTED}"
  printf '%*s' "$width" '' | tr ' ' "$UI_BOX_H_S"
  printf "${UI_RESET}\n"

  # Show progress summary
  local percent=$(( completed * 100 / total ))
  printf "%*s${UI_BOLD}Stage %d/%d${UI_RESET} ${UI_MUTED}(%d%% complete)${UI_RESET}\n" \
    $(( width - 25 )) '' \
    $(( UI_CURRENT_STAGE + 1 )) "$total" "$percent"
  echo ""
}

# ------------------------------------------------------------------------------
# SECTION: SUMMARY TABLE
# ------------------------------------------------------------------------------

#
# Print a formatted table
#
# @param $1 Column widths (comma-separated, e.g., "30,15,10")
# @param ... Rows (comma-separated values)
#
ui_table() {
  local widths_str="${1:-}"
  shift
  local headers="${1:-}"
  shift

  # Parse column widths
  IFS=',' read -ra widths <<< "$widths_str"
  local total_width=1
  for w in "${widths[@]}"; do
    total_width=$(( total_width + w + 3 ))
  done

  # Print top border
  printf "${UI_PRIMARY}${UI_BOX_TL_S}"
  local fill_str
  for i in "${!widths[@]}"; do
    printf -v fill_str '%*s' "${widths[$i]}" ''
    printf "%s" "${fill_str// /$UI_BOX_H_S}"
    printf "${UI_BOX_H_S}${UI_BOX_H_S}"
    if [[ $i -lt $(( ${#widths[@]} - 1 )) ]]; then
      printf "${UI_BOX_T_DOWN}"
    fi
  done
  printf "${UI_BOX_TR_S}${UI_RESET}\n"

  # Print header row
  IFS=',' read -ra cols <<< "$headers"
  printf "${UI_PRIMARY}${UI_BOX_V_S}${UI_RESET}"
  for i in "${!cols[@]}"; do
    printf " ${UI_BOLD}%-*s${UI_RESET} ${UI_PRIMARY}${UI_BOX_V_S}${UI_RESET}" "${widths[$i]}" "${cols[$i]}"
  done
  printf "\n"

  # Print header separator
  printf "${UI_PRIMARY}${UI_BOX_T_RIGHT}"
  for i in "${!widths[@]}"; do
    printf -v fill_str '%*s' "${widths[$i]}" ''
    printf "%s" "${fill_str// /$UI_BOX_H_S}"
    printf "${UI_BOX_H_S}${UI_BOX_H_S}"
    if [[ $i -lt $(( ${#widths[@]} - 1 )) ]]; then
      printf "${UI_BOX_CROSS}"
    fi
  done
  printf "${UI_BOX_T_LEFT}${UI_RESET}\n"

  # Print data rows
  for row in "$@"; do
    IFS=',' read -ra cols <<< "$row"
    printf "${UI_PRIMARY}${UI_BOX_V_S}${UI_RESET}"
    for i in "${!cols[@]}"; do
      local cell="${cols[$i]}"
      local cell_color=""

      # Check for status indicators and colorize
      case "$cell" in
        *"$UI_ICON_SUCCESS"*|*"Complete"*|*"Success"*)
          cell_color="$UI_SUCCESS"
          ;;
        *"$UI_ICON_ERROR"*|*"Failed"*|*"Error"*)
          cell_color="$UI_ERROR"
          ;;
        *"$UI_ICON_WARNING"*|*"Skipped"*|*"Warning"*)
          cell_color="$UI_WARNING"
          ;;
      esac

      printf " ${cell_color}%-*s${UI_RESET} ${UI_PRIMARY}${UI_BOX_V_S}${UI_RESET}" "${widths[$i]}" "$cell"
    done
    printf "\n"
  done

  # Print bottom border
  printf "${UI_PRIMARY}${UI_BOX_BL_S}"
  for i in "${!widths[@]}"; do
    printf -v fill_str '%*s' "${widths[$i]}" ''
    printf "%s" "${fill_str// /$UI_BOX_H_S}"
    printf "${UI_BOX_H_S}${UI_BOX_H_S}"
    if [[ $i -lt $(( ${#widths[@]} - 1 )) ]]; then
      printf "${UI_BOX_T_UP}"
    fi
  done
  printf "${UI_BOX_BR_S}${UI_RESET}\n"
}

# ------------------------------------------------------------------------------
# SECTION: GUM INTEGRATION (OPTIONAL ENHANCED UI)
# ------------------------------------------------------------------------------

#
# Display a selection menu (uses gum if available, fallback to simple menu)
#
# @param $1 Prompt text
# @param ... Options to choose from
# @return Selected option (printed to stdout)
#
ui_select() {
  local prompt="${1:-Select an option:}"
  shift
  local options=("$@")

  if [[ "$UI_HAS_GUM" == "true" ]] && [[ -t 0 ]] && [[ -t 1 ]]; then
    gum choose --header "$prompt" "${options[@]}"
    return
  fi

  # Fallback to simple numbered menu
  echo ""
  printf "${UI_BOLD}%s${UI_RESET}\n" "$prompt"
  echo ""

  local i=1
  for opt in "${options[@]}"; do
    printf "  ${UI_PRIMARY}%d)${UI_RESET} %s\n" "$i" "$opt"
    ((i++))
  done

  echo ""
  local choice
  while true; do
    read -p "Enter choice [1-${#options[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le ${#options[@]} ]]; then
      echo "${options[$((choice-1))]}"
      return
    fi
    printf "${UI_ERROR}Invalid selection. Please try again.${UI_RESET}\n"
  done
}

#
# Display a multi-select menu (uses gum if available)
#
# @param $1 Prompt text
# @param ... Options (prefix with '+' for pre-selected)
# @return Selected options (one per line)
#
ui_multiselect() {
  local prompt="${1:-Select options (space to toggle):}"
  shift
  local options=("$@")

  if [[ "$UI_HAS_GUM" == "true" ]] && [[ -t 0 ]] && [[ -t 1 ]]; then
    local selected=()
    local items=()
    for opt in "${options[@]}"; do
      if [[ "$opt" == +* ]]; then
        selected+=("${opt:1}")
        items+=("${opt:1}")
      else
        items+=("$opt")
      fi
    done
    if [[ ${#selected[@]} -gt 0 ]]; then
      gum choose --no-limit --header "$prompt" --selected="${selected[*]}" "${items[@]}"
    else
      gum choose --no-limit --header "$prompt" "${items[@]}"
    fi
    return
  fi

  # Fallback: display checklist and let user type numbers
  echo ""
  printf "${UI_BOLD}%s${UI_RESET}\n" "$prompt"
  echo ""

  local -a selected_status=()
  local i=1
  for opt in "${options[@]}"; do
    if [[ "$opt" == +* ]]; then
      selected_status+=("1")
      printf "  ${UI_SUCCESS}[${UI_ICON_SUCCESS}]${UI_RESET} ${UI_PRIMARY}%d)${UI_RESET} %s\n" "$i" "${opt:1}"
    else
      selected_status+=("0")
      printf "  ${UI_MUTED}[ ]${UI_RESET} ${UI_PRIMARY}%d)${UI_RESET} %s\n" "$i" "$opt"
    fi
    ((i++))
  done

  echo ""
  printf "${UI_INFO}Enter numbers to toggle (comma-separated), then press Enter:${UI_RESET}\n"
  read -p "> " toggles

  IFS=',' read -ra toggle_nums <<< "$toggles"
  for num in "${toggle_nums[@]}"; do
    num=$(echo "$num" | tr -d ' ')
    if [[ "$num" =~ ^[0-9]+$ ]] && [[ "$num" -ge 1 ]] && [[ "$num" -le ${#options[@]} ]]; then
      local idx=$((num - 1))
      if [[ "${selected_status[$idx]}" == "1" ]]; then
        selected_status[$idx]="0"
      else
        selected_status[$idx]="1"
      fi
    fi
  done

  # Output selected items
  for i in "${!options[@]}"; do
    if [[ "${selected_status[$i]}" == "1" ]]; then
      local opt="${options[$i]}"
      [[ "$opt" == +* ]] && opt="${opt:1}"
      echo "$opt"
    fi
  done
}

#
# Display a confirmation prompt (uses gum if available)
#
# @param $1 Question text
# @param $2 Default (Y/N, optional)
# @return 0 for yes, 1 for no
#
ui_confirm() {
  local question="${1:-Continue?}"
  local default="${2:-}"

  if [[ "$UI_HAS_GUM" == "true" ]] && [[ -t 0 ]] && [[ -t 1 ]]; then
    if [[ "$default" == "Y" ]]; then
      gum confirm --default=yes "$question"
    elif [[ "$default" == "N" ]]; then
      gum confirm --default=no "$question"
    else
      gum confirm "$question"
    fi
    return
  fi

  # Fallback to simple prompt
  local prompt_suffix
  case "$default" in
    Y) prompt_suffix="[Y/n]" ;;
    N) prompt_suffix="[y/N]" ;;
    *) prompt_suffix="[y/n]" ;;
  esac

  while true; do
    printf "${UI_BOLD}%s${UI_RESET} %s " "$question" "$prompt_suffix"
    read -r reply

    [[ -z "$reply" ]] && reply="$default"

    case "$reply" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
    esac
    printf "${UI_ERROR}Please answer yes or no.${UI_RESET}\n"
  done
}

#
# Display styled input prompt (uses gum if available)
#
# @param $1 Prompt text
# @param $2 Default value (optional)
# @return User input
#
ui_input() {
  local prompt="${1:-Enter value:}"
  local default="${2:-}"

  if [[ "$UI_HAS_GUM" == "true" ]] && [[ -t 0 ]] && [[ -t 1 ]]; then
    if [[ -n "$default" ]]; then
      gum input --placeholder "$default" --header "$prompt" --value "$default"
    else
      gum input --header "$prompt"
    fi
    return
  fi

  # Fallback
  local result
  if [[ -n "$default" ]]; then
    read -p "$prompt [$default]: " result
    [[ -z "$result" ]] && result="$default"
  else
    read -p "$prompt: " result
  fi
  echo "$result"
}

# ------------------------------------------------------------------------------
# SECTION: STYLED MESSAGE FUNCTIONS
# ------------------------------------------------------------------------------

#
# Print a section header
#
ui_header() {
  local text="${1:-}"
  local width="${2:-$UI_TERM_WIDTH}"
  [[ $width -gt 80 ]] && width=80

  echo ""
  printf "${UI_PRIMARY}${UI_BOLD}"
  local fill_str
  printf -v fill_str '%*s' "$width" ''
  printf "%s" "${fill_str// /$UI_BOX_H}"
  printf "${UI_RESET}\n"
  printf "${UI_PRIMARY}${UI_BOLD}  %s${UI_RESET}\n" "$text"
  printf "${UI_PRIMARY}${UI_BOLD}"
  printf "%s" "${fill_str// /$UI_BOX_H}"
  printf "${UI_RESET}\n"
  echo ""
}

#
# Print a styled step indicator
#
ui_step() {
  local step_num="${1:-1}"
  local total_steps="${2:-1}"
  local description="${3:-}"

  printf "${UI_PRIMARY}${UI_BOLD}[%d/%d]${UI_RESET} ${UI_BOLD}%s${UI_RESET}\n" \
    "$step_num" "$total_steps" "$description"
}

#
# Print a styled list item
#
ui_list_item() {
  local text="${1:-}"
  local indent="${2:-0}"
  local bullet="${3:-$UI_ICON_BULLET}"

  printf '%*s' "$indent" ''
  printf "${UI_MUTED}%s${UI_RESET} %s\n" "$bullet" "$text"
}

#
# Print a key-value pair
#
ui_keyval() {
  local key="${1:-}"
  local value="${2:-}"
  local key_width="${3:-20}"

  printf "${UI_MUTED}%-*s${UI_RESET} ${UI_BOLD}%s${UI_RESET}\n" "$key_width" "$key:" "$value"
}

#
# Print a notice/callout box
#
ui_notice() {
  local type="${1:-info}"
  local message="${2:-}"
  local width="${3:-$UI_TERM_WIDTH}"
  [[ $width -gt 80 ]] && width=80

  local icon color label
  case "$type" in
    success) icon="$UI_ICON_SUCCESS"; color="$UI_SUCCESS"; label="SUCCESS" ;;
    error)   icon="$UI_ICON_ERROR";   color="$UI_ERROR";   label="ERROR" ;;
    warning) icon="$UI_ICON_WARNING"; color="$UI_WARNING"; label="WARNING" ;;
    *)       icon="$UI_ICON_INFO";    color="$UI_INFO";    label="NOTE" ;;
  esac

  echo ""
  printf "${color}${UI_BOX_TL_S}${UI_BOX_H_S}${UI_BOX_H_S} %s %s ${UI_BOX_H_S}" "$icon" "$label"
  local fill_str
  printf -v fill_str '%*s' $(( width - 10 - ${#label} )) ''
  printf "%s" "${fill_str// /$UI_BOX_H_S}"
  printf "${UI_BOX_TR_S}${UI_RESET}\n"

  printf "${color}${UI_BOX_V_S}${UI_RESET} %-*s ${color}${UI_BOX_V_S}${UI_RESET}\n" \
    $(( width - 4 )) "$message"

  printf "${color}${UI_BOX_BL_S}"
  printf -v fill_str '%*s' $(( width - 2 )) ''
  printf "%s" "${fill_str// /$UI_BOX_H_S}"
  printf "${UI_BOX_BR_S}${UI_RESET}\n"
  echo ""
}

# ------------------------------------------------------------------------------
# SECTION: CLEANUP & UTILITIES
# ------------------------------------------------------------------------------

#
# Clean up any running spinners on exit
#
ui_cleanup() {
  if [[ -n "$_UI_SPINNER_PID" ]]; then
    kill "$_UI_SPINNER_PID" 2>/dev/null
    wait "$_UI_SPINNER_PID" 2>/dev/null
  fi
}

trap ui_cleanup EXIT

#
# Hide cursor (useful during animations)
#
ui_cursor_hide() {
  printf "\033[?25l"
}

#
# Show cursor
#
ui_cursor_show() {
  printf "\033[?25h"
}

#
# Clear current line
#
ui_clear_line() {
  printf "\r\033[K"
}

#
# Move cursor up N lines
#
ui_cursor_up() {
  local n="${1:-1}"
  printf "\033[%dA" "$n"
}

# Export all functions
export -f ui_print_banner ui_print_banner_mini
export -f ui_box_top ui_box_line ui_box_bottom ui_box_separator ui_box
export -f ui_progress_bar ui_progress_bar_done
export -f ui_spinner_start ui_spinner_stop
export -f ui_stages_init ui_stage_complete ui_stage_skip ui_stage_fail ui_stage_start ui_stages_print
export -f ui_table
export -f ui_select ui_multiselect ui_confirm ui_input
export -f ui_header ui_step ui_list_item ui_keyval ui_notice
export -f ui_cleanup ui_cursor_hide ui_cursor_show ui_clear_line ui_cursor_up
export -f ui_color_256
