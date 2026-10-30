#!/usr/bin/env bash
# Ovira node: installer and management tool for a node.
# A node is an extra server that a panel on another server controls.
# Debian, Ubuntu, AlmaLinux, Rocky and CentOS Stream. Copyright (c) Erfan-XRay.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/node.sh) --panel-ip PANEL_IP
#
# On a new server it asks what it needs and installs the node agent, then prints
# a node key: in the panel open Nodes, Connect a node, and paste it. On a server
# that already has a node it opens a menu. After installing, the same menu is
# the "ovira" command:
#
#   ovira                 menu
#   ovira status          state, version, address, node key
#   ovira key             print the node key
#   ovira update          install the newest release (tunnels stay up)
#   ovira logs [-f]       show (or follow) the log
#   ovira restart|start|stop
#   ovira uninstall
#
# Everything the questions ask can be given as options instead:
#
#   --port 62060            port the panel connects to (TCP)
#   --panel-ip IP           accept calls from this panel address only
#   --beta                  use the newest beta instead of the stable release
#   --binary ./ovira-linux-amd64   use a local build instead of downloading
#   --yes                   do not ask; use the options and defaults
#   --fresh                 after a removal that kept its data: start empty instead
#   --purge                 with uninstall: delete data and key too
#
# A leading "node" or "install" word is accepted and ignored.
# Running the script again updates an existing node; tunnels stay up.
# After "uninstall" (which keeps the data) it offers to reinstall with that data.
# shellcheck disable=SC2034  # some shared settings are used by only one of the two scripts
set -euo pipefail
# The binary asks this script to run its own commands; it must not call back.
export OVIRA_MANAGE=1

# ===== shared: begin =====
# Everything between these two markers is identical in install.sh and node.sh;
# a test keeps the copies in sync. Change it in both files.

REPO="Erfan-XRay/Ovira"
OWNER="Erfan-XRay"
SITE="github.com/Erfan-XRay/Ovira"
RAW_BASE="https://raw.githubusercontent.com/$REPO/main"
MIRROR="https://ovpn.rapcity.shop/api/v1/releases"
# Release signing key (Ed25519, SPKI DER in base64): every download is checked against it.
RELEASE_PUB="MCowBQYDK2VwAyEAO10TTvbUiBU7HOoYjVzZZzs76CjNFul7HkdkhWFSFgw="

# Installations from before the product was renamed keep their old file and
# unit names, so an update never moves anything; new ones use "ovira".
SLUG=ovira
if [[ -e /usr/local/bin/burrow || -d /etc/burrow || -d /etc/burrow-node || -d /var/lib/burrow || -d /var/lib/burrow-node ]]; then SLUG=burrow; fi
CONFDIR=/etc/$SLUG
CONFIG=$CONFDIR/config.json
DATA=/var/lib/$SLUG
NCONFDIR=/etc/$SLUG-node
NCONFIG=$NCONFDIR/node.json
NDATA=/var/lib/$SLUG-node
BIN=/usr/local/bin/$SLUG
LIBDIR=/usr/local/lib/$SLUG
MANAGE=$LIBDIR/manage.sh
LOGFILE=/var/log/ovira-install.log
UNITDIR=/etc/systemd/system
BACKUP_DIR=/root
DISPATCH_MARK="Ovira dispatcher"

ARGS=()
BINARY=""
BETA=0
YES=0
PURGE=0
FRESH=0
FORCE=0
FOLLOW=0
TAG=""
TMP=""
TMP_OWNER=""
SIGNED=0

# ----------------------------------------------------------------- look & feel
# Colour and box drawing only on a terminal; NO_COLOR and non-UTF-8 locales
# get plain text and ASCII shapes. Every state is also written as a word.

UI_FD=""         # descriptor the user's keys come from; empty when nobody can answer
UI_ROWS=24
UI_COLS=80
UI_KEY=""
UI_PAUSED=1      # 0 once a screen printed something the user has not dismissed
MENU_PID=0       # PID of the menu loop while it runs
MENU_IDLE=0      # 1 while the menu itself, not a screen, owns the terminal
CANCEL_NOTE="Cancelled."
UTF=0
COLOR=0
VER_CACHE=""

ui_style() {
  if (( COLOR )); then
    if [[ "${COLORTERM:-}" == *truecolor* || "${COLORTERM:-}" == *24bit* ]]; then ACC=$'\033[38;2;196;248;42m'; else ACC=$'\033[38;5;154m'; fi
    BOLD=$'\033[1m'; DIM=$'\033[2m'; RST=$'\033[0m'
    GRN=$'\033[38;5;84m'; TEAL=$'\033[38;5;44m'; PURPLE=$'\033[38;5;141m'; GRAY=$'\033[38;5;245m'
    YEL=$'\033[38;5;220m'; RED=$'\033[38;5;203m'; SEL_BG=$'\033[48;5;237m'
    LOGO_TINT=($'\033[38;5;154m' $'\033[38;5;118m' $'\033[38;5;84m' $'\033[38;5;79m' $'\033[38;5;44m')
    [[ "$ACC" == *'38;2;'* ]] && LOGO_TINT[0]=$ACC
  else
    ACC=""; BOLD=""; DIM=""; RST=""; GRN=""; TEAL=""; PURPLE=""; GRAY=""; YEL=""; RED=""; SEL_BG=""
    LOGO_TINT=("" "" "" "" "")
  fi
  if (( UTF )); then
    G_TL="╭"; G_TR="╮"; G_BL="╰"; G_BR="╯"; G_V="│"; G_H="─"; G_LT="├"; G_SEC="◆"
    G_OK="✓"; G_ERR="✗"; G_ON="●"; G_OFF="○"; G_HALF="◐"; G_ARR="›"; G_SEL="❯"; G_MID="·"
    G_COPY="©"; G_UP="▲"; G_DN="▼"; G_UD="↑/↓"; G_FLOW="→"
    SPIN=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  else
    G_TL="+"; G_TR="+"; G_BL="+"; G_BR="+"; G_V="|"; G_H="-"; G_LT="+"; G_SEC="*"
    G_OK="+"; G_ERR="x"; G_ON="*"; G_OFF="o"; G_HALF="~"; G_ARR=">"; G_SEL=">"; G_MID="-"
    G_COPY="(c)"; G_UP="^"; G_DN="v"; G_UD="Up/Down"; G_FLOW="->"
    SPIN=('|' '/' '-' '\')
  fi
}

ui_init() { # after the options are read: style, and where answers come from
  case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) UTF=1 ;; esac
  if [[ -t 1 && -z "${NO_COLOR:-}" && "${TERM:-}" != dumb ]]; then COLOR=1; fi
  ui_style
  UI_FD=""
  if (( YES == 0 )); then
    if [[ -t 0 ]]; then
      UI_FD=0
    elif [[ -r /dev/tty && -w /dev/tty ]] && { : < /dev/tty; } 2>/dev/null; then
      # A script piped into bash has no keyboard on stdin; ask on the terminal.
      exec 3< /dev/tty
      UI_FD=3
    fi
  fi
  trap handle_interrupt INT
  trap cleanup EXIT
}

ui_has_input() { [[ -n "$UI_FD" ]]; }
ui_rich() { [[ -n "$UI_FD" && -t 1 ]]; }   # cursor-addressed menus and pickers

cleanup() {
  ui_restore_terminal
  if [[ -n "$TMP" && "$TMP_OWNER" == "$BASHPID" ]]; then rm -rf "$TMP"; fi
}

# Undo what menus and pickers change: hidden cursor, line wrap, key echo.
ui_restore_terminal() {
  if [[ -t 1 ]]; then printf '\033[?25h\033[?7h'; fi
  if [[ -n "$UI_FD" ]]; then stty echo icanon <&"$UI_FD" 2>/dev/null || true; fi
}

# Ctrl+C: on the idle menu, leave with the goodbye line; in a screen (its own
# subshell), end only that screen; anywhere else cancel the command. The
# handler always exits, so a pending "read" never leaves the terminal stuck.
handle_interrupt() {
  if (( MENU_PID && BASHPID == MENU_PID )); then
    (( MENU_IDLE )) || return 0
    menu_goodbye
  fi
  trap '' INT
  ui_restore_terminal
  [[ -n "$CANCEL_NOTE" ]] && printf '\n  %s%s %s%s\n' "$YEL" "$G_ERR" "$CANCEL_NOTE" "$RST" >&2
  exit 130
}

ok()   { printf '  %s%s%s %s\n' "$GRN" "$G_OK" "$RST" "$*"; UI_PAUSED=0; }
err()  { printf '  %s%s %s%s\n' "$RED" "$G_ERR" "$*" "$RST" >&2; UI_PAUSED=0; }
warn() { printf '  %s!%s %s\n' "$YEL" "$RST" "$*"; UI_PAUSED=0; }
info() { printf '  %s%s%s %s\n' "$TEAL" "$G_ARR" "$RST" "$*"; UI_PAUSED=0; }
die()  { err "$*"; exit 1; }

# ui_line <width> [char]: a horizontal line.
ui_line() {
  local line
  printf -v line '%*s' "$1" ''
  printf '%s' "${line// /${2:-$G_H}}"
}
rule() { printf '  %s%s%s\n' "$DIM$TEAL" "$(ui_line "${1:-46}")" "$RST"; }

