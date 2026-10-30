#!/usr/bin/env bash
# Ovira: installer and management tool for the panel.
# Debian, Ubuntu, AlmaLinux, Rocky and CentOS Stream. Copyright (c) Erfan-XRay.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
#
# On a new server it asks what it needs and installs the panel. On a server that
# already has Ovira it opens a menu. After installing, the same menu is the
# "ovira" command:
#
#   ovira                 menu
#   ovira status          what is running, versions, address, license
#   ovira update          install the newest release
#   ovira password        set a new password for a panel admin
#   ovira license         license and machine ID
#   ovira ssl             HTTPS certificate for the panel
#   ovira local-node enable|disable   make this server a node of its own panel (or panel only)
#   ovira logs [-f]       show (or follow) the log
#   ovira backup          save the database and settings to one file
#   ovira restart|start|stop
#   ovira uninstall
#
# Everything the questions ask can be given as options instead:
#
#   --local-node            this server is also a node of the panel (default; same as --with-openvpn)
#   --no-local-node         panel only, it manages other nodes (same as --panel-only)
#   --port 2053             panel port
#   --ssl domain|ip|none    HTTPS with a Let's Encrypt certificate, or plain HTTP
#   --domain panel.example.com   --email you@example.com
#   --user admin            name of the first admin
#   --beta                  use the newest beta instead of the stable release
#   --binary ./ovira-linux-amd64   use a local build instead of downloading
#   --yes                   do not ask; use the options and defaults
#   --fresh                 after a removal that kept its data: start empty instead
#   --purge                 with uninstall: delete data too
#
# The installer creates no inbounds: create them in the panel under Inbounds.
# --udp-port, --tcp-port and --tcp are still accepted but ignored.
#
# Nodes have their own installer, node.sh. The old forms "install.sh node ...",
# --node and --uninstall --node still work: they hand over to node.sh.
# Running the installer again updates an existing installation.
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

SELF_MARK="Ovira: installer and management tool for the panel"
brand_init() {
  TAGLINE="VPN Panel $G_MID OpenVPN $G_MID WireGuard $G_MID OpenConnect"
  TAGLINE_SHORT="VPN Panel"
}

# ---------------------------------------------------------------- arguments

CMD=""
PORT=""
IGNORED_OPT=0
SSL=""
DOMAIN=""
EMAIL=""
OPENVPN_HERE=""
ADMIN_USER="admin"
ORIG_ARGS=("$@")

