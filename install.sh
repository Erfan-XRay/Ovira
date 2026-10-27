#!/usr/bin/env bash
# Burrow installer for Debian, Ubuntu, AlmaLinux, Rocky and CentOS Stream.
#
#   bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Burrow/main/install.sh)
#
# Run without options it asks for the panel port, the OpenVPN ports and how
# the panel gets HTTPS. Everything can be given as options instead:
#
#   --port 2053             panel port
#   --udp-port 1194         OpenVPN UDP port
#   --tcp-port 443          OpenVPN TCP port (the TCP server starts only with --tcp)
#   --tcp                   start the TCP server too
#   --ssl domain|ip|none    HTTPS with a Let's Encrypt certificate for a domain
#                           or for the server's IP, or plain HTTP
#   --domain panel.example.com   --email you@example.com
#   --beta                  install the latest beta instead of the stable release
#   --binary ./burrow-linux-amd64   use a local build instead of downloading
#   --yes                   do not ask; use the options and defaults
#   --uninstall [--purge]   remove Burrow (data is kept unless --purge)
#
# Node mode (an extra server run by a panel elsewhere):
#   --node [--port 62060] [--panel-ip PANEL_IP]
#   --node --uninstall [--purge]
#
# Rerunning the script updates an existing installation; tunnels on nodes stay up.
set -euo pipefail

REPO="Erfan-XRay/Burrow"
MIRROR="https://ovpn.rapcity.shop/api/v1/releases"
# Release signing key (Ed25519, SPKI DER in base64): every download is checked against it.
RELEASE_PUB="MCowBQYDK2VwAyEAO10TTvbUiBU7HOoYjVzZZzs76CjNFul7HkdkhWFSFgw="

PORT=""
UDP_PORT=""
TCP_PORT=""
TCP_ON=""
SSL=""
DOMAIN=""
EMAIL=""
NODE=0
PANEL_IP=""
BINARY=""
BETA=0
YES=0
UNINSTALL=0
PURGE=0
ADMIN_USER="admin"
CONFIG=/etc/burrow/config.json
DATA=/var/lib/burrow
NCONFIG=/etc/burrow-node/node.json
NDATA=/var/lib/burrow-node
BIN=/usr/local/bin/burrow

while [[ $# -gt 0 ]]; do
  case "$1" in
    --port) PORT="$2"; shift 2 ;;
    --udp-port) UDP_PORT="$2"; shift 2 ;;
    --tcp-port) TCP_PORT="$2"; shift 2 ;;
    --tcp) TCP_ON=1; shift ;;
    --ssl) SSL="$2"; shift 2 ;;
    --domain) DOMAIN="$2"; shift 2 ;;
    --email) EMAIL="$2"; shift 2 ;;
    --node) NODE=1; shift ;;
    --panel-ip) PANEL_IP="$2"; shift 2 ;;
    --binary) BINARY="$2"; shift 2 ;;
    --beta) BETA=1; shift ;;
    --yes|-y) YES=1; shift ;;
    --user) ADMIN_USER="$2"; shift 2 ;;
    --uninstall) UNINSTALL=1; shift ;;
    --purge) PURGE=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done

c_ok() { printf '\033[1;33m%s\033[0m\n' "$*"; }
c_err() { printf '\033[1;31m%s\033[0m\n' "$*" >&2; }
step() { printf '\033[2m->\033[0m %s\n' "$*"; }

[[ $EUID -eq 0 ]] || { c_err "Run as root (sudo bash install.sh)."; exit 1; }
command -v systemctl >/dev/null || { c_err "systemd is required."; exit 1; }

# Questions go to the terminal even when the script itself arrives on stdin.
TTY=""
if [[ $YES -eq 0 && -r /dev/tty && -w /dev/tty ]]; then TTY=/dev/tty; fi
ask() { # ask VAR "question" default
  local __v=$1 q=$2 def=$3 a=""
  if [[ -n "$TTY" ]]; then
    printf '%s [%s]: ' "$q" "$def" > "$TTY"
    IFS= read -r a < "$TTY" || true
  fi
  printf -v "$__v" '%s' "${a:-$def}"
}

tcp_busy() { ss -Hltn "sport = :$1" 2>/dev/null | grep -q .; }
udp_busy() { ss -Hlun "sport = :$1" 2>/dev/null | grep -q .; }
valid_port() { [[ "$1" =~ ^[0-9]+$ ]] && (( $1 >= 1 && $1 <= 65535 )); }

