# Xray inbounds

An Xray inbound serves clients from proxy apps such as Happ, v2rayNG and Hiddify. It sits next to OpenVPN, WireGuard and OpenConnect inbounds: the same clients, groups, quotas and subscription links.

## Choose a scenario

Press **New inbound** and pick **Xray**. Each scenario fills in the rest for you.

| Scenario | Use it when |
|---|---|
| **Direct connection** (recommended) | Clients connect straight to the node. Nothing to enter. |
| **Behind a CDN (Cloudflare)** | Clients reach the node through a domain on Cloudflare. |
| **Behind a relay or tunnel server** | Clients reach the node through a relay, for example a server in Iran. |
| **Classic VMess** | You need VMess for older apps. |
| **Trojan** | You need Trojan. |
| **Shadowsocks** | You need Shadowsocks. |
| **Manual (advanced)** | You want to choose every setting yourself. |

## Create one

1. Pick the scenario.
2. Fill in what it asks for, if anything.
3. Press **Create**, then attach the inbound to a node as for any other inbound.

The port and the other settings are chosen for you, and you can change them afterwards.

- **Direct** needs nothing else.
- **CDN** needs a domain on Cloudflare that points to the node.
- **Relay** needs the IP addresses of your relay servers. Once set, only the relays can connect, so direct connections stop working. The panel shows example configurations for the relay servers.

## Clients

Clients on an Xray inbound follow the same speed and device limits as on other inbounds. A client's page shows their Xray links and a QR code for each, and you can replace a client's links from the client's page.

The Xray engine is installed on a node automatically when you attach an Xray inbound to it.

## Related pages

- [Inbounds](/use/inbounds): the list and the other protocols.
- [The subscription page](/use/subscription-page): proxy apps and subscription links.
- [Xray API](/api/reference/xray)
