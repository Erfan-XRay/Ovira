# Command line

All commands run as root on the server. Type `ovira` alone for a menu; every menu entry is also a command.

## Everyday commands

| Command | What it does |
|---|---|
| `ovira` | Menu |
| `ovira status` | What is running: version, panel address, machine ID, license, OpenVPN services. Tells you when an update is out |
| `ovira update` | Install the newest release (`--beta` for the beta channel, `--force` to reinstall) |
| `ovira restart` / `start` / `stop` | Control the panel (or the node) service |
| `ovira logs` | Last 100 log lines; `-f` follows them; `ovira logs udp1194` shows one OpenVPN server |
| `ovira password [USER]` | New password for a panel admin: type one or press Enter for a strong random one. Other sessions of that admin are signed out |
| `ovira license` | License and machine ID (the license is activated in the panel under **License**) |
| `ovira ssl [status\|domain\|ip\|off]` | HTTPS certificate for the panel, see [HTTPS](./https) |
| `ovira openvpn enable\|disable\|status` | Run OpenVPN on the panel's own server too, or stop. See [Install](./install#panel-with-openvpn-or-an-empty-panel) |
| `ovira backup [FILE]` | Save the database and settings into one private `.tar.gz` (default `/root/ovira-backup-DATE.tar.gz`) |
| `ovira key` | On a node: print the node key again |
| `ovira uninstall [--purge]` | Remove Ovira; `--purge` deletes the data too |

## Panel, low level

```bash
ovira info                                   # panel address, machine ID, license
ovira admin list
ovira admin passwd -username admin           # set a new random password
ovira admin reset-2fa -username admin        # if the phone with the authenticator is lost
ovira ssl issue -mode domain -domain panel.example.com
ovira apply                                  # rewrite OpenVPN files from the database
ovira version
```

## Node

```bash
ovira key                                    # print the node key again
ovira node reset-key                         # new API key; paste the new key in the panel
```

## Services and logs

```bash
systemctl status ovira                       # the panel
systemctl status 'ovira-ovpn@*'              # OpenVPN servers on the panel's server
systemctl status ovira-node 'ovira-node-ovpn@*'   # on a node
journalctl -u ovira -u 'ovira-ovpn@*' -f    # follow the logs
```

## Files

| Path | Contents |
|---|---|
| `/etc/ovira/config.json` | Panel port, secret path, HTTPS |
| `/var/lib/ovira/` | Database, PKI, OpenVPN configs, certificates |
| `/etc/ovira-node/` | Node config, TLS identity, API key |
| `/var/lib/ovira-node/` | OpenVPN files pushed by the panel |
| `/usr/local/lib/ovira/manage.sh` | The script behind the `ovira` menu |
| `/var/log/ovira-install.log` | Output of the installer and updater |

Back up from **Settings → Backup**, with `ovira backup`, or by copying `/var/lib/ovira/ovira.db`.

## Installed before the rename?

The product used to be called Burrow. A server installed under that name keeps its original file and service names, so an update never moves anything: replace `ovira` with `burrow` in the service names and paths above (`systemctl status burrow`, `/etc/burrow/config.json`, `/var/lib/burrow/`). The `ovira` command works there too; it is the same program. If `ovira` shows no menu on such a server, run the install command once: it adds the menu.