# ---- uninstall ----
if [[ $UNINSTALL -eq 1 ]]; then
  if [[ $NODE -eq 1 ]]; then
    step "stopping node services"
    for unit in $(systemctl list-units --all --plain --no-legend 'burrow-node-ovpn@*' | awk '{print $1}'); do
      systemctl disable --now "$unit" || true
    done
    systemctl disable --now burrow-node.service 2>/dev/null || true
    rm -f /etc/systemd/system/burrow-node.service /etc/systemd/system/burrow-node-ovpn@.service
    [[ -f /etc/systemd/system/burrow.service ]] || rm -f "$BIN" /etc/sysctl.d/99-burrow.conf
    systemctl daemon-reload
    if [[ $PURGE -eq 1 ]]; then rm -rf /etc/burrow-node "$NDATA"; c_ok "Burrow node removed, including its data and key."
    else c_ok "Burrow node removed. Data kept in $NDATA and /etc/burrow-node (use --purge to delete)."; fi
  else
    step "stopping services"
    for unit in $(systemctl list-units --all --plain --no-legend 'burrow-ovpn@*' | awk '{print $1}'); do
      systemctl disable --now "$unit" || true
    done
    systemctl disable --now burrow.service 2>/dev/null || true
    rm -f /etc/systemd/system/burrow.service /etc/systemd/system/burrow-ovpn@.service
    [[ -f /etc/systemd/system/burrow-node.service ]] || rm -f "$BIN" /etc/sysctl.d/99-burrow.conf
    systemctl daemon-reload
    if [[ $PURGE -eq 1 ]]; then rm -rf /etc/burrow "$DATA"; c_ok "Burrow removed, including all data."
    else c_ok "Burrow removed. Data kept in $DATA and /etc/burrow (use --purge to delete)."; fi
  fi
  exit 0
fi

UPDATE=0
if [[ $NODE -eq 1 ]]; then [[ -f $NCONFIG ]] && UPDATE=1; else [[ -f $CONFIG ]] && UPDATE=1; fi

# ---- questions (first install only) ----
if [[ $UPDATE -eq 0 && $NODE -eq 0 ]]; then
  [[ -n "$TTY" ]] && { echo > "$TTY"; c_ok "Burrow setup" > "$TTY"; echo "Press Enter to keep a default." > "$TTY"; }
  [[ -n "$PORT" ]] || ask PORT "Panel port" 2053
  [[ -n "$UDP_PORT" ]] || ask UDP_PORT "OpenVPN UDP port" 1194
  if [[ -z "$TCP_ON" ]]; then
    ask a "Also run OpenVPN over TCP (for networks that block UDP)? y/n" n
    [[ "$a" =~ ^[Yy] ]] && TCP_ON=1 || TCP_ON=0
  fi
  [[ -n "$TCP_PORT" ]] || { if [[ $TCP_ON -eq 1 ]]; then ask TCP_PORT "OpenVPN TCP port" 443; else TCP_PORT=443; fi; }
  if [[ -z "$SSL" ]]; then
    if [[ -n "$DOMAIN" ]]; then SSL=domain
    else
      if [[ -n "$TTY" ]]; then
        {
          echo "HTTPS for the panel:"
          echo "  1) Let's Encrypt certificate for a domain (the domain must point at this server)"
          echo "  2) Let's Encrypt certificate for this server's IP (no domain needed)"
          echo "  3) none: plain HTTP"
        } > "$TTY"
      fi
      ask a "Choose 1, 2 or 3" 2
      case "$a" in 1) SSL=domain ;; 3) SSL=none ;; *) SSL=ip ;; esac
    fi
  fi
  if [[ "$SSL" == domain && -z "$DOMAIN" ]]; then ask DOMAIN "Domain for the panel (e.g. panel.example.com)" ""; fi
  if [[ "$SSL" != none && -z "$EMAIL" ]]; then ask EMAIL "Email for certificate notices (optional)" ""; fi
  [[ "$SSL" == domain && -z "$DOMAIN" ]] && { c_err "A domain is required for --ssl domain."; exit 1; }
  TCP_ON=${TCP_ON:-0}
  for p in "$PORT" "$UDP_PORT" "$TCP_PORT"; do valid_port "$p" || { c_err "Not a port number: $p"; exit 1; }; done
  tcp_busy "$PORT" && { c_err "Port $PORT/tcp is already in use; choose another panel port with --port."; exit 1; }
  udp_busy "$UDP_PORT" && { c_err "Port $UDP_PORT/udp is already in use; choose another with --udp-port."; exit 1; }
  if [[ $TCP_ON -eq 1 ]] && tcp_busy "$TCP_PORT"; then c_err "Port $TCP_PORT/tcp is already in use; choose another with --tcp-port."; exit 1; fi
