# OpenConnect (Cisco)

Besides OpenVPN, Ovira can run **OpenConnect** inbounds. OpenConnect is the open version of Cisco AnyConnect: clients use **Cisco Secure Client** (the app formerly called AnyConnect) or any **OpenConnect** app. Clients, groups, traffic limits, end dates, device limits, node multipliers and the live connections list work the same way as for OpenVPN.

## OpenVPN or OpenConnect?

| | OpenVPN | OpenConnect |
|---|---|---|
| Client app | OpenVPN Connect and others | Cisco Secure Client, OpenConnect apps |
| Setup for a client | Import a profile file | Type in an address, sign in |
| Sign-in | Certificate and/or password | User name and password |
| Transport | UDP or TCP | TCP on the port, plus UDP (DTLS) on the same port number |
| Looks like | VPN traffic | Ordinary HTTPS on port 443 |

Choose OpenConnect when a network blocks OpenVPN but lets HTTPS through, or when your customers already know the Cisco app. Both kinds can run side by side. A client allowed on both uses the same user name and password everywhere.

OpenConnect is available on every plan, Free included. Clients and nodes count against your limits exactly as for OpenVPN.

## Create an inbound

1. **Inbounds → New inbound**.
2. Under **Protocol**, pick **OpenConnect (Cisco)**. The protocol is fixed once the inbound exists.
3. Give it a **Name** and keep port **443** if it is free on the node you attach it to. Set the tunnel network; **Certificate** can stay on **Automatic** so the node chooses when attached.
4. Press **Create**. It is saved under **Not on a node** and does not run yet.
5. On **Nodes**, press **Attach inbound** on the target node's card (including **This server**) and select it. Port availability, tunnel network overlaps, OpenConnect installation and the certificate are checked against that node here. If a check fails, nothing changes and the dialog shows why; otherwise the inbound starts there.

To use OpenConnect on the panel's own server, press **Install OpenConnect** on the **This server** card on **Nodes** and wait for installation to finish before attaching the inbound there. Another node installs OpenConnect by itself when the first OpenConnect inbound is attached to it. Creating or editing an inbound does not check installation or certificate availability.

::: tip Nodes
A node needs a recent Ovira version to run OpenConnect. If the attach dialog says the node must be updated, update it from **Updates** (nodes follow the panel) and try again. The Nodes page shows the OpenConnect version of every node and of the main server, or *not installed*.
:::

## Settings

- **DTLS (UDP)**: also opens UDP on the same port number for better speed. Apps fall back to TCP when UDP is blocked. Leave it on unless UDP causes trouble.
- **Cisco client compatibility**: keep on for Cisco Secure Client.
- **Camouflage**: hides the inbound from scanners and probes. Only an address that includes the secret (`https://host:443/?secret`) reaches the VPN login; every other request sees a plain refusal. The secret is part of the address you give clients, so changing it means sending them the new address. Camouflage needs **ocserv 1.2.0 or newer**; on older versions the option is greyed out and shows the version found.
- **Timeouts**: idle timeouts and dead-peer detection for desktop and mobile apps, and how long a client may resume a session without signing in again. Keep that last one short so a blocked client cannot keep resuming.
- **TLS priorities**, **PROXY protocol** (only for a relay in front that sends PROXY headers) and **extra directives** are for special cases. Directives that run scripts, change sign-in or write files are refused.

DNS, routes, NAT, IPv6, maximum clients, tunnel network and the public address override work as for OpenVPN. OpenVPN-only options (ciphers, tls-crypt, compression and so on) are hidden.

## Certificate

OpenConnect always uses TLS, so the app checks the server's certificate. Leave **Certificate** on **Automatic** for the node to choose when attached, or pick a source per inbound:

