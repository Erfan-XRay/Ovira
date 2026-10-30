# Nodes

A [node](/reference/glossary) is a server that runs inbounds for the panel, whatever the protocol. The **Nodes** page shows one card per node, starting with **This server**. A client created once works on every node, and its device limit counts across all of them. This page covers the cards, the node dialog, traffic multipliers, connect addresses for relays, and removing a node. To install a node, see [Add a node](/start/add-node).

## The cards

Each card shows the node's name and its state:

| State | Meaning |
|---|---|
| **Connected** | The panel reaches the node. |
| **Unreachable** | The panel cannot reach it. The card shows when it was last seen. |
| **Disabled** | You switched the node off in its dialog. |
| **Panel only** | The card of **This server** when the server does not run inbounds. |

A chip shows the traffic multiplier. Below the name:

- **Online now**, **Inbounds**, **Real traffic**, and for a node that reports them **CPU**, **Memory** and **Up for**.
- The versions: `Ovira X · OpenVPN Y`, then `WireGuard ready` or `No TUN`. WireGuard needs `/dev/net/tun` on the node.
- The OpenConnect state: its version, or a note that it is not installed, or `Update this node to use OpenConnect` for an older node.
- **Connect addresses**, if any.
- The inbounds on the node, each with a **Detach** icon, and the **Attach inbound** button.

Owners also see **Edit** and the **More** menu:

| Action | What it does |
|---|---|
| **Send settings again** | Pushes the node's configuration to it again. Not for **This server**. |
| **Reset traffic counter** | Sets the node's traffic counter to zero. |
| **Remove node** | Takes the node out of the panel, see below. Not for **This server**. |

The page banner says `Your license allows N nodes` when the limit is reached. The panel's own server does not count against it. Connecting a node needs a license with the nodes feature, and the free plan allows two.

## Attach, detach and move inbounds

New inbounds are saved under **Not on a node** and do not run. On a card, press **Attach inbound**, choose the inbound in **Choose an inbound**, and confirm. The panel checks the node first: the port, overlapping tunnel networks, and for OpenConnect the installed software and certificate. If a check fails, nothing changes and the dialog says why.

**Detach** stops an inbound and returns it to **Not on a node**. Clients keep their access, and the clients connected to it are disconnected. To move an inbound, use **Attach inbound** on another node and choose it under **Move from another node**. The new node is checked before the inbound leaves the old one, and connected users are disconnected.

For OpenConnect on **This server**, press **Install OpenConnect** on the card first. Remote nodes install it themselves when the inbound is attached.

## The node dialog

**Connect a node** opens the dialog in three steps; **Edit** opens the same fields for an existing node.

| Field | What it does |
|---|---|
| **Node key** | The key the node installer printed. Leave empty when editing to keep the current key, and paste a new one after you reinstall the node. |
| **Node address** | The IP or domain the panel uses to reach the node. Filled from the key. |
| **Node port** | The port the node listens on. Default `62060`. |
| **Name** | 1 to 40 characters. It appears on subscription pages. |
| **Traffic multiplier** | How the node's traffic counts toward quotas, from 0 to 20. |
| **Connect addresses** | Addresses that clients use instead of the node's own. See below. |
| **Note** | Free text, up to 500 characters. |
| **Enabled** | When off, the panel stops managing the node and its inbounds leave every profile. Tunnels already open stay up. |

For **This server**, the key, address, port and **Enabled** are not shown.

## Traffic multiplier

The multiplier changes how much of a client's quota the traffic on a node uses.

| Multiplier | 1 GB used on the node counts as |
|---|---|
| 1 | 1 GB |
| 1.5 | 1.5 GB |
| 0.5 | 0.5 GB |
| 0 | nothing |

Use it to make an expensive link cost more, or a free one cost nothing. The traffic on the card, in **Real traffic**, is always the real amount. Subscription pages show the multiplier next to each inbound.

## Connect addresses and relays

By default clients connect to the node's own address. If a relay or tunnel server sits in front of a node, add its address under **Connect addresses**, so the profiles clients download point at it.

| Field | What it does |
|---|---|
| **Label** | A name for the address, for example `Tehran relay`. |
| **Host** | The relay's domain or IP. |
| **Port** | Empty means the inbound's own port. A different port needs a specific inbound under **For** when the node runs several. |
| **For** | **All inbounds**, or one inbound on this node. |

Each address becomes its own profile for clients, plus a `remote` line in the all-in-one profile. You can add up to 32 addresses per node.

Adding a connect address changes only what the profiles advertise. It does not set up the relay. You still configure the relay or tunnel yourself.

::: warning
When a node has connect addresses, profiles use only those. Add the node's own address as one of them if clients may also connect directly, or direct connections disappear from the profiles.
:::

## Remove a node

**More → Remove node** asks for confirmation. The node's inbounds stop and move to **Not on a node**, and clients keep access to them. The software stays installed on the server; remove it there with `ovira uninstall` (see [Remove Ovira](/start/uninstall)). Attach the inbounds to another node to run them again.

## Related pages

- [Add a node](/start/add-node): installing and connecting a new node.
- [Inbounds](/use/inbounds): create inbounds before attaching them.
- [How a node and its panel work together](/how/nodes): the link, and what a node does when the panel is away.
- [Traffic, quotas and limits](/how/traffic): how multipliers enter the count.
