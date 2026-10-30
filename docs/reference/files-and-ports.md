# Files, services and ports

This page lists where Ovira keeps its files, which systemd services it runs and which ports it uses. Use it when you open a firewall, look for a log, or take a backup by hand. Paths are for new installations. A server installed before the rename uses `burrow` in place of `ovira`; see [Command line](./cli#installed-before-the-rename).

## Ports

Open these in the server's firewall and in your provider's firewall or security group.

| Port | Where | What it is for |
|---|---|---|
| TCP 2053 | Panel | The panel and the subscription pages. This is the default; the installer asks and `--port` sets it. |
| TCP 62060 | Node | The node's API, which only the panel connects to. `--port` sets another. Clients never use it. |
| UDP 1194 | Node | The port the form suggests for an OpenVPN inbound on UDP. Any port works. |
| TCP and UDP of your choice | Node | An OpenVPN inbound uses the one protocol you chose on its port. |
| UDP 51820 | Node | The port the form suggests for a WireGuard inbound. |
| TCP 443, and UDP 443 with DTLS | Node | The port the form suggests for an OpenConnect inbound. |
| TCP 80 or TCP 443 | Panel | Needed during issuing and renewal of the panel's Let's Encrypt certificate. |
| TCP 80 | Node | Needed during issuing and renewal of an OpenConnect inbound's Let's Encrypt certificate. |

The installer opens the panel or node port in `ufw` and in `firewalld` when either is active. When an inbound starts, Ovira adds the firewall and NAT rules it needs: through `iptables`, or in its own `ovira` table when the server uses nftables (`nft list table ip ovira`), and an allow rule in `ufw` if that is active. It does not change a cloud provider's firewall. The ports of all inbounds, and port 80 where listed above, must also be open there.

Each inbound also has a management port on `127.0.0.1` that the panel or node uses to talk to it. It is not reachable from outside and needs no rule.

The server also needs outbound HTTPS: to download releases, to get certificates from Let's Encrypt and, on a panel, for plan and license services.

## Services

Ovira runs plain systemd services. Inbounds are template units whose instance name is the inbound's name, for example `ovira-ovpn@udp1194`.

| Service | Runs |
|---|---|
| `ovira` | The panel. |
| `ovira-ovpn@NAME` | An OpenVPN inbound on the panel's own server. |
| `ovira-oc@NAME` | An OpenConnect inbound on the panel's own server. |
| `ovira-wg@NAME` | A WireGuard inbound on the panel's own server. |
| `ovira-node` | The node service (the agent the panel connects to). |
| `ovira-node-ovpn@NAME` | An OpenVPN inbound on a node. |
| `ovira-node-oc@NAME` | An OpenConnect inbound on a node. |
| `ovira-node-wg@NAME` | A WireGuard inbound on a node. |

```bash
systemctl status ovira
systemctl status 'ovira-ovpn@*' 'ovira-oc@*' 'ovira-wg@*'          # on the panel server
systemctl status ovira-node 'ovira-node-ovpn@*' 'ovira-node-oc@*' 'ovira-node-wg@*'   # on a node
journalctl -u ovira -f                                                # follow the panel log
```

The panel service restarts itself two seconds after a crash. `ovira logs` and `ovira logs NAME` are shortcuts for `journalctl`.

## Files on the panel server

| Path | Contents |
|---|---|
| `/usr/local/bin/ovira` | The program. |
| `/etc/ovira/config.json` | Panel port, secret path, subscription path, data directory, HTTPS and proxy settings. |
| `/var/lib/ovira/ovira.db` | The database: clients, inbounds, nodes, groups, accounts and settings. |
| `/var/lib/ovira/pki/` | The certificate authority and keys behind OpenVPN profiles. |
| `/var/lib/ovira/openvpn/` | Generated OpenVPN server configuration, one file per inbound. |
| `/var/lib/ovira/ocserv/NAME/` | Generated OpenConnect configuration and certificate of an inbound. |
| `/var/lib/ovira/wireguard/NAME/` | Generated WireGuard server data of an inbound. |
| `/var/lib/ovira/tls/` | The panel's HTTPS certificate. |
| `/var/lib/ovira/updates/` | Releases downloaded by the updater. |
| `/etc/sysctl.d/99-ovira.conf` | Turns on IPv4 forwarding. |
| `/usr/local/lib/ovira/` | `manage.sh`, the script behind the `ovira` command, and the panel and node menu scripts it hands over to. |
| `/var/log/ovira-install.log` | Output of the installer and updater. |
| `/root/ovira-backup-DATE.tar.gz` | Where `ovira backup` writes by default. |

Do not edit generated files. The panel rewrites them from the database. Change inbounds in the panel.

`config.json` holds keys such as `listen`, `basePath`, `subPath`, `tlsCert`, `tlsKey` and `trustProxy`. Most of them can also be changed in the panel under **Settings → Panel access**.

## Files on a node

| Path | Contents |
|---|---|
| `/etc/ovira-node/node.json` | The node's listen port, data directory, public address, the panel addresses it accepts and its key. Its TLS identity is kept next to it. |
| `/var/lib/ovira-node/openvpn/`, `ocserv/NAME/`, `wireguard/NAME/`, `pki/` | Files the panel pushed. Rewritten whenever the panel resends the state. |

Keep `node.json` private: anyone who holds the key can manage the node.

## Environment

The services read these variables, which the installer sets in the unit files. You rarely need to change them.

| Variable | Meaning |
|---|---|
| `OVIRA_CONFIG` | Path of the panel's `config.json`. |
| `OVIRA_NODE_CONFIG` | Path of the node's `node.json`. |

## Backups and removal

- `ovira backup` saves the database and `config.json` into a `.tar.gz` with mode 600. See [Command line](./cli).
- Removing Ovira while keeping its data leaves `/etc/ovira` and `/var/lib/ovira` in place, so a later install can reuse them. Choosing a fresh install saves the old data to `/root/ovira-previous-DATE.tar.gz` before deleting it.
- `ovira uninstall --purge` deletes both directories.

## Related pages

- [Command line](./cli): the commands that act on these files and services.
- [Troubleshooting](./troubleshooting): ports that are in use or blocked.
- [Back up and restore](/use/backup): the panel's backup page.
