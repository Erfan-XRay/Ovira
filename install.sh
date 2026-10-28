#!/usr/bin/env bash
# Ovira: installer and management tool for Debian, Ubuntu, AlmaLinux, Rocky and CentOS Stream.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
#
# On a new server it asks what to install. On a server that already has Ovira
# it opens a menu. After installing, the same menu is the "ovira" command:
#
#   ovira                 menu
#   ovira status          what is running, versions, address, license
#   ovira update          install the newest release
#   ovira password        set a new password for a panel admin
#   ovira license         license and machine ID
#   ovira ssl             HTTPS certificate for the panel
#   ovira openvpn enable  also run OpenVPN servers on the panel's own server
#   ovira logs [-f]       show (or follow) the log
#   ovira backup          save the database and settings to one file
#   ovira restart|start|stop
#   ovira uninstall
#
# Everything the questions ask can be given as options instead:
#
#   panel | node            what to install (default: panel)
#   --panel-only            the panel only manages nodes; no OpenVPN on this server
#   --with-openvpn          the panel's own server runs OpenVPN too (default)
#   --port 2053             panel port (node: 62060)
#   --udp-port 1194         OpenVPN UDP port
#   --tcp-port 443          OpenVPN TCP port (started only with --tcp)
#   --tcp                   start the TCP server too
#   --ssl domain|ip|none    HTTPS with a Let's Encrypt certificate, or plain HTTP
#   --domain panel.example.com   --email you@example.com
#   --user admin            name of the first admin
#   --panel-ip IP           node only: accept calls from this panel address only
#   --beta                  use the newest beta instead of the stable release
#   --binary ./ovira-linux-amd64   use a local build instead of downloading
#   --yes                   do not ask; use the options and defaults
#   --purge                 with uninstall: delete data too
#
# Old forms still work: --node, --uninstall, --uninstall --node.
# Rerunning the installer updates an existing installation; tunnels on nodes stay up.
set -euo pipefail
# The binary asks this script to run its own commands; it must not call back.
export OVIRA_MANAGE=1

REPO="Erfan-XRay/Ovira"
MIRROR="https://ovpn.rapcity.shop/api/v1/releases"
RAW="https://raw.githubusercontent.com/$REPO/main/install.sh"
# Release signing key (Ed25519, SPKI DER in base64): every download is checked against it.
RELEASE_PUB="MCowBQYDK2VwAyEAO10TTvbUiBU7HOoYjVzZZzs76CjNFul7HkdkhWFSFgw="

CMD=""
ARGS=()
PORT=""
UDP_PORT=""
TCP_PORT=""
TCP_ON=""
SSL=""
DOMAIN=""
EMAIL=""
PANEL_IP=""
BINARY=""
OPENVPN_HERE=""
BETA=0
YES=0
PURGE=0
FOLLOW=0
FORCE=0
ADMIN_USER="admin"

# Installations from before the product was renamed keep their old file and
# unit names, so an update never moves anything; new ones use "ovira".
SLUG=ovira
if [[ -e /usr/local/bin/burrow || -d /etc/burrow || -d /etc/burrow-node ]]; then SLUG=burrow; fi
CONFIG=/etc/$SLUG/config.json
DATA=/var/lib/$SLUG
NCONFIG=/etc/$SLUG-node/node.json
NDATA=/var/lib/$SLUG-node
BIN=/usr/local/bin/$SLUG
LIBDIR=/usr/local/lib/$SLUG
MANAGE=$LIBDIR/manage.sh
LOGFILE=/var/log/ovira-install.log

# ---------------------------------------------------------------- arguments

while [[ $# -gt 0 ]]; do
  case "$1" in
    panel|node|install|update|upgrade|uninstall|status|info|start|stop|restart|logs|password|passwd|license|ssl|openvpn|key|backup|menu|version|help)
      if [[ -z "$CMD" ]]; then CMD="$1"; else ARGS+=("$1"); fi; shift ;;
    --node) CMD=node; shift ;;
    --uninstall) UNINSTALL_FLAG=1; shift ;;
    --panel-only) OPENVPN_HERE=0; shift ;;
    --with-openvpn) OPENVPN_HERE=1; shift ;;
    --port) PORT="$2"; shift 2 ;;
    --udp-port) UDP_PORT="$2"; shift 2 ;;
    --tcp-port) TCP_PORT="$2"; shift 2 ;;
    --tcp) TCP_ON=1; shift ;;
    --ssl) SSL="$2"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    --email) EMAIL="$2"; shift 2 ;;
    --panel-ip) PANEL_IP="$2"; shift 2 ;;
    --binary) BINARY="$2"; shift 2 ;;
    --beta) BETA=1; shift ;;
    --yes|-y) YES=1; shift ;;
    --user|--username) ADMIN_USER="$2"; shift 2 ;;
    --purge) PURGE=1; shift ;;
    --force) FORCE=1; shift ;;
    -f|--follow) FOLLOW=1; shift ;;
    -h|--help) CMD=help; shift ;;
    -v|--version) CMD=version; shift ;;
    -*) echo "unknown option: $1 (see: ovira help)" >&2; exit 2 ;;
    *) if [[ -n "$CMD" ]]; then ARGS+=("$1"); else echo "unknown command: $1 (see: ovira help)" >&2; exit 2; fi; shift ;;
  esac
