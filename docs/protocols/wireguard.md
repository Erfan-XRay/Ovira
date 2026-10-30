# WireGuard and AmneziaWG

WireGuard is a fast UDP protocol with no sign-in step: each device holds its own key. Ovira runs it with a built-in engine, so nothing is installed on the server. AmneziaWG is the same inbound with obfuscation turned on, for networks that detect and block plain WireGuard. This page covers creating the inbound, the two modes, how devices work and what clients import.

## What it is good for

- Phones and laptops where speed and battery life matter.
- Customers who accept one configuration per device, imported by QR code or `.conf` file.
- With **Amnezia obfuscation** on, networks that block plain WireGuard.

## Create an inbound

1. Open **Inbounds** and press **New inbound**.
2. Under **Protocol**, pick **WireGuard**. The protocol cannot be changed after the inbound exists.
3. Give it a **Name**. The form suggests UDP and port 51820. The port must be free on the node you attach the inbound to.
4. Under **Tunnel network**, enter a range, or leave the field empty to have a free range picked when the inbound is attached to a node. The form shows how many devices the range holds.
5. Under **WireGuard**, turn **Amnezia obfuscation** on or off. See below.
6. Under **Access**, choose which existing groups and clients get the new inbound.
7. Press **Create**. The inbound is saved under **Not on a node** and does not run yet.
8. On **Nodes**, press **Attach inbound** on the target node's card, including **This server**, and pick it. The port and tunnel network are checked against that node first. If a check fails, nothing changes and the dialog shows why.

The machine only needs TUN (`/dev/net/tun`), which almost every VPS has. Some container-based VPS types do not. The **Nodes** page shows **WireGuard ready** or **No TUN** for every node.

::: tip Node version
A node needs Ovira 0.7.0 or newer to run WireGuard. If the attach dialog says the node must be updated, update it from **Updates**. While WireGuard inbounds exist, Ovira refuses to install an older version.
:::

## Plain or Amnezia mode

| | Plain | Amnezia |
|---|---|---|
| **Amnezia obfuscation** | Off | On |
| Client apps | The official **WireGuard** apps | **AmneziaVPN** or **AmneziaWG** |
| Default tunnel MTU | 1420 | 1280 |
| Subscription page tab | WireGuard | AmneziaWG |

A plain WireGuard app cannot connect to an Amnezia inbound. To offer both, create two inbounds on different ports and let clients pick the one that works on their network.

With obfuscation on, the form shows the generated parameters and a **Regenerate Amnezia parameters** button. Regenerating changes what every device needs, so each device must import a new configuration afterwards.

## Settings

| Field | What it does |
|---|---|
| **Server public key** | Shown for reference. The panel generates the server keys when the inbound is created. |
| **Tunnel network** | An IPv4 range from /8 to /24. Each device gets one address from it, so a /24 holds 253 devices and a /16 about 65,500. |
| **Tunnel MTU** | Between 1280 and 9000. Keep the default unless a network needs smaller packets. |
| **Persistent keepalive (seconds)** | How often a device sends a small packet to keep the connection open. Default 25; 0 turns it off. |
| **Send all traffic through the VPN** | On means every route goes through the VPN. Off means split tunnel, and you must list at least one route under **Routes to push**. |
| **Routes to push** | One CIDR per line, for example `192.168.0.0/16`. |
| **DNS servers**, **NAT client traffic to the internet**, **IPv6 inside the tunnel**, **Max connected clients** | Work as for [OpenVPN](./openvpn#network-and-routing). |
| **Public address override** | The address written into configurations. For a relay in front of the inbound, enter the relay's address. The relay must forward the inbound's UDP port. |

## Devices

WireGuard has no sign-in, so every device gets its own configuration.

- A client has one configuration per device, up to its **Devices at once** limit. A client with no limit gets 10.
- A device's configuration works on every WireGuard inbound the client is allowed on, so adding an inbound needs no extra step for existing devices.
- A device counts toward the device limit only while it is connected, which means it completed a handshake in the last three minutes. WireGuard devices count together with the client's OpenVPN and OpenConnect connections. A device that would go over the limit is disconnected.
- Using one device configuration in two places at once disconnects the older one. Give each phone or computer its own device.
- **Reset keys** on a device makes its old configuration stop working on every server. The client then imports the new one.

On the client's page in the panel, the **WireGuard devices** section lists each device as **Device 1**, **Device 2** and so on, with **Online** or **Offline**, the **Last handshake**, the traffic it used, and **Download .conf** and **Show QR** for every WireGuard inbound the client can use.

## What clients need

The client's subscription page has a **WireGuard** tab and, if you run Amnezia inbounds, an **AmneziaWG** tab. When the client has more than one device, a device selector comes first. For each inbound the page shows a QR code, a `.conf` download and a copy button.

In the app:

1. Install **WireGuard** (Android, iPhone and iPad, Windows, macOS, Linux) for a plain inbound, or **AmneziaVPN** or **AmneziaWG** for an Amnezia inbound. See [Client apps](./apps).
2. Add a tunnel by scanning the QR code, or import the downloaded `.conf` file.
3. Connect.

The downloaded file is named `CLIENT-device-N-INBOUND.conf`. It contains the device's private key, so tell customers to keep it private.

## What it cannot do

- It cannot work over TCP. Where UDP is blocked, use OpenVPN or OpenConnect.
- It cannot give one configuration to several devices at once without them disconnecting each other.
- It cannot be mixed with a Cisco app. Those need an [OpenConnect](./openconnect) inbound.

## Related pages

- [Choosing a protocol](./index): how WireGuard compares with the other two.
- [Client apps](./apps): where to get the apps for each platform.
- [The life of a connection](/how/connection): how devices are counted and cut off.
- [Troubleshooting](/reference/troubleshooting): no handshake, no traffic, or an inbound that will not start.
