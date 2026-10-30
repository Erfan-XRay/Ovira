# Relays and connect addresses

A relay is a server that sits between your clients and a [node](/reference/glossary#node) and forwards their traffic to it. Customers in a country with a poor route to your node often connect to a nearby relay instead. Ovira does not build the relay. It lets you tell the panel the relay's address, and it then hands that address to clients. This page explains how the addresses are used and what a relay has to do.

## What Ovira does

On a node's editor, under **Connect addresses**, you can add addresses:

| Field | What it does |
|---|---|
| **Label** | A name shown to you and the client, for example `Tehran relay`. |
| **Host** | The relay's host name or IP address. |
| **Port** | Empty means the inbound's own port. Fill it in if the relay listens on a different one. |
| **For** | **All inbounds** on the node, or one inbound. |

Each address then becomes its own connection on the client's subscription page:

- For OpenVPN, a separate profile, plus a `remote` line in the **All servers in one profile** file. That file only combines inbounds whose settings are compatible with the first one.
- For WireGuard, a separate configuration whose endpoint is the relay.
- For OpenConnect, a separate server address.

Everything else is unchanged. The client signs in as usual, the node still makes the decision, and the traffic is still counted on the node, with that node's multiplier.

## Which address a client gets

For each inbound a client may use, the panel picks the address like this:

1. If the node has connect addresses that apply to the inbound, the client gets those, and only those.
2. Otherwise, if the inbound has a **Public address override**, the client gets that.
3. Otherwise the client gets the node's own address. For **This server**, that is the public address set in **Settings**, or the address the client used to open the subscription page.

Step 1 means that adding a relay hides the node's own address. If customers should also be able to connect directly, add the node's own address as another connect address.

## What the relay must do

The relay is your own server, and it has to be set up outside Ovira. Whatever it uses, it must forward:

- the relay's port to the inbound's port on the node, using the same protocol;
- UDP for WireGuard, and for OpenVPN inbounds that use UDP;
- TCP, and UDP if **DTLS** is on, for OpenConnect.

Two consequences follow from the relay being the one clients reach:

- The node sees the relay's address as the client's address, not the customer's. The **From** column on **Connections** then shows the relay.
- An OpenConnect inbound with a trusted certificate presents the node's name, which does not match the relay's name. Cisco shows a mismatch. Use the certificate pin in an OpenConnect app, or the Ovira certificate. See [OpenConnect](/protocols/openconnect#certificate).

## Changing a relay's address

Profiles and configuration files carry the address they were created with. If you remove or change a connect address, clients that already imported a file keep trying the old one and fail. Add the new address first, tell clients to re-import, and remove the old address once they have.

## Related pages

- [A node and its panel](./nodes): what the panel does for a node.
- [Nodes](/use/nodes): the editor where connect addresses are entered.
- [OpenVPN](/protocols/openvpn): the profile files a relay address changes.
- [WireGuard and AmneziaWG](/protocols/wireguard): the **Public address override** for relays.
