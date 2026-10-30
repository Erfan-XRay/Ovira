# Get started

Ovira is a web panel for running VPN servers. The panel stores your clients, plans and settings. The servers that carry the traffic are called [nodes](/reference/glossary), and one server can be both the panel and a node. This section takes you from an empty Linux server to a client that is connected.

## What you need

- A server running Debian, Ubuntu, AlmaLinux, Rocky Linux or CentOS Stream, on amd64 or arm64, with systemd.
- Root access, and a public IPv4 address.
- Outbound HTTPS from the server, so the installer can download Ovira and, later, the panel can check for updates.
- A TCP port for the panel (the installer offers `2053`), and the ports of the inbounds you create later. The installer opens its own ports in `ufw` or `firewalld` when one of them is active. A firewall at your hosting provider is yours to open.
- Optional: a domain whose A record points at the server. Without one the panel uses the server's IP address for HTTPS.

A node is a second server that the panel controls. You do not need one to start, because the panel's own server can run inbounds.

## The order of the first steps

1. [Install the panel](/start/install-panel). One command, a few questions, and a printed address and password.
2. [Sign in for the first time](/start/first-sign-in). Check the address, turn on two-factor sign-in.
3. [Set up HTTPS](/start/https) if you skipped it or the certificate failed.
4. [Add a node](/start/add-node) when you want more servers, or keep [this server as a node](/start/same-server).
5. [Create your first client](/start/first-client). An inbound, a client, a link, a working connection.

The remaining pages cover [updating](/start/update), [moving the panel to a new server](/start/move-server) and [removing Ovira](/start/uninstall).

## Related pages

- [Using the panel](/use/) describes every screen once the panel is running.
- [How Ovira works](/how/) explains the parts and how they talk to each other.
- [Choosing a protocol](/protocols/) helps you decide between OpenVPN, WireGuard and OpenConnect.
