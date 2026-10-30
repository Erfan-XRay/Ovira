# OpenVPN

OpenVPN is the protocol with the widest client support. An OpenVPN [inbound](/reference/glossary#inbound) runs on UDP or TCP, and each client imports a profile file into an OpenVPN app. This page covers creating the inbound, its sign-in modes, its network settings and the options under **Advanced**.

## What it is good for

- Customers on any platform. OpenVPN Connect and other OpenVPN apps exist for Android, iPhone and iPad, Windows, macOS and Linux.
- Networks where UDP is blocked. The same inbound type can listen on TCP.
- Sign-in by certificate, so a customer has nothing to type.

## Create an inbound

1. Open **Inbounds** and press **New inbound**.
2. Under **Protocol**, pick **OpenVPN**. The protocol cannot be changed after the inbound exists.
3. Fill in the basics. The form suggests a name, UDP and port 1194, and the tunnel network `10.20.0.0/24`.
4. Under **Access**, choose which existing groups and clients get the new inbound. Groups that have **All inbounds, including ones added later** get it anyway.
5. Press **Create**. The inbound is saved under **Not on a node** and does not run yet.
6. Open **Nodes**, press **Attach inbound** on the card of the node that should run it (including **This server**) and pick the inbound.

Attaching is where the checks happen: the port must be free on that node, and the tunnel network must not overlap another inbound or a route the node already has (WireGuard, Docker, another VPN). If a check fails, nothing changes and the dialog shows the reason. See [Nodes](/use/nodes).

The machine needs OpenVPN 2.5 or newer. The installer adds it, and on Debian and Ubuntu it adds the OpenVPN community repository when the packaged version is older.

## Basics

| Field | What it does |
|---|---|
| **Name** | Lowercase letters, digits and dashes. It becomes part of the service name (`ovira-ovpn@NAME`). Cannot be changed later. |
| **Description** | Shown to clients on their page, for example "Use this on mobile data". |
| **Protocol** | **UDP**, **TCP**, **UDP (IPv4 + IPv6)** or **TCP (IPv4 + IPv6)**. |
| **Port** | The port clients connect to. It must be free on the node. |
| **Tunnel network** | A private IPv4 range for client addresses, from /16 to /28, in 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 or 100.64.0.0/10. The last quarter is reserved for fixed addresses. |
| **Public address override** | The host name or address written into profiles. Empty means the node's own address. |
| **Run this inbound** | Off keeps the inbound saved but stopped. |

UDP avoids the cost of carrying a TCP connection inside a TCP connection, so it is the usual first choice. TCP is the fallback for networks that block UDP.

## Sign-in

**Clients sign in with** has three modes.

| Mode | What the client needs |
|---|---|
| **Certificate** (default) | The profile only. |
| **Certificate and password** | The profile, plus the client name and **VPN password**. The name must match the certificate. |
| **Username and password** | The client name and **VPN password**. No client certificate is used. |

When an inbound asks for a name and password, the client sees them on its subscription page. The password is the client's **VPN password**, which Ovira generates if you leave the field empty.

Renaming a client replaces its certificate and disconnects it. The client then needs to import the new profile.

## Network and routing

| Field | What it does |
|---|---|
| **Send all traffic through the VPN** | On by default. Off means split tunnel: only the **Routes to push** go through the VPN. |
| **Routes to push** | One CIDR per line, for example `192.168.10.0/24`. |
| **NAT client traffic to the internet** | On by default. Lets clients reach the internet through the server. Turn it off only if you route the tunnel network yourself. |
| **Let clients reach each other** | Allows traffic between clients on this inbound. |
| **IPv6 inside the tunnel** and **IPv6 network** | Gives clients an IPv6 address from the network you choose. |
| **Max connected clients** | Default 1024. |
| **DNS servers** | One per line, up to four. The defaults are 1.1.1.1 and 8.8.8.8. |
| **Search domain** | Pushed to clients. |
| **Block DNS outside the tunnel on Windows** | On by default. Stops Windows clients from leaking DNS queries around the VPN. |

A client can also have a **Fixed tunnel address** on its own page. It must lie in the reserved last quarter of the inbound's network.

## Advanced

The advanced sections are folded away while the recommended defaults are in use. Press **Customize** to open them.

| Field | Default | What it does |
|---|---|---|
| **Control channel protection** | tls-crypt | **tls-crypt** hides the handshake. **tls-auth** and **None** exist for old clients. |
| **Data ciphers** | AES-256-GCM, AES-128-GCM, CHACHA20-POLY1305 | Ciphers offered to clients. |
| **Cipher for old clients** | None | A fallback cipher for clients older than OpenVPN 2.4. |
| **HMAC digest** | SHA256 | SHA384, SHA512 and SHA1 are also offered. |
| **Minimum TLS version** | 1.2 | TLS 1.3 is the other choice. |
| **Compression** | Off | Compression on encrypted links leaks information. Turn it on only for old clients that need it. |
| **Keepalive** | every 10 s, timeout 60 s | Ping interval and the silence after which a client is dropped. |
| **Tunnel MTU**, **MSS fix**, **Fragment**, **Socket buffers** | OpenVPN defaults | For networks that need smaller packets. |
| **Key renegotiation** | 3600 s | How often the data keys are renewed. |
| **Share the port with a web server** | Off | TCP only. Visitors that are not VPN clients are forwarded to the host and port you enter. It needs a compatible web server behind it and does not share a port that another program already owns. |
| **Tell the server when UDP clients disconnect** | On | UDP clients tell the server when they disconnect, so it does not wait for the keepalive timeout. |
| **Log detail** | 3 | |
| **Extra directives**, **Extra client directives** | Empty | One OpenVPN directive per line. Directives that run scripts, write files or touch the management interface are refused. |

The **Config file** tab of an inbound shows the generated server configuration, and **Logs** shows its recent log lines.

## Changing the port

Edit the inbound, change **Port** and save. If the inbound is attached to a node, Ovira rewrites the configuration, moves the firewall rules and restarts the inbound, which disconnects the people on it. Clients get the new port the next time they download their profile, so tell them to re-import.

## What clients need

On the subscription page, the **OpenVPN** tab offers:

- **Open in OpenVPN Connect**, which imports the profile on a phone with one tap.
- **Download profile**, a `.ovpn` file to open with any OpenVPN app.
- **All servers in one profile**, a profile with several `remote` lines. The app uses the first server that answers.

The all-in-one profile only combines inbounds whose OpenVPN settings are compatible with the first one, so it does not mix sign-in modes. Each [connect address](/how/relays) on a node also becomes its own profile.

One profile works on all of a client's devices. Ovira, not OpenVPN, enforces the client's device limit, so two phones on the same profile do not disconnect each other until the limit is reached.

## What it cannot do

- OpenVPN profiles do not work in Cisco apps or WireGuard apps. Those need an [OpenConnect](./openconnect) or [WireGuard](./wireguard) inbound.
- Port 443 alone does not get OpenVPN through a network that inspects traffic. TCP on 443 helps only where the network allows OpenVPN over TCP.
- Changing **Name** or the protocol means deleting the inbound and creating a new one.

## Related pages

- [Inbounds](/use/inbounds): the page where inbounds are listed, edited and started.
- [Nodes](/use/nodes): attaching, detaching and moving an inbound.
- [The life of a connection](/how/connection): how a sign-in is accepted or refused.
- [Troubleshooting](/reference/troubleshooting): clients that connect but have no internet.
