# Inbounds

An [inbound](/reference/glossary) is one protocol listening on one port, with its own tunnel network. The **Inbounds** page lists them, grouped by the node that runs each one. This page covers the list, creating an inbound, the tabs of an existing one and deleting it. The protocol-specific settings are on the [OpenVPN](/protocols/openvpn), [WireGuard and AmneziaWG](/protocols/wireguard) and [OpenConnect](/protocols/openconnect) pages.

## The list

Inbounds are grouped under their node: the panel's own server appears as **This server**, and inbounds that no node runs yet are under **Not on a node**. A node that does not answer is marked **unreachable**.

Each row shows:

- The protocol badge, the transport (`UDP` or `TCP`), the port and the tunnel network.
- How clients sign in: **Certificate**, **Certificate and password**, **Username and password**, or **Device keys** for WireGuard.
- The description, if you gave one, and for OpenConnect the state of the certificate.
- The state: **Running**, **Stopped**, **Disabled** or **Not on a node**. Below it, **Panel connected** or **Panel not connected** tells you whether the panel can reach the node that runs it.
- The number of clients online, and how many clients are allowed on it.
- **Restart** and **Stop** for a running inbound, **Start** for a stopped one.

Select a row to open the inbound.

## Create an inbound

Press **New inbound**. The form starts with the protocol.

| Field | What it does |
|---|---|
| **Protocol** | **OpenVPN**, **OpenConnect** or **WireGuard**. Fixed once the inbound exists. |
| **Name** | Lowercase letters, digits and dashes. It cannot be changed later. |
| **Protocol** (transport) | **UDP**, **TCP**, **UDP (IPv4 + IPv6)** or **TCP (IPv4 + IPv6)** for OpenVPN. WireGuard is UDP only. OpenConnect signs in over TCP, and offers faster DTLS over UDP on the same port. |
| **Port** | The port clients connect to. It must be free on the node you attach the inbound to. |
| **Tunnel network** | A private IPv4 range for client addresses. The last quarter is reserved for fixed client addresses. |
| **Description** | Shown to clients on their page, for example `Use this on mobile data`. |
| **Public address override** | Leave empty to use the panel's **Public address**. |
| **Run this inbound** | When off, the inbound is saved but does not start. |

The form suggests a name, a port and a network. Settings you rarely change are folded away under **Customize**, with the recommended defaults in use.

Below the basics, **Access** lists the groups and clients that will receive the new inbound. Groups that already include all inbounds are marked. Groups with a chosen list, and clients with their own list, can be ticked to include it. You can change this later in [Groups](/use/groups) and in the client form.

Creating checks only the inbound's own fields: the name, the port number and the format of the ranges. The new inbound is saved under **Not on a node** and does not run. Attach it from **Nodes**; the node is then checked for a free port, overlapping networks and, for OpenConnect, the software and a certificate. See [Nodes](/use/nodes).

## An existing inbound

Opening an inbound shows three tabs.

- **Settings**: the same form, in sections: **Basics**, **Sign-in and encryption**, **Network and routing**, **DNS**, **Performance** and **Advanced**. The sections depend on the protocol. The **Node** line shows where it runs and links to **Nodes**, where you move it.
- **Config file**: the file Ovira wrote for this inbound, and its path on the node. It is for reading; change the settings instead.
- **Logs**: the recent log lines of this inbound. **Refresh** reloads them.

The buttons at the top restart a running inbound or start a stopped one. If the inbound is attached to a node, saving a changed port rewrites the configuration, moves the firewall rules and restarts that inbound. Clients get the new port the next time they download their profile.

## Delete an inbound

Press **Delete** at the top of the inbound. Ovira asks for confirmation, because the inbound stops on its port and connected clients drop. Clients keep their other inbounds. To stop an inbound but keep it, use **Detach** on the node card instead: it returns to **Not on a node** and clients keep their access to it.

## Related pages

- [Nodes](/use/nodes): attach, detach and move inbounds.
- [Groups](/use/groups): decide which clients get which inbounds.
- [Choosing a protocol](/protocols/): what each protocol is good for.
- [Your first client](/start/first-client): the whole path from inbound to connection.