ui_term_size() {
  local size=""
  [[ -n "$UI_FD" ]] && size=$(stty size <&"$UI_FD" 2>/dev/null || true)
  UI_ROWS=${size%% *}
  UI_COLS=${size##* }
  [[ "$UI_ROWS" =~ ^[0-9]+$ ]] && (( UI_ROWS > 0 )) || UI_ROWS=${LINES:-24}
  [[ "$UI_COLS" =~ ^[0-9]+$ ]] && (( UI_COLS > 0 )) || UI_COLS=${COLUMNS:-80}
}

# Width of boxes and rules: the terminal minus margins, between 40 and 72 columns.
ui_width() {
  local w=$(( UI_COLS - 4 ))
  (( w > 72 )) && w=72
  (( w < 40 )) && w=40
  printf '%d' "$w"
}

app_version() { # v0.8.1, or nothing when no binary is installed
  if [[ -z "$VER_CACHE" && -x $BIN ]]; then VER_CACHE=$("$BIN" version 2>/dev/null | awk '{print $2}' || true); fi
  [[ -n "$VER_CACHE" ]] && printf 'v%s' "${VER_CACHE#v}"
  return 0
}

copyright_line() { printf '  %s%s %s %s %s%s\n' "$GRAY" "$G_COPY" "$OWNER" "$G_MID" "$SITE" "$RST"; }

# Compact title bar at the top of every screen.
ui_title_bar() {
  local w inner title="Ovira" tag="${TAGLINE_SHORT:-}" version pad
  w=$(ui_width); inner=$(( w - 2 ))
  version=$(app_version)
  # The row is "  <diamond> " + title + "  " + tag + padding + version + "  ".
  pad=$(( inner - 4 - ${#title} - 2 - ${#tag} - ${#version} - 2 ))
  (( pad < 1 )) && pad=1
  printf '  %s%s%s%s%s\n' "$DIM$TEAL" "$G_TL" "$(ui_line "$inner")" "$G_TR" "$RST"
  printf '  %s%s%s  %s%s %s%s  %s%s%s%*s%s%s%s  %s%s%s\n' \
    "$DIM$TEAL" "$G_V" "$RST" "$BOLD$ACC" "$G_SEC" "$title" "$RST" "$PURPLE" "$tag" "$RST" \
    "$pad" "" "$GRAY" "$version" "$RST" "$DIM$TEAL" "$G_V" "$RST"
  printf '  %s%s%s%s%s\n' "$DIM$TEAL" "$G_BL" "$(ui_line "$inner")" "$G_BR" "$RST"
}

# Large logo for the main menu and the start of an install on a roomy terminal.
ui_logo() {
  # shellcheck disable=SC1003  # the backslashes are part of the art
  local -a art=(
    '  ___  __     __ ___  ____      _    '
    ' / _ \ \ \   / /|_ _||  _ \    / \   '
    '| | | | \ \ / /  | | | |_) |  / _ \  '
    '| |_| |  \ V /   | | |  _ <  / ___ \ '
    ' \___/    \_/   |___||_| \_\/_/   \_\'
  )
  local i version; version=$(app_version)
  for i in "${!art[@]}"; do
    printf '  %s%s%s\n' "$BOLD${LOGO_TINT[i]}" "${art[i]}" "$RST"
  done
  printf '  %s%s%s%s\n' "$PURPLE" "${TAGLINE:-}" "$RST" "${version:+  $GRAY$G_MID$RST  $version}"
  copyright_line
}

# ui_header [big]: the top of a screen. Clears the screen only inside the menu.
ui_header() {
  if ui_rich; then
    ui_term_size
    (( MENU_PID )) && printf '\033[H\033[2J\033[3J'
  fi
  if [[ "${1:-}" == big ]] && ui_rich && (( UI_ROWS >= 30 && UI_COLS >= 56 )); then
    echo; ui_logo
  else
    ui_title_bar
  fi
  UI_PAUSED=0
}

section() {
  printf '\n  %s%s %s%s\n' "$BOLD$PURPLE" "$G_SEC" "$1" "$RST"
  printf '  %s%s%s\n' "$DIM$TEAL" "$(ui_line "$(ui_width)")" "$RST"
  UI_PAUSED=0
}

step() { # step N TOTAL "Title"
  printf '\n  %s%s Step %s/%s %s %s%s\n' "$BOLD$PURPLE" "$G_SEC" "$1" "$2" "$G_MID" "$3" "$RST"
  printf '  %s%s%s\n' "$DIM$TEAL" "$(ui_line "$(ui_width)")" "$RST"
  UI_PAUSED=0
}

# ui_kv <label> <value> [colour]: one "label  value" row inside a card.
ui_kv() {
  printf '  %s%s%s  %s%-14s%s %s%s%s\n' "$DIM$TEAL" "$G_V" "$RST" "$GRAY" "$1" "$RST" "${3:-}" "$2" "$RST"
  UI_PAUSED=0
}
card_top() { printf '\n  %s%s%s %s%s%s %s%s%s\n' "$DIM$TEAL" "$G_TL" "$G_H" "$BOLD$ACC" "$1" "$RST" "$DIM$TEAL" "$(ui_line $(( $(ui_width) - ${#1} - 4 )))" "$RST"; UI_PAUSED=0; }
card_sep() { printf '  %s%s%s %s %s%s\n' "$DIM$TEAL" "$G_LT" "$G_H" "$1" "$(ui_line $(( $(ui_width) - ${#1} - 4 )))" "$RST"; UI_PAUSED=0; }
card_text() { printf '  %s%s%s  %s\n' "$DIM$TEAL" "$G_V" "$RST" "$1"; UI_PAUSED=0; }
card_end() { printf '  %s%s%s%s\n' "$DIM$TEAL" "$G_BL" "$(ui_line $(( $(ui_width) - 1 )))" "$RST"; UI_PAUSED=0; }
# A value on a line of its own, with nothing around it, so it copies cleanly.
card_copy() { printf '\n  %s%s%s\n\n' "$BOLD$ACC" "$1" "$RST"; UI_PAUSED=0; }

# ui_state_row <running|stopped|failed|missing|starting> <label> [detail]
ui_state_row() {
  local dot word colour
  case "$1" in
    running)  dot=$G_ON;   word="running";  colour=$GRN ;;
    starting) dot=$G_HALF; word="starting"; colour=$YEL ;;
    failed)   dot=$G_ON;   word="failed";   colour=$RED ;;
    missing)  dot=$G_OFF;  word="missing";  colour=$GRAY ;;
    *)        dot=$G_OFF;  word="stopped";  colour=$RED ;;
  esac
  printf '  %s%s%s %-13s %s%-9s%s %s\n' "$colour" "$dot" "$RST" "$2" "$colour" "$word" "$RST" "${3:-}"
  UI_PAUSED=0
}
# ui_item <glyph> <label> <value> [colour]: a status row that is not a service.
ui_item() { printf '  %s%s%s %-13s %s\n' "${4:-$PURPLE}" "$1" "$RST" "$2" "$3"; UI_PAUSED=0; }

# The "~" that ends keys such as Home and Page Up.
ui_drop_key() { IFS= read -rsn1 -t 0.05 _ <&"$UI_FD" || true; }

# ui_read_key: wait up to a second for one key and store it in UI_KEY as
# up, down, home, end, pgup, pgdn, enter, esc, backspace, other, or the character.
# Returns 1 at the end of input and 2 when no key was pressed.
ui_read_key() {
  local key="" rest="" status
  UI_KEY=""
  IFS= read -rsn1 -t 1 key <&"$UI_FD"
  status=$?
  (( status > 128 )) && return 2
  (( status == 0 )) || return 1
  case "$key" in
    "") UI_KEY="enter"; return 0 ;;
    $'\177'|$'\b') UI_KEY="backspace"; return 0 ;;
    $'\033') ;;
    *) UI_KEY="$key"; return 0 ;;
  esac
  IFS= read -rsn2 -t 0.05 rest <&"$UI_FD" || true
  case "$rest" in
    '[A'|'OA') UI_KEY="up" ;;
    '[B'|'OB') UI_KEY="down" ;;
    '[H'|'OH') UI_KEY="home" ;;
    '[F'|'OF') UI_KEY="end" ;;
    '[1'|'[7') UI_KEY="home"; ui_drop_key ;;
    '[4'|'[8') UI_KEY="end"; ui_drop_key ;;
    '[5') UI_KEY="pgup"; ui_drop_key ;;
    '[6') UI_KEY="pgdn"; ui_drop_key ;;
    '') UI_KEY="esc" ;;
    *) UI_KEY="other"; ui_drop_key ;;
  esac
  return 0
}

# ui_choose <var> <default index> <option>...: arrow-key picker drawn in place.
# Stores the chosen index (0-based) in <var>; returns 1 when the user backs out.
# Without a terminal it asks for a number; with nobody to ask it takes the default.
ui_choose() {
  local -n __uc_out="$1"
  local __uc_sel="$2" __uc_i __uc_n __uc_drawn=0 __uc_w __uc_pad __uc_line __uc_frame __uc_ans __uc_status
  shift 2
  local -a __uc_opts=("$@")
  __uc_n=${#__uc_opts[@]}
  (( __uc_sel >= 0 && __uc_sel < __uc_n )) || __uc_sel=0
  if [[ -z "$UI_FD" ]]; then __uc_out=$__uc_sel; return 0; fi

  if ! ui_rich; then
    for __uc_i in "${!__uc_opts[@]}"; do printf '    [%d] %s\n' $(( __uc_i + 1 )) "${__uc_opts[__uc_i]}"; done
    while :; do
      printf '  Select 1-%d [%d]: ' "$__uc_n" $(( __uc_sel + 1 ))
      IFS= read -r __uc_ans <&"$UI_FD" || return 1
      __uc_ans=${__uc_ans:-$(( __uc_sel + 1 ))}
      if [[ "$__uc_ans" =~ ^[0-9]+$ ]] && (( __uc_ans >= 1 && __uc_ans <= __uc_n )); then break; fi
    done
    __uc_out=$(( __uc_ans - 1 ))
    return 0
  fi

  ui_term_size
  __uc_w=$(ui_width)
  for __uc_i in "${!__uc_opts[@]}"; do (( ${#__uc_opts[__uc_i]} + 8 > __uc_w )) && __uc_w=$(( ${#__uc_opts[__uc_i]} + 8 )); done
  (( __uc_w > UI_COLS - 3 )) && __uc_w=$(( UI_COLS - 3 ))
  # Hide the cursor and turn off line wrap, so every option is exactly one line to redraw.
  printf '\033[?25l\033[?7l'
  stty -echo <&"$UI_FD" 2>/dev/null || true
  while :; do
    __uc_frame=""
    (( __uc_drawn )) && __uc_frame+=$'\033'"[${__uc_drawn}A"$'\r'
    for __uc_i in "${!__uc_opts[@]}"; do
      if (( __uc_i == __uc_sel )); then
        __uc_pad=$(( __uc_w - 8 - ${#__uc_opts[__uc_i]} ))
        (( __uc_pad < 1 )) && __uc_pad=1
        printf -v __uc_line '  %s%s%s %s %d  %s%*s%s' "$ACC" "$G_SEL" "$RST" "$SEL_BG$BOLD" \
          $(( __uc_i + 1 )) "${__uc_opts[__uc_i]}" "$__uc_pad" "" "$RST"
      else
        printf -v __uc_line '     %s%d%s  %s' "$GRAY" $(( __uc_i + 1 )) "$RST" "${__uc_opts[__uc_i]}"
      fi
      __uc_frame+="${__uc_line}"$'\033[K\n'
    done
    __uc_frame+="  ${DIM}${GRAY}${G_UD} move ${G_MID} Enter select ${G_MID} q back${RST}"$'\033[K\n'
    printf '%s' "$__uc_frame"
    __uc_drawn=$(( __uc_n + 1 ))

    __uc_status=0
    ui_read_key || __uc_status=$?
    case $__uc_status in
      1) UI_KEY="esc" ;;
      2) continue ;;
    esac
    case "$UI_KEY" in
      up|k) (( __uc_sel = (__uc_sel - 1 + __uc_n) % __uc_n )) ;;
      down|j|$'\t') (( __uc_sel = (__uc_sel + 1) % __uc_n )) ;;
      home|pgup) __uc_sel=0 ;;
      end|pgdn) __uc_sel=$(( __uc_n - 1 )) ;;
      [1-9]) (( UI_KEY <= __uc_n )) && __uc_sel=$(( UI_KEY - 1 )) ;;
      enter) break ;;
      esc|q|Q)
        printf '\033[%dA\r\033[J\033[?7h\033[?25h' "$__uc_drawn"
        stty echo <&"$UI_FD" 2>/dev/null || true
        printf '  %s%s Back%s\n' "$DIM$GRAY" "$G_ARR" "$RST"
        return 1
        ;;
    esac
  done
  printf '\033[%dA\r\033[J\033[?7h\033[?25h' "$__uc_drawn"
  stty echo <&"$UI_FD" 2>/dev/null || true
  printf '  %s%s%s %s\n' "$GRN" "$G_OK" "$RST" "${__uc_opts[__uc_sel]}"
  __uc_out="$__uc_sel"
  return 0
}

