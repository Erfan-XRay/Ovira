# How Ovira fits together

Ovira has one [panel](/reference/glossary#panel) that holds every decision and any number of [nodes](/reference/glossary#node) that carry the traffic. This page names the pieces and shows who talks to whom. The other pages in this section explain the mechanisms one at a time.

## The pieces

| Piece | What it is | Where it runs |
|---|---|---|
| **Panel** | The web interface, the database and the rules: who may connect, how much traffic they have left, what each inbound looks like. | One server. |
| **Node** | A server that runs inbounds for the panel. Clients connect to it. | Any number of servers. |
| **This server** | The panel's own machine, when you let it act as a node too. | The panel's server. |
| **Inbound** | One VPN server with a port, a protocol and a tunnel network. It is defined in the panel and runs on exactly one node. | On a node. |
| **Relay** | A server in front of a node that forwards traffic to it. Ovira does not run it; you tell Ovira its address. | Anywhere. |
| **Subscription page** | The page a client opens to get its profile, QR code or server address. | Served by the panel. |

An inbound that is not attached to a node is stored under **Not on a node** and does not run.

## Who talks to whom

- **Clients connect to a node**, on the port of an inbound. The panel is not in the path of the traffic.
- **The panel connects to each node**, on the node's API port (TCP 62060 by default). The node never connects to the panel. Through that connection the panel sends the node what to run, and reads its state, its sessions and its traffic counters.
- **Clients open the subscription page on the panel**, at `https://PANEL:PORT/sub/TOKEN`. That page lists only the connections the client may use.
- **The panel and the nodes trust each other through the node key.** The install command on a node prints it, and you paste it into the panel once. The panel then talks only to that node.
- **Administrators use the panel** at the secret path printed by the installer.

On the panel's own server the same arrangement applies, without a separate node program: the panel starts the inbounds itself.

## What the panel decides, and when

Every time a client connects, the node asks the panel whether to let it in. The panel answers from its database: the client must exist, be enabled, be within its end date and traffic, be allowed on that inbound, and be under its device limit. The details are in [The life of a connection](./connection).

While clients are connected, the panel reads their byte counters every few seconds, adds them to the client's usage and disconnects the client when it runs out. See [Traffic, quotas and limits](./traffic).

If the panel cannot be reached, nodes keep what is already running but cannot accept new sign-ins. See [A node and its panel](./nodes).

## Related pages

- [The life of a connection](./connection): how a client is let in and cut off.
- [Traffic, quotas and limits](./traffic): counting, multipliers and resets.
- [A node and its panel](./nodes): the link between them and what happens when it breaks.
- [Relays and connect addresses](./relays): putting a server in front of a node.
- [Add a node](/start/add-node): the install command.
