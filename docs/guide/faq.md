# Troubleshooting

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

- Check that **NAT** is on for that server (**Servers → server → Network**).
- Another firewall (for example a cloud provider's security group) must allow the OpenVPN port.
- On servers where nftables manages the firewall, Ovira keeps its rules in its own `ovira` table: `nft list table ip ovira`.

### "device limit reached"

The client already has as many tunnels open as allowed, counted across all servers and nodes. Disconnect an old session under **Connections**, or raise the limit.

### Two devices on one profile kick each other off

Update to the latest version: Ovira lets one profile run on several devices and enforces the device limit itself.

### A node shows "Unreachable"

- The node's port (62060 by default) must be reachable from the panel's server.
- If the node was installed with `--panel-ip`, the panel must connect from that IP.
- After reinstalling a node, paste its new key (`ovira key` on the node).

### Port 62060 is already in use on the node

Another panel's node may use it. Install with another port: `node --port 62070`, and use the same port in the panel.

### No HTTPS certificate

Ports 80 and 443 are both used by another program. See [HTTPS](./https).

### The panel says the license server is unreachable

The panel needs outbound HTTPS to `ovpn.rapcity.shop` twice a day. It keeps working for 10 days without it.
