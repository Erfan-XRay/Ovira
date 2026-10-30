# A node and its panel

A [node](/reference/glossary#node) is a server that runs inbounds for a [panel](/reference/glossary#panel). This page explains how the two stay connected, what the panel sends to a node, and what each protocol does when the panel cannot be reached.

## The link

The panel opens the connection, never the node. Each node runs a small service, `ovira-node`, that listens on TCP port 62060 (or the port you chose with `--port`) and answers only the panel that holds its key.

- The **node key** is printed when you install the node, and `ovira key` on the node prints it again. You paste it into **Nodes → Connect a node**. It is what lets the panel and the node recognise each other, so treat it like a password. Anyone with the key and access to the node's port can manage the node.
- If you installed the node with `--panel-ip`, the node accepts calls only from that address. Without it, any address with the key can connect.
- If you reinstall a node, its key changes. Paste the new key into the node's editor in the panel.

The firewall in front of the node must allow the panel to reach that port. Clients never use it.

## What the panel keeps in sync

Every ten seconds the panel asks each node for its status: versions, load, which inbounds are running and a fingerprint of the configuration it last applied. If the configuration differs from what the panel wants, the panel sends the whole desired state, and the node writes the files and starts, restarts or removes inbounds to match.

That desired state is every inbound attached to the node, with its certificates, keys and settings. It is why you edit inbounds in the panel and never on the node. Changes you make on the node by hand are overwritten.

The node's card on **Nodes** shows the result:

| Card says | Meaning |
|---|---|
| **Connected** | The last status request succeeded. |
| **Unreachable** | The panel could not reach the node. The card shows when the node was last seen and the error. |
| **Disabled** | You switched the node off. The panel stops managing it and its inbounds leave every client's profile. Tunnels already open stay up. |

The node's card also has **Send settings again**, which makes the panel resend the desired state immediately. Use it after fixing a problem the card reported, such as an installation that failed.

A node and a panel that run incompatible versions refuse to work together, and the card says so. Update the node from **Updates**.

## While the panel is away

Nodes and the panel are separate machines, so the link can break while the node keeps running. What happens depends on the protocol.

| Protocol | Connections already open | New sign-ins |
|---|---|---|
| OpenVPN | Stay up. | Not accepted until the panel is back. |
| OpenConnect | Stay up. | Wait a few seconds for the panel, then are refused. |
| WireGuard | Stay up for about two minutes. After that the node drops every device on the inbound. | Not accepted. |

The reason is that sign-in decisions are made by the panel. A node that cannot ask cannot let anyone new in, and for WireGuard it cannot know whether a device should still be allowed.

While the panel is away, nothing is counted on that node and nobody is cut off for traffic or an end date. When the link returns:

1. The panel reads which connections are open and gives each a session record, including ones that started while it was away.
2. It adds the traffic that passed on connections that stayed open, using the counters kept by the VPN process.
3. It re-checks every client and cuts off those who ran out in the meantime.

Traffic is lost only if the VPN process itself restarted while the panel was away, because its counters restart too. A connection that tried to sign in during the outage and was left waiting is made to retry, so it does not take up a device slot.

## What does not interrupt connections

- Restarting the node service, `ovira restart` on the node, leaves inbounds running.
- Updating a node restarts only its service, and tunnels stay up.
- **Disabled** on the node's card, or removing the node from the panel, stops the panel from managing it. A disabled node keeps its open tunnels. A removed node stops its inbounds and moves them to **Not on a node**.
- Restarting or updating the panel does not stop inbounds, and its link to the nodes is back within seconds.

Connections end when the machine reboots, the inbound is stopped or detached, or the VPN process crashes.

## Related pages

- [How Ovira fits together](./index): the overview of panel, nodes and clients.
- [Traffic, quotas and limits](./traffic): what is counted while the link is up.
- [Nodes](/use/nodes): the page where you connect, attach inbounds and set multipliers.
- [Add a node](/start/add-node): the install command and what the node needs.
- [Troubleshooting](/reference/troubleshooting): a node that stays **Unreachable**.
