# Choosing a protocol

An [inbound](/reference/glossary#inbound) is one VPN server with its own port and tunnel network, and every inbound runs exactly one protocol: OpenVPN, WireGuard or OpenConnect. This page compares them so you can decide which inbounds to create. The pages that follow cover each protocol in detail.

All three are available on every plan, including Free. Clients, groups, traffic limits, end dates, device limits, node multipliers and the **Connections** list work the same way whichever protocol a client uses.

## At a glance

| | OpenVPN | WireGuard | AmneziaWG | OpenConnect |
|---|---|---|---|---|
| Transport | UDP or TCP | UDP | UDP | TCP, plus UDP (DTLS) on the same port number |
| Port the form suggests | 1194 | 51820 | 51820 | 443 |
| Sign-in | Certificate, certificate and password, or password only | None; the device holds its own key | None; the device holds its own key | Client name and password |
| What a client imports | A profile file | A `.conf` file or QR code, one per device | A `.conf` file or QR code, one per device | A server address, typed into the app |
| Apps | OpenVPN Connect and other OpenVPN apps | WireGuard | AmneziaVPN, AmneziaWG | Cisco Secure Client, OpenConnect apps |
| Needs on the machine | OpenVPN 2.5 or newer | TUN (`/dev/net/tun`) | TUN (`/dev/net/tun`) | `ocserv`, installed from the panel |
| Details | [OpenVPN](./openvpn) | [WireGuard and AmneziaWG](./wireguard) | [WireGuard and AmneziaWG](./wireguard) | [OpenConnect](./openconnect) |

AmneziaWG is not a fourth protocol in the **New inbound** form. It is a WireGuard inbound with **Amnezia obfuscation** switched on, and it appears as its own tab on the subscription page.

## What the three have in common

- A client is created once and can be allowed on inbounds of any protocol. Which inbounds a client gets is decided by its [groups](/use/groups).
- The device limit counts a client's connections across every inbound, every node and every protocol together. See [The life of a connection](/how/connection).
- Traffic is counted in both directions and multiplied by the [node's traffic multiplier](/how/traffic).
- The client's subscription page shows one tab for each protocol the client has access to: OpenVPN, WireGuard, AmneziaWG and Cisco. The owner can reorder, hide or rename tabs in **Settings**. See [Subscription page](/use/subscription-page).

## What differs

| | OpenVPN | WireGuard | OpenConnect |
|---|---|---|---|
| Profile | One profile per client, used on all devices | One configuration per device | No file; address plus name and password |
| Counting devices | Every open tunnel counts | Every device that completed a handshake in the last three minutes counts | Every open tunnel counts |
| Client certificate | Yes, unless the inbound uses password sign-in | No | No |
| Looks like | VPN traffic | VPN traffic | Ordinary HTTPS, usually on port 443 |
| Behind a relay | Yes, per [connect address](/how/relays) | Yes, the relay must forward UDP | Yes, but a trusted certificate does not match the relay's name |

## How to choose

- Start with OpenVPN if you do not know your customers' networks. Its apps exist on every platform and it can fall back to TCP when UDP is blocked.
- Add WireGuard for customers who want speed and light battery use on phones. Give each device its own configuration.
- Add an Amnezia-mode WireGuard inbound on a second port for networks that block plain WireGuard. Plain WireGuard apps cannot connect to it.
- Add OpenConnect on port 443 for networks that block OpenVPN but let HTTPS through, or for customers who already use the Cisco app.
- Run more than one. A client allowed on several protocols sees them all on its subscription page and picks whichever works on its current network.

::: warning One port, one inbound
Two inbounds cannot use the same port and protocol on one node. OpenConnect on TCP 443 conflicts with an OpenVPN inbound on TCP 443. The attach dialog on **Nodes** checks this and tells you before anything starts.
:::

## Related pages

- [OpenVPN](./openvpn): sign-in modes, network and routing, advanced options.
- [WireGuard and AmneziaWG](./wireguard): devices, Amnezia mode and the `.conf` files.
- [OpenConnect](./openconnect): certificates, camouflage and the Cisco app.
- [Client apps](./apps): which app to install on which platform.
- [Inbounds](/use/inbounds): the panel page where all of this is configured.