fi
if [[ $NODE -eq 1 ]]; then PORT=${PORT:-62060}; fi

# ---- packages ----
. /etc/os-release
step "installing packages on $PRETTY_NAME"
case "${ID_LIKE:-$ID}" in
  *debian*|*ubuntu*|debian|ubuntu)
    export DEBIAN_FRONTEND=noninteractive NEEDRESTART_SUSPEND=1  # never restart other services on a live server
    apt-get update -qq
    apt-get install -y -qq openvpn iptables curl ca-certificates openssl >/dev/null
    ;;
  *rhel*|*fedora*|*centos*)
    if command -v dnf >/dev/null; then PM=dnf; else PM=yum; fi
    $PM install -y -q epel-release >/dev/null 2>&1 || true
    $PM install -y -q openvpn iptables curl ca-certificates openssl >/dev/null
    ;;
  *) c_err "Unsupported distribution: $ID. Install openvpn and iptables, then rerun."; exit 1 ;;
esac

OVPN=$(command -v openvpn)
VER=$($OVPN --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
MAJOR=${VER%%.*}; REST=${VER#*.}; MINOR=${REST%%.*}
if (( MAJOR < 2 || (MAJOR == 2 && MINOR < 5) )); then
  if [[ "${ID_LIKE:-$ID}" == *debian* || "$ID" == debian || "$ID" == ubuntu ]]; then
    step "OpenVPN $VER is too old; adding the OpenVPN community repository"
    curl -fsSL https://swupdate.openvpn.net/repos/repo-public.gpg | gpg --dearmor -o /usr/share/keyrings/openvpn.gpg
    echo "deb [signed-by=/usr/share/keyrings/openvpn.gpg] https://build.openvpn.net/debian/openvpn/stable ${VERSION_CODENAME} main" > /etc/apt/sources.list.d/openvpn.list
    apt-get update -qq && apt-get install -y -qq openvpn >/dev/null
    VER=$($OVPN --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  else
    c_err "OpenVPN $VER found; Burrow needs 2.5 or newer."; exit 1
  fi
fi
step "OpenVPN $VER at $OVPN"
# The distribution's own unit is not used; Burrow runs its instances itself.
systemctl disable --now openvpn.service openvpn-server@server.service 2>/dev/null || true

# ---- binary ----
ARCH=$(uname -m)
case "$ARCH" in x86_64) GOARCH=amd64 ;; aarch64|arm64) GOARCH=arm64 ;; *) c_err "Unsupported CPU: $ARCH"; exit 1 ;; esac
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# fetch NAME: the asset of the chosen release, from GitHub or the mirror.
fetch() {
  local name=$1
  curl -fsSL --retry 2 --max-time 300 -o "$TMP/$name" "$GH_BASE/$name" 2>/dev/null ||
    curl -fsSL --retry 2 --max-time 300 -o "$TMP/$name" "$MIRROR_BASE/$name"
}

if [[ -n "$BINARY" ]]; then
  install -m 0755 "$BINARY" "$BIN.new"
elif [[ -f "$(dirname "$0")/burrow-linux-$GOARCH" ]]; then
  install -m 0755 "$(dirname "$0")/burrow-linux-$GOARCH" "$BIN.new"
