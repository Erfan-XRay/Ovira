# Nodes and relays

A **node** is another server that runs OpenVPN, OpenConnect or WireGuard inbounds for your panel. Clients are created once, in the panel, and work on every node.

## Add a node

**1. In the panel**, open **Nodes → Connect a node**. It shows the install command with your panel's address already filled in; press the copy button and run it as root on the new server:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) node --panel-ip PANEL_IP
```

The script downloads Ovira from GitHub itself, so nothing is copied to the new server first. `--panel-ip` makes the node answer only your panel. When it finishes it prints a **node key** (`BNK1-…`). The node listens on TCP port **62060**; use `--port` for another one.

**2. Back in the dialog**, paste the key, give the node a name and save. The panel connects within seconds.

**3. Add an inbound on it**: on the node's card, **Add an inbound on this node**. Pick the protocol, then its port, like on **This server**. The first OpenConnect inbound installs OpenConnect on the node automatically; until then the node's card says *OpenConnect not installed*. A node that runs an older Ovira shows *Update this node to use OpenConnect*: update it first.

The node key contains the node's API key and its certificate fingerprint, so the panel talks only to that node. If you reinstall a node, paste its new key in the node's editor. `ovira key` on the node prints the key again.

## The panel's own server

A panel can be installed **on its own** (an empty panel that only manages nodes) or together with OpenVPN on the same server, see [Install](./install#panel-with-openvpn-or-an-empty-panel). On an empty panel the card of **This server** says *Panel only*. To make that server a node too, run on it:

```bash
ovira openvpn enable
```

It installs OpenVPN if needed and creates the first inbounds. `ovira openvpn disable` stops them again; the panel and its other nodes keep working.

## Devices at once

The device limit counts a client's tunnels on **all** inbounds together. With a limit of 2, a client may use two devices anywhere: both on one node, or one on each.

## Traffic multiplier

Each node (and the main server) has a multiplier for quota accounting:

| Multiplier | 1 GB used there counts as |
|---|---|
| ×1 | 1 GB |
| ×1.5 | 1.5 GB |
| ×0.5 | 0.5 GB |
| ×0 | nothing (free traffic) |

The traffic shown on the node's card is always the real amount. Subscription pages show the multiplier next to each inbound.

## Connect addresses (relays and tunnels)

By default clients connect to the node's own address. If you put **relay servers** in front of a node (for example servers inside the country tunneled to a node abroad), add their addresses in the node's editor under **Connect addresses**:

| Field | Example |
|---|---|
| Label | `Tehran relay` |
| Host | `ir1.example.com` |
| Port | empty = the inbound's own port, or the relay's port |
| For | All inbounds, or one OpenVPN inbound on the node |

Each enabled address becomes an endpoint profile on the subscription page. The all-in-one profile includes failover `remote` lines only for inbounds compatible with its first inbound's OpenVPN settings; it does not combine every protocol and authentication mode. Set up the actual relay or tunnel separately: adding a connect address only changes the endpoints advertised to clients.

::: warning
When a node has connect addresses, profiles use only those. Add the node's own address too if clients may also connect directly.
:::

## When a node goes offline

If only the management connection is lost, existing OpenVPN processes may keep their tunnels running, but new authentication and live quota enforcement depend on the panel connection. A host or VPN service outage interrupts tunnels. After reconnection, the panel reconciles surviving sessions and their counters; it cannot recover counters lost when the VPN process itself restarted.

## Remove a node

**Nodes → ⋯ → Remove node** stops its inbounds and takes them out of every profile. To remove the software from the node itself:

```bash
ovira --node --uninstall --purge
```