done
if [[ "${UNINSTALL_FLAG:-0}" == 1 ]]; then
  [[ "$CMD" == node ]] && NODE_UNINSTALL=1
  CMD=uninstall
fi
NODE_UNINSTALL=${NODE_UNINSTALL:-0}

# ----------------------------------------------------------------- look & feel

UTF=0
case "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" in *[Uu][Tt][Ff]-8*|*[Uu][Tt][Ff]8*) UTF=1 ;; esac
if [[ -t 1 && -z "${NO_COLOR:-}" ]]; then
  if [[ "${COLORTERM:-}" == *truecolor* || "${COLORTERM:-}" == *24bit* ]]; then ACC=$'\033[38;2;196;248;42m'; else ACC=$'\033[1;33m'; fi
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[1;31m'; GRN=$'\033[1;32m'; YEL=$'\033[1;33m'; RST=$'\033[0m'
else
  ACC=""; BOLD=""; DIM=""; RED=""; GRN=""; YEL=""; RST=""
fi
if [[ $UTF -eq 1 ]]; then OKM="✓"; ERM="✗"; DOT="●"; ARR="›"; HR="─"; else OKM="+"; ERM="x"; DOT="*"; ARR=">"; HR="-"; fi

ok()    { printf '  %s%s%s %s\n' "$GRN" "$OKM" "$RST" "$*"; }
err()   { printf '  %s%s %s%s\n' "$RED" "$ERM" "$*" "$RST" >&2; }
warn()  { printf '  %s!%s %s\n' "$YEL" "$RST" "$*"; }
info()  { printf '  %s%s%s %s\n' "$DIM" "$ARR" "$RST" "$*"; }
die()   { err "$*"; exit 1; }
rule()  { local n=${1:-46} s=""; for ((i = 0; i < n; i++)); do s="$s$HR"; done; printf '  %s%s%s\n' "$DIM" "$s" "$RST"; }

banner() {
  echo
  printf '  %s%sOVIRA%s  %sOpenVPN panel%s\n' "$ACC" "$BOLD" "$RST" "$DIM" "$RST"
  rule
}

# Questions go to the terminal even when the script itself arrives on stdin.
TTY=""
if [[ $YES -eq 0 && -r /dev/tty && -w /dev/tty ]] && { : < /dev/tty; } 2>/dev/null; then TTY=/dev/tty; fi
ask() { # ask VAR "question" default
  local __v=$1 __q=$2 __def=$3 __ans=""
  if [[ -n "$TTY" ]]; then
    printf '  %s%s%s %s %s[%s]%s: ' "$ACC" "$ARR" "$RST" "$__q" "$DIM" "$__def" "$RST" > "$TTY"
    IFS= read -r __ans < "$TTY" || true
  fi
  printf -v "$__v" '%s' "${__ans:-$__def}"
}
yesno() { # yesno "question" default(y|n) -> 0 for yes
  local a
  ask a "$1 (y/n)" "$2"
  [[ "$a" =~ ^[Yy] ]]
}
pause() { [[ -n "$TTY" ]] && { printf '\n  %sPress Enter to go back...%s' "$DIM" "$RST" > "$TTY"; IFS= read -r _ < "$TTY" || true; }; return 0; }

spin_wait() { # spin_wait PID "message"
  local pid=$1 msg=$2 i=0 f
  if [[ $UTF -eq 1 ]]; then f=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏); else f=('|' '/' '-' '\'); fi
  while kill -0 "$pid" 2>/dev/null; do
    printf '\r  %s%s%s %s' "$ACC" "${f[i % ${#f[@]}]}" "$RST" "$msg"
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

need_root() { [[ $EUID -eq 0 ]] || die "Run as root (sudo bash install.sh, or sudo ovira)."; }
need_systemd() { command -v systemctl >/dev/null || die "systemd is required."; }

tcp_busy() { ss -Hltn "sport = :$1" 2>/dev/null | grep -q .; }
udp_busy() { ss -Hlun "sport = :$1" 2>/dev/null | grep -q .; }
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

# --------------------------------------------------------------------- state

IS_PANEL=0; IS_NODE=0
[[ -f $CONFIG ]] && IS_PANEL=1
[[ -f $NCONFIG ]] && IS_NODE=1
# The binary starts this script as "ovira"; it knows its own path.
[[ -n "${OVIRA_BIN:-}" && -x "${OVIRA_BIN:-}" ]] && BIN=$OVIRA_BIN

svc_state() { # unit -> running|stopped|missing
  local u=$1
  if ! systemctl cat "$u" >/dev/null 2>&1; then echo missing
  elif systemctl is-active --quiet "$u"; then echo running
  else echo stopped; fi
}
installed_version() { [[ -x $BIN ]] && "$BIN" version 2>/dev/null | awk '{print $2}' || true; }
val() { local v=${1#*:}; printf "%s" "${v# }" | sed "s/^ *//"; }
panel_cmd() { OVIRA_CONFIG=$CONFIG "$BIN" "$@"; }
node_cmd() { OVIRA_NODE_CONFIG=$NCONFIG "$BIN" "$@"; }
local_on() { # does this server run OpenVPN for the panel?
  local out
  if out=$(panel_cmd openvpn status 2>/dev/null); then
    [[ "$out" == *": on"* ]]
  else # a binary from before the command existed: look at the units
    systemctl list-units --plain --no-legend "${SLUG}-ovpn@*" 2>/dev/null | grep -q running
  fi
}

# ------------------------------------------------------------ release download

latest_tag() { # newest release tag for the chosen channel, empty when unknown
  local t=""
  if [[ $BETA -eq 1 ]]; then
    t=$(curl -fsSL --max-time 15 "https://api.github.com/repos/$REPO/releases?per_page=10" 2>/dev/null | grep -m1 '"tag_name"' | cut -d'"' -f4 || true)
    [[ -n "$t" ]] || t=$(curl -fsSL --max-time 15 "$MIRROR?channel=beta" 2>/dev/null | grep -o '"tag":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
  else
    t=$(curl -fsSIL --max-time 15 -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest" 2>/dev/null | sed -n 's|.*/tag/||p' || true)
    [[ -n "$t" ]] || t=$(curl -fsSL --max-time 15 "$MIRROR?channel=stable" 2>/dev/null | grep -o '"tag":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
  fi
  printf '%s' "$t"
}

TMP=""
mktmp() { [[ -n "$TMP" ]] || { TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT; }; }

fetch() { # fetch NAME: an asset of the chosen release, from GitHub or the mirror
  curl -fsSL --retry 2 --max-time 300 -o "$TMP/$1" "$GH_BASE/$1" 2>/dev/null ||
    curl -fsSL --retry 2 --max-time 300 -o "$TMP/$1" "$MIRROR_BASE/$1"
}

verify_sums() { # the release signature, then the checksum of each given asset
  fetch SHA256SUMS && fetch SHA256SUMS.sig || return 1
  if openssl version 2>/dev/null | grep -qE "^OpenSSL [3-9]" && echo "$RELEASE_PUB" | base64 -d > "$TMP/pub.der" 2>/dev/null &&
     openssl pkey -pubin -inform DER -in "$TMP/pub.der" -out "$TMP/pub.pem" 2>/dev/null; then
    base64 -d "$TMP/SHA256SUMS.sig" > "$TMP/sig.bin"
    openssl pkeyutl -verify -pubin -inkey "$TMP/pub.pem" -rawin -in "$TMP/SHA256SUMS" -sigfile "$TMP/sig.bin" >/dev/null 2>&1 || {
      err "The release signature is not valid. Refusing to install."; return 1; }
    SIGNED=1
  else
    SIGNED=0
  fi
  local a
  for a in "$@"; do
    (cd "$TMP" && grep -E "[ *]$a\$" SHA256SUMS | sha256sum -c --status) || { err "$a does not match its checksum. Refusing to install."; return 1; }
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
    if [[ "${SIGNED:-0}" == 1 ]]; then ok "Signature verified"; else warn "OpenSSL 3 is not available here, so only the checksum was checked."; fi
    install -m 0755 "$TMP/ovira-linux-$goarch" "$BIN.new"
  fi
  "$BIN.new" version >/dev/null || { rm -f "$BIN.new"; die "The binary does not run on this machine."; }
}

place_binary() {
  mv -f "$BIN.new" "$BIN"
  # The docs call the command "ovira"; an older installation answers to both names.
  if [[ "$SLUG" == burrow ]]; then ln -sfn "$BIN" /usr/local/bin/ovira; fi
}

# install_manager: keeps this script as the "ovira" menu next to the binary.
install_manager() {
  mkdir -p "$LIBDIR"
  local new="$MANAGE.new"
  if [[ -f "$0" && -r "$0" && "$0" != "$MANAGE" && "$0" != /dev/fd/* && "$0" != /proc/* ]] && grep -q "Ovira: installer and management tool" "$0" 2>/dev/null; then
    install -m 0755 "$0" "$new"
  elif [[ -n "${TMP:-}" && -n "${GH_BASE:-}" ]] && fetch install.sh 2>/dev/null && verify_sums install.sh 2>/dev/null; then
    install -m 0755 "$TMP/install.sh" "$new"
  elif curl -fsSL --max-time 30 -o "$new" "$RAW" 2>/dev/null; then
    chmod 0755 "$new"
  else
    warn "Could not save the management menu; the ovira command will still work without it."
    return 0
  fi
  mv -f "$new" "$MANAGE"
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

# ----------------------------------------------------------------- unit files

write_panel_units() {
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
  systemctl daemon-reload
}

write_node_units() {
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
  systemctl daemon-reload
}

# ------------------------------------------------------------------- install

do_install_node() {
  need_root; need_systemd
  [[ $IS_PANEL -eq 1 && $IS_NODE -eq 0 ]] && warn "This server already runs an Ovira panel. A node is meant for another server."
  banner
  detect_os
  ensure_base_tools
  PORT=${PORT:-62060}
  valid_port "$PORT" || die "Not a port number: $PORT"
  if [[ $IS_NODE -eq 0 ]] && tcp_busy "$PORT"; then die "Port $PORT/tcp is already in use on this server. Pick a free one with --port."; fi
  ensure_openvpn
  get_binary
  place_binary
  ok "Installed $("$BIN" version)"
  enable_forwarding
  write_node_units
  install_manager

  if [[ $IS_NODE -eq 1 ]]; then
    systemctl restart "${SLUG}-node.service"   # OpenVPN instances keep running; only the agent restarts
    echo; ok "Ovira node updated. Tunnels stayed up."
    print_node_key
    return 0
  fi
  local public key
  public=$(public_ip)
  info "Public address: $public"
  mkdir -p "$NDATA"; chmod 711 "$NDATA"
  key=$(OVIRA_NODE_CONFIG=$NCONFIG "$BIN" node init -config "$NCONFIG" -data "$NDATA" -port "$PORT" -public-host "$public" -allow "$PANEL_IP")
  systemctl enable --now "${SLUG}-node.service" >/dev/null 2>&1
  open_port "$PORT/tcp"
  echo
  printf '  %s%sOvira node is running.%s\n' "$ACC" "$BOLD" "$RST"
  rule
  echo "  In the panel, open Nodes → Connect a node and paste this key:"
  echo
  printf '  %s%s%s\n' "$BOLD" "$key" "$RST"
  echo
  printf '  %-10s %s   %s(port %s/tcp must be reachable from the panel)%s\n' "Address" "$public" "$DIM" "$PORT" "$RST"
  if [[ -n "$PANEL_IP" ]]; then
    printf '  %-10s only calls from %s are accepted\n' "Security" "$PANEL_IP"
  else
    printf '  %-10s %sany address may call the node (it still needs the key). To limit it to your panel,%s\n' "Security" "$DIM" "$RST"
    printf '  %-10s %sreinstall with --panel-ip PANEL_IP.%s\n' "" "$DIM" "$RST"
  fi
  echo
  echo "  Manage this node any time with:  ovira   (menu)   ovira key   ovira update"
}

print_node_key() {
  echo
  printf '  %-10s %s\n' "Node key" "$(node_cmd node key -config "$NCONFIG")"
}

do_install_panel() {
  need_root; need_systemd
  [[ $IS_NODE -eq 1 && $IS_PANEL -eq 0 ]] && warn "This server already runs an Ovira node. A panel is usually installed on its own server."
  banner
  detect_os
  local update=$IS_PANEL

  if [[ $update -eq 0 ]]; then
    [[ -n "$TTY" ]] && { printf '  Press Enter to keep a default.\n\n' > "$TTY"; }
    [[ -n "$PORT" ]] || ask PORT "Panel port" 2053
    if [[ -z "$OPENVPN_HERE" ]]; then
      if [[ -n "$TTY" ]]; then
        printf '\n  %sOpenVPN on this server%s\n' "$BOLD" "$RST" > "$TTY"
        printf '  %s  yes: this server runs the panel and OpenVPN together (a single-server setup)%s\n' "$DIM" "$RST" > "$TTY"
        printf '  %s  no : an empty panel that only manages nodes; add them later under Nodes%s\n' "$DIM" "$RST" > "$TTY"
        printf '  %s  You can switch any time with: ovira openvpn enable%s\n\n' "$DIM" "$RST" > "$TTY"
      fi
      if yesno "Run OpenVPN on this server too?" y; then OPENVPN_HERE=1; else OPENVPN_HERE=0; fi
    fi
    if [[ "$OPENVPN_HERE" == 1 ]]; then
      [[ -n "$UDP_PORT" ]] || ask UDP_PORT "OpenVPN UDP port" 1194
      if [[ -z "$TCP_ON" ]]; then
        if yesno "Also run OpenVPN over TCP (for networks that block UDP)?" n; then TCP_ON=1; else TCP_ON=0; fi
      fi
      [[ -n "$TCP_PORT" ]] || { if [[ $TCP_ON -eq 1 ]]; then ask TCP_PORT "OpenVPN TCP port" 443; else TCP_PORT=443; fi; }
    else
      UDP_PORT=${UDP_PORT:-1194}; TCP_PORT=${TCP_PORT:-443}; TCP_ON=0
    fi
    if [[ -z "$SSL" ]]; then
      if [[ -n "$DOMAIN" ]]; then SSL=domain
      else
        if [[ -n "$TTY" ]]; then
          {
            printf '\n  %sHTTPS for the panel%s\n' "$BOLD" "$RST"
            echo "    1) Let's Encrypt certificate for a domain (the domain must point at this server)"
            echo "    2) Let's Encrypt certificate for this server's IP (no domain needed)"
            echo "    3) none: plain HTTP"
          } > "$TTY"
        fi
        ask a "Choose 1, 2 or 3" 2
        case "$a" in 1) SSL=domain ;; 3) SSL=none ;; *) SSL=ip ;; esac
      fi
    fi
    if [[ "$SSL" == domain && -z "$DOMAIN" ]]; then ask DOMAIN "Domain for the panel (e.g. panel.example.com)" ""; fi
    if [[ "$SSL" != none && -z "$EMAIL" ]]; then ask EMAIL "Email for certificate notices (optional)" ""; fi
    [[ "$SSL" == domain && -z "$DOMAIN" ]] && die "A domain is required for --ssl domain."
    OPENVPN_HERE=${OPENVPN_HERE:-1}; TCP_ON=${TCP_ON:-0}
    local p
    for p in "$PORT" "$UDP_PORT" "$TCP_PORT"; do valid_port "$p" || die "Not a port number: $p"; done
    tcp_busy "$PORT" && die "Port $PORT/tcp is already in use; choose another panel port with --port."
    if [[ "$OPENVPN_HERE" == 1 ]]; then
      udp_busy "$UDP_PORT" && die "Port $UDP_PORT/udp is already in use; choose another with --udp-port."
      if [[ $TCP_ON -eq 1 ]] && tcp_busy "$TCP_PORT"; then die "Port $TCP_PORT/tcp is already in use; choose another with --tcp-port."; fi
    fi
    echo
  else
    OPENVPN_HERE=0; local_on && OPENVPN_HERE=1
  fi

  if [[ "$OPENVPN_HERE" == 1 ]]; then ensure_openvpn; else ensure_base_tools; fi
  get_binary
  place_binary
  ok "Installed $("$BIN" version)"
  [[ "$OPENVPN_HERE" == 1 ]] && enable_forwarding
  write_panel_units
  install_manager

  if [[ $update -eq 1 ]]; then
    # The panel restarts OpenVPN servers whose config the new version changes.
    systemctl restart "${SLUG}.service"
    echo; ok "Ovira updated."
    print_panel_summary
    return 0
  fi

  local public pubhost out pass base scheme host
  public=$(public_ip)
  info "Public address: $public"
  mkdir -p "/etc/$SLUG" "$DATA"
  chmod 711 "$DATA"  # OpenVPN (as nobody) must reach pki/crl.pem
  local tcp_flag=""; [[ $TCP_ON -eq 1 ]] && tcp_flag="-tcp"
  local local_flag="-local=true"; [[ "$OPENVPN_HERE" == 1 ]] || local_flag="-local=false"
  pubhost=$public; [[ "$SSL" == domain ]] && pubhost=$DOMAIN
  out=$(OVIRA_CONFIG=$CONFIG "$BIN" init -config "$CONFIG" -data "$DATA" -port "$PORT" -public-host "$pubhost" -username "$ADMIN_USER" \
    -udp-port "$UDP_PORT" -tcp-port "$TCP_PORT" $tcp_flag $local_flag)
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
  if [[ "$OPENVPN_HERE" == 1 ]]; then
    systemctl enable --now "${SLUG}-ovpn@udp$UDP_PORT.service" >/dev/null 2>&1 || warn "OpenVPN did not start; check: journalctl -u ${SLUG}-ovpn@udp$UDP_PORT"
    [[ $TCP_ON -eq 1 ]] && { systemctl enable --now "${SLUG}-ovpn@tcp$TCP_PORT.service" >/dev/null 2>&1 || true; }
    open_port "$UDP_PORT/udp" nat
    [[ $TCP_ON -eq 1 ]] && open_port "$TCP_PORT/tcp" nat
  fi

  echo
  printf '  %s%sOvira is running.%s\n' "$ACC" "$BOLD" "$RST"
  rule
  printf '  %-10s %s%s://%s:%s%s%s\n' "Panel" "$BOLD" "$scheme" "$host" "$PORT" "$base" "$RST"
  printf '  %-10s %s\n' "Username" "$ADMIN_USER"
  printf '  %-10s %s%s%s\n' "Password" "$BOLD" "$pass" "$RST"
  if [[ "$OPENVPN_HERE" == 1 ]]; then
    printf '  %-10s udp/%s%s on this server\n' "OpenVPN" "$UDP_PORT" "$([[ $TCP_ON -eq 1 ]] && echo ", tcp/$TCP_PORT")"
  else
    printf '  %-10s %spanel only: open Nodes in the panel to connect a server (or run: ovira openvpn enable)%s\n' "OpenVPN" "$DIM" "$RST"
  fi
  echo
  echo "  Keep the panel path secret: everything else on that port answers 404."
  echo "  Change the password and turn on two-factor sign-in under Settings → My account."
  echo "  Free plan: 5 active clients and 2 nodes. Upgrade any time under License."
  echo
  printf '  %sManage it any time:%s  ovira  (menu)   ovira status   ovira update   ovira password   ovira logs\n' "$BOLD" "$RST"
}

print_panel_summary() {
  panel_cmd info 2>/dev/null | sed 's/^/  /' || true
}

# ------------------------------------------------------------------ uninstall

do_uninstall() {
  need_root; need_systemd
  local what="the panel"; local node=$NODE_UNINSTALL
  if [[ $node -eq 0 && $IS_PANEL -eq 0 && $IS_NODE -eq 1 ]]; then node=1; fi
  [[ $node -eq 1 ]] && what="the node"
  if [[ $YES -eq 0 && -n "$TTY" ]]; then
    banner
    printf '  This removes %s from this server.\n' "$what"
    [[ $PURGE -eq 1 ]] && printf '  %sIts data (clients, keys, certificates) will be deleted too.%s\n' "$RED" "$RST" || printf '  Its data stays on disk, so installing again picks up where you left off.\n'
    yesno "Remove $what?" n || { info "Nothing was changed."; return 0; }
  fi
  if [[ $node -eq 1 ]]; then
    run "Stopping node services" bash -c "for u in \$(systemctl list-units --all --plain --no-legend '${SLUG}-node-ovpn@*' | awk '{print \$1}'); do systemctl disable --now \"\$u\" || true; done; systemctl disable --now ${SLUG}-node.service 2>/dev/null || true"
    rm -f "/etc/systemd/system/${SLUG}-node.service" "/etc/systemd/system/${SLUG}-node-ovpn@.service"
    if [[ ! -f /etc/systemd/system/${SLUG}.service ]]; then rm -f "$BIN" /usr/local/bin/ovira "/etc/sysctl.d/99-$SLUG.conf"; rm -rf "$LIBDIR"; fi
    systemctl daemon-reload
    if [[ $PURGE -eq 1 ]]; then rm -rf "/etc/${SLUG:?}-node" "${NDATA:?}"; ok "Ovira node removed, including its data and key."
    else ok "Ovira node removed. Data kept in $NDATA and /etc/$SLUG-node (use --purge to delete)."; fi
  else
    run "Stopping services" bash -c "for u in \$(systemctl list-units --all --plain --no-legend '${SLUG}-ovpn@*' | awk '{print \$1}'); do systemctl disable --now \"\$u\" || true; done; systemctl disable --now ${SLUG}.service 2>/dev/null || true"
    rm -f "/etc/systemd/system/${SLUG}.service" "/etc/systemd/system/${SLUG}-ovpn@.service"
    if [[ ! -f /etc/systemd/system/${SLUG}-node.service ]]; then rm -f "$BIN" /usr/local/bin/ovira "/etc/sysctl.d/99-$SLUG.conf"; rm -rf "$LIBDIR"; fi
    systemctl daemon-reload
    if [[ $PURGE -eq 1 ]]; then rm -rf "/etc/${SLUG:?}" "${DATA:?}"; ok "Ovira removed, including all data."
    else ok "Ovira removed. Data kept in $DATA and /etc/$SLUG (use --purge to delete)."; fi
  fi
}

# ------------------------------------------------------------------ management

require_installed() {
  [[ $IS_PANEL -eq 1 || $IS_NODE -eq 1 ]] || die "Ovira is not installed here. Run this script without options to install it."
  [[ -x $BIN ]] || die "The Ovira program is missing ($BIN)."
}
main_unit() { if [[ $IS_PANEL -eq 1 ]]; then echo "$SLUG.service"; else echo "$SLUG-node.service"; fi; }

cmd_status() {
  require_installed
  banner
  local v unit st kind
  v=$(installed_version); unit=$(main_unit); st=$(svc_state "$unit")
  [[ $IS_PANEL -eq 1 ]] && kind="Panel" || kind="Node"
  local mark="$GRN$DOT$RST"; [[ "$st" == running ]] || mark="$RED$DOT$RST"
  printf '  %-10s %s%s%s  %s %s\n' "$kind" "$BOLD" "Ovira ${v:-?}" "$RST" "$mark" "$st"
  if [[ $IS_PANEL -eq 1 ]]; then
    local line
    while IFS= read -r line; do
      case "$line" in
        panel:*) printf '  %-10s %s\n' "Address" "$(val "$line")" ;;
        machine*) printf '  %-10s %s\n' "Machine ID" "$(val "$line")" ;;
        license:*) printf '  %-10s %s\n' "License" "$(val "$line")" ;;
      esac
    done < <(panel_cmd info 2>/dev/null || true)
    if local_on; then
      printf '  %-10s on this server\n' "OpenVPN"
      local u
      while read -r u; do [[ -n "$u" ]] && printf '  %-10s %s %s\n' "" "${u%.service}" "$(svc_state "$u")"; done < <(systemctl list-units --all --plain --no-legend "${SLUG}-ovpn@*" | awk '{print $1}')
    else
      printf '  %-10s %spanel only; add servers under Nodes, or: ovira openvpn enable%s\n' "OpenVPN" "$DIM" "$RST"
    fi
  else
    printf '  %-10s %s\n' "Node key" "$(node_cmd node key -config "$NCONFIG" 2>/dev/null || echo unknown)"
  fi
  local latest; latest=$(TAG="" latest_tag 2>/dev/null || true)
  if [[ -n "$latest" && -n "$v" && "$latest" != "v$v" ]]; then
    echo; printf '  %sUpdate available: %s%s   (run: ovira update)\n' "$ACC" "$latest" "$RST"
  fi
  echo
}

cmd_info() {
  require_installed
  if [[ $IS_PANEL -eq 1 ]]; then panel_cmd info; else printf 'node key: %s\n' "$(node_cmd node key -config "$NCONFIG")"; fi
}

cmd_service() { # start|stop|restart
  require_installed; need_root
  local unit; unit=$(main_unit)
  local verb; case "$1" in start) verb=Starting ;; stop) verb=Stopping ;; *) verb=Restarting ;; esac
  run "$verb ${unit%.service}" systemctl "$1" "$unit" || return 1
}

cmd_logs() {
  require_installed
  local unit; unit=$(main_unit)
  local target=${ARGS[0]:-}
  if [[ -n "$target" ]]; then unit="$SLUG-ovpn@$target.service"; fi
  if [[ $FOLLOW -eq 1 ]]; then journalctl -u "$unit" -n 50 -f --no-pager; else journalctl -u "$unit" -n 100 --no-pager; fi
}

cmd_update() {
  require_installed; need_root
  local cur latest; cur=$(installed_version)
  latest=$(latest_tag)
  if [[ -n "$latest" && "$latest" == "v$cur" && $FORCE -eq 0 && -z "$BINARY" ]]; then
    banner
    ok "Ovira $cur is the newest release."
    mktmp; [[ -f "$MANAGE" ]] || install_manager
    return 0
  fi
  [[ -n "$latest" ]] && info "Installed $cur → $latest"
  TAG=$latest
  if [[ $IS_PANEL -eq 1 ]]; then do_install_panel; else do_install_node; fi
}

cmd_password() {
  require_installed; need_root
  [[ $IS_PANEL -eq 1 ]] || die "Admin passwords belong to the panel; this is a node."
  banner
  printf '  Panel admins:\n'
  panel_cmd admin list 2>/dev/null | sed 's/^/    /'
  echo
  local user pw
  user=${ARGS[0]:-}
  if [[ -z "$user" ]]; then ask user "Which admin?" "$ADMIN_USER"; fi
  ask pw "New password (Enter = make a strong random one)" ""
  local out
  if [[ -n "$pw" ]]; then
    out=$(panel_cmd admin passwd -username "$user" -password "$pw") || { err "$out"; return 1; }
  else
    out=$(panel_cmd admin passwd -username "$user") || { err "$out"; return 1; }
  fi
  echo
  ok "Password changed. Other sessions of $user were signed out."
  printf '  %-10s %s\n  %-10s %s%s%s\n' "Username" "$user" "Password" "$BOLD" "$(echo "$out" | awk -F': *' '/^password/ {print $2}')" "$RST"
}

cmd_license() {
  require_installed
  [[ $IS_PANEL -eq 1 ]] || die "The license belongs to the panel; this is a node."
  banner
  local line
  while IFS= read -r line; do
    case "$line" in
      machine*) printf '  %-10s %s\n' "Machine ID" "$(val "$line")" ;;
      license:*) printf '  %-10s %s\n' "License" "$(val "$line")" ;;
    esac
  done < <(panel_cmd info 2>/dev/null || true)
  echo
  info "Activate or change the license in the panel under License; it asks for the machine ID above."
}

cmd_ssl() {
  require_installed; need_root
  [[ $IS_PANEL -eq 1 ]] || die "HTTPS belongs to the panel; this is a node."
  local sub=${ARGS[0]:-}
  if [[ -z "$sub" && -n "$TTY" ]]; then
    banner
    panel_cmd ssl status 2>/dev/null | sed 's/^/  /' || true
    echo
    printf '    1) Certificate for a domain\n    2) Certificate for this server'"'"'s IP\n    3) Turn HTTPS off (plain HTTP)\n    0) Back\n\n' > "$TTY"
    local a; ask a "Choose" 0
    case "$a" in
      1) sub=domain ;; 2) sub=ip ;; 3) sub=off ;; *) return 0 ;;
    esac
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
  [[ $IS_PANEL -eq 1 ]] || die "This is a node; it already runs OpenVPN for its panel."
  local sub=${ARGS[0]:-status}
  case "$sub" in
    status) panel_cmd openvpn status ;;
    enable)
      banner
      detect_os
      [[ -n "$UDP_PORT" ]] || ask UDP_PORT "OpenVPN UDP port" 1194
      valid_port "$UDP_PORT" || die "Not a port number: $UDP_PORT"
      ensure_openvpn
      enable_forwarding
      write_panel_units
      local tcp=""; [[ $TCP_ON -eq 1 ]] && tcp="-tcp"
      [[ -n "$TCP_PORT" ]] || TCP_PORT=443
      OVIRA_MANAGE=1 panel_cmd openvpn enable -udp-port "$UDP_PORT" -tcp-port "$TCP_PORT" $tcp
      run "Restarting the panel" systemctl restart "$SLUG.service"
      open_port "$UDP_PORT/udp" nat
      [[ $TCP_ON -eq 1 ]] && open_port "$TCP_PORT/tcp" nat
      ok "This server now runs OpenVPN too (udp/$UDP_PORT). See Servers in the panel." ;;
    disable)
      if [[ $YES -eq 0 && -n "$TTY" ]]; then yesno "Stop OpenVPN on this server? Clients connected here are disconnected." n || return 0; fi
      OVIRA_MANAGE=1 panel_cmd openvpn disable
      run "Restarting the panel" systemctl restart "$SLUG.service"
      ok "OpenVPN is off here. The panel and its nodes keep working." ;;
    *) die "Use: ovira openvpn enable|disable|status" ;;
  esac
}

cmd_key() {
  require_installed
  [[ $IS_NODE -eq 1 ]] || die "Only a node has a key."
  printf '%s\n' "$(node_cmd node key -config "$NCONFIG")"
}

cmd_backup() {
  require_installed; need_root
  [[ $IS_PANEL -eq 1 ]] || die "Backups are for the panel; a node keeps no client data."
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
  ok "Backup saved: $out"
  info "It holds the client list, keys and settings. Keep it private."
}

cmd_help() {
  cat <<'HELP'

  Ovira: installer and management tool

    ovira                 menu
    ovira status          what is running, versions, address, license
    ovira update          install the newest release (--beta for the beta channel)
    ovira password [USER] set a new password for a panel admin
    ovira license         license and machine ID
    ovira ssl             HTTPS certificate for the panel
    ovira openvpn enable  also run OpenVPN servers on the panel's own server
    ovira openvpn disable | status
    ovira logs [-f]       show (or follow) the log
    ovira backup [FILE]   save the database and settings to one file
    ovira key             show a node's key
    ovira start|stop|restart
    ovira uninstall [--purge]

  Install on a new server:

    bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) [panel|node] [options]

  Options: --panel-only  --with-openvpn  --port N  --udp-port N  --tcp-port N  --tcp
           --ssl domain|ip|none  --domain D  --email E  --user NAME  --panel-ip IP
           --beta  --binary FILE  --yes

HELP
}

# ------------------------------------------------------------------------ menu

menu_header() {
  clear 2>/dev/null || true
  banner
  local v unit st mark
  v=$(installed_version); unit=$(main_unit); st=$(svc_state "$unit")
  mark="$GRN$DOT$RST"; [[ "$st" == running ]] || mark="$RED$DOT$RST"
  printf '  %s  %s%s%s %s%s%s   %s\n' "$mark" "$BOLD" "Ovira ${v:-?}" "$RST" "$DIM" "$([[ $IS_PANEL -eq 1 ]] && echo panel || echo node)" "$RST" "$st"
  if [[ $IS_PANEL -eq 1 ]]; then
    local addr; addr=$(panel_cmd info 2>/dev/null | sed -n 's/^panel: *//p' || true)
    [[ -n "$addr" ]] && printf '  %s%s%s\n' "$DIM" "$addr" "$RST"
  fi
  echo
}

menu_item() { printf '    %s%2s%s  %s\n' "$ACC" "$1" "$RST" "$2"; }

main_menu() {
  [[ -n "$TTY" ]] || { cmd_status; return; }
  while true; do
    menu_header
    if [[ $IS_PANEL -eq 1 ]]; then
      menu_item 1 "Status and address"
      menu_item 2 "Update"
      menu_item 3 "Restart the panel"
      menu_item 4 "Show the log"
      menu_item 5 "Change an admin password"
      menu_item 6 "License and machine ID"
      menu_item 7 "HTTPS certificate"
      if local_on; then menu_item 8 "OpenVPN on this server: on  (turn off)"; else menu_item 8 "OpenVPN on this server: off  (turn on)"; fi
      menu_item 9 "Back up the database"
      menu_item 10 "Uninstall"
    else
      menu_item 1 "Status and node key"
      menu_item 2 "Update"
      menu_item 3 "Restart the node"
      menu_item 4 "Show the log"
      menu_item 5 "Show the node key"
      menu_item 10 "Uninstall"
    fi
    menu_item 0 "Exit"
    echo
    local a; ask a "Choose" 0
    echo
    case "$a" in
      1) cmd_status; pause ;;
      2) cmd_update || true; pause ;;
      3) cmd_service restart || true; pause ;;
      4) cmd_logs || true; pause ;;
      5) if [[ $IS_PANEL -eq 1 ]]; then cmd_password || true; else cmd_key || true; fi; pause ;;
      6) [[ $IS_PANEL -eq 1 ]] && { cmd_license || true; pause; } ;;
      7) [[ $IS_PANEL -eq 1 ]] && { ARGS=(); cmd_ssl || true; pause; } ;;
      8) if [[ $IS_PANEL -eq 1 ]]; then if local_on; then ARGS=(disable); else ARGS=(enable); fi; cmd_openvpn || true; pause; fi ;;
      9) [[ $IS_PANEL -eq 1 ]] && { ARGS=(); cmd_backup || true; pause; } ;;
      10) cmd_uninstall_menu; ;;
      0|q|Q|"") return 0 ;;
    esac
  done
}
cmd_uninstall_menu() {
  do_uninstall || true
  pause
  if [[ ! -f $CONFIG && ! -f $NCONFIG ]]; then exit 0; fi
  return 0
}

# ------------------------------------------------------------- first-run chooser

choose_component() {
  banner
  if [[ -n "$TTY" ]]; then
    printf '  What do you want to install on this server?\n\n' > "$TTY"
    printf '    %s1%s  Panel   %sthe web panel that manages everything (recommended)%s\n' "$ACC" "$RST" "$DIM" "$RST" > "$TTY"
    printf '    %s2%s  Node    %san extra OpenVPN server controlled by a panel on another server%s\n\n' "$ACC" "$RST" "$DIM" "$RST" > "$TTY"
    local a; ask a "Choose 1 or 2" 1
    case "$a" in 2) CMD=node ;; *) CMD=panel ;; esac
  else
    CMD=panel
  fi
}

