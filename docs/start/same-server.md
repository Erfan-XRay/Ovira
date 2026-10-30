# This server as a node

The server that runs the panel can also carry VPN traffic. In the panel it appears as the node **This server**. This page covers turning that on and off, and what each choice means for a single-server setup.

## Panel only or panel and node

The installer asks **Use this server as a node too?**. The answer decides what the card of **This server** on the **Nodes** page does:

- Yes: the server runs inbounds. Create them under **Inbounds** and attach them to **This server**.
- No: the card says **Panel only**. The server runs the panel, and inbounds run on other nodes you [connect](/start/add-node).

For one VPS, answer yes. For a larger setup, a panel-only server keeps the VPN load, and the ports clients connect to, off the machine that holds your clients and settings.

## Turn it on or off later

Run these on the panel server as root.

```bash
ovira local-node enable     # installs OpenVPN if needed, then makes this server a node
ovira local-node disable    # panel only again
ovira local-node status
```

The same switch is in the `ovira` menu, under **This server**. While the server is panel only, its card shows a command you can copy to turn this on.

Turning it off stops the inbounds on this server, so clients connected to them are disconnected. The inbounds stay in the panel and the panel and its other nodes keep working. Turning it on again starts them.

## Using the server's own node

- Create the inbound under **Inbounds**, then press **Attach inbound** on the **This server** card. [Your first client](/start/first-client) shows the steps.
- For OpenConnect on this server, press **Install OpenConnect** on the card first. A remote node installs it by itself when you attach an OpenConnect inbound.
- For WireGuard, the server needs `/dev/net/tun`. The card shows `WireGuard ready` or `No TUN`. On a container-based VPS, enable TUN at your provider.
- The **Traffic multiplier** of **This server** is editable like any other node's.

## What it cannot do

**This server** cannot be removed or switched off with the **Enabled** switch in the node dialog; use `ovira local-node disable`. The license node limit counts only remote nodes, so the panel's own server never uses one of them.

## Related pages

- [Add a node](/start/add-node): connecting a second server.
- [Nodes](/use/nodes): what the cards show.
- [Inbounds](/use/inbounds): creating and attaching inbounds.
