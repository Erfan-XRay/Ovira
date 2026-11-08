# Certificates

The **Certificates** page lists every certificate Ovira uses: the panel's HTTPS certificate and the certificate behind each OpenConnect and IKEv2 inbound, with the type, which inbounds use it, the expiry date and whether it renews on its own.

## Types

| Type | What it is |
|---|---|
| **Panel certificate** | The panel's HTTPS certificate, set at install or with `ovira ssl`. See [HTTPS for the panel](/start/https). |
| **Let's Encrypt** | A public certificate for a node's domain or IPv4 address. Devices trust it without installing anything. |
| **Ovira CA** | A certificate signed by your panel's own CA. Free and automatic, but devices must trust the CA once. |

## Request a Let's Encrypt certificate for a node

1. Open **Certificates** and press **New certificate**.
2. Choose the **Node**. A node marked *update needed* must be updated to Ovira 1.0 first.
3. Enter a domain name that points at that node, or leave **Name or address** empty to use the node's IPv4 address. IP certificates are short-lived and renewed automatically.
4. Press **Request certificate**. The node issues it within a minute or two; the status moves from **Being issued** to **Valid**.

Then pick the certificate in an OpenConnect or IKEv2 inbound on that node. When you edit an inbound, certificates already on its node are suggested.

::: tip Port 80
Let's Encrypt needs TCP port 80 on the node, free and open, for issuing and every renewal (or port 443 while the inbound that will use it has not started yet).
:::

## The main server

The main server can get a Let's Encrypt certificate from this page too, like any node. Inbounds on **This server** can use it, and the panel's HTTPS settings offer it as **Main server certificate**: pick it there and restart the panel. Renewals are picked up automatically.

## Renewal

Let's Encrypt certificates renew on their own before they expire; **Renew now** starts a renewal at once. Renewed certificates reach running IKEv2 servers without dropping connected users. If a renewal fails, the status says **Renewal failed** and the inbound keeps the last valid certificate, or falls back to the Ovira certificate (**Using the Ovira certificate**).

## Delete a certificate

A certificate can be deleted once no inbound uses it; the page names the inbounds to change first. The node removes its files, and you can request it again later.

## Related pages

- [IKEv2 and L2TP/IPsec](/protocols/ipsec)
- [OpenConnect](/protocols/openconnect)
- [HTTPS for the panel](/start/https)