| Source | Where | What clients see |
|---|---|---|
| **Ovira certificate** (self-signed) | Any server | Works anywhere. Cisco apps warn that the server is untrusted; clients can instead check the **certificate pin** shown on their page. |
| **Panel certificate** (trusted) | Servers on the panel's own server | No warning, because it is the panel's own Let's Encrypt certificate. Needs an HTTPS certificate on the panel (see [HTTPS](./https)), and clients must connect to the same domain or IP the certificate was issued for. |
| **Trusted, from the node** (Let's Encrypt) | Servers on a node | No warning. The node itself gets a free Let's Encrypt certificate for its own IP address or for a domain name that points at it. Clients must connect to that name or IP. |

Certificate availability is checked when the inbound is attached to a node. When the panel certificate is renewed, or issued by hand with `ovira ssl issue`, the OpenConnect inbounds that use it reload it by themselves; connected clients stay connected.

### Trusted certificates on a node

Pick **Trusted (Let's Encrypt, from the node)** in the inbound's **Certificate** field and fill in the **Certificate name**:

- **A domain name** such as `vpn.example.com`. It must already point at the node (an `A` record to the node's IPv4 address). Let's Encrypt checks it from the outside, so a name that points elsewhere cannot be issued. The certificate is checked against the node when you attach the inbound, rather than when you save the form. Certificates for a name last about 90 days.
- **Empty**, for a certificate for the node's **IP address**. This works when the node is added to the panel by its IP address. Such certificates are short-lived (about 6 days) and renew by themselves every few days. If the node is added by a name, enter the name or its IP address instead.

How it works: the node, not the panel, asks Let's Encrypt, because Let's Encrypt must reach the machine the clients connect to. The node keeps one Let's Encrypt account and its certificates in its own data directory. It renews when a third of the certificate's lifetime is left, retries with growing pauses (5 minutes up to an hour) if that fails, and reloads the server without disconnecting anyone.

::: warning Port 80 on the node
Let's Encrypt validates on **TCP port 80** (the node opens it in its own firewall only while it validates, and closes it again). Keep port 80 free on the node, and open in any cloud firewall, for the first certificate **and for every renewal**.

If port 80 is taken, the node can use TCP port 443 instead, but only while the OpenConnect server is not running on it yet (the first certificate of a new server on port 443). If neither is possible, the server keeps working with the **Ovira certificate** and the Servers page shows the reason and the missing port. Renewals of a server that already runs on port 443 need port 80.
:::

The Inbounds page shows the certificate of each such inbound: the name, when it expires, and any problem. While a trusted certificate is not available (not issued yet, or issuing failed and the old one expired), the inbound serves the Ovira certificate and the page says so; clients then see the pin instead of a trusted address.

::: warning Relays
A trusted certificate belongs to the node's name or IP. A client that connects through a **relay** address (see [Nodes](./nodes)) sees a different name and Cisco shows a name mismatch. On the subscription page, only addresses that equal the certificate's name or IP are marked trusted; the others show the certificate pin. For relays use the pin with an OpenConnect app, or the Ovira certificate. Because a Let's Encrypt certificate gets a new key at every renewal, a pin of it changes at each renewal (every few days for IP certificates).
:::

Nodes need a recent Ovira version for this; an older node refuses the option with *update this node*. The panel's own server uses the panel certificate instead (trusted certificates from a node are only for nodes).

OpenConnect support starts with Ovira 0.6.0. While OpenConnect inbounds exist, Ovira refuses to install an older version (on the panel or on a node); delete the OpenConnect inbounds first if you really need to go back.

## What clients do

The client's subscription page has an **OpenConnect / Cisco** section with:

- the **server address** (with a copy button and an optional QR code),
- their **user name and password**,
- links to the apps for their device,
- under **Advanced**, the certificate pin (only for addresses without a trusted certificate).

In the app:

1. Install **Cisco Secure Client** (Android, iPhone and iPad, Windows, macOS) or an OpenConnect app: **OpenConnect** on Android (Google Play or F-Droid), **OpenConnect-GUI** on Windows, `openconnect` on Linux and macOS.
2. Add a new connection with the server address from the page.
3. Sign in with the user name and password.

With a trusted certificate, the app connects with no warning. With the self-signed Ovira certificate, Cisco Secure Client needs **Block untrusted servers** turned off in its settings (Preferences) before it connects. OpenConnect apps ask you to accept the certificate; compare the pin on the page if you want to be sure.

On the admin side, a client's page (**Clients → client**) lists the OpenConnect inbounds with their address and pin instead of a profile download.

## Troubleshooting

- **The Cisco app says "untrusted server"**: turn off *Block untrusted servers*, or use a trusted certificate (the panel certificate, or one from the node). If the server should have a trusted certificate, look at the Inbounds page: it shows when the node could not get one, and the Ovira certificate is served meanwhile.
- **A trusted certificate is not issued**: check that the name points at the node, and that TCP port 80 on the node is free and open (also in the provider's firewall). The error on the inbound says which.
- **A browser or scanner sees "Restricted Content" or a refusal**: that is camouflage working. Use the full address including `?secret`.
- **Camouflage is greyed out**: the machine has an ocserv older than 1.2.0. Update ocserv on it, then reopen the form.
- **The port is "already used"**: OpenConnect needs the TCP port, and with DTLS the UDP port of the same number, to be free on the node you attach it to. Another OpenVPN inbound on TCP 443 conflicts with it; use a different port.
- **Connects but no internet**: check **NAT** on the inbound and your provider's firewall for the TCP and UDP port, as with OpenVPN (see [Troubleshooting](./faq)).
- **A client is refused**: the same rules as OpenVPN apply (disabled, expired, out of traffic, device limit). Check **Connections** and the client's page.