# Nodes have their own installer now. The old forms (install.sh node ...,
# --node, --uninstall --node, --panel-ip) hand over to it.
run_node_script() { # run_node_script [installed] args...: node.sh next to this file, the installed one, or a download
  local use_installed=0 script="" t="" rc=0
  [[ "${1:-}" == installed ]] && { use_installed=1; shift; }
  if [[ "$0" != /dev/fd/* && "$0" != /proc/* && -f "$(dirname "$0")/node.sh" ]]; then
    script="$(dirname "$0")/node.sh"
  elif (( use_installed )) && [[ -f $LIBDIR/node.sh ]]; then
    script=$LIBDIR/node.sh
  else
    t=$(mktemp)
    curl -fsSL --max-time 30 -o "$t" "$RAW_BASE/node.sh" || { rm -f "$t"; die "Could not download node.sh from $RAW_BASE/node.sh"; }
    script=$t
  fi
  bash "$script" "$@" || rc=$?
  [[ -n "$t" ]] && rm -f "$t"
  exit "$rc"
}

want_node=0; skip=0; nargs=()
for a in "$@"; do
  if (( skip )); then skip=0; nargs+=("$a"); continue; fi
  case "$a" in
    --port|--udp-port|--tcp-port|--ssl|--domain|--email|--binary|--user|--username) skip=1; nargs+=("$a") ;;
    --panel-ip) want_node=1; skip=1; nargs+=("$a") ;;
    node|--node) want_node=1 ;;
    --uninstall) nargs+=(uninstall) ;;
    *) nargs+=("$a") ;;
  esac
done
if (( want_node )); then
  ui_init
  info "Nodes now have their own command: bash <(curl -fsSL $RAW_BASE/node.sh)"
  run_node_script ${nargs[@]+"${nargs[@]}"}
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    panel|install|update|upgrade|uninstall|status|info|start|stop|restart|logs|password|passwd|license|ssl|openvpn|local-node|ocserv|key|backup|menu|version|help)
      if [[ -z "$CMD" ]]; then CMD="$1"; else ARGS+=("$1"); fi; shift ;;
    --uninstall) CMD=uninstall; shift ;;
    --panel-only|--no-local-node) OPENVPN_HERE=0; shift ;;
    --with-openvpn|--local-node) OPENVPN_HERE=1; shift ;;
    --port) PORT="${2:-}"; shift 2 || shift ;;
    --udp-port|--tcp-port) IGNORED_OPT=1; shift 2 || shift ;;
    --tcp) IGNORED_OPT=1; shift ;;
    --ssl) SSL="${2:-}"; shift 2 || shift ;;
    --domain) DOMAIN="${2:-}"; shift 2 || shift ;;
    --email) EMAIL="${2:-}"; shift 2 || shift ;;
    --binary) BINARY="${2:-}"; shift 2 || shift ;;
    --beta) BETA=1; shift ;;
    --yes|-y) YES=1; shift ;;
    --fresh) FRESH=1; shift ;;
    --user|--username) ADMIN_USER="${2:-admin}"; shift 2 || shift ;;
    --purge) PURGE=1; shift ;;
    --force) FORCE=1; shift ;;
    -f|--follow) FOLLOW=1; shift ;;
    -h|--help) CMD=help; shift ;;
    -v|--version) CMD=version; shift ;;
    -*) echo "unknown option: $1 (see: ovira help)" >&2; exit 2 ;;
    *) if [[ -n "$CMD" ]]; then ARGS+=("$1"); else echo "unknown command: $1 (see: ovira help)" >&2; exit 2; fi; shift ;;
  esac
done
ui_init
brand_init
(( IGNORED_OPT )) && printf '  %s--udp-port, --tcp-port and --tcp are ignored: create inbounds in the panel under Inbounds.%s\n' "$DIM" "$RST"

# ------------------------------------------------------------ panel specifics

local_on() { # is this server a node of its own panel?
  local out
  if out=$(panel_cmd openvpn status 2>/dev/null); then
    [[ "$out" == *": yes"* || "$out" == *": on"* ]]
  else # a binary from before the command existed: look at the units
    systemctl list-units --plain --no-legend "${SLUG}-ovpn@*" 2>/dev/null | grep -q running
  fi
}

PI_ADDR=""; PI_MID=""; PI_LIC=""
panel_info_load() {
  local line out
  PI_ADDR=""; PI_MID=""; PI_LIC=""
  out=$(panel_cmd info 2>/dev/null || true)
  while IFS= read -r line; do
    case "$line" in
      panel:*) PI_ADDR=$(val "$line") ;;
      machine*) PI_MID=$(val "$line") ;;
      license:*) PI_LIC=$(val "$line") ;;
    esac
  done <<< "$out"
  return 0
}
panel_port() { panel_cmd info 2>/dev/null | sed -n 's|^panel: *[a-z]*://[^/]*:\([0-9]*\)\(/.*\)\{0,1\}$|\1|p' | head -1; }

# ----------------------------------------------------------------- unit files

write_panel_units() {
  warn_tun
  local ovpn; ovpn=$(command -v openvpn || echo /usr/sbin/openvpn)
  cat > "/etc/systemd/system/${SLUG}.service" <<UNIT
[Unit]
Description=Ovira OpenVPN panel
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=$BIN serve -config $CONFIG
Restart=always
RestartSec=2
LimitNOFILE=65535
Environment=OVIRA_CONFIG=$CONFIG

[Install]
WantedBy=multi-user.target
UNIT
  cat > "/etc/systemd/system/${SLUG}-ovpn@.service" <<UNIT
[Unit]
Description=Ovira OpenVPN instance %i
After=network-online.target ${SLUG}.service
Wants=network-online.target

[Service]
Type=simple
Environment=OVIRA_CONFIG=$CONFIG
ExecStartPre=-$BIN nat up %i
ExecStart=$ovpn --suppress-timestamps --config $DATA/openvpn/%i.conf
ExecStopPost=-$BIN nat down %i
Restart=on-failure
RestartSec=3
LimitNPROC=infinity
DeviceAllow=/dev/net/tun rw

[Install]
WantedBy=multi-user.target
UNIT
  # OpenConnect instances run under their own template; it costs nothing when unused.
  cat > "/etc/systemd/system/${SLUG}-oc@.service" <<UNIT
[Unit]
Description=Ovira OpenConnect instance %i
After=network-online.target ${SLUG}.service
Wants=network-online.target

[Service]
Type=simple
Environment=OVIRA_CONFIG=$CONFIG
ExecStartPre=-$BIN nat up %i
ExecStart=$BIN oc run %i
ExecReload=/bin/kill -HUP \$MAINPID
ExecStopPost=-$BIN nat down %i
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
  cat > "/etc/systemd/system/${SLUG}-wg@.service" <<UNIT
[Unit]
Description=Ovira WireGuard instance %i
After=network-online.target ${SLUG}.service
Wants=network-online.target

[Service]
Type=simple
Environment=OVIRA_CONFIG=$CONFIG
ExecStartPre=-$BIN nat up %i
ExecStart=$BIN wg run %i
ExecStopPost=-$BIN nat down %i
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

# install_manager: keep this script as panel.sh and make "ovira" run it.
install_manager() {
  install_self install.sh "$LIBDIR/panel.sh" || return 0
  write_dispatcher panel
}

# ------------------------------------------------------------------- install


# Fills in what the options did not give, then shows a summary. Returns 1 when the user cancels.
panel_wizard() {
  local a idx=1
  if ui_has_input; then
    printf '\n  %sEnter keeps the value in brackets. To install a node instead, see: ovira help%s\n' "$DIM$GRAY" "$RST"
  fi

  step 1 4 "Panel"
  if [[ -n "$PORT" ]]; then
    valid_port "$PORT" || die "Not a port number: $PORT"
    tcp_busy "$PORT" && die "Port $PORT/tcp is already in use; choose another panel port with --port."
  else
    ask_port PORT "Panel port" 2053 tcp
  fi

  step 2 4 "This server as a node"
  if [[ -z "$OPENVPN_HERE" ]]; then
    if ui_has_input; then
      printf '  %s  yes: this server also runs VPN inbounds and shows up in the Nodes list as the panel'"'"'s own node%s\n' "$DIM" "$RST"
      printf '  %s  no : panel only, it just manages other nodes (change it later from the menu)%s\n' "$DIM" "$RST"
      if pick_yesno "Use this server as a node too?" y; then OPENVPN_HERE=1; else OPENVPN_HERE=0; fi
    else
      OPENVPN_HERE=1
    fi
  fi

  step 3 4 "HTTPS"
  if [[ -z "$SSL" ]]; then
    if [[ -n "$DOMAIN" ]]; then
      SSL=domain
    elif ui_has_input; then
      printf '  %sThe panel can serve HTTPS with a free Let'"'"'s Encrypt certificate.%s\n' "$DIM" "$RST"
      ui_choose idx 1 "Certificate for a domain (the domain must point at this server)" \
        "Certificate for this server's IP (no domain needed)" "None: plain HTTP" || idx=1
      case "$idx" in 0) SSL=domain ;; 2) SSL=none ;; *) SSL=ip ;; esac
    else
      SSL=ip
    fi
  fi
  case "$SSL" in domain|ip|none) ;; *) die "--ssl must be domain, ip or none." ;; esac
  if [[ "$SSL" == domain && -z "$DOMAIN" ]]; then
    while :; do
      ask DOMAIN "Domain for the panel (e.g. panel.example.com)" ""
      [[ -n "$DOMAIN" ]] && break
      ui_has_input || die "A domain is required for --ssl domain."
      warn "A domain is needed for this choice."
    done
  fi
  if [[ "$SSL" != none && -z "$EMAIL" ]]; then ask EMAIL "Email for certificate notices (optional)" ""; fi

  step 4 4 "Review"
  card_top "SUMMARY"
  ui_kv "Panel port" "$PORT/tcp"
  ui_kv "Admin user" "$ADMIN_USER"
  ui_kv "Node here" "$([[ "$OPENVPN_HERE" == 1 ]] && echo yes || echo no)"
  ui_kv "Inbounds" "none yet: create them in the panel under Inbounds"
  case "$SSL" in
    domain) ui_kv "HTTPS" "Let's Encrypt for $DOMAIN" ;;
    ip) ui_kv "HTTPS" "Let's Encrypt for this server's IP" ;;
    *) ui_kv "HTTPS" "off (plain HTTP)" ;;
  esac
  ui_kv "Release" "$([[ -n "$BINARY" ]] && echo "local file" || { [[ $BETA -eq 1 ]] && echo "newest beta" || echo "newest stable"; })"
  card_end
  if ui_has_input; then pick_yesno "Start installation?" y || return 1; fi
  return 0
}

ready_card_panel() { # ready_card_panel URL PASSWORD
  local v; v=$(app_version)
  card_top "READY $G_MID Ovira ${v:-}"
  ui_kv "Username" "$ADMIN_USER" "$BOLD"
  if [[ "$OPENVPN_HERE" == 1 ]]; then
    ui_kv "Node" "this server is a node of this panel (add inbounds under Inbounds)"
  else
    ui_kv "Panel only" "connect nodes under Nodes" "$DIM"
  fi
  card_sep "Panel address (open it in your browser)"
  card_copy "$1"
  card_sep "Password (shown once; change it in the panel)"
  card_copy "$2"
  card_sep "Quick guide"
  card_text "Keep the panel path secret; other paths on that port answer 404."
  card_text "Turn on two-factor sign-in under Settings $G_FLOW My account."
  card_text "Free plan: 5 active clients, 2 nodes. Upgrade under License."
  card_text "Run ${BOLD}ovira${RST} any time for the menu (status, update, logs)."
  card_text "Create your first inbound under Inbounds."
  card_text "To add a node, run the node command on another server."
  card_end
}

ready_card_kept() { # ready_card_kept URL
  local v; v=$(app_version)
  card_top "READY $G_MID Ovira ${v:-}"
  ui_kv "Data" "kept: your clients, keys and settings are back"
  ui_kv "Sign-in" "your existing admin accounts (forgot it? ovira password)"
  card_sep "Panel address (open it in your browser)"
  card_copy "$1"
  card_text "Run ${BOLD}ovira${RST} any time for the menu."
  card_end
}

# bring the VPN servers that were running back after a reinstall that kept the data
restore_from_db() {
  local db=$DATA/$SLUG.db rows="" kind name p n=0 q
  q="SELECT kind, name FROM instances WHERE enabled = 1 AND node_id = 0 AND COALESCE((SELECT enabled FROM nodes WHERE id = 0), 1) = 1"
  if command -v sqlite3 >/dev/null; then
    rows=$(sqlite3 -separator ' ' "$db" "$q" 2>/dev/null || true)
  elif command -v python3 >/dev/null; then
    rows=$(python3 - "$db" "$q" <<'PY' 2>/dev/null || true
import sqlite3, sys
for k, n in sqlite3.connect(sys.argv[1]).execute(sys.argv[2]):
    print(k, n)
PY
)
  fi
  [[ -n "$rows" ]] || return 1
  while read -r kind name; do
    [[ -n "$name" ]] || continue
    case "$kind" in ocserv) p=oc ;; wireguard) p=wg ;; *) p=ovpn ;; esac
    if systemctl enable --now "$SLUG-$p@$name.service" >/dev/null 2>&1; then n=$((n + 1)); else warn "Could not start $name; check: journalctl -u $SLUG-$p@$name"; fi
  done <<< "$rows"
  ok "VPN servers started again: $n"
}

do_install_panel() {
  need_root; need_systemd
  local mode=install
  if (( IS_PANEL )); then mode=update; elif (( LEFT_PANEL )); then mode=leftover; fi
  (( IS_NODE && ! IS_PANEL )) && warn "This server already runs an Ovira node. A panel is usually installed on its own server."
  ui_header big
  detect_os
  local wipe=0
  if [[ $mode == leftover ]]; then
    leftover_choose "$CONFIG" "$DATA" || { info "Nothing was changed."; return 0; }
    if [[ $LEFT_ACTION == fresh ]]; then mode=install; wipe=1; else mode=keep; fi
  fi

  if [[ $mode == install ]]; then
    panel_wizard || { info "Nothing was changed."; return 0; }
    if (( wipe )); then
      echo; backup_leftover "$SLUG" "$CONFDIR" "$DATA"
    fi
  fi

  echo
  case "$mode" in
    update) section "UPDATING OVIRA"; OPENVPN_HERE=0; local_on && OPENVPN_HERE=1 ;;
    keep) section "REINSTALLING OVIRA (KEEPING YOUR DATA)" ;;
    *) section "INSTALLING OVIRA" ;;
  esac

  if [[ $mode == keep ]]; then
    ensure_base_tools
  elif [[ "$OPENVPN_HERE" == 1 ]]; then ensure_openvpn; else ensure_base_tools; fi
  get_binary
  place_binary
  ok "Installed $("$BIN" version)"
  if [[ $mode == keep ]]; then
    OPENVPN_HERE=0; local_on && OPENVPN_HERE=1
    [[ "$OPENVPN_HERE" == 1 ]] && ensure_openvpn
  fi
  [[ "$OPENVPN_HERE" == 1 ]] && enable_forwarding
  write_panel_units
  install_manager

  if [[ $mode == update ]]; then
    # The panel restarts OpenVPN servers whose config the new version changes.
    systemctl restart "${SLUG}.service"
    echo; ok "Ovira updated."
    panel_info_load; ui_item "$G_SEC" "Panel" "${PI_ADDR:-unknown}"; echo
    return 0
  fi

  if [[ $mode == keep ]]; then
    PORT=$(panel_port)
    valid_port "${PORT:-}" || die "Could not read the panel port from $CONFIG."
    tcp_busy "$PORT" && die "Port $PORT/tcp is in use by another program; free it and run the installer again."
    systemctl enable --now "${SLUG}.service" >/dev/null 2>&1 || die "The panel did not start; check: journalctl -u $SLUG"
    ok "Panel started"
    open_port "$PORT/tcp"
    if [[ "$OPENVPN_HERE" == 1 ]]; then
      restore_instances "$CONFDIR/restore-units" || restore_from_db || warn "Start your VPN servers from Servers in the panel."
    fi
    panel_info_load
    ready_card_kept "${PI_ADDR/SERVER_IP/$(public_ip)}"
    after_install
    return 0
  fi

  local public pubhost out pass base scheme host
  public=$(public_ip)
  info "Public address: $public"
  mkdir -p "$CONFDIR" "$DATA"
  chmod 711 "$DATA"  # OpenVPN (as nobody) must reach pki/crl.pem
  local local_flag="-local=true"; [[ "$OPENVPN_HERE" == 1 ]] || local_flag="-local=false"
  pubhost=$public; [[ "$SSL" == domain ]] && pubhost=$DOMAIN
  out=$(OVIRA_CONFIG=$CONFIG "$BIN" init -config "$CONFIG" -data "$DATA" -port "$PORT" -public-host "$pubhost" -username "$ADMIN_USER" $local_flag)
  pass=$(echo "$out" | awk -F': *' '/^password/ {print $2}')
  base=$(echo "$out" | awk -F': *' '/^panel path/ {print $2}')

  scheme=http; host=$public
  if [[ "$SSL" == domain || "$SSL" == ip ]]; then
    local name=$public; [[ "$SSL" == domain ]] && name=$DOMAIN
    info "Getting a Let's Encrypt certificate for $name"
    if OVIRA_CONFIG=$CONFIG "$BIN" ssl issue -mode "$SSL" -domain "$name" -email "$EMAIL" >> "$LOGFILE" 2>&1; then
      scheme=https; host=$name; ok "HTTPS certificate issued for $name"
    else
      warn "No certificate yet; the panel starts on plain HTTP. Retry later with: ovira ssl"
    fi
  fi

  systemctl enable --now "${SLUG}.service" >/dev/null 2>&1
  open_port "$PORT/tcp"
  ok "Panel started"
  ready_card_panel "$scheme://$host:$PORT$base" "$pass"
  after_install
}

# "What next?" after an install on a terminal.
after_install() {
  ui_has_input || return 0
  local pick=0
  printf '\n  %sWhat next?%s\n' "$BOLD" "$RST"
  ui_choose pick 0 "Open the Ovira menu" "Exit to the terminal" || pick=1
  if (( pick == 0 )); then
    detect_state
    (( IS_PANEL )) && main_menu
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
  if (( ! IS_PANEL && ! LEFT_PANEL )); then
    (( IS_NODE )) && run_node_script installed "${ORIG_ARGS[@]}"
    die "No Ovira panel is installed on this server."
  fi
  local purge=$PURGE
  if [[ $YES -eq 0 ]] && ui_has_input; then
    ui_header
    echo
    printf '  %sRemove the Ovira panel from this server?%s\n' "$BOLD" "$RST"
    printf '  %sKeeping the data means installing again picks up where you left off.%s\n' "$DIM$GRAY" "$RST"
    local pick=0 word=""; (( purge )) && pick=1
    ui_choose pick "$pick" "Remove, keep data (recommended)" \
      "Remove and delete all data (clients, keys, certificates)" "Cancel" || pick=2
    case $pick in
      0) purge=0 ;;
      1)
        purge=1
        warn "This deletes every client, key and certificate. It cannot be undone."
        ask word "Type delete to confirm" ""
        [[ "$word" == delete ]] || { info "Nothing was changed."; return 0; } ;;
      *) info "Nothing was changed."; return 0 ;;
    esac
  fi
  stop_panel_services() {
    stop_instances "$([[ $purge -eq 1 ]] && echo '' || echo "$CONFDIR/restore-units")" "$SLUG-ovpn" "$SLUG-oc" "$SLUG-wg"
    systemctl disable --now "$SLUG.service" 2>/dev/null || true
  }
  mkdir -p "$CONFDIR"
  run "Stopping services" stop_panel_services
  rm -f "$UNITDIR/${SLUG}.service" "$UNITDIR/${SLUG}-ovpn@.service" "$UNITDIR/${SLUG}-oc@.service" "$UNITDIR/${SLUG}-wg@.service"
  if [[ ! -f $UNITDIR/${SLUG}-node.service ]]; then
    rm -f "$BIN" /usr/local/bin/ovira "/etc/sysctl.d/99-$SLUG.conf"; rm -rf "$LIBDIR"
  else
    rm -f "$LIBDIR/panel.sh"; write_dispatcher node
  fi
  systemctl daemon-reload
  if [[ $purge -eq 1 ]]; then
    rm -rf "${CONFDIR:?}" "${DATA:?}"; ok "Ovira removed, including all data."
  else
    ok "Ovira removed. Data kept in $DATA and $CONFDIR."
    info "Run the installer again to reinstall with it (or choose a fresh install)."
  fi
}

# ------------------------------------------------------------------ management

require_installed() {
  if (( IS_PANEL )); then return 0; fi
  if (( LEFT_PANEL )); then
    die "Ovira was removed from this server but its data is still here. Run the installer again to reinstall: bash <(curl -fsSL $RAW_BASE/install.sh)"
  fi
  die "Ovira is not installed here. Run the installer without options to install it."
}

panel_status_lines() {
  local v st addr tls latest=${MENU_LATEST:-}
  v=$(installed_version); st=$(svc_state "$SLUG.service")
  ui_state_row "$st" "Panel" "Ovira ${v:-?}"
  addr=${PI_ADDR/SERVER_IP/${MENU_IP:-SERVER_IP}}
  ui_item "$G_SEC" "Address" "${addr:-unknown}"
  case "$PI_ADDR" in
    https://*) tls="on (Let's Encrypt certificate)" ;;
    *) tls="off (plain HTTP); turn it on with: ovira ssl" ;;
  esac
  ui_item "$G_SEC" "HTTPS" "$tls"
  ui_item "$G_SEC" "License" "${PI_LIC:-unknown}"
  if (( ${MENU_LOCAL:-0} )); then
    ui_item "$G_SEC" "Node here" "yes: this server is a node of this panel"
  else
    ui_item "$G_SEC" "Node here" "no: panel only (connect nodes, or turn it on in the menu)"
  fi
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
  MENU_LOCAL=0; local_on && MENU_LOCAL=1
  panel_info_load
  [[ -n "${MENU_IP:-}" ]] || MENU_IP=$(public_ip 2>/dev/null || true)
  MENU_LATEST=$(LATEST_TIMEOUT=6 latest_tag 2>/dev/null || true)
  panel_status_lines
  [[ -n "$PI_MID" ]] && ui_item "$G_SEC" "Machine ID" "$PI_MID"
  local u any=0
  while read -r u; do
    [[ -n "$u" ]] || continue
    (( any )) || { echo; any=1; }
    ui_state_row "$(svc_state "$u")" "${u%.service}"
  done < <(instance_units "$SLUG-ovpn" "$SLUG-oc" "$SLUG-wg")
  echo
}

cmd_info() {
  require_installed
  panel_cmd info
}

cmd_service() { # start|stop|restart
  require_installed; need_root
  local unit=$SLUG.service verb
  case "$1" in start) verb=Starting ;; stop) verb=Stopping ;; *) verb=Restarting ;; esac
  if [[ "$1" == stop && $YES -eq 0 ]] && (( MENU_PID )) && ui_has_input; then
    pick_yesno "Stop the panel? You cannot reach it until it is started again." n || { info "Nothing was changed."; return 0; }
  fi
  run "$verb ${unit%.service}" systemctl "$1" "$unit" || return 1
}

cmd_logs() {
  require_installed
  local unit=$SLUG.service target=${ARGS[0]:-}
  if [[ -n "$target" ]]; then
    unit="$SLUG-ovpn@$target.service"
    # OpenConnect and WireGuard instances have their own unit templates.
    local alt
    for alt in oc wg; do
      if systemctl cat "$SLUG-$alt@$target.service" >/dev/null 2>&1 && ! systemctl cat "$unit" >/dev/null 2>&1; then unit="$SLUG-$alt@$target.service"; fi
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
    mktmp; [[ -f "$LIBDIR/panel.sh" ]] || { set_release_base "$latest"; install_manager; }
    return 0
  fi
  local target=$latest
  if [[ -n "$BINARY" ]]; then
    # A copied or downloaded build is often not executable yet.
    local local_version
    mktmp; install -m 0755 "$BINARY" "$TMP/version-check"
    local_version=$("$TMP/version-check" version 2>/dev/null | awk '{print $2}' || true)
    rm -f "$TMP/version-check"
    [[ -n "$local_version" ]] && target=$local_version
  fi
  [[ -n "$target" ]] && info "Installed $cur $G_FLOW $target"
  TAG=$latest
  do_install_panel
}

cmd_password() {
  require_installed; need_root
  ui_header
  section "ADMIN PASSWORD"
  printf '  Panel admins:\n'
  panel_cmd admin list 2>/dev/null | sed 's/^/    /'
  echo
  local user pw out
  user=${ARGS[0]:-}
  if [[ -z "$user" ]]; then ask user "Which admin?" "$ADMIN_USER"; fi
  ask_secret pw "New password (Enter = make a strong random one)"
  if [[ -n "$pw" ]]; then
    out=$(panel_cmd admin passwd -username "$user" -password "$pw") || { err "$out"; return 1; }
  else
    out=$(panel_cmd admin passwd -username "$user") || { err "$out"; return 1; }
  fi
  echo
  ok "Password changed. Other sessions of $user were signed out."
  ui_kv "Username" "$user"
  card_sep "Password"
  if [[ -n "$pw" ]]; then card_text "(the one you typed)"; else card_copy "$(echo "$out" | awk -F': *' '/^password/ {print $2}')"; fi
  card_end
}

cmd_license() {
  require_installed
  ui_header
  section "LICENSE"
  panel_info_load
  ui_item "$G_SEC" "Machine ID" "${PI_MID:-unknown}"
  ui_item "$G_SEC" "License" "${PI_LIC:-unknown}"
  echo
  info "Activate or change the license under License in the panel. Manual activation may need owner approval using the request ID shown there."
}

cmd_ssl() {
  require_installed; need_root
  local sub=${ARGS[0]:-} pick=0
  if [[ -z "$sub" ]] && ui_has_input; then
    ui_header
    section "HTTPS CERTIFICATE"
    panel_cmd ssl status 2>/dev/null | sed 's/^/  /' || true
    echo
    ui_choose pick 3 "Certificate for a domain" "Certificate for this server's IP" "Turn HTTPS off (plain HTTP)" "Back" || pick=3
    case "$pick" in 0) sub=domain ;; 1) sub=ip ;; 2) sub=off ;; *) return 0 ;; esac
  fi
  case "${sub:-status}" in
    status) panel_cmd ssl status ;;
    off) panel_cmd ssl off && systemctl restart "$SLUG.service" && ok "HTTPS is off. The panel restarted on plain HTTP." ;;
    domain|ip|issue)
      local mode=$sub name=$DOMAIN
      [[ "$sub" == issue ]] && mode=${SSL:-ip}
      if [[ "$mode" == domain && -z "$name" ]]; then ask name "Domain (must point at this server)" ""; fi
      [[ "$mode" == domain && -z "$name" ]] && die "A domain is required."
      [[ "$mode" == ip ]] && name=$(public_ip)
      [[ -n "$EMAIL" ]] || ask EMAIL "Email for certificate notices (optional)" ""
      if panel_cmd ssl issue -mode "$mode" -domain "$name" -email "$EMAIL"; then
        systemctl restart "$SLUG.service"; ok "HTTPS is on for $name. The panel restarted."
      else
        die "The certificate could not be issued."
      fi ;;
    *) die "Use: ovira ssl [status|domain|ip|off]" ;;
  esac
}

cmd_openvpn() {
  require_installed; need_root
  local sub=${ARGS[0]:-status}
  case "$sub" in
    status) panel_cmd openvpn status ;;
    enable)
      ui_header
      detect_os
      ensure_openvpn
      enable_forwarding
      write_panel_units
      OVIRA_MANAGE=1 panel_cmd openvpn enable
      run "Restarting the panel" systemctl restart "$SLUG.service"
      ok "This server is now a node of this panel. Create inbounds under Inbounds." ;;
    disable)
      if [[ $YES -eq 0 ]] && ui_has_input; then pick_yesno "Stop using this server as a node? Clients connected here are disconnected." n || { info "Nothing was changed."; return 0; }; fi
      OVIRA_MANAGE=1 panel_cmd openvpn disable
      run "Restarting the panel" systemctl restart "$SLUG.service"
      ok "This server is panel only now. The panel and its other nodes keep working." ;;
    *) die "Use: ovira local-node enable|disable|status" ;;
  esac
}

cmd_ocserv() {
  require_installed; need_root
  local sub=${ARGS[0]:-status}
  case "$sub" in
    status) panel_cmd ocserv status ;;
    install)
      detect_os
      ensure_ocserv
      write_panel_units
      ok "OpenConnect is ready. Add an OpenConnect server under Servers in the panel." ;;
    *) die "Use: ovira ocserv install|status" ;;
  esac
}

cmd_backup() {
  require_installed; need_root
  local out=${ARGS[0]:-/root/$SLUG-backup-$(date +%Y%m%d-%H%M%S).tar.gz}
  mktmp
  local stage="$TMP/backup"; mkdir -p "$stage"
  local db="$DATA/$SLUG.db"
  [[ -f $db ]] || die "No database found at $db."
  if command -v sqlite3 >/dev/null; then sqlite3 "$db" ".backup '$stage/$SLUG.db'"
  elif command -v python3 >/dev/null; then python3 - "$db" "$stage/$SLUG.db" <<'PY'
import sqlite3, sys
s = sqlite3.connect(sys.argv[1]); d = sqlite3.connect(sys.argv[2]); s.backup(d); d.close(); s.close()
PY
  else
    systemctl stop "$SLUG.service"; cp -a "$db" "$stage/"; systemctl start "$SLUG.service"
  fi
  cp -a "$CONFIG" "$stage/config.json"
  (umask 077; tar -czf "$out" -C "$stage" .)
  chmod 600 "$out"
  ui_header
  ok "Backup saved:"
  card_copy "$out"
  info "It holds the client list, keys and settings. Keep it private."
}

cmd_help() {
  ui_header
  cat <<HELP

  ${BOLD}Manage${RST}
    ovira                 menu
    ovira status          what is running, versions, address, license
    ovira update          install the newest release (--beta for the beta channel)
    ovira password [USER] set a new password for a panel admin
    ovira license         license and machine ID
    ovira ssl             HTTPS certificate for the panel
    ovira local-node enable   make this server a node of its own panel too
    ovira local-node disable | status
    ovira ocserv install  install the OpenConnect (Cisco AnyConnect) server software
    ovira ocserv status
    ovira logs [-f]       show (or follow) the log
    ovira backup [FILE]   save the database and settings to one file
    ovira start|stop|restart
    ovira uninstall [--purge]

  ${BOLD}Install the panel on a new server${RST}

    bash <(curl -fsSL $RAW_BASE/install.sh) [options]

    --local-node  --no-local-node  --port N   (the panel creates no inbounds; add them under Inbounds)
    --ssl domain|ip|none  --domain D  --email E  --user NAME
    --beta  --binary FILE  --yes  --fresh  --purge

  ${BOLD}Install a node${RST} (an extra server controlled by a panel)

    bash <(curl -fsSL $RAW_BASE/node.sh) [--panel-ip IP] [--port N]

HELP
  copyright_line
  echo
}

# ------------------------------------------------------------------------ menu

MENU_IP=""; MENU_LATEST=""; MENU_LATEST_DONE=0; MENU_LOCAL=0
SELF_SUM=""

menu_build() {
  local upd="Update Ovira" v; v=$(installed_version)
  [[ -n "$MENU_LATEST" && -n "$v" && "$MENU_LATEST" != "v$v" ]] && upd="Update Ovira ($MENU_LATEST available)"
  menu_reset
  menu_section "PANEL"
  menu_add status "Status & address" "Panel state, version, address, license and the running VPN servers."
  menu_add password "Change admin password" "Set a new password for a panel admin. Their other sessions are signed out."
  menu_add license "License & machine ID" "Show your machine ID and license state."
  menu_add ssl "HTTPS certificate" "A free Let's Encrypt certificate for a domain or this server's IP."
  menu_section "SERVICES"
  menu_add restart "Restart the panel" "Restart the panel service."
  menu_add start "Start the panel" "Start the panel if it is stopped."
  menu_add stop "Stop the panel" "Stop the panel service. Asks first."
  menu_add logs "Live logs" "Follow the panel log. Ctrl+C comes back here."
  menu_section "THIS SERVER"
  if (( MENU_LOCAL )); then
    menu_add openvpn "This server as a node: ON (turn off)" "Stop this machine's inbounds and list it as panel only. Asks first."
  else
    menu_add openvpn "This server as a node: OFF (turn on)" "Also use the panel's own machine as a node, so inbounds can run here."
  fi
  menu_add ocserv "Install OpenConnect" "Install the OpenConnect (AnyConnect) server software."
  (( IS_NODE )) && menu_add node "Node on this server" "Open the menu of the node that is installed here."
  menu_section "MAINTENANCE"
  menu_add update "$upd" "Download and install the newest release (verified). Servers stay up."
  menu_add backup "Back up the database" "Save the database and settings to one private file in /root."
  menu_add uninstall "Uninstall Ovira" "Remove the panel. You choose whether to keep the data. Asks first."
  menu_add_exit
  MENU_DANGER=" stop uninstall "
}

menu_refresh() {
  if ui_rich; then printf '\033[H\033[2J\n  %s%s Loading...%s' "$TEAL" "$G_ARR" "$RST"; fi
  detect_state
  panel_info_load
  [[ -n "$MENU_IP" ]] || MENU_IP=$(public_ip 2>/dev/null || true)
  if (( ! MENU_LATEST_DONE )); then MENU_LATEST=$(LATEST_TIMEOUT=4 latest_tag 2>/dev/null || true); MENU_LATEST_DONE=1; fi
  MENU_LOCAL=0; local_on && MENU_LOCAL=1
  MENU_STATUS=$(panel_status_lines)
  menu_build
}

screen_ssl() { ARGS=(); cmd_ssl; }
screen_backup() { ARGS=(); cmd_backup; }
screen_openvpn() { if (( MENU_LOCAL )); then ARGS=(disable); else ARGS=(enable); fi; cmd_openvpn; }
screen_ocserv() { ARGS=(install); cmd_ocserv; }
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
      password) ARGS=(); run_screen cmd_password ;;
      license) run_screen cmd_license ;;
      ssl) run_screen screen_ssl ;;
      restart|start|stop) run_screen cmd_service "$MENU_CHOICE" ;;
      logs) run_screen screen_logs ;;
      openvpn) run_screen screen_openvpn ;;
      ocserv) run_screen screen_ocserv ;;
      node) run_screen bash "$LIBDIR/node.sh" menu ;;
      update)
        run_screen cmd_update
        MENU_LATEST_DONE=0; VER_CACHE=""
        if [[ "$0" == "$LIBDIR/panel.sh" && -n "$SELF_SUM" && "$(cksum < "$0" 2>/dev/null || true)" != "$SELF_SUM" ]]; then
          ui_restore_terminal
          exec bash "$LIBDIR/panel.sh" menu
        fi ;;
      backup) run_screen screen_backup ;;
      uninstall)
        run_screen do_uninstall
        detect_state
        (( IS_PANEL )) || { ui_restore_terminal; copyright_line; echo; exit 0; } ;;
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
  install|panel) do_install_panel ;;
  uninstall) do_uninstall ;;
  menu|"")
    if (( IS_PANEL )); then
      # An installation from before the menu existed gets it now.
      [[ -f "$LIBDIR/panel.sh" ]] || { mktmp; install_manager 2>/dev/null || true; }
      main_menu
    elif (( IS_NODE && ! LEFT_PANEL )); then
      run_node_script installed menu
    else
      do_install_panel
    fi ;;
  *)
    if (( ! IS_PANEL )) && (( IS_NODE )); then run_node_script installed "${ORIG_ARGS[@]}"; fi
    case "$CMD" in
      status) cmd_status ;;
      info) cmd_info ;;
      start|stop|restart) cmd_service "$CMD" ;;
      logs) cmd_logs ;;
      update|upgrade) cmd_update ;;
      password|passwd) cmd_password ;;
      license) cmd_license ;;
      ssl) cmd_ssl ;;
      openvpn|local-node) cmd_openvpn ;;
      ocserv) cmd_ocserv ;;
      key) if (( IS_NODE )); then run_node_script installed "${ORIG_ARGS[@]}"; else die "Only a node has a key."; fi ;;
      backup) cmd_backup ;;
    esac ;;
esac
