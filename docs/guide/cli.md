# Command line

All commands run as root on the server.

## Panel

```bash
ovira info                                   # panel address, machine ID, license
ovira admin passwd -username admin           # set a new random password
ovira admin reset-2fa -username admin        # if the phone with the authenticator is lost
ovira admin list
ovira ssl issue -mode domain -domain panel.example.com
ovira ssl issue -mode ip
ovira ssl status | off
ovira apply                                  # rewrite OpenVPN files from the database
ovira version
```

## Node

```bash
ovira node key                               # print the node key again
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

Back up the database from **Settings → Backup** or copy `/var/lib/ovira/ovira.db`.

## Installed before the rename?

The product used to be called Burrow. A server installed under that name keeps its original file and service names, so an update never moves anything: replace `ovira` with `burrow` in the service names and paths above (`systemctl status burrow`, `/etc/burrow/config.json`, `/var/lib/burrow/`). The `ovira` command works there too; it is the same program.
