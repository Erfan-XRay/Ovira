# OpenVPN servers

**Servers** lists every server the panel runs, grouped by node. Each one is a separate process with its own port, protocol and tunnel network, and a badge shows whether it is **OpenVPN** or **OpenConnect**. This page covers OpenVPN; see [OpenConnect (Cisco)](./openconnect) for the other kind.

In **Servers → New server**, the first choice is the **Protocol**. It cannot be changed later.

## Ports

Change a server's port in its editor (**Servers → server → Port**) and save: Ovira rewrites the config, moves the firewall rules and restarts that server. Clients get the new port in their profile the next time they download it.

To run another protocol or port side by side, **Servers → New server**:

- **UDP** avoids TCP-over-TCP overhead and is a usual starting point; actual performance depends on the network.
- **TCP** is an option where UDP is blocked, when that network allows OpenVPN over TCP. Port 443 alone does not guarantee access. OpenVPN's *port share* needs explicit configuration and a compatible web backend; it does not automatically share a listener owned by another service.
- On a node, pick the node in the **Node** field; ports only need to be free on that machine.

## Sign-in modes

| Mode | Client needs |
|---|---|
| Certificate | The profile only (default) |
| Certificate + password | Profile, user name and password |
| Password only | User name and password; no client certificate |

Clients see their user name and password on the subscription page when a server asks for them.

## Network and routing

- **Tunnel network**: a private range like `10.8.0.0/24`. Ovira refuses ranges that overlap a route already on the server (WireGuard, docker, other VPNs).
- **Full tunnel** sends all traffic through the VPN; turn it off and list routes for split tunnel.
- **NAT** lets clients reach the internet through the server.
- **Fixed IPs**: the last quarter of the range is kept for fixed client addresses.

## Advanced

Ciphers, TLS minimum, tls-crypt/tls-auth, MTU, MSS, keepalive, compression and extra directives are all in the editor. Script hooks and file-writing directives are refused.
