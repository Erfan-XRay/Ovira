# Troubleshooting

### Which VPN protocols are available?

Ovira serves **OpenVPN** and **OpenConnect** (Cisco Secure Client / AnyConnect). Each client works on both with the same name and password; OpenVPN profiles do not work in Cisco apps, so use the OpenConnect server for those. See [OpenConnect (Cisco)](./openconnect). It also serves **WireGuard** (plain, or Amnezia mode for networks that block WireGuard), with one configuration per device; see [WireGuard](./wireguard).

### Does Ovira provide Telegram support?

There is no official Telegram support service for this project. A support link configured by a panel owner belongs to that owner, not to Ovira. Use this guide and the [project repository](https://github.com/Erfan-XRay/Ovira) for project information.

### The Cisco app says "untrusted server" (OpenConnect)

Turn off **Block untrusted servers** in Cisco Secure Client's settings, or use the panel certificate for that inbound. See [OpenConnect (Cisco)](./openconnect#certificate).

### I lost the panel address

```bash
ovira info
```

### I forgot the password or lost my authenticator

```bash
ovira admin passwd -username admin
ovira admin reset-2fa -username admin
```

### A client connects but has no internet

- Check that **NAT** is on for that inbound (**Inbounds → inbound → Network**).
- Another firewall (for example a cloud provider's security group) must allow the OpenVPN port.
- On servers where nftables manages the firewall, Ovira keeps its rules in its own `ovira` table: `nft list table ip ovira`.

### "device limit reached"

The client already has as many tunnels open as allowed, counted across all inbounds and nodes. Disconnect an old session under **Connections**, or raise the limit.

### Two devices on one profile kick each other off

Update to the latest version: Ovira lets one profile run on several devices and enforces the device limit itself.

### A node shows "Unreachable"

- The node's port (62060 by default) must be reachable from the panel's server.
- If the node was installed with `--panel-ip`, the panel must connect from that IP.
- After reinstalling a node, paste its new key (`ovira key` on the node).

### Port 62060 is already in use on the node

Another panel's node may use it. Install with another port: `node --port 62070`, and use the same port in the panel.

### No HTTPS certificate

Check the error shown by the panel or installer. Common causes include both validation ports being occupied, blocked inbound ports, a domain pointing at another host, or certificate-authority limits. See [HTTPS](./https).

### The panel says the license server is unreachable

The panel needs outbound HTTPS to `ovpn.rapcity.shop` to renew its license.
