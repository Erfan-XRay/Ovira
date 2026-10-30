# WireGuard

Ovira can run **WireGuard** inbounds next to OpenVPN and OpenConnect, on **This server** and on nodes. Clients, groups, traffic limits, end dates, device limits, node multipliers and the live connections list work the same way as for the other protocols.

WireGuard is available on every plan, Free included. Clients and nodes count against your limits exactly as for OpenVPN.

## Which protocol?

| | OpenVPN | OpenConnect | WireGuard |
|---|---|---|---|
| Client app | OpenVPN Connect and others | Cisco Secure Client, OpenConnect apps | WireGuard, or AmneziaVPN / AmneziaWG |
| Setup for a client | Import a profile file | Type in an address, sign in | Scan a QR code or import a file |
| Transport | UDP or TCP | TCP (plus UDP) | UDP |
| Per device | One profile for all devices | Same name and password everywhere | One configuration per device |

WireGuard is fast and light on phones. All three can run side by side, and a client can be allowed on any mix of them.

## Plain or Amnezia mode

Each WireGuard inbound runs in one of two modes:

- **Plain**: standard WireGuard. Clients use the official **WireGuard** apps.
- **Amnezia**: WireGuard with traffic obfuscation, for networks that detect and block WireGuard. Clients use **AmneziaVPN** or **AmneziaWG**. Plain WireGuard apps cannot connect to it.

Turn on **Amnezia obfuscation** in the inbound form to use Amnezia mode. You can run one inbound of each kind and let clients pick the one that works on their network.

## Create an inbound

1. **Inbounds → New inbound**.
2. Under **Protocol**, pick **WireGuard**. The protocol is fixed once the inbound exists.
3. Give it a **Name**, and choose a UDP **Port** (default 51820) that is free on the node you attach it to.
4. **Tunnel network**: enter a range to see how many devices it holds (a /16 holds about 65,000 devices), or leave it empty to have a free range picked when attached.
5. Under **Access**, choose which existing groups and clients get the new inbound. All of them are selected by default; groups with *all inbounds* get it anyway.
6. Press **Create**. It is saved under **Not on a node** and does not run yet.
7. On **Nodes**, press **Attach inbound** on the target node's card (including **This server**) and select it. The port and tunnel network are checked against that node before it starts; if a check fails, nothing changes and the dialog shows why.

Nothing needs to be installed: WireGuard is built into Ovira. The machine only needs **TUN** (`/dev/net/tun`), which almost every VPS has; some container-based VPS types do not. The Nodes page shows *WireGuard ready* or *No TUN* for every node.

::: tip Nodes
A node needs Ovira 0.7.0 or newer to run WireGuard. Update it from **Updates** if the attach dialog says so.
:::

## Devices

WireGuard has no sign-in, so every device gets its own configuration:

- A client gets one configuration per device, up to their **device limit** (unlimited clients get 10).
- A device's configuration works on **every** WireGuard inbound the client is allowed on, so adding an inbound needs no extra step.
- Only devices that are connected count toward the device limit, together with the client's OpenVPN and OpenConnect connections. A device that would go over the limit is disconnected.
- Using the same device configuration in two places at once disconnects the older one. Give each phone or computer its own device.
- **Reset keys** on a device (on the client's page) makes its old configuration stop working everywhere; the client then imports the new one.

## Settings

- **Tunnel MTU**: keep the default unless a network needs smaller packets.
- **Persistent keepalive**: how often devices send a small packet to keep the connection open (default 25 seconds, 0 turns it off).
- **Send all traffic through the VPN**: off means split tunnel, where only the routes you list go through the VPN.
- **DNS servers**, **NAT**, **IPv6 inside the tunnel** and **Max connected clients** work as for OpenVPN.
- **Public address override**: the address put in client configurations. For a relay in front of the inbound, enter the relay's address; the relay must forward the inbound's **UDP** port.

WireGuard support starts with Ovira 0.7.0. While WireGuard inbounds exist, Ovira refuses to install an older version; delete them first if you really need to go back.

## What clients do

The client's subscription page has a **WireGuard** section. With more than one device it starts with a device selector; for each inbound it shows:

- a **QR code**, a **.conf download** and a **copy** button,
- which app to use for that inbound (WireGuard, or AmneziaVPN / AmneziaWG for Amnezia mode),
- links to the apps for each platform.

In the app:

1. Install **WireGuard** (Android, iPhone and iPad, Windows, macOS, Linux) for plain inbounds, or **AmneziaVPN** / **AmneziaWG** for Amnezia inbounds.
2. Add a tunnel by scanning the QR code, or import the downloaded `.conf` file.
3. Connect.

## Troubleshooting

- **Connects but no traffic, or no handshake**: check that the UDP port is open in your provider's firewall, and that a relay, if any, forwards UDP to it.
- **Works with WireGuard on one network but not another**: the network may block WireGuard. Try an Amnezia inbound with the AmneziaVPN app.
- **A device stops working when another connects**: they share one device configuration. Use a separate device for each.
- **The inbound does not start on a node**: the Nodes page shows *No TUN*; enable TUN at your provider or use another node.
- **The inbound does not start**: another program on that machine may already use the UDP port or the tunnel network. Pick a different port or network.
- **If the panel is unreachable for about two minutes**, its WireGuard inbounds disconnect everyone until it is back, the same way the other protocols refuse new logins without the panel.
