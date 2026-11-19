# Smart DNS

Smart DNS lets a client reach services that block Iranian addresses, such as game launchers, developer tools and AI services, by changing only the DNS of the device. There is no app and no tunnel. This page covers creating the inbound, the domain lists and how clients register.

## What it is good for

- Games, consoles and launchers that refuse Iranian addresses.
- Developer tools and AI services that do the same.
- Customers who want no app at all.

It only gets around sanctions. Sites that are filtered, such as YouTube or Instagram, do not open with it. Traffic through Smart DNS counts toward the client's traffic limit.

## Create an inbound

1. Open **Inbounds** and press **New inbound**.
2. Pick **Smart DNS**. The protocol cannot be changed after the inbound exists.
3. Give it a **Name** and turn on the **Domain lists** you want.
4. Under **Access**, choose which groups and clients get it, then press **Create**.
5. On **Nodes**, press **Attach inbound** on the target node, including **This server**.

Smart DNS answers DNS on port 53 and passes web traffic on ports 80 and 443 of the server. Another inbound, or the panel itself, on one of those ports blocks it, and the panel says which. It runs on nodes and on the panel's own server. It uses no tunnel network.

## Domain lists

Only domains in the lists you turn on pass through this server. Every other site gets its normal answer.

| List | What it covers |
|---|---|
| **Games** | Launchers, stores and publishers. |
| **Development** | Developer tools, Docker, JetBrains, GitLab, SDK downloads. |
| **AI services** | ChatGPT, Gemini, Claude and other AI tools. |
| **General** | Design, work and learning services. |
| **Download servers** | Game and driver download networks. Whole downloads then go through the node. |
| **Broad (whole companies)** | All traffic of large companies. It can use a lot of traffic. Leave it off unless you need it. |

You can pick single domains in a list, add **Extra domains** and list domains that must **Never pass**. **Addresses per client** limits how many IP addresses one client can register.

## What clients do

The client's page shows a **Smart DNS** section.

1. Set the DNS shown there as the DNS of the device or Wi-Fi network. The page has steps for Android, iPhone and iPad, Windows, PlayStation and Xbox, and browsers.
2. Press **Register this IP**. Smart DNS answers only registered addresses, so register again whenever the address changes, for example on a new network. Optional one-tap shortcuts do it for you.

If a VPN is on, turn it off first. The page checks the connection and says whether the device is using Smart DNS.

## Related pages

- [Choosing a protocol](./): compare it with the VPN protocols.
- [Inbounds](/use/inbounds): create, attach and delete inbounds.
- [Subscription page](/use/subscription-page): what the client sees.
