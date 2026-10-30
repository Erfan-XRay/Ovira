# Glossary

The terms the documentation uses, in alphabetical order, with the same names the panel shows. Each entry is short and points to the page that explains it.

## Active client

A client that is enabled and has not passed its end date. Plans limit the number of active clients. A client that has used its traffic still counts until it is disabled or expires. See [License](/use/license).

## Amnezia mode

A WireGuard inbound with **Amnezia obfuscation** turned on, for networks that block plain WireGuard. Clients use AmneziaVPN or AmneziaWG. See [WireGuard and AmneziaWG](/protocols/wireguard).

## Attach

Putting an inbound on a node so that it runs. You attach from **Nodes → Attach inbound**. The node is checked first, and nothing changes if a check fails. **Detach** stops the inbound and returns it to **Not on a node**. See [Nodes](/use/nodes).

## Camouflage

An OpenConnect setting that makes the inbound answer scanners with a plain refusal. Only an address that includes the secret reaches the login. See [OpenConnect](/protocols/openconnect).

## Certificate pin

A fingerprint of an OpenConnect server's certificate, shown on the client's subscription page. Apps that cannot verify the server can compare it. See [OpenConnect](/protocols/openconnect#certificate).

## Client

One customer's VPN account. A client has a name, a traffic allowance, an end date, a device limit and a list of inbounds, and works on every node. The name is also the VPN user name. See [Clients](/use/clients).

## Connect address

An extra address under a node's **Connect addresses** that clients use instead of the node's own, normally the address of a relay. See [Relays and connect addresses](/how/relays).

## Connections

The page that lists open tunnels live and finished ones in its history. It has the **Disconnect** button. See [Connections](/use/connections).

## Device

For WireGuard, one numbered configuration of a client, **Device 1**, **Device 2** and so on, imported on one phone or computer. For the other protocols, any open connection of the client counts as a device against the device limit.

## Device limit

The most connections a client may have open at once, set in **Devices at once**. It counts across all inbounds, nodes and protocols. 0 means no limit. See [The life of a connection](/how/connection).

## DTLS

The UDP part of an OpenConnect inbound. It uses the same port number as the TCP part and gives better speed. Apps fall back to TCP when UDP is blocked.

## First connection

The moment a client first connects. If its end date was set with **Start the clock → At first connection**, the days start counting then. Until it happens the status is **Not started**. See [Traffic, quotas and limits](/how/traffic#when-the-clock-starts).

## Fixed tunnel address

An address inside an inbound's reserved range that a client always receives, for OpenVPN and OpenConnect. The last quarter of an inbound's tunnel network is reserved for these.

## Group

A named set of inbounds. A client in groups gets the inbounds of its enabled groups. A group can include **All inbounds, including ones added later**. See [Groups](/use/groups).

## Inbound

One VPN server with a protocol, a port and a tunnel network. It is created in the panel and runs on one node. Until it is attached it is under **Not on a node**. See [Inbounds](/use/inbounds).

## License

Decides the plan: how many active clients, nodes, panels and panel accounts you can have, and whether reseller accounts are available. See [License](/use/license).

## Local node

See **This server**.

## Node

Another server that runs inbounds for the panel. The panel connects to it with a node key. Clients are created once and work on every node. See [A node and its panel](/how/nodes).

## Node key

A line starting `BNK1-` that the node installer prints. You paste it into **Nodes → Connect a node**. `ovira key` on the node prints it again. Keep it private.

## Not on a node

The place an inbound sits after you create it, or after it is detached or its node is removed. Inbounds there do not run, and clients keep their access to them.

## Overview

The panel's first page, with online clients, traffic, running-out plans and the state of the server. See [Overview](/use/dashboard).

## Owner

The panel account with no limits. It manages everything, including accounts, roles, settings, license and updates. Other roles cannot do those.

## Panel

The web interface and the program behind it. It holds the database, makes every connection decision and manages the nodes. See [How Ovira fits together](/how/).

## Panel account

A person who signs in to the panel, with a role. The owner, admins and resellers are all panel accounts. See [Panel accounts](/use/admins).

## Periodic reset

A client's **Reset traffic** setting: **Never**, **Every day**, **Every week** or **Every month**. When a period begins, the client's used traffic goes back to zero. See [Traffic, quotas and limits](/how/traffic#periodic-resets).

## Plan

The set of limits that comes with a license. The Free plan needs no license. See [License](/use/license).

## Protocol

OpenVPN, WireGuard or OpenConnect. It is chosen when an inbound is created and cannot be changed. See [Choosing a protocol](/protocols/).

## Public address override

An inbound field that replaces the address written into clients' profiles. Empty means the node's own address.

## Relay

A server in front of a node that forwards clients' traffic to it. Ovira does not run relays. You list their addresses as connect addresses.

## Reseller

A panel account that manages only its own clients, within a client limit and, optionally, a traffic pool and an end date. Resellers need a plan that includes them. See [Resellers](/use/resellers).

## Role

What a panel account may do. **Admin** and **Reseller** are built in. You can duplicate a role and change the copy. A role sets, for each action, whether it applies to the account's own clients or to all clients. See [Panel accounts](/use/admins).

## Secret path

The part after the panel's address that opens the admin interface, for example `/k3x9qa7bd1/`. Everything else on the panel port, except subscription pages, answers `404`.

## Status

What a client's state is: **Active**, **Disabled**, **Expired**, **Used up** or **Not started**.

## Subscription link

The address of a client's subscription page, in the form `https://PANEL:PORT/sub/TOKEN`. Copy it from the client's row and send it to the customer.

## Subscription page

The page a client opens to see its usage and get its profile, QR code or server address, with tabs for OpenVPN, WireGuard, AmneziaWG and Cisco. See [Subscription page](/use/subscription-page).

## This server

The panel's own machine, shown on **Nodes** as a node when it is allowed to run inbounds. If it is not, its card says **Panel only**. See [This server as a node](/start/same-server).

## Traffic allowance

A client's total of upload and download it may use. Empty means unlimited.

## Traffic multiplier

A number on each node that changes how much of a client's allowance traffic on that node uses. At 1.5, 1 GB used there counts as 1.5 GB. See [Traffic, quotas and limits](/how/traffic#the-node-multiplier).

## Traffic pool

A reseller account's shared allowance. All its clients draw from it. When it is used up, all of them stop. See [Traffic, quotas and limits](/how/traffic#reseller-pools).

## TUN

The `/dev/net/tun` device that VPNs need. Almost every VPS has it. The **Nodes** page shows **No TUN** where it is missing.

## Tunnel network

The private IPv4 range from which an inbound hands out client addresses. It must not overlap another inbound or a route on the node.
