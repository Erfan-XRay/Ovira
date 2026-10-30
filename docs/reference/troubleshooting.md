# Troubleshooting

This page lists problems by what you see, with the most likely cause first. Two checks answer most questions: the log, and the node's card on **Nodes**.

```bash
ovira status          # is the panel running, and at what address
ovira logs -f         # follow the panel log
ovira logs NAME       # the log of one inbound, for example udp1194
```

On a node, the same commands show the node. The panel log is where the reason for a refused connection is written. See [The life of a connection](/how/connection).

## The panel does not open

- The address is missing the secret path. The panel answers `404` on every path except the one the installer printed. `ovira status` prints the full address.
- The port is closed. Open the panel port (2053 unless you chose another) in the server's firewall and in your provider's firewall.
- The page was opened as `http://` but the panel serves HTTPS, or the other way round. `ovira status` shows whether HTTPS is on.
- The service is not running. `systemctl status ovira`, then `journalctl -u ovira -n 50`.

## I lost the address, the password or the authenticator

```bash
ovira status                              # the address
ovira password admin                      # a new password for the account "admin"
ovira admin reset-2fa -username admin     # remove two-factor sign-in from an account
```

## A node stays Unreachable

- The panel cannot reach the node's port. TCP 62060 (or the port you chose) must be open on the node and in its provider's firewall.
- The node was installed with `--panel-ip` and the panel connects from another address. Reinstall with the right address, or edit `allowFrom` in `/etc/ovira-node/node.json` and restart the node.
- The node was reinstalled and its key changed. Run `ovira key` on the node and paste the new key into the node's editor.
- The node service is stopped. `systemctl status ovira-node` on the node.
- The node and panel versions are incompatible. The card says so. Update the node, or run the node installer again.

The card's message and **seen …** time say how long this has lasted. See [A node and its panel](/how/nodes).

## The node install fails

- Port 62060 is in use, for example by another panel's node. Install with `--port 62070` and use the same port when you connect the node.
- The distribution is not supported. Ovira supports Debian, Ubuntu, AlmaLinux, Rocky and CentOS Stream.
- OpenSSL older than 3 is installed. The scripts need OpenSSL 3 or newer.
- The server has no systemd, or no root access. Both are required.
- The log of the attempt is in `/var/log/ovira-install.log`.

## An inbound will not attach or start

The attach dialog on **Nodes** names the reason. Nothing changes when a check fails.

- The port is already used on that node by another inbound or program. Pick another port.
- The tunnel network overlaps another inbound or a route on the node (WireGuard, Docker, another VPN). Pick another network.
- OpenConnect is not installed on **This server**. Press **Install OpenConnect** on its card first.
- The node is too old for the protocol. OpenConnect needs 0.6.0 and WireGuard 0.7.0. Update the node from **Updates**.
- The node shows **No TUN**. Enable TUN at your provider, or use another node.
- The node is **Unreachable**. Fix that first.

## A client cannot connect

Look at the panel log for `connection denied`. It names the reason.

| Reason in the log | Cause and fix |
|---|---|
| `unknown client` | The name does not exist, usually a typo or a deleted client. |
| `wrong password` | The password is wrong. The client's **VPN password** is on its page. |
| `certificate was replaced` | The client's certificate changed, for example after a rename. Send the new profile. |
| `username does not match certificate` | On a **Certificate and password** inbound, the user name must equal the client name. |
| `account disabled` | The client is switched off, or its reseller is. |
| `account expired` | The end date passed. Extend it. |
| `traffic quota used up` | The allowance is gone. Reset or raise it. |
| `not allowed on this server` | The client's groups do not include this inbound. |
| `license client limit exceeded` | The panel has more active clients than its plan allows. See **License**. |
| `device limit reached` | The client already has as many connections as allowed. Disconnect one under **Connections**, or raise the limit. |

If the log shows no refusal at all, the connection never reached the node:

- The inbound's port is blocked in a firewall, at the server or at the provider. UDP needs a UDP rule.
- The profile has an old port or address. After a port change, clients must import the profile again.
- A relay is not forwarding to the inbound's port and protocol.
- The inbound is stopped. **Inbounds** shows its state.
- The node is **Unreachable**. A node without its panel cannot accept new sign-ins.

## A client connects but has no internet

- **NAT client traffic to the internet** is off on the inbound. Turn it on.
- A firewall in front of the server blocks forwarded traffic. On servers where nftables manages the firewall, Ovira keeps its rules in its own table: `nft list table ip ovira`.
- IPv4 forwarding is off. `sysctl net.ipv4.ip_forward` should print 1.
- The server has no IPv4 default route, so NAT cannot be set up. The panel log says so.
- The DNS servers on the inbound are unreachable from the client's network. Try different ones.

## Two devices kick each other off

- On WireGuard, both devices import the same device configuration. Give each its own device on the client's subscription page.
- On OpenVPN, the client has reached its device limit. The newer connection is refused, not the older one.

## OpenConnect problems

- The Cisco app says "untrusted server". Turn off **Block untrusted servers** in its settings, or give the inbound a trusted certificate.
- A browser opens the address and shows "Restricted Content", or a plain refusal. That is camouflage working. Use the full address including `?secret`.
- **Camouflage** is greyed out. The machine has `ocserv` older than 1.2.0.
- A trusted certificate is not issued. The name must point at the node, and TCP port 80 on the node must be free and open, also in the provider's firewall. The error on the inbound says which part failed. See [OpenConnect](/protocols/openconnect#certificate).
- The port is already used. OpenConnect needs the TCP port, and the UDP port of the same number when DTLS is on. An OpenVPN inbound on TCP 443 conflicts with it.
- A relay shows a certificate name mismatch. Use the certificate pin. See [Relays and connect addresses](/how/relays).

## WireGuard problems

- No handshake, or connected but no traffic. The UDP port must be open at the provider's firewall, and a relay must forward UDP to it.
- It works on one network but not another. The network may block WireGuard. Try an Amnezia inbound with the AmneziaVPN app.
- A plain WireGuard app cannot connect to an Amnezia inbound, and the reverse.
- The inbound does not start on a node. The **Nodes** page shows **No TUN**; enable TUN or use another node.

## The panel has no HTTPS certificate

Let's Encrypt connects to the server on port 80 or 443 while it issues. If another program (nginx, Caddy, Xray) holds both ports, issuing fails. Free one of them during issuing and renewal. A domain must point at this server, and some domains are limited by Let's Encrypt's rate limits. See [HTTPS for the panel](/start/https).

## The panel says changes are paused

The panel shows that changes are paused when its license has ended or could not be renewed. Clients keep their limits and connections continue, but you cannot change settings until it is renewed. Open **License** to renew or reactivate. The panel needs outbound HTTPS to reach the license service.

## Traffic looks wrong

- A node with a multiplier other than 1 counts more or less against quotas than it shows on the node's card. That card shows the real amount. See [Traffic, quotas and limits](/how/traffic).
- A node was unreachable and a connection ended during that time. Traffic on a VPN process that restarted in the meantime cannot be recovered.
- A client with a periodic reset was reset at midnight in the panel server's time zone.

## Related pages

- [Command line](./cli): the commands used above.
- [Files, services and ports](./files-and-ports): paths, services and the ports to open.
- [The life of a connection](/how/connection): why a connection is refused or dropped.
- [A node and its panel](/how/nodes): what happens when the link breaks.
