# Command line

All commands run as root on the server.

## Panel

```bash
burrow info                                   # panel address, machine ID, license
burrow admin passwd -username admin           # set a new random password
burrow admin reset-2fa -username admin        # if the phone with the authenticator is lost
burrow admin list
burrow ssl issue -mode domain -domain panel.example.com
burrow ssl issue -mode ip
burrow ssl status | off
burrow apply                                  # rewrite OpenVPN files from the database
burrow version
```

## Node

```bash
burrow node key                               # print the node key again
burrow node reset-key                         # new API key; paste the new key in the panel
```

## Services and logs

```bash
systemctl status burrow                       # the panel
systemctl status 'burrow-ovpn@*'              # OpenVPN servers on the panel's server
systemctl status burrow-node 'burrow-node-ovpn@*'   # on a node
journalctl -u burrow -u 'burrow-ovpn@*' -f    # follow the logs
```

## Files

| Path | Contents |
|---|---|
| `/etc/burrow/config.json` | Panel port, secret path, HTTPS |
| `/var/lib/burrow/` | Database, PKI, OpenVPN configs, certificates |
| `/etc/burrow-node/` | Node config, TLS identity, API key |
| `/var/lib/burrow-node/` | OpenVPN files pushed by the panel |

Back up the database from **Settings → Backup** or copy `/var/lib/burrow/burrow.db`.
