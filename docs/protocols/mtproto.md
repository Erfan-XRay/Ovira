# Telegram proxy (MTProto)

A Telegram proxy inbound gives each client a personal proxy link for Telegram. The client taps **Open in Telegram** on the subscription page and Telegram works without a VPN. This page covers creating the inbound, the connection modes and what clients see.

## What it is good for

- Customers who only need Telegram and do not want to install anything.
- A light extra for clients who also have a VPN inbound.

Traffic through the proxy counts toward the client's traffic limit. The end date and the device limit apply too: the device limit is the number of addresses connected at once. A client that is expired, disabled or out of traffic has its proxy paused.

## Create an inbound

1. Open **Inbounds** and press **New inbound**.
2. Pick **Telegram proxy**. The protocol cannot be changed after the inbound exists.
3. Give it a **Name**. The form suggests port 443, which looks like ordinary web traffic.
4. Check the connection modes and the cover site below, or keep the defaults.
5. Under **Access**, choose which groups and clients get it, then press **Create**.
6. On **Nodes**, press **Attach inbound** on the target node, including **This server**.

It uses no tunnel network, so it never clashes with another VPN's address range. The port must be free on the server: another inbound on the same port, or the panel itself, blocks it. It runs on nodes and on the panel's own server.

## Connection modes

| Mode | What it does |
|---|---|
| **Fake-TLS** | The connection looks like a normal visit to a real website. The hardest to detect, and the right choice for almost everyone. Needs a recent Telegram app. |
| **Secure** | Random padding. Easier to detect than Fake-TLS. |
| **Classic** | The original mode. The easiest to detect and block. |

Turn on **Secure** and **Classic** only for old apps. Clients get **Links for older apps** on their page for these.

## Cover site

Fake-TLS pretends to be a visit to one site. Set **Fake-TLS domain** to a large, popular site that opens from inside Iran. Anything that is not Telegram is passed on to the real site (**Pass other traffic to the real site**).

::: warning Changing the domain
The domain is part of every client's link. If you change it later, every client has to add the proxy again with the new link.
:::

## More options

- **Sponsored channel tag**: a 32-character tag from @MTProxybot that shows a sponsored channel in Telegram. A single client can have its own tag, or use the inbound's.
- **Connection limit**: the simultaneous connections of the whole proxy.
- **Listen on IPv6**: lets clients reach the proxy over IPv6 as well.

## What clients see

The client's page shows a **Telegram proxy** section with **Open in Telegram** and a QR code. Telegram asks for confirmation; tap **Connect**. Keep Telegram up to date, because older versions cannot use Fake-TLS.

Telegram voice and video calls do not go through a proxy. [Outbound routing](/use/routing) does not apply to it either.

On the client's page in the panel, a **Telegram proxy** section shows connections now, the addresses they come from and the proxy traffic. **Replace the secret** stops every proxy link of that client at once, so the client has to add the proxy again.

## Related pages

- [Choosing a protocol](./): compare it with the VPN protocols.
- [Inbounds](/use/inbounds): create, attach and delete inbounds.
- [Subscription page](/use/subscription-page): what the client sees.