# ------------------------------------------------------------------------ main

case "$CMD" in
  help) cmd_help; exit 0 ;;
  version) if [[ -x $BIN ]]; then "$BIN" version; else echo "ovira (not installed)"; fi; exit 0 ;;
esac

need_root
case "$CMD" in
  status) cmd_status ;;
  info) cmd_info ;;
  start|stop|restart) cmd_service "$CMD" ;;
  logs) cmd_logs ;;
  update|upgrade) cmd_update ;;
  password|passwd) cmd_password ;;
  license) cmd_license ;;
  ssl) cmd_ssl ;;
  openvpn) cmd_openvpn ;;
  key) cmd_key ;;
  backup) cmd_backup ;;
  uninstall) do_uninstall ;;
  node) do_install_node ;;
  panel) do_install_panel ;;
  install)
    if [[ "${ARGS[0]:-}" == node ]]; then do_install_node
    elif [[ $IS_PANEL -eq 1 ]]; then do_install_panel
    elif [[ $IS_NODE -eq 1 ]]; then do_install_node
    else choose_component; if [[ $CMD == node ]]; then do_install_node; else do_install_panel; fi; fi ;;
  menu|"")
    need_root
    if [[ $IS_PANEL -eq 1 || $IS_NODE -eq 1 ]]; then
      # An installation from before the menu existed gets it now.
      [[ -f "$MANAGE" ]] || { mktmp; install_manager 2>/dev/null || true; }
      main_menu
    else
      choose_component
      if [[ $CMD == node ]]; then do_install_node; else do_install_panel; fi
    fi ;;
esac
