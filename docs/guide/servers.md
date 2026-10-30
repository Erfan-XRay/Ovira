# Inbounds and OpenVPN

An **inbound** is one protocol with its own port and tunnel network. **Inbounds** lists every inbound, grouped by node or under **Not on a node**; the node that hosts the panel is shown as **This server**. A badge shows whether each one is **OpenVPN**, **OpenConnect** or **WireGuard**. This page covers OpenVPN; see [OpenConnect (Cisco)](./openconnect) and [WireGuard](./wireguard) for the others.

In **Inbounds → New inbound**, the first choice is the **Protocol**. It cannot be changed later. The form suggests a name and port, and keeps the advanced settings collapsed until you open them.

## Ports

Change an inbound's port in its editor (**Inbounds → inbound → Port**) and save. If it is attached to a node, Ovira rewrites the config, moves the firewall rules and restarts that inbound. Clients get the new port in their profile the next time they download it.

To run another protocol or port side by side, **Inbounds → New inbound**:

- **UDP** avoids TCP-over-TCP overhead and is a usual starting point; actual performance depends on the network.
- **TCP** is an option where UDP is blocked, when that network allows OpenVPN over TCP. Port 443 alone does not guarantee access. OpenVPN's *port share* needs explicit configuration and a compatible web backend; it does not automatically share a listener owned by another service.
- Create the inbound, then attach it from **Nodes**; its port must be free on the node you attach it to.

## Attaching to a node

New inbounds are saved under **Not on a node** and do not run yet. Creating or editing checks only the inbound's own fields, such as its name, port number and range format.

On **Nodes**, press **Attach inbound** on any node card, including **This server**, and pick the inbound. Ovira checks that node for a free port, tunnel network overlaps with other inbounds or server routes, and, for OpenConnect, installation and certificate availability. If a check fails, nothing changes and the dialog shows why. If the checks pass, the inbound starts there.

Use the **Detach** icon beside an inbound on a node card to stop it and return it to **Not on a node**. Clients keep their access, but connected users are disconnected. To move it, use **Attach inbound** on another node and select it; the new node is checked before it leaves the old one.

## Sign-in modes

| Mode | Client needs |
|---|---|
| Certificate | The profile only (default) |
| Certificate + password | Profile, user name and password |
| Password only | User name and password; no client certificate |

Clients see their user name and password on the subscription page when an inbound asks for them.

## Network and routing

- **Tunnel network**: a private range like `10.8.0.0/24`. When attaching, Ovira refuses ranges that overlap another inbound or a route already on that node (WireGuard, docker, other VPNs).
- **Full tunnel** sends all traffic through the VPN; turn it off and list routes for split tunnel.
- **NAT** lets clients reach the internet through the server.
- **Fixed IPs**: the last quarter of the range is kept for fixed client addresses.

## Advanced

Ciphers, TLS minimum, tls-crypt/tls-auth, MTU, MSS, keepalive, compression and extra directives are all in the editor. Script hooks and file-writing directives are refused.
