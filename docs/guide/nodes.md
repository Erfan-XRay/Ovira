# Nodes and relays

A **node** is another server that runs OpenVPN for your panel. Clients are created once, in the panel, and work on every node.

## Add a node

**1. On the new server**, as root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) --node --panel-ip PANEL_IP
```

`--panel-ip` makes the node answer only your panel. The installer prints a **node key** (`BNK1-…`). The node listens on TCP port **62060**; use `--port` for another one.

**2. In the panel**, **Nodes → Connect a node**, paste the key, give it a name and save. The panel connects within seconds.

**3. Add an OpenVPN server on it**: on the node's card, **Add a server here**. Pick its port and protocol like on the main server.

The node key contains the node's API key and its certificate fingerprint, so the panel talks only to that node. If you reinstall a node, paste its new key in the node's editor. `ovira node key` prints the key again.

## Devices at once

The device limit counts a client's tunnels on **all** servers together. With a limit of 2, a client may use two devices anywhere: both on one node, or one on each.

## Traffic multiplier

Each node (and the main server) has a multiplier for quota accounting:

| Multiplier | 1 GB used there counts as |
|---|---|
| ×1 | 1 GB |
| ×1.5 | 1.5 GB |
| ×0.5 | 0.5 GB |
| ×0 | nothing (free traffic) |

The traffic shown on the node's card is always the real amount. Subscription pages show the multiplier next to each server.

## Connect addresses (relays and tunnels)

By default clients connect to the node's own address. If you put **relay servers** in front of a node (for example servers inside the country tunneled to a node abroad), add their addresses in the node's editor under **Connect addresses**:

| Field | Example |
|---|---|
| Label | `Tehran relay` |
| Host | `ir1.example.com` |
| Port | empty = the server's own port, or the relay's port |
| For | All servers, or one OpenVPN server on the node |

Every address becomes **its own profile** on the subscription page, and a failover `remote` line in the all-in-one profile. Four relays in front of two nodes give clients four profiles to choose from.

::: warning
When a node has connect addresses, profiles use only those. Add the node's own address too if clients may also connect directly.
:::

## When a node goes offline

Tunnels on it keep running. The panel reconnects when the node is back, sends anything that changed while it was away, and counts traffic without counting anything twice.

## Remove a node

**Nodes → ⋯ → Remove node** stops its OpenVPN servers and takes them out of every profile. To remove the software from the node itself:

```bash
bash install.sh --node --uninstall --purge
```