# pick_yesno "Question" y|n: arrow-key Yes/No; returns 0 for yes. Takes the default when nobody can answer.
pick_yesno() {
  local a def=0 d=${2:-n}
  [[ "${d,,}" == y* ]] || def=1
  ui_has_input || { (( def == 0 )); return; }
  printf '\n  %s%s%s\n' "$BOLD" "$1" "$RST"
  ui_choose a "$def" "Yes" "No" || return 1
  (( a == 0 ))
}

# ask VAR "question" [default]: read one line (with line editing on a terminal);
# an empty answer takes the default, and so does having nobody to ask.
ask() {
  local -n __ask_out="$1"
  local __ask_q="$2" __ask_def="${3-}" __ask_line="" __ask_p __so=$'\001' __sc=$'\002'
  if [[ -z "$UI_FD" ]]; then __ask_out=$__ask_def; return 0; fi
  if [[ "$UI_FD" == 0 && -t 1 ]]; then
    # \001 and \002 mark the colour codes so readline measures the prompt correctly.
    __ask_p="  ${__so}${BOLD}${ACC}${__sc}?${__so}${RST}${__sc} ${__ask_q}"
    [[ -n "$__ask_def" ]] && __ask_p+=" ${__so}${GRAY}${__sc}[${__ask_def}]${__so}${RST}${__sc}"
    read -e -r -p "${__ask_p}: " __ask_line || __ask_line=""
  else
    printf '  %s?%s %s' "$BOLD$ACC" "$RST" "$__ask_q"
    [[ -n "$__ask_def" ]] && printf ' %s[%s]%s' "$GRAY" "$__ask_def" "$RST"
    printf ': '
    IFS= read -r __ask_line <&"$UI_FD" || __ask_line=""
  fi
  __ask_out=${__ask_line:-$__ask_def}
}

ask_secret() { # ask_secret VAR "question": no echo
  local -n __sec_out="$1"
  local __sec_line=""
  if [[ -z "$UI_FD" ]]; then __sec_out=""; return 0; fi
  printf '  %s?%s %s: ' "$BOLD$ACC" "$RST" "$2"
  IFS= read -r -s __sec_line <&"$UI_FD" || __sec_line=""
  printf '\n'
  __sec_out=$__sec_line
}

# ask_port VAR "question" default tcp|udp [avoid...]: asks again on a bad or busy port.
ask_port() {
  local -n __ap_out="$1"
  local __ap_q=$2 __ap_def=$3 __ap_proto=$4 __ap_v __ap_a __ap_bad
  shift 4
  while :; do
    ask __ap_v "$__ap_q" "$__ap_def"
    __ap_bad=""
    if ! valid_port "$__ap_v"; then __ap_bad="Not a port number (1-65535): $__ap_v"
    elif port_busy "$__ap_proto" "$__ap_v"; then __ap_bad="Port $__ap_v/$__ap_proto is already in use on this server."
    else
      for __ap_a in "$@"; do [[ -n "$__ap_a" && "$__ap_a" == "$__ap_v" ]] && __ap_bad="Port $__ap_v is already chosen for something else."; done
    fi
    [[ -z "$__ap_bad" ]] && break
    if ! ui_has_input; then die "$__ap_bad"; fi
    warn "$__ap_bad Pick another."
  done
  __ap_out=$__ap_v
}

pause() { # press any key
  UI_PAUSED=1
  ui_has_input || return 0
  printf '\n  %s%s Press any key to continue%s ' "$DIM$GRAY" "$G_BL$G_H" "$RST"
  IFS= read -rsn1 _ <&"$UI_FD" || true
  # Drop the rest of a multi-byte key (arrows) so the next prompt does not receive it.
  while IFS= read -rsn1 -t 0.02 _ <&"$UI_FD"; do :; done
  printf '\n'
  return 0
}

# Run one menu screen in its own subshell, so Ctrl+C or a failure inside it
# ends only that screen. A screen that printed something and returned
# without waiting gets a "press any key" before the menu redraws.
run_screen() {
  local status=0
  MENU_IDLE=0
  ui_restore_terminal
  (
    trap 'handle_interrupt' INT
    UI_PAUSED=1
    CANCEL_NOTE="Cancelled."
    screen_status=0
    "$@" || screen_status=$?
    (( UI_PAUSED )) || pause
    exit "$screen_status"
  ) || status=$?
  MENU_IDLE=1
  # Leave the "Cancelled" line on screen for a moment before the menu redraws.
  (( status == 130 )) && sleep 0.4
  return 0
}

spin_wait() { # spin_wait PID "message"
  local pid=$1 msg=$2 i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r  %s%s%s %s' "$ACC" "${SPIN[i % ${#SPIN[@]}]}" "$RST" "$msg"
    i=$((i + 1)); sleep 0.1
  done
  printf '\r\033[K'
}
run() { # run "message" command args...: show a spinner, keep the output in the log
  local msg=$1 rc=0; shift
  mkdir -p "$(dirname "$LOGFILE")" 2>/dev/null || true
  echo "== $msg" >> "$LOGFILE" 2>/dev/null || true
  if [[ -t 1 ]]; then
    "$@" >> "$LOGFILE" 2>&1 &
    local pid=$!
    spin_wait "$pid" "$msg"
    wait "$pid" || rc=$?
  else
    "$@" >> "$LOGFILE" 2>&1 || rc=$?
  fi
  if [[ $rc -eq 0 ]]; then ok "$msg"; else
    err "$msg failed"; tail -n 12 "$LOGFILE" | sed 's/^/      /' >&2; echo "      (full log: $LOGFILE)" >&2
  fi
  return $rc
}

# ------------------------------------------------------------------- main menu
# Arrow keys (or j/k) move, Enter opens, digits jump to an item, q quits. The
# calling script fills MENU_ROWS with menu_section / menu_add / menu_gap.

MENU_ROWS=()        # "id|number|label|hint", "#SECTION", or "" for a gap
MENU_DANGER=" "     # ids whose number is drawn in red
MENU_N=0
MENU_SEL=1          # index in MENU_ROWS of the highlighted item
MENU_TOP=0          # first list row on screen when the list scrolls
MENU_CHOICE=""
MENU_STATUS=""      # status lines, rebuilt each time the menu is shown
MENU_RESIZED=0
MENU_HEAD=()        # logo or title bar plus the status lines, for the current size

