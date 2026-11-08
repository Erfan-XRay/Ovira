# Changelog

What changed in each minor release, newest first. Patch releases are folded into the minor release they belong to. The full notes are on the [GitHub releases page](https://github.com/Erfan-XRay/Ovira/releases). Update from the panel or with `ovira update`; see [Update the panel and nodes](/start/update).

## 1.0

November 8, 2026. The first stable 1.0. **Outbound routing**: send clients' traffic out through another server, per node, from the new [Routing](/use/routing) page, with VLESS, VMess, Trojan, Shadowsocks, Hysteria2, WireGuard, SOCKS and HTTP outbounds added field by field or from a link, Cloudflare WARP and NordVPN in one click, rules by site list, domain, IP, port or inbound, and a test that shows latency and the exit IP. **IKEv2 and L2TP/IPsec** inbounds on the panel's server and on nodes, with setup files for Apple devices, Android and Windows; see [IKEv2 and L2TP/IPsec](/protocols/ipsec). The [Certificates](/use/certificates) page requests Let's Encrypt certificates for nodes and the main server. The Nodes page became a list with a details panel, installs and removes protocols, and updates every node at once. The panel port can be chosen at install and changed in **Settings**, and subscription links can have their own port. Panel accounts are limited only by the plan's account count. Update the panel and its nodes together.

## 0.9

October 30, 2026. Inbounds are no longer tied to a node when you create them. **New inbound** has no node field, and a new inbound waits under **Not on a node**. You run it from **Nodes → Attach inbound**, which checks the port, network and certificate against that node first. Inbounds can be detached or moved to another node, and removing a node keeps its inbounds. A new panel starts with no inbounds, and the installer asks whether the panel's own server should also be a node. Let's Encrypt certificates for a server's IP address were fixed. Panels with hundreds of online users save traffic much faster and no longer hang connections. Nodes do not need to be updated for 0.9. The 0.9 patch releases added Telegram backups, API tokens with a public API, one inbound shared by several nodes and protocols installed on demand.

## 0.8

October 30, 2026. Panel accounts with roles: give resellers a traffic pool, an end date and a client limit, and choose which groups and inbounds they can hand out. The subscription page has a new look and protocol tabs for OpenVPN, WireGuard, AmneziaWG and Cisco, which you can reorder, hide or rename in **Settings**. "Servers" became "Inbounds". **Connections** gained search, filters and a per-client view that flags clients using more devices than allowed. You can choose a colour for the admin panel. The `ovira` menu was redesigned with arrow-key navigation and a status header, and nodes got their own install command, `node.sh`.

## 0.7

October 29, 2026. WireGuard inbounds on the panel's own server and on nodes, on every plan. Each inbound runs in plain mode for the official WireGuard apps, or in Amnezia mode for networks that block WireGuard. Every device gets its own configuration and QR code on the subscription page. WireGuard needs nothing installed beyond TUN. When you create an inbound you can give it to existing groups and clients at once.

## 0.6

October 29, 2026. OpenConnect inbounds, which work with Cisco Secure Client and OpenConnect apps, on the panel's own server and on nodes, on every plan. Clients, traffic limits, device limits and groups work the same as for OpenVPN. Nodes install OpenConnect themselves after updating.

## 0.5

October 29, 2026. More reliable panel and node updates, English and Persian update progress, mobile layout fixes and display of the server's time zone. Plan limits are applied the same way everywhere in the panel, so a panel that already exceeds its plan after upgrading has the extras refused.

## 0.4

October 28, 2026. Burrow is now Ovira, with a new logo and this documentation site. New installations use `ovira` for the command, services and folders. Existing installations keep their file and service names, so an update moves nothing, and the `ovira` command appears next to `burrow`. Installs through the script now need OpenSSL 3 or newer.

## 0.3

October 27, 2026. The first release with nodes: connect more servers to one panel, with the device limit counted across all of them. Each node has a traffic multiplier, and connect addresses let you put relays in front of it. Plans and payments moved into the panel, with a free plan of 5 active clients and 2 nodes. The panel can update itself from stable and beta channels, with release notes and automatic installs. HTTPS with Let's Encrypt for a domain or the server's IP. The subscription page gained three looks, an accent colour, and a shop name with support and channel links. Two devices on one profile no longer disconnect each other.