else
  if [[ $BETA -eq 1 ]]; then
    TAG=$(curl -fsSL --max-time 20 "https://api.github.com/repos/$REPO/releases?per_page=10" 2>/dev/null | grep -m1 '"tag_name"' | cut -d'"' -f4 || true)
    [[ -n "$TAG" ]] || TAG=$(curl -fsSL --max-time 20 "$MIRROR?channel=beta" | grep -o '"tag":"[^"]*"' | head -1 | cut -d'"' -f4)
    GH_BASE="https://github.com/$REPO/releases/download/$TAG"; MIRROR_BASE="$MIRROR/$TAG"
  else
    GH_BASE="https://github.com/$REPO/releases/latest/download"; MIRROR_BASE="$MIRROR/latest"
  fi
  step "downloading burrow-linux-$GOARCH"
  fetch "burrow-linux-$GOARCH" || { c_err "Download failed from GitHub and from the mirror."; exit 1; }
  fetch SHA256SUMS && fetch SHA256SUMS.sig || { c_err "Could not download the release checksums."; exit 1; }
  if openssl version 2>/dev/null | grep -qE "^OpenSSL [3-9]" && echo "$RELEASE_PUB" | base64 -d > "$TMP/pub.der" 2>/dev/null &&
     openssl pkey -pubin -inform DER -in "$TMP/pub.der" -out "$TMP/pub.pem" 2>/dev/null; then
    base64 -d "$TMP/SHA256SUMS.sig" > "$TMP/sig.bin"
    openssl pkeyutl -verify -pubin -inkey "$TMP/pub.pem" -rawin -in "$TMP/SHA256SUMS" -sigfile "$TMP/sig.bin" >/dev/null 2>&1 ||
      { c_err "The release signature is not valid. Refusing to install."; exit 1; }
    step "release signature verified"
  else
    c_err "OpenSSL 3 is not available here, so only the checksum is checked."
  fi
  (cd "$TMP" && grep " burrow-linux-$GOARCH\$" SHA256SUMS | sha256sum -c --status) ||
    { c_err "The download does not match its checksum. Refusing to install."; exit 1; }
  install -m 0755 "$TMP/burrow-linux-$GOARCH" "$BIN.new"
fi
"$BIN.new" version >/dev/null || { c_err "The binary does not run on this machine."; rm -f "$BIN.new"; exit 1; }
mv -f "$BIN.new" "$BIN"
step "installed $($BIN version)"

# IPv4 only: turning on IPv6 forwarding globally disables router
# advertisements and can drop the server's own IPv6 address. Burrow enables
# it at runtime only for instances that use IPv6.
echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-burrow.conf
sysctl -q -p /etc/sysctl.d/99-burrow.conf || true

open_port() { # port/proto
  if command -v ufw >/dev/null && ufw status | grep -q "Status: active"; then
    ufw allow "$1" >/dev/null
  fi
  if command -v firewall-cmd >/dev/null && firewall-cmd --state >/dev/null 2>&1; then
    firewall-cmd -q --permanent --add-port="$1"
    firewall-cmd -q --permanent --add-masquerade
    firewall-cmd -q --reload
  fi
}

public_ip() {
  curl -4 -fsS --max-time 6 https://api.ipify.org || curl -4 -fsS --max-time 6 https://ifconfig.me || hostname -I | awk '{print $1}'
}

# ---- node mode ----
if [[ $NODE -eq 1 ]]; then
  cat > /etc/systemd/system/burrow-node.service <<UNIT
[Unit]
Description=Burrow node agent
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=$BIN node serve -config $NCONFIG
Restart=always
RestartSec=2
LimitNOFILE=65535
Environment=BURROW_NODE_CONFIG=$NCONFIG

[Install]
WantedBy=multi-user.target
UNIT
  cat > /etc/systemd/system/burrow-node-ovpn@.service <<UNIT
[Unit]
Description=Burrow node OpenVPN instance %i
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
Environment=BURROW_NODE_CONFIG=$NCONFIG
ExecStartPre=-$BIN node nat up %i
ExecStart=$OVPN --suppress-timestamps --config $NDATA/openvpn/%i.conf
ExecStopPost=-$BIN node nat down %i
Restart=on-failure
RestartSec=3
LimitNPROC=infinity
DeviceAllow=/dev/net/tun rw

[Install]
WantedBy=multi-user.target
UNIT
  systemctl daemon-reload
  if [[ $UPDATE -eq 1 ]]; then
    # OpenVPN instances keep running; only the agent restarts.
    systemctl restart burrow-node.service
    c_ok "Burrow node updated. Tunnels stayed up."
    echo
    echo "  Node key   $($BIN node key -config $NCONFIG)"
    exit 0
  fi
  if tcp_busy "$PORT"; then
    c_err "Port $PORT/tcp is already in use on this server (another panel's node?). Pick a free one with --port."
    exit 1
  fi
  PUBLIC=$(public_ip)
  step "public address: $PUBLIC"
  mkdir -p "$NDATA"
  chmod 711 "$NDATA"
  KEY=$($BIN node init -config "$NCONFIG" -data "$NDATA" -port "$PORT" -public-host "$PUBLIC" -allow "$PANEL_IP")
  systemctl enable --now burrow-node.service
  open_port "$PORT/tcp"
  echo
  c_ok "Burrow node is running."
  echo
  echo "  In the panel, open Nodes -> Connect a node and paste this key:"
  echo
  echo "  $KEY"
  echo
  echo "  Address    $PUBLIC   (port $PORT/tcp must be reachable from the panel)"
  if [[ -z "$PANEL_IP" ]]; then
    echo "  Tip: on a fresh install, --panel-ip PANEL_IP makes the node accept only your panel."
  fi
  echo "  Show the key again: burrow node key"
  exit 0