menu_reset() { MENU_ROWS=(); MENU_N=0; }
menu_section() { [[ ${#MENU_ROWS[@]} -gt 0 ]] && MENU_ROWS+=(""); MENU_ROWS+=("#$1"); }
menu_add() { MENU_N=$(( MENU_N + 1 )); MENU_ROWS+=("$1|$MENU_N|$2|$3"); }
menu_add_exit() { MENU_ROWS+=("" "exit|0|Exit|Close the menu. Run 'ovira' to open it again."); }

menu_is_item() {
  local row="${MENU_ROWS[$1]}"
  [[ -n "$row" && "$row" != \#* ]]
}

# menu_move <-1|1>: move the highlight to the previous or next item, wrapping around.
menu_move() {
  local n=${#MENU_ROWS[@]} i=$MENU_SEL step
  for (( step = 0; step < n; step++ )); do
    i=$(( (i + $1 + n) % n ))
    if menu_is_item "$i"; then MENU_SEL=$i; return 0; fi
  done
}

# menu_jump <number>: highlight the item with that number; returns 1 if there is none.
menu_jump() {
  local i row num
  for i in "${!MENU_ROWS[@]}"; do
    menu_is_item "$i" || continue
    row="${MENU_ROWS[i]#*|}"; num="${row%%|*}"
    if [[ "$num" == "$1" ]]; then MENU_SEL=$i; return 0; fi
  done
  return 1
}


menu_sel_id() { # keep the highlight on the item that was open before
  local i row
  for i in "${!MENU_ROWS[@]}"; do
    menu_is_item "$i" || continue
    row="${MENU_ROWS[i]}"
    if [[ "${row%%|*}" == "$1" ]]; then MENU_SEL=$i; return 0; fi
  done
  return 0
}

# True when some item number starts with <digits> and is longer than it (1 matches 10..).
menu_has_longer() {
  local i row num
  for i in "${!MENU_ROWS[@]}"; do
    menu_is_item "$i" || continue
    row="${MENU_ROWS[i]#*|}"; num="${row%%|*}"
    [[ "$num" == "$1"?* ]] && return 0
  done
  return 1
}

# Build the part above the list for the current terminal size: the large logo
# when everything fits under it, the compact title bar otherwise.
menu_prepare() {
  local -a brand status
  mapfile -t status <<< "$MENU_STATUS"
  # A short terminal keeps the state and the address and gives the rest to the list.
  (( UI_ROWS < 32 && ${#status[@]} > 2 )) && status=("${status[@]:0:2}")
  if (( UI_ROWS >=8 + 1 + ${#status[@]} + 1 + ${#MENU_ROWS[@]} + 4 && UI_COLS >= 56 )); then
    mapfile -t brand < <(ui_logo)
  else
    mapfile -t brand < <(ui_title_bar)
  fi
  MENU_HEAD=("${brand[@]}" "" "${status[@]}" "")
}

# menu_draw [typed digits]: draw the whole menu in one write, from the top-left corner.
menu_draw() {
  local digits="${1:-}" w n list_h cap top i row id num label hint title pad colour fill frame=""
  local -a lines=()
  w=$(ui_width)
  n=${#MENU_ROWS[@]}
  lines=("${MENU_HEAD[@]}")

  # The list gets the rows left over; it scrolls, with markers, when that is too few.
  list_h=$(( UI_ROWS - ${#MENU_HEAD[@]} - 4 ))
  (( list_h < 5 )) && list_h=5
  if (( n <= list_h )); then
    top=0; cap=$n
  else
    cap=$(( list_h - 2 ))
    top=$MENU_TOP
    (( MENU_SEL < top )) && top=$MENU_SEL
    (( MENU_SEL >= top + cap )) && top=$(( MENU_SEL - cap + 1 ))
    # Keep a section title visible above its first item.
    if (( top > 0 && top == MENU_SEL )) && [[ "${MENU_ROWS[top - 1]}" == \#* ]]; then top=$(( top - 1 )); fi
    (( top > n - cap )) && top=$(( n - cap ))
    (( top < 0 )) && top=0
    MENU_TOP=$top
    if (( top > 0 )); then lines+=("  ${DIM}${GRAY}${G_UP} more${RST}"); else lines+=(""); fi
  fi

  for (( i = top; i < top + cap && i < n; i++ )); do
    row="${MENU_ROWS[i]}"
    if [[ -z "$row" ]]; then
      lines+=("")
    elif [[ "$row" == \#* ]]; then
      title="${row#\#}"
      pad=$(( w - ${#title} - 1 )); (( pad < 1 )) && pad=1
      printf -v fill '%*s' "$pad" ''
      lines+=("  ${BOLD}${PURPLE}${title}${RST} ${DIM}${TEAL}${fill// /$G_H}${RST}")
    else
      IFS='|' read -r id num label hint <<< "$row"
      colour="$ACC"
      [[ "$MENU_DANGER" == *" ${id} "* ]] && colour="$RED"
      [[ "$id" == "exit" ]] && colour="$GRAY"
      (( ${#num} < 2 )) && num=" ${num}"
      if (( i == MENU_SEL )); then
        pad=$(( w - 7 - ${#label} )); (( pad < 1 )) && pad=1
        printf -v fill '%*s' "$pad" ''
        lines+=("  ${BOLD}${ACC}${G_SEL}${RST} ${SEL_BG}${BOLD}${colour} ${num}${RST}${SEL_BG}${BOLD}  ${label}${fill}${RST}")
      else
        lines+=("     ${colour}${num}${RST}  ${label}")
      fi
    fi
  done

  if (( n > list_h )); then
    if (( top + cap < n )); then lines+=("  ${DIM}${GRAY}${G_DN} more${RST}"); else lines+=(""); fi
  fi

  IFS='|' read -r _ _ _ hint <<< "${MENU_ROWS[MENU_SEL]}"
  lines+=("  ${DIM}${TEAL}$(ui_line "$w")${RST}")
  lines+=("  ${ACC}${G_ARR}${RST} ${hint}")
  if [[ -n "$digits" ]]; then
    lines+=("  ${DIM}${GRAY}${G_UD} move ${G_MID} Enter open ${G_MID} q quit${RST}   ${BOLD}${YEL}#${digits}${RST}")
  else
    lines+=("  ${DIM}${GRAY}${G_UD} move ${G_MID} Enter open ${G_MID} 0-${MENU_N} jump ${G_MID} q quit${RST}")
  fi

  for row in "${lines[@]}"; do frame+="${row}"$'\033[K\n'; done
  printf '\033[H%s\033[J' "$frame"
}

# Let the user pick an item; its id goes to MENU_CHOICE.
menu_select() {
  local digits="" last_digit=0 now status

  if ! ui_rich; then menu_select_plain; return; fi

  ui_term_size
  menu_prepare
  # No cursor, no line wrap (each row stays one line), no echo of keys typed while drawing.
  printf '\033[?25l\033[?7l\033[H\033[2J'
  stty -echo <&"$UI_FD" 2>/dev/null || true
  while :; do
    menu_draw "$digits"
    status=0
    ui_read_key || status=$?
    if (( status == 1 )); then MENU_CHOICE="exit"; break; fi
    now="${EPOCHREALTIME//[!0-9]/}"
    [[ -n "$now" ]] || now=$(( SECONDS * 1000000 ))
    if (( status == 2 )); then
      if (( MENU_RESIZED )); then
        MENU_RESIZED=0; ui_term_size; menu_prepare; printf '\033[H\033[2J'
      fi
      # Forget half-typed digits after a pause.
      if [[ -n "$digits" ]] && (( now - last_digit > 1500000 )); then digits=""; fi
      continue
    fi
    case "$UI_KEY" in
      up|k) menu_move -1 ;;
      down|j|$'\t') menu_move 1 ;;
      home) MENU_SEL=0; menu_move 1 ;;
      end) MENU_SEL=$(( ${#MENU_ROWS[@]} - 1 )) ;;
      pgup) for _ in 1 2 3 4 5; do menu_move -1; done ;;
      pgdn) for _ in 1 2 3 4 5; do menu_move 1; done ;;
      [0-9])
        # "1" then "3" within a moment reaches item 13.
        if [[ -n "$digits" ]] && (( now - last_digit < 1500000 )) && menu_jump "${digits}${UI_KEY}"; then
          digits+="$UI_KEY"
        else
          digits="$UI_KEY"
          menu_jump "$digits" || digits=""
        fi
        last_digit=$now
        # Nothing longer can follow (such as "5" or "13"): drop the buffer.
        if [[ -n "$digits" ]] && ! menu_has_longer "$digits"; then digits=""; fi
        ;;
      backspace) digits="" ;;
      enter|' ')
        IFS='|' read -r MENU_CHOICE _ <<< "${MENU_ROWS[MENU_SEL]}"
        break ;;
      q|Q|esc) MENU_CHOICE="exit"; break ;;
    esac
  done
  printf '\033[?7h\033[?25h'
  stty echo <&"$UI_FD" 2>/dev/null || true
}

# Numbered menu for input that is not a cursor-addressable terminal.
menu_select_plain() {
  local row id num label answer
  printf '%s\n' "$MENU_STATUS"
  for row in "${MENU_ROWS[@]}"; do
    if [[ "$row" == \#* ]]; then
      printf '\n  %s\n' "${row#\#}"
    elif [[ -n "$row" ]]; then
      IFS='|' read -r id num label _ <<< "$row"
      printf '  [%2s] %s\n' "$num" "$label"
    fi
  done
  printf '\n  Select an option [0-%s]: ' "$MENU_N"
  if ! IFS= read -r answer <&"$UI_FD"; then MENU_CHOICE="exit"; return; fi
  MENU_CHOICE=""
  if menu_jump "$answer"; then IFS='|' read -r MENU_CHOICE _ <<< "${MENU_ROWS[MENU_SEL]}"; fi
}

menu_goodbye() {
  ui_restore_terminal
  if [[ -t 1 ]]; then printf '\033[H\033[2J'; fi
  printf '\n  %sOvira closed.%s Run %sovira%s to open the menu again.\n' "$ACC" "$RST" "$BOLD" "$RST"
  copyright_line
  echo
  exit 0
}

# ------------------------------------------------------------------ small tools

need_root() { [[ $EUID -eq 0 ]] || die "Run as root (sudo -i, then run the command again)."; }
need_systemd() { command -v systemctl >/dev/null || die "systemd is required."; }

tcp_busy() { ss -Hltn "sport = :$1" 2>/dev/null | grep -q .; }
udp_busy() { ss -Hlun "sport = :$1" 2>/dev/null | grep -q .; }
port_busy() { if [[ "$1" == udp ]]; then udp_busy "$2"; else tcp_busy "$2"; fi; }
valid_port() { [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 )); }
public_ip() {
  curl -4 -fsS --max-time 6 https://api.ipify.org 2>/dev/null || curl -4 -fsS --max-time 6 https://ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}'
}
open_port() { # open_port port/proto [nat]: NAT is for ports OpenVPN clients connect to
  if command -v ufw >/dev/null && ufw status 2>/dev/null | grep -q "Status: active"; then ufw allow "$1" >/dev/null; fi
  if command -v firewall-cmd >/dev/null && firewall-cmd --state >/dev/null 2>&1; then
    firewall-cmd -q --permanent --add-port="$1"
    [[ "${2:-}" == nat ]] && firewall-cmd -q --permanent --add-masquerade
    firewall-cmd -q --reload
  fi
}

svc_state() { # unit -> running|starting|failed|stopped|missing
  local u=$1 s
  if ! systemctl cat "$u" >/dev/null 2>&1; then echo missing; return; fi
  s=$(systemctl is-active "$u" 2>/dev/null || true)
  case "$s" in active) echo running ;; activating|reloading) echo starting ;; failed) echo failed ;; *) echo stopped ;; esac
}
installed_version() { [[ -x $BIN ]] && "$BIN" version 2>/dev/null | awk '{print $2}' || true; }
val() { local v=${1#*:}; printf "%s" "${v# }" | sed "s/^ *//"; }
panel_cmd() { OVIRA_CONFIG=$CONFIG "$BIN" "$@"; }
node_cmd() { OVIRA_NODE_CONFIG=$NCONFIG "$BIN" "$@"; }

# ------------------------------------------------------------------------ state
# "Installed" means the config, the main unit and the program are all there.
# A config or database without them is a leftover of a removed installation.

IS_PANEL=0; IS_NODE=0; LEFT_PANEL=0; LEFT_NODE=0
# The binary starts this script as "ovira"; it knows its own path.
[[ -n "${OVIRA_BIN:-}" && -x "${OVIRA_BIN:-}" ]] && BIN=$OVIRA_BIN
detect_state() {
  IS_PANEL=0; IS_NODE=0; LEFT_PANEL=0; LEFT_NODE=0
  if [[ -f $CONFIG && -f $UNITDIR/$SLUG.service && -x $BIN ]]; then IS_PANEL=1
  elif [[ -f $CONFIG || -f $DATA/$SLUG.db ]]; then LEFT_PANEL=1; fi
  if [[ -f $NCONFIG && -f $UNITDIR/$SLUG-node.service && -x $BIN ]]; then IS_NODE=1
  elif [[ -f $NCONFIG || -d $NDATA/openvpn ]]; then LEFT_NODE=1; fi
  return 0
}

# ------------------------------------------------------------ release download

latest_tag() { # newest release tag for the chosen channel, empty when unknown
  local t="" to=${LATEST_TIMEOUT:-15}
  if [[ $BETA -eq 1 ]]; then
    t=$(curl -fsSL --max-time "$to" "https://api.github.com/repos/$REPO/releases?per_page=10" 2>/dev/null | grep -m1 '"tag_name"' | cut -d'"' -f4 || true)
    [[ -n "$t" ]] || t=$(curl -fsSL --max-time "$to" "$MIRROR?channel=beta" 2>/dev/null | grep -o '"tag":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
  else
    t=$(curl -fsSIL --max-time "$to" -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest" 2>/dev/null | sed -n 's|.*/tag/||p' || true)
    [[ -n "$t" ]] || t=$(curl -fsSL --max-time "$to" "$MIRROR?channel=stable" 2>/dev/null | grep -o '"tag":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
  fi
  printf '%s' "$t"
}

mktmp() {
  [[ -n "$TMP" && -d "$TMP" ]] && return 0
  TMP=$(mktemp -d); TMP_OWNER=$BASHPID
  trap cleanup EXIT
}

fetch() { # fetch NAME: an asset of the chosen release, from GitHub or the mirror
  curl -fsSL --retry 2 --max-time 300 -o "$TMP/$1" "$GH_BASE/$1" 2>/dev/null ||
    curl -fsSL --retry 2 --max-time 300 -o "$TMP/$1" "$MIRROR_BASE/$1"
}

verify_sums() { # the release signature, then the checksum of each given asset
  fetch SHA256SUMS && fetch SHA256SUMS.sig || return 1
  SIGNED=0
  openssl version 2>/dev/null | grep -qE "^OpenSSL ([3-9]|[1-9][0-9]+)\." || {
    err "OpenSSL 3 or newer is required to verify releases. Upgrade OpenSSL before installing."; return 1; }
  echo "$RELEASE_PUB" | base64 -d > "$TMP/pub.der" 2>/dev/null &&
    openssl pkey -pubin -inform DER -in "$TMP/pub.der" -out "$TMP/pub.pem" 2>/dev/null &&
    base64 -d "$TMP/SHA256SUMS.sig" > "$TMP/sig.bin" 2>/dev/null &&
    openssl pkeyutl -verify -pubin -inkey "$TMP/pub.pem" -rawin -in "$TMP/SHA256SUMS" -sigfile "$TMP/sig.bin" >/dev/null 2>&1 || {
      err "The release signature could not be verified. Refusing to install."; return 1; }
  SIGNED=1
  local a
  for a in "$@"; do
    (cd "$TMP" && awk -v name="$a" 'length($1) == 64 && ($2 == name || $2 == "*" name) { print; found++ } END { if (found != 1) exit 1 }' SHA256SUMS > asset.sum &&
      test -s asset.sum && sha256sum -c --status asset.sum) || { err "$a does not match its checksum. Refusing to install."; return 1; }
  done
}

set_release_base() {
  local tag=$1
  if [[ -n "$tag" ]]; then
    GH_BASE="https://github.com/$REPO/releases/download/$tag"; MIRROR_BASE="$MIRROR/$tag"
  else
    GH_BASE="https://github.com/$REPO/releases/latest/download"; MIRROR_BASE="$MIRROR/latest"
  fi
}

# get_binary: leaves the verified new executable at $BIN.new.
get_binary() {
  local arch goarch
  arch=$(uname -m)
  case "$arch" in x86_64) goarch=amd64 ;; aarch64|arm64) goarch=arm64 ;; *) die "Unsupported CPU: $arch" ;; esac
  mktmp
  if [[ -n "$BINARY" ]]; then
    install -m 0755 "$BINARY" "$BIN.new"
  elif [[ -f "$(dirname "$0")/ovira-linux-$goarch" ]]; then
    install -m 0755 "$(dirname "$0")/ovira-linux-$goarch" "$BIN.new"
  else
    TAG=${TAG:-$(latest_tag)}
    set_release_base "$TAG"
    run "Downloading Ovira ${TAG:-latest} for $goarch" fetch "ovira-linux-$goarch" || die "Download failed from GitHub and from the mirror."
    verify_sums "ovira-linux-$goarch" || die "Could not verify the download."
    ok "Signature verified"
    install -m 0755 "$TMP/ovira-linux-$goarch" "$BIN.new"
  fi
  "$BIN.new" version >/dev/null || { rm -f "$BIN.new"; die "The binary does not run on this machine."; }
}

place_binary() {
  mv -f "$BIN.new" "$BIN"
  VER_CACHE=""
  # The docs call the command "ovira"; an older installation answers to both names.
  if [[ "$SLUG" == burrow ]]; then ln -sfn "$BIN" /usr/local/bin/ovira; fi
}

# install_self ASSET DEST: keep this script as DEST. It is this very file, or
# else the signed release asset of the same name. node.sh is missing from
# releases before it existed; only then the main branch is used, over HTTPS.
install_self() {
  local asset=$1 dest=$2 new="$2.new"
  mkdir -p "$LIBDIR"
  if [[ -f "$0" && -r "$0" && "$0" != "$dest" && "$0" != /dev/fd/* && "$0" != /proc/* ]] && grep -qF "$SELF_MARK" "$0" 2>/dev/null; then
    install -m 0755 "$0" "$new"
  elif [[ -n "${TMP:-}" && -n "${GH_BASE:-}" ]] && fetch "$asset" 2>/dev/null && verify_sums "$asset" 2>/dev/null; then
    install -m 0755 "$TMP/$asset" "$new"
  elif [[ "$asset" == node.sh && -n "${TMP:-}" && -n "${GH_BASE:-}" ]] && verify_sums 2>/dev/null &&
       ! awk -v n="$asset" '$2 == n || $2 == "*" n { f = 1 } END { exit !f }' "$TMP/SHA256SUMS" &&
       curl -fsSL --max-time 30 -o "$TMP/$asset" "$RAW_BASE/$asset" 2>/dev/null && grep -qF "$SELF_MARK" "$TMP/$asset"; then
    warn "This release has no node.sh yet; saved the menu from the main branch instead."
    install -m 0755 "$TMP/$asset" "$new"
  elif [[ "$0" == "$dest" ]] && grep -qF "$SELF_MARK" "$dest" 2>/dev/null; then
    return 0   # running as the installed copy already; offline updates keep it
  else
    warn "Could not save the management menu; the ovira command will still work without it."
    return 1
  fi
  mv -f "$new" "$dest"
}

# write_dispatcher SIDE: manage.sh is what the ovira command runs; it hands over
# to the script of what is installed (the panel first). A full script left by an
# older version is kept for the other side before it is replaced.
write_dispatcher() {
  local side=$1 other=node
  [[ "$side" == node ]] && other=panel
  mkdir -p "$LIBDIR"
  if [[ -f $MANAGE ]] && ! grep -qF "$DISPATCH_MARK" "$MANAGE"; then
    local unit=$SLUG; [[ $other == node ]] && unit=$SLUG-node
    if [[ -f $UNITDIR/$unit.service && ! -f $LIBDIR/$other.sh ]]; then cp -p "$MANAGE" "$LIBDIR/$other.sh"; fi
  fi
  cat > "$MANAGE.new" <<DISPATCH
#!/usr/bin/env bash
# $DISPATCH_MARK: runs the management script of what is installed on this server.
d=$LIBDIR
if [[ -f $UNITDIR/$SLUG.service && -f \$d/panel.sh ]]; then exec bash "\$d/panel.sh" "\$@"; fi
if [[ -f $UNITDIR/$SLUG-node.service && -f \$d/node.sh ]]; then exec bash "\$d/node.sh" "\$@"; fi
echo "Ovira is not installed on this server." >&2
exit 1
DISPATCH
  chmod 0755 "$MANAGE.new"
  mv -f "$MANAGE.new" "$MANAGE"
}

# ------------------------------------------------------------------ packages

OS_FAMILY=""
detect_os() {
  [[ -r /etc/os-release ]] || die "Cannot tell which system this is."
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID_LIKE:-$ID}" in
    *debian*|*ubuntu*) OS_FAMILY=debian ;;
    *rhel*|*fedora*|*centos*) OS_FAMILY=rhel ;;
    *) die "Unsupported distribution: $ID. Ovira supports Debian, Ubuntu, AlmaLinux, Rocky and CentOS Stream." ;;
  esac
  OS_NAME=${PRETTY_NAME:-$ID}
}

pkg_install() {
  case "$OS_FAMILY" in
    debian)
      export DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1  # never restart other services on a live server
      apt-get update -qq && apt-get install -y -qq "$@" >/dev/null ;;
    rhel)
      local pm=yum; command -v dnf >/dev/null && pm=dnf
      $pm install -y -q epel-release >/dev/null 2>&1 || true
      $pm install -y -q "$@" >/dev/null ;;
  esac
}

ensure_openvpn() {
  run "Installing OpenVPN and tools ($OS_NAME)" pkg_install openvpn iptables curl ca-certificates openssl || die "Package installation failed."
  local ovpn ver major rest minor
  ovpn=$(command -v openvpn)
  ver=$("$ovpn" --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  major=${ver%%.*}; rest=${ver#*.}; minor=${rest%%.*}
  if (( major < 2 || (major == 2 && minor < 5) )); then
    if [[ "$OS_FAMILY" == debian ]]; then
      info "OpenVPN $ver is too old; adding the OpenVPN community repository"
      # shellcheck disable=SC1091
      . /etc/os-release
      curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | gpg --dearmor -o /usr/share/keyrings/openvpn.gpg
      echo "deb [signed-by=/usr/share/keyrings/openvpn.gpg] https://build.openvpn.net/debian/openvpn/stable ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/openvpn.list
      run "Updating OpenVPN" bash -c 'apt-get update -qq && apt-get install -y -qq openvpn >/dev/null'
      ver=$("$ovpn" --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    else
      die "OpenVPN $ver found; Ovira needs 2.5 or newer."
    fi
  fi
  ok "OpenVPN $ver"
  # The distribution's own unit is not used; Ovira runs its instances itself.
  systemctl disable --now openvpn.service openvpn-server@server.service 2>/dev/null || true
}

ensure_ocserv() {
  if ! command -v ocserv >/dev/null; then
    run "Installing the OpenConnect server, ocserv ($OS_NAME)" pkg_install ocserv || die "Could not install ocserv. Your distribution may not offer it."
  fi
  local ver; ver=$(ocserv --version 2>&1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -1)
  ok "ocserv ${ver:-?}"
  # The distribution's own units would start a second server on port 443; Ovira runs its instances itself.
  # Unit by unit: some distributions (Ubuntu 24.04) ship no ocserv.socket, and one missing unit must not block the other.
  local u
  for u in ocserv.service ocserv.socket; do
    if systemctl disable --now "$u" >/dev/null 2>&1; then
      systemctl reset-failed "$u" >/dev/null 2>&1 || true
    fi
  done
}

ensure_base_tools() {
  command -v curl >/dev/null && command -v openssl >/dev/null && return 0
  run "Installing tools ($OS_NAME)" pkg_install curl ca-certificates openssl || die "Package installation failed."
}

enable_forwarding() {
  # IPv4 only: turning on IPv6 forwarding globally disables router
  # advertisements and can drop the server's own IPv6 address. Ovira enables
  # it at runtime only for instances that use IPv6.
  echo "net.ipv4.ip_forward=1" > "/etc/sysctl.d/99-$SLUG.conf"
  sysctl -q -p "/etc/sysctl.d/99-$SLUG.conf" || true
}

warn_tun() {
  [[ -c /dev/net/tun ]] || warn "WireGuard requires /dev/net/tun. Enable TUN on this host or container before adding a WireGuard server."
}

# ------------------------------------------------- leftovers of a removed install

# instance_units PREFIX...: instance units that are loaded or enabled, one per line.
instance_units() {
  local p
  for p in "$@"; do
    systemctl list-units --all --plain --no-legend "${p}@*" 2>/dev/null | awk '$3 == "active" || $3 == "activating" || $3 == "failed" || $3 == "reloading" { print $1 }'
    systemctl list-unit-files --plain --no-legend --state=enabled "${p}@*" 2>/dev/null | awk '{ print $1 }'
  done | grep '@.\+\.service$' | sort -u || true
}

# stop_instances FILE PREFIX...: remember the instance units in FILE (so a
# reinstall can bring them back), then stop and disable them.
stop_instances() {
  local file=$1 u; shift
  local list; list=$(instance_units "$@")
  if [[ -n "$list" && -n "$file" ]]; then mkdir -p "$(dirname "$file")"; printf '%s\n' "$list" > "$file"; fi
  while IFS= read -r u; do [[ -n "$u" ]] && systemctl disable --now "$u" >/dev/null 2>&1 || true; done <<< "$list"
}

# restore_instances FILE: start the units that were running when the install was removed.
restore_instances() {
  local file=$1 u n=0
  [[ -f "$file" ]] || return 1
  while IFS= read -r u; do
    [[ -n "$u" ]] || continue
    if systemctl enable --now "$u" >/dev/null 2>&1; then n=$((n + 1)); else warn "Could not start $u; check: journalctl -u ${u%.service}"; fi
  done < "$file"
  rm -f "$file"
  ok "VPN servers started again: $n"
}

# backup_leftover LABEL DIR...: save the old settings and data in one private
# tarball in /root, then delete them. Nothing is deleted unless the tarball exists.
backup_leftover() {
  local label=$1 out d; shift
  local -a rel=()
  out="$BACKUP_DIR/$label-previous-$(date +%Y%m%d-%H%M%S).tar.gz"
  for d in "$@"; do [[ -e "$d" ]] && rel+=("${d#/}"); done
  if [[ ${#rel[@]} -gt 0 ]]; then
    (umask 077; tar -czf "$out" -C / "${rel[@]}") || { rm -f "$out"; die "Could not save the backup; nothing was deleted."; }
    chmod 600 "$out"
    ok "Backup of the previous data saved: $out"
    for d in "$@"; do rm -rf "${d:?}"; done
  fi
}

# What to do with the data a removed installation left behind.
LEFT_ACTION=keep
leftover_choose() { # leftover_choose CONFIGFILE DATADIR
  local cfg=$1 dir=$2 pick=0
  local -a opts=() ids=()
  if [[ -f $cfg ]]; then
    opts+=("Reinstall and keep the previous data (clients, keys, settings)"); ids+=(keep)
  fi
  opts+=("Fresh install: delete the previous data (a backup is saved in /root)"); ids+=(fresh)
  opts+=("Cancel"); ids+=(cancel)
  if (( FRESH )); then LEFT_ACTION=fresh; return 0; fi
  if [[ ! -f $cfg ]]; then
    warn "Data from an earlier installation is in $dir, but its settings file is gone, so it cannot be reused."
    LEFT_ACTION=fresh
    ui_has_input || return 0
  elif ! ui_has_input; then
    LEFT_ACTION=keep; return 0
  else
    warn "Ovira was removed from this server earlier, but its data is still in $dir."
  fi
  printf '\n  %sWhat should the installer do?%s\n' "$BOLD" "$RST"
  ui_choose pick 0 "${opts[@]}" || pick=$(( ${#opts[@]} - 1 ))
  LEFT_ACTION=${ids[pick]}
  [[ $LEFT_ACTION != cancel ]]
}
# ===== shared: end =====

SELF_MARK="Ovira node: installer and management tool"
brand_init() {
  TAGLINE="Node agent $G_MID OpenVPN $G_MID WireGuard $G_MID OpenConnect"
  TAGLINE_SHORT="Node agent"
}

# ---------------------------------------------------------------- arguments

CMD=""
PORT=""
PANEL_IP=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    install|update|upgrade|uninstall|status|info|start|stop|restart|logs|key|menu|version|help)
      if [[ -z "$CMD" ]]; then CMD="$1"; else ARGS+=("$1"); fi; shift ;;
    node|--node) shift ;;
    --uninstall) CMD=uninstall; shift ;;
    --port) PORT="${2:-}"; shift 2 || shift ;;
    --panel-ip) PANEL_IP="${2:-}"; shift 2 || shift ;;
    --binary) BINARY="${2:-}"; shift 2 || shift ;;
    --beta) BETA=1; shift ;;
    --yes|-y) YES=1; shift ;;
    --fresh) FRESH=1; shift ;;
    --purge) PURGE=1; shift ;;
    --force) FORCE=1; shift ;;
    -f|--follow) FOLLOW=1; shift ;;
    # Options of the panel installer are accepted and ignored, so old commands keep working.
    --udp-port|--tcp-port|--ssl|--domain|--email|--user|--username) shift 2 || shift ;;
    --panel-only|--with-openvpn|--tcp) shift ;;
    -h|--help) CMD=help; shift ;;
    -v|--version) CMD=version; shift ;;
    -*) echo "unknown option: $1 (see: ovira help)" >&2; exit 2 ;;
    *) if [[ -n "$CMD" ]]; then ARGS+=("$1"); else echo "unknown command: $1 (see: ovira help)" >&2; exit 2; fi; shift ;;
  esac
done
ui_init
brand_init

# ------------------------------------------------------------- node specifics

# Values from the node's settings file (one JSON document, read without jq).
node_listen_port() { tr -d '\n' < "$NCONFIG" 2>/dev/null | grep -o '"listen": *"[^"]*"' | sed 's/.*:\([0-9]*\)"/\1/' | head -1; }
node_allow_from() { tr -d '\n ' < "$NCONFIG" 2>/dev/null | grep -o '"allowFrom":\[[^]]*\]' | sed 's/.*\[\(.*\)\]/\1/; s/"//g' | head -1; }
node_public_host() { tr -d '\n' < "$NCONFIG" 2>/dev/null | grep -o '"publicHost": *"[^"]*"' | sed 's/.*: *"\(.*\)"/\1/' | head -1; }
node_key() { node_cmd node key -config "$NCONFIG" 2>/dev/null || true; }
valid_panel_ip() { [[ -z "$1" || "$1" =~ ^[0-9a-fA-F:.,/]+$ ]]; }

# ----------------------------------------------------------------- unit files

write_node_units() {
  warn_tun
  local ovpn; ovpn=$(command -v openvpn || echo /usr/sbin/openvpn)
  cat > "/etc/systemd/system/${SLUG}-node.service" <<UNIT
[Unit]
Description=Ovira node agent
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=$BIN node serve -config $NCONFIG
Restart=always
RestartSec=2
LimitNOFILE=65535
Environment=OVIRA_NODE_CONFIG=$NCONFIG

[Install]
WantedBy=multi-user.target
UNIT
  cat > "/etc/systemd/system/${SLUG}-node-ovpn@.service" <<UNIT
[Unit]
Description=Ovira node OpenVPN instance %i
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=OVIRA_NODE_CONFIG=$NCONFIG
ExecStartPre=-$BIN node nat up %i
ExecStart=$ovpn --suppress-timestamps --config $NDATA/openvpn/%i.conf
ExecStopPost=-$BIN node nat down %i
Restart=on-failure
RestartSec=3
LimitNPROC=infinity
DeviceAllow=/dev/net/tun rw

[Install]
WantedBy=multi-user.target
UNIT
  cat > "/etc/systemd/system/${SLUG}-node-oc@.service" <<UNIT
[Unit]
Description=Ovira node OpenConnect instance %i
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=OVIRA_NODE_CONFIG=$NCONFIG
ExecStartPre=-$BIN node nat up %i
ExecStart=$BIN node oc run %i
ExecReload=/bin/kill -HUP \$MAINPID
ExecStopPost=-$BIN node nat down %i
Restart=on-failure
RestartSec=3
TimeoutStopSec=20
LimitNPROC=infinity
LimitNOFILE=65535
DeviceAllow=/dev/net/tun rw

[Install]
WantedBy=multi-user.target
UNIT
  # WireGuard uses the embedded engine; no host package is needed.
  cat > "/etc/systemd/system/${SLUG}-node-wg@.service" <<UNIT
[Unit]
Description=Ovira node WireGuard instance %i
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=OVIRA_NODE_CONFIG=$NCONFIG
ExecStartPre=-$BIN node nat up %i
ExecStart=$BIN node wg run %i
ExecStopPost=-$BIN node nat down %i
Restart=on-failure
RestartSec=3
TimeoutStopSec=20
LimitNPROC=infinity
LimitNOFILE=65535
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
DeviceAllow=/dev/net/tun rw

[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload
}

# install_manager: keep this script as node.sh and make "ovira" run it.
install_manager() {
  install_self node.sh "$LIBDIR/node.sh" || return 0
  write_dispatcher node
}

# ------------------------------------------------------------------- install

# Fills in what the options did not give, then shows a summary. Returns 1 when the user cancels.
node_wizard() {
  if ui_has_input; then
    printf '\n  %sEnter keeps the value in brackets.%s\n' "$DIM$GRAY" "$RST"
  fi
  step 1 2 "Node"
  if [[ -n "$PORT" ]]; then
    valid_port "$PORT" || die "Not a port number: $PORT"
    tcp_busy "$PORT" && die "Port $PORT/tcp is already in use on this server. Pick a free one with --port."
  else
    ask_port PORT "Port the panel connects to" 62060 tcp
  fi
  if [[ -z "$PANEL_IP" ]] && ui_has_input; then
    printf '  %sPanel IP: only calls from this address are accepted. Enter = allow any address%s\n' "$DIM" "$RST"
    printf '  %s(the node still needs its key). You can find your panel IP on the Nodes page.%s\n' "$DIM" "$RST"
    while :; do
      ask PANEL_IP "IP address of your panel" ""
      valid_panel_ip "$PANEL_IP" && break
      warn "That does not look like an IP address."
    done
  fi
  valid_panel_ip "$PANEL_IP" || die "Not an IP address: $PANEL_IP"

  step 2 2 "Review"
  card_top "SUMMARY"
  ui_kv "Node port" "$PORT/tcp (must be reachable from the panel)"
  if [[ -n "$PANEL_IP" ]]; then ui_kv "Panel access" "only calls from $PANEL_IP"; else ui_kv "Panel access" "any address (the node still needs its key)"; fi
  ui_kv "OpenVPN" "installed on this server"
  ui_kv "Release" "$([[ -n "$BINARY" ]] && echo "local file" || { [[ $BETA -eq 1 ]] && echo "newest beta" || echo "newest stable"; })"
  card_end
  if ui_has_input; then pick_yesno "Start installation?" y || return 1; fi
  return 0
}

ready_card_node() { # ready_card_node KEY ADDRESS [kept]
  local v; v=$(app_version)
  card_top "READY $G_MID Ovira node ${v:-}"
  ui_kv "Address" "$2 (port $PORT/tcp must be reachable from the panel)"
  if [[ -n "$(node_allow_from)" ]]; then ui_kv "Panel access" "only calls from $(node_allow_from)"
  else ui_kv "Panel access" "any address; to limit it, reinstall with --panel-ip PANEL_IP" "$DIM"; fi
  [[ "${3:-}" == kept ]] && ui_kv "Data" "kept: the node key and its servers are back"
  card_sep "Node key (copy this line)"
  card_copy "$1"
  card_sep "Next"
  card_text "In the panel: Nodes $G_FLOW Connect a node, then paste this key."
  card_text "Run ${BOLD}ovira${RST} any time for the menu; ovira key shows the key again."
  card_end
}

do_install_node() {
  need_root; need_systemd
  local mode=install
  if (( IS_NODE )); then mode=update; elif (( LEFT_NODE )); then mode=leftover; fi
  (( IS_PANEL && ! IS_NODE )) && warn "This server already runs an Ovira panel. A node is meant for another server."
  ui_header big
  detect_os
  local wipe=0
  if [[ $mode == leftover ]]; then
    leftover_choose "$NCONFIG" "$NDATA" || { info "Nothing was changed."; return 0; }
    if [[ $LEFT_ACTION == fresh ]]; then mode=install; wipe=1; else mode=keep; fi
  fi

  if [[ $mode == install ]]; then
    node_wizard || { info "Nothing was changed."; return 0; }
    if (( wipe )); then echo; backup_leftover "$SLUG-node" "$NCONFDIR" "$NDATA"; fi
  fi

  echo
  case "$mode" in
    update) section "UPDATING THE NODE" ;;
    keep) section "REINSTALLING THE NODE (KEEPING ITS DATA)" ;;
    *) section "INSTALLING THE NODE" ;;
  esac

  ensure_openvpn
  get_binary
  place_binary
  ok "Installed $("$BIN" version)"
  enable_forwarding
  write_node_units
  install_manager

  local public
  if [[ $mode == update ]]; then
    systemctl restart "${SLUG}-node.service"   # OpenVPN instances keep running; only the agent restarts
    echo; ok "Ovira node updated. Tunnels stayed up."
    ui_item "$G_SEC" "Node key" "(run: ovira key)"; echo
    return 0
  fi

  if [[ $mode == keep ]]; then
    PORT=$(node_listen_port)
    valid_port "${PORT:-}" || die "Could not read the node port from $NCONFIG."
    tcp_busy "$PORT" && die "Port $PORT/tcp is in use by another program; free it and run the installer again."
    systemctl enable --now "${SLUG}-node.service" >/dev/null 2>&1 || die "The node did not start; check: journalctl -u $SLUG-node"
    ok "Node started"
    open_port "$PORT/tcp"
    public=$(node_public_host); [[ -n "$public" ]] || public=$(public_ip)
    if ! restore_instances "$NCONFDIR/restore-units"; then info "The panel starts the VPN servers on this node again within a minute."; fi
    ready_card_node "$(node_key)" "$public:$PORT" kept
    after_install
    return 0
  fi

  PORT=${PORT:-62060}
  valid_port "$PORT" || die "Not a port number: $PORT"
  if tcp_busy "$PORT"; then die "Port $PORT/tcp is already in use on this server. Pick a free one with --port."; fi
  local key
  public=$(public_ip)
  info "Public address: $public"
  mkdir -p "$NDATA"; chmod 711 "$NDATA"
  key=$(OVIRA_NODE_CONFIG=$NCONFIG "$BIN" node init -config "$NCONFIG" -data "$NDATA" -port "$PORT" -public-host "$public" -allow "$PANEL_IP")
  systemctl enable --now "${SLUG}-node.service" >/dev/null 2>&1
  open_port "$PORT/tcp"
  ok "Node started"
  ready_card_node "$key" "$public:$PORT"
  after_install
}

# "What next?" after an install on a terminal.
after_install() {
  ui_has_input || return 0
  local pick=0
  printf '\n  %sWhat next?%s\n' "$BOLD" "$RST"
  ui_choose pick 0 "Open the Ovira node menu" "Exit to the terminal" || pick=1
  if (( pick == 0 )); then
    detect_state
    (( IS_NODE )) && main_menu
  else
    printf '\n  %s%s%s Done. Run %sovira%s any time to open the menu.\n' "$GRN" "$G_OK" "$RST" "$BOLD" "$RST"
    copyright_line
    echo
  fi
}

# ------------------------------------------------------------------ uninstall

do_uninstall() {
  need_root; need_systemd
  detect_state
  if (( ! IS_NODE && ! LEFT_NODE )); then die "No Ovira node is installed on this server."; fi
  local purge=$PURGE
  if [[ $YES -eq 0 ]] && ui_has_input; then
    ui_header
    echo
    printf '  %sRemove the Ovira node from this server?%s\n' "$BOLD" "$RST"
    printf '  %sKeeping the data means installing again picks up where you left off.%s\n' "$DIM$GRAY" "$RST"
    local pick=0 word=""; (( purge )) && pick=1
    ui_choose pick "$pick" "Remove, keep data (recommended)" \
      "Remove and delete all data (the node key and its servers)" "Cancel" || pick=2
    case $pick in
      0) purge=0 ;;
      1)
        purge=1
        warn "This deletes the node key and all its data. It cannot be undone."
        ask word "Type delete to confirm" ""
        [[ "$word" == delete ]] || { info "Nothing was changed."; return 0; } ;;
      *) info "Nothing was changed."; return 0 ;;
    esac
  fi
  stop_node_services() {
    stop_instances "$([[ $purge -eq 1 ]] && echo '' || echo "$NCONFDIR/restore-units")" "$SLUG-node-ovpn" "$SLUG-node-oc" "$SLUG-node-wg"
    systemctl disable --now "$SLUG-node.service" 2>/dev/null || true
  }
  mkdir -p "$NCONFDIR"
  run "Stopping node services" stop_node_services
  rm -f "$UNITDIR/${SLUG}-node.service" "$UNITDIR/${SLUG}-node-ovpn@.service" "$UNITDIR/${SLUG}-node-oc@.service" "$UNITDIR/${SLUG}-node-wg@.service"
  if [[ ! -f $UNITDIR/${SLUG}.service ]]; then
    rm -f "$BIN" /usr/local/bin/ovira "/etc/sysctl.d/99-$SLUG.conf"; rm -rf "$LIBDIR"
  else
    rm -f "$LIBDIR/node.sh"; write_dispatcher panel
  fi
  systemctl daemon-reload
  if [[ $purge -eq 1 ]]; then
    rm -rf "${NCONFDIR:?}" "${NDATA:?}"; ok "Ovira node removed, including its data and key."
  else
    ok "Ovira node removed. Data kept in $NDATA and $NCONFDIR."
    info "Run the installer again to reinstall with it (or choose a fresh install)."
  fi
}

# ------------------------------------------------------------------ management

require_installed() {
  if (( IS_NODE )); then return 0; fi
  if (( LEFT_NODE )); then
    die "The node was removed from this server but its data is still here. Run the installer again to reinstall: bash <(curl -fsSL $RAW_BASE/node.sh)"
  fi
  die "No node is installed here. Run the installer without options to install one."
}

node_status_lines() {
  local v st allow host port latest=${MENU_LATEST:-}
  v=$(installed_version); st=$(svc_state "$SLUG-node.service")
  ui_state_row "$st" "Node" "Ovira ${v:-?}"
  host=$(node_public_host); port=$(node_listen_port)
  ui_item "$G_SEC" "Address" "${host:-${MENU_IP:-unknown}}:${port:-62060} (TCP, the panel connects here)"
  allow=$(node_allow_from)
  if [[ -n "$allow" ]]; then ui_item "$G_SEC" "Panel access" "only calls from $allow"; else ui_item "$G_SEC" "Panel access" "any address (the node key is still required)"; fi
  ui_item "$G_SEC" "Node key" "choose Show node key to see it"
  if [[ -z "$latest" ]]; then
    ui_item "$G_SEC" "Update" "could not check for a newer release"
  elif [[ -n "$v" && "$latest" != "v$v" ]]; then
    ui_item "$G_UP" "Update" "$latest is available $G_FLOW Update Ovira (ovira update)" "$YEL"
  else
    ui_item "$G_OK" "Update" "up to date" "$GRN"
  fi
}

cmd_status() {
  require_installed
  ui_header
  section "STATUS"
  [[ -n "${MENU_IP:-}" ]] || MENU_IP=$(public_ip 2>/dev/null || true)
  MENU_LATEST=$(LATEST_TIMEOUT=6 latest_tag 2>/dev/null || true)
  node_status_lines
  local u any=0
  while read -r u; do
    [[ -n "$u" ]] || continue
    (( any )) || { echo; any=1; }
    ui_state_row "$(svc_state "$u")" "${u%.service}"
  done < <(instance_units "$SLUG-node-ovpn" "$SLUG-node-oc" "$SLUG-node-wg")
  card_sep "Node key (copy this line)"
  card_copy "$(node_key)"
  card_end
}

cmd_info() {
  require_installed
  printf 'node key: %s\n' "$(node_key)"
}

cmd_key() { # plain output, for scripts and copying
  require_installed
  printf '%s\n' "$(node_key)"
}

screen_key() {
  require_installed
  ui_header
  section "NODE KEY"
  info "In the panel: Nodes $G_FLOW Connect a node, then paste this key."
  card_copy "$(node_key)"
  info "Anyone with this key and access to the node port can manage this node. Keep it private."
}

cmd_service() { # start|stop|restart
  require_installed; need_root
  local unit=$SLUG-node.service verb
  case "$1" in start) verb=Starting ;; stop) verb=Stopping ;; *) verb=Restarting ;; esac
  if [[ "$1" == stop && $YES -eq 0 ]] && (( MENU_PID )) && ui_has_input; then
    pick_yesno "Stop the node? The panel cannot manage this server until it is started again." n || { info "Nothing was changed."; return 0; }
  fi
  run "$verb ${unit%.service}" systemctl "$1" "$unit" || return 1
}

cmd_logs() {
  require_installed
  local unit=$SLUG-node.service target=${ARGS[0]:-}
  if [[ -n "$target" ]]; then
    unit="$SLUG-node-ovpn@$target.service"
    local alt
    for alt in oc wg; do
      if systemctl cat "$SLUG-node-$alt@$target.service" >/dev/null 2>&1 && ! systemctl cat "$unit" >/dev/null 2>&1; then unit="$SLUG-node-$alt@$target.service"; fi
    done
  fi
  CANCEL_NOTE=""
  if [[ $FOLLOW -eq 1 ]]; then journalctl -u "$unit" -n 50 -f --no-pager; else journalctl -u "$unit" -n 100 --no-pager; fi
}

cmd_update() {
  require_installed; need_root
  local cur latest; cur=$(installed_version)
  latest=$(latest_tag)
  if [[ -n "$latest" && "$latest" == "v$cur" && $FORCE -eq 0 && -z "$BINARY" ]]; then
    ui_header
    ok "Ovira $cur is the newest release."
    mktmp; [[ -f "$LIBDIR/node.sh" ]] || { set_release_base "$latest"; install_manager; }
    return 0
  fi
  local target=$latest
  if [[ -n "$BINARY" ]]; then
    local local_version
    mktmp; install -m 0755 "$BINARY" "$TMP/version-check"
    local_version=$("$TMP/version-check" version 2>/dev/null | awk '{print $2}' || true)
    rm -f "$TMP/version-check"
    [[ -n "$local_version" ]] && target=$local_version
  fi
  [[ -n "$target" ]] && info "Installed $cur $G_FLOW $target"
  TAG=$latest
  do_install_node
}

cmd_help() {
  ui_header
  cat <<HELP

  ${BOLD}Manage${RST}
    ovira                 menu
    ovira status          state, version, address, node key
    ovira key             print the node key
    ovira update          install the newest release (--beta for the beta channel)
    ovira logs [-f]       show (or follow) the log
    ovira start|stop|restart
    ovira uninstall [--purge]

  ${BOLD}Install a node on a new server${RST}

    bash <(curl -fsSL $RAW_BASE/node.sh) [options]

    --port N  --panel-ip IP  --beta  --binary FILE  --yes  --fresh  --purge

  The panel itself is installed with install.sh:

    bash <(curl -fsSL $RAW_BASE/install.sh)

HELP
  copyright_line
  echo
}

# ------------------------------------------------------------------------ menu

MENU_IP=""; MENU_LATEST=""; MENU_LATEST_DONE=0
SELF_SUM=""

menu_build() {
  local upd="Update Ovira" v; v=$(installed_version)
  [[ -n "$MENU_LATEST" && -n "$v" && "$MENU_LATEST" != "v$v" ]] && upd="Update Ovira ($MENU_LATEST available)"
  menu_reset
  menu_section "NODE"
  menu_add status "Status & node key" "State, version, address, panel access and the node key."
  menu_add key "Show node key" "The key to paste in the panel under Nodes, Connect a node."
  menu_section "SERVICES"
  menu_add restart "Restart the node" "Restart the node agent. Running tunnels stay up."
  menu_add start "Start the node" "Start the node agent if it is stopped."
  menu_add stop "Stop the node" "Stop the node agent. Asks first."
  menu_add logs "Live logs" "Follow the node log. Ctrl+C comes back here."
  menu_section "MAINTENANCE"
  menu_add update "$upd" "Download and install the newest release (verified). Tunnels stay up."
  menu_add uninstall "Uninstall the node" "Remove the node. You choose whether to keep the data. Asks first."
  menu_add_exit
  MENU_DANGER=" stop uninstall "
}

menu_refresh() {
  if ui_rich; then printf '\033[H\033[2J\n  %s%s Loading...%s' "$TEAL" "$G_ARR" "$RST"; fi
  detect_state
  [[ -n "$MENU_IP" ]] || MENU_IP=$(public_ip 2>/dev/null || true)
  if (( ! MENU_LATEST_DONE )); then MENU_LATEST=$(LATEST_TIMEOUT=4 latest_tag 2>/dev/null || true); MENU_LATEST_DONE=1; fi
  MENU_STATUS=$(node_status_lines)
  menu_build
}

screen_logs() { ARGS=(); FOLLOW=1; cmd_logs; }

main_menu() {
  ui_has_input || { cmd_status; return 0; }
  MENU_PID=$BASHPID; MENU_IDLE=1; MENU_SEL=1
  SELF_SUM=$(cksum < "$0" 2>/dev/null || true)
  trap 'MENU_RESIZED=1' WINCH
  local last=""
  while :; do
    menu_refresh
    [[ -n "$last" ]] && menu_sel_id "$last"
    menu_select
    last=$MENU_CHOICE
    case "$MENU_CHOICE" in
      status) run_screen cmd_status ;;
      key) run_screen screen_key ;;
      restart|start|stop) run_screen cmd_service "$MENU_CHOICE" ;;
      logs) run_screen screen_logs ;;
      update)
        run_screen cmd_update
        MENU_LATEST_DONE=0; VER_CACHE=""
        if [[ "$0" == "$LIBDIR/node.sh" && -n "$SELF_SUM" && "$(cksum < "$0" 2>/dev/null || true)" != "$SELF_SUM" ]]; then
          ui_restore_terminal
          exec bash "$LIBDIR/node.sh" menu
        fi ;;
      uninstall)
        run_screen do_uninstall
        detect_state
        (( IS_NODE )) || { ui_restore_terminal; copyright_line; echo; exit 0; } ;;
      exit) menu_goodbye ;;
      *) ;;
    esac
  done
}

# ------------------------------------------------------------------------ main

case "$CMD" in
  help) cmd_help; exit 0 ;;
  version) if [[ -x $BIN ]]; then "$BIN" version; else echo "ovira (not installed)"; fi; exit 0 ;;
esac

need_root
detect_state
case "$CMD" in
  install) do_install_node ;;
  uninstall) do_uninstall ;;
  menu|"")
    if (( IS_NODE )); then
      # An installation from before the menu existed gets it now.
      [[ -f "$LIBDIR/node.sh" ]] || { mktmp; install_manager 2>/dev/null || true; }
      main_menu
    else
      do_install_node
    fi ;;
  status) cmd_status ;;
  info) cmd_info ;;
  start|stop|restart) cmd_service "$CMD" ;;
  logs) cmd_logs ;;
  update|upgrade) cmd_update ;;
  key) cmd_key ;;
esac
