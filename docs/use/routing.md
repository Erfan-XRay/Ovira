# Outbound routing

Outbound routing decides where your VPN clients' traffic leaves a node. By default it goes straight out to the internet from that node. With routing on, chosen traffic leaves through an **outbound** instead: another server such as a VLESS or WireGuard server, Cloudflare WARP or NordVPN. Typical uses are reaching sites that refuse your node's country (for example Gemini or OpenAI), keeping local sites direct, or sending everything through a clean exit IP.

Routing is set per node on the **Routing** page (owner only). It is available on every plan.

## How it works

Each node runs a small routing engine (Xray) next to its inbounds. Client traffic of the routed inbounds passes through your rules from top to bottom; the first rule that matches decides:

- **Send via outbound:** leave through one of your outbounds.
- **Direct:** leave from the node as usual.
- **Block:** drop it.

Traffic that matches no rule follows the **Default for unmatched traffic**: **Direct** or **Through an outbound**.

Some traffic never goes through an outbound: private addresses, your VPN subnets and DNS lookups always go direct, so a slow or UDP-less outbound cannot break name resolution. Domain rules still see the real site names.

::: tip Requirements
The node runs Ubuntu or Debian on amd64 or arm64, and Ovira 1.0 or newer. The routing engine and the site lists (about 30 MB) are downloaded the first time they are needed and refreshed weekly.
:::

## 1. Add an outbound

Open **Routing → Outbounds → Add outbound**. Three input modes:

| Mode | What you give |
|---|---|
| **Form** | Every field by hand: VLESS, VMess, Trojan, Shadowsocks, Hysteria2, WireGuard, SOCKS or HTTP, with transport (TCP, WebSocket, gRPC, HTTPUpgrade, XHTTP), security (TLS or REALITY) and multiplexing. |
| **Link** | A `vless://`, `vmess://`, `trojan://`, `ss://`, `hysteria2://` or `hy2://` link, or a WireGuard `.conf`. The link opens in the form so you can check it. |
| **JSON** | An Xray outbound object, for options the form does not cover. |

Keys and passwords are stored on the panel and never shown again. When editing, leave a secret field empty to keep its value.

### Cloudflare WARP and NordVPN in one click

- **Add WARP** registers a new free WARP device from the panel and turns it into an outbound. Add a WARP+ or Unlimited license key afterwards if you have one. The endpoint can stay on **Default** or use a custom `host:port` (ports 2408, 500, 1701 and 4500 work).
- **Add NordVPN** uses your Nord access token (Nord Account → NordVPN → manual setup), lets you pick a country and a server, and connects with NordLynx (WireGuard).

## 2. Test it

Press **Test** on an outbound and choose **Test from**: the main server or any node. The test connects through the outbound three times and shows whether it worked, the best and average latency, and the **exit IP** and country. It takes up to 40 seconds and installs the routing engine first if it is missing. Test before you route real clients through it.

## 3. Set the node's policy

Open **Routing → Rules**, pick the **Node** and turn on **Route this node's traffic**.

- **Inbounds to route:** **All inbounds**, or **Chosen inbounds** with a checkbox per inbound. Unchecked inbounds connect directly, as if routing were off.
- **Default for unmatched traffic:** **Direct**, or **Through an outbound** to send everything through it and add **Direct** rules for exceptions.
- **Rules:** press **Add rule**, then match traffic to any of:
  - **Geosite** and **GeoIP** lists such as `geosite:openai` or `geoip:ir`,
  - **Domains** (`example.com` also matches its subdomains; `full:`, `keyword:` and `regexp:` work too),
  - **IPs and ranges**, IPv4 or IPv6,
  - **Ports**, such as `443` or `1000-2000,8443`,
  - **Only for these inbounds**. A rule with nothing but inbounds sends all traffic of those inbounds.

  Then choose **Send via outbound**, **Direct** or **Block**. Reorder rules with the arrows; the first match wins.

**Quick start** adds ready-made rules: *Gemini via outbound*, *OpenAI via outbound* and *Iran direct*.

Press **Save**. The node applies the policy within seconds and the status changes to **Active**. If it shows **Needs attention**, the details explain why (for example a node that needs an update).

## Examples

| Goal | Default | Rules |
|---|---|---|
| AI sites through WARP, the rest direct | Direct | `geosite:openai`, `geosite:google-gemini` → WARP |
| Everything through an outbound, local sites direct | Through an outbound | `geoip:ir`, `geosite:category-ir` → Direct |
| One inbound fully through NordVPN | Direct | Only for inbound *premium* → NordVPN |

## If something goes wrong

- **Sites stop opening after routing is on:** test the outbound from the same node. If the test fails, the outbound itself is down or blocked from that node.
- **The node shows "Not supported":** it is not amd64/arm64, not Debian/Ubuntu, or needs an update.
- **Turn routing off** on the node at any time. Clients then go out directly again; the engine also fails open, so if it stops, traffic leaves directly instead of being cut.

## Related pages

- [Nodes](./nodes): attach inbounds and open a node's routing from its menu.
- [Inbounds](./inbounds): which inbounds exist on a node.
- [How Ovira fits together](/how/): where the panel, nodes and outbounds sit.
