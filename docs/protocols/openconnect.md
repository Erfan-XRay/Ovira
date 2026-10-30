# OpenConnect

OpenConnect is the open implementation of the Cisco AnyConnect protocol. An OpenConnect [inbound](/reference/glossary#inbound) looks like ordinary HTTPS on port 443, and clients sign in with their name and password in Cisco Secure Client (the app formerly called AnyConnect) or in an OpenConnect app. This page covers creating the inbound, its settings, the certificate choices and what clients do.

## What it is good for

- Networks that block OpenVPN but let HTTPS through.
- Customers who already use the Cisco app and only want to type an address and a password.
- Setups where you want the server to answer scanners with a plain refusal. See **Camouflage** below.

## Create an inbound

1. Open **Inbounds** and press **New inbound**.
2. Under **Protocol**, pick **OpenConnect**. The protocol cannot be changed after the inbound exists.
3. Give it a **Name** and keep port 443 if it is free on the node you attach it to. Set the **Tunnel network**. **Certificate** can stay on **Automatic (chosen when attached)**.
4. Press **Create**. The inbound is saved under **Not on a node** and does not run yet.
5. On **Nodes**, press **Attach inbound** on the target node's card and pick the inbound.

Attaching is where the checks happen: the port, tunnel network overlaps, whether OpenConnect is installed, and the certificate. If a check fails, nothing changes and the dialog shows the reason. Creating or editing an inbound does not check any of these.

To use OpenConnect on the panel's own server, press **Install OpenConnect** on the **This server** card on **Nodes** and wait for it to finish before you attach the inbound. Any other node installs OpenConnect by itself when the first OpenConnect inbound is attached to it.

::: tip Node version
A node needs Ovira 0.6.0 or newer to run OpenConnect. The **Nodes** page shows the OpenConnect version of every node, or that it is not installed. While OpenConnect inbounds exist, Ovira refuses to install an older version.
:::

## Settings

| Field | What it does |
|---|---|
| **DTLS (UDP) for speed** | On by default. Also opens UDP on the same port number. Apps fall back to TCP when UDP is blocked. |
| **Cisco client compatibility** | On by default. Keep it on for Cisco Secure Client. |
| **Camouflage** | On by default. Only an address that includes the secret (`https://host:443/?secret`) reaches the VPN login. Every other request sees a plain refusal. Needs `ocserv` 1.2.0 or newer; on older versions the option is greyed out and shows the version found. |
| **Camouflage secret** | Part of the address you give clients. Changing it means sending them the new address. **New secret** generates one. |
| **Camouflage text** | What a browser sees when it opens the address without the secret. Default "Restricted Content". |
| **Idle timeout**, **Idle timeout, mobile** | How long an idle session stays open. Defaults 1200 and 2400 seconds. |
| **Dead peer detection**, **Dead peer detection, mobile** | Seconds of silence before a client is dropped. Defaults 90 and 1800. |
| **Session resume window** | How long a client can reconnect without signing in again. Default 300 seconds. Keep it short so a blocked client cannot keep resuming. |
| **TLS priorities** | A GnuTLS priority string. Leave it unless you know you need to change it. |
| **PROXY protocol** | Only for a relay in front that sends PROXY headers. |
| **Extra ocserv directives** | Directives that run scripts, change sign-in or write files are refused. |

DNS, routes, NAT, IPv6, **Max connected clients**, **Tunnel network** and **Public address override** work as for [OpenVPN](./openvpn#network-and-routing). OpenVPN-only options such as ciphers and tls-crypt are hidden.

Clients sign in with their client name and password. Certificates are not used for sign-in.

## Certificate

OpenConnect always uses TLS, so the app checks the server's certificate. Choose a source under **Certificate**, or leave **Automatic** and let the node choose when the inbound is attached.

| Source | Available on | What clients see |
|---|---|---|
| **Ovira certificate (self-signed)** | Any node | Works anywhere. Cisco apps warn that the server is untrusted. Clients can instead compare the certificate pin shown on their page. |
| **Panel certificate (trusted)** | This server | No warning, because it is the panel's own Let's Encrypt certificate. The panel needs HTTPS (see [HTTPS for the panel](/start/https)), and clients must connect to the same domain or address the certificate was issued for. |
| **Trusted (Let's Encrypt, from the node)** | Remote nodes | No warning. The node gets a free certificate for its own IP address or for a domain name. Clients must connect to that name or address. |

Certificate availability is checked when the inbound is attached. When the panel renews its certificate, or you issue one with `ovira ssl issue`, the OpenConnect inbounds that use it reload it by themselves and connected clients stay connected.

### Trusted certificates on a node

Choose **Trusted (Let's Encrypt, from the node)** and fill in **Certificate name**:

- A domain name such as `vpn.example.com`. It must already point at the node with an `A` record. Let's Encrypt checks it from the outside, so a name that points elsewhere cannot be issued. Certificates for a name last about 90 days.
- Empty, for a certificate for the node's IP address. This works when the node was added to the panel by its IP address. Such certificates are short-lived, about six days, and renew by themselves every few days.

The node, not the panel, asks Let's Encrypt, because Let's Encrypt must reach the machine that clients connect to. The node keeps its certificates in its own data directory, renews them well before they end, retries with growing pauses if a renewal fails, and reloads the server without disconnecting anyone.

::: warning Port 80 on the node
Let's Encrypt validates on TCP port 80. The node opens that port in its own firewall only while it validates. Keep port 80 free on the node, and open in any cloud firewall, for the first certificate and for every renewal.

If port 80 is taken, the node can use TCP 443 instead, but only while the OpenConnect server is not running on it yet. If neither works, the inbound keeps serving the Ovira certificate and **Inbounds** shows the reason.
:::

The **Inbounds** page shows each inbound's certificate: the name, when it expires and any problem. While a trusted certificate is not available, the inbound serves the Ovira certificate and the page says so. Clients then see the pin instead of a trusted address.

::: warning Relays
A trusted certificate belongs to the node's name or address. A client that connects through a [relay](/how/relays) address sees a different name, and Cisco shows a name mismatch. On the subscription page only addresses equal to the certificate's name are marked trusted. For relays, use the pin with an OpenConnect app, or the Ovira certificate. A Let's Encrypt certificate gets a new key at every renewal, so its pin changes each time.
:::

## What clients need

The **Cisco** tab on the client's subscription page shows:

- the **Server address**, with a copy button and a **Show QR code** option;
- the client's user name and password;
- links to the apps for their device;
- under **Advanced: certificate pin**, the pin, only for addresses without a trusted certificate.

In the app:

1. Install **Cisco Secure Client** (Android, iPhone and iPad, Windows, macOS) or an OpenConnect app: **OpenConnect** on Android, **OpenConnect-GUI** on Windows, `openconnect` on Linux and macOS. See [Client apps](./apps).
2. Add a new connection with the server address from the page.
3. Sign in with the user name and password.

With a trusted certificate the app connects without a warning. With the self-signed Ovira certificate, Cisco Secure Client needs **Block untrusted servers** turned off in its settings before it connects. OpenConnect apps ask you to accept the certificate, and you can compare the pin first.

On the admin side, a client's page lists its OpenConnect inbounds with their address and pin instead of a profile download.

## What it cannot do

- It cannot use client certificates. Sign-in is always name and password.
- It cannot share TCP port 443 with an OpenVPN inbound on the same node. Pick another port for one of them.
- A trusted certificate cannot cover a relay's address.
- Camouflage cannot be used with `ocserv` older than 1.2.0.

## Related pages

- [Choosing a protocol](./index): when OpenConnect is the right choice.
- [Client apps](./apps): the Cisco and OpenConnect apps by platform.
- [Relays and connect addresses](/how/relays): why a relay changes the certificate name.
- [Troubleshooting](/reference/troubleshooting): untrusted-server warnings and certificates that are not issued.