fi

# ---- panel ----
cat > /etc/systemd/system/burrow.service <<UNIT
[Unit]
Description=Burrow OpenVPN panel
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=$BIN serve -config $CONFIG
Restart=always
RestartSec=2
LimitNOFILE=65535
Environment=BURROW_CONFIG=$CONFIG

[Install]
WantedBy=multi-user.target
UNIT

cat > /etc/systemd/system/burrow-ovpn@.service <<UNIT
[Unit]
Description=Burrow OpenVPN instance %i
After=network-online.target burrow.service
Wants=network-online.target

[Service]
Type=simple
Environment=BURROW_CONFIG=$CONFIG
ExecStartPre=-$BIN nat up %i
ExecStart=$OVPN --suppress-timestamps --config $DATA/openvpn/%i.conf
ExecStopPost=-$BIN nat down %i
Restart=on-failure
RestartSec=3
LimitNPROC=infinity
DeviceAllow=/dev/net/tun rw

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload

if [[ $UPDATE -eq 1 ]]; then
  # The panel restarts OpenVPN servers whose config the new version changes.
  step "updating"
  systemctl restart burrow.service
  c_ok "Burrow updated."
  BURROW_CONFIG=$CONFIG $BIN info
  exit 0
fi

# ---- first install ----
PUBLIC=$(public_ip)
step "public address: $PUBLIC"
mkdir -p /etc/burrow "$DATA"
chmod 711 "$DATA"  # OpenVPN (as nobody) must reach pki/crl.pem
TCP_FLAG=""; [[ $TCP_ON -eq 1 ]] && TCP_FLAG="-tcp"
PUBHOST=$PUBLIC; [[ "$SSL" == domain ]] && PUBHOST=$DOMAIN
OUT=$(BURROW_CONFIG=$CONFIG $BIN init -config "$CONFIG" -data "$DATA" -port "$PORT" -public-host "$PUBHOST" -username "$ADMIN_USER" \
  -udp-port "$UDP_PORT" -tcp-port "$TCP_PORT" $TCP_FLAG)
PASS=$(echo "$OUT" | awk -F': *' '/^password/ {print $2}')
BASE=$(echo "$OUT" | awk -F': *' '/^panel path/ {print $2}')

SCHEME=http
HOST=$PUBLIC
if [[ "$SSL" == domain || "$SSL" == ip ]]; then
  NAME=$PUBLIC; [[ "$SSL" == domain ]] && NAME=$DOMAIN
  step "getting a Let's Encrypt certificate for $NAME"
  if BURROW_CONFIG=$CONFIG $BIN ssl issue -mode "$SSL" -domain "$NAME" -email "$EMAIL"; then
    SCHEME=https; HOST=$NAME
  else
    c_err "No certificate yet; the panel starts on plain HTTP. Retry later under Settings -> HTTPS."
  fi
fi

systemctl enable --now burrow.service
systemctl enable --now "burrow-ovpn@udp$UDP_PORT.service" || c_err "OpenVPN did not start; check: journalctl -u burrow-ovpn@udp$UDP_PORT"
[[ $TCP_ON -eq 1 ]] && { systemctl enable --now "burrow-ovpn@tcp$TCP_PORT.service" || true; }

open_port "$PORT/tcp"
open_port "$UDP_PORT/udp"
[[ $TCP_ON -eq 1 ]] && open_port "$TCP_PORT/tcp"

echo
c_ok "Burrow is running."
echo
echo "  Panel      $SCHEME://$HOST:$PORT$BASE"
echo "  Username   $ADMIN_USER"
echo "  Password   $PASS"
echo "  OpenVPN    udp/$UDP_PORT$([[ $TCP_ON -eq 1 ]] && echo ", tcp/$TCP_PORT")"
echo
echo "  Keep the panel path secret: everything else on that port answers 404."
echo "  Change the password and turn on two-factor sign-in under Settings -> My account."
echo "  Free plan: 5 active clients and 2 nodes. Upgrade any time under License."
echo "  Lost the address later?  burrow info"
