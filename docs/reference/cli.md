# Command line

The `ovira` command manages Ovira from the server's shell. Run it as root. Typed alone it opens a menu, and every menu entry is also a command. The same command exists on a panel server and on a node server, and it works out which one it is on. This page lists every command, the options of the install scripts, and the menu.

## Everyday commands on a panel

| Command | What it does |
|---|---|
| `ovira` | Opens the menu. |
| `ovira status` | Shows the panel state, version, address, whether HTTPS is on, the license state, whether this server is a node, the machine ID and the running inbounds. It also says when a newer release exists. |
| `ovira update` | Installs the newest release. `--beta` uses the beta channel, `--force` reinstalls the current version, `--binary FILE` installs a binary you supply. |
| `ovira start`, `ovira stop`, `ovira restart` | Control the panel service. `stop` asks first. |
| `ovira logs` | Shows the last 100 lines of the panel log. `-f` follows it. |
| `ovira logs NAME` | Shows the log of one inbound by its name, for example `udp1194`. Works for OpenVPN, OpenConnect and WireGuard inbounds. |
| `ovira password [USER]` | Sets a new password for a panel account. Type one, or press Enter for a strong random one, which is shown once. The account's other sessions are signed out. |
| `ovira license` | Shows the machine ID and the license state. Activate or change a license in the panel under **License**. |
| `ovira ssl [status\|domain\|ip\|off]` | Manages the panel's HTTPS certificate. See [HTTPS for the panel](/start/https). |
| `ovira local-node enable\|disable\|status` | Makes the panel's own server a node too, or panel only. `disable` keeps its inbounds for later. See [This server as a node](/start/same-server). |
| `ovira ocserv install` | Installs the OpenConnect server software on the panel's own server. `ovira ocserv status` shows the version found. |
| `ovira backup [FILE]` | Saves the database and `config.json` into one private `.tar.gz`. The default is `/root/ovira-backup-DATE.tar.gz`. |
| `ovira uninstall [--purge]` | Removes Ovira. It asks whether to keep the data. `--purge` deletes the data too. |
| `ovira version` | Prints the installed version. |
| `ovira help` | Prints a summary of these commands. |

`ovira local-node` is also reachable as `ovira openvpn`, and `ovira ocserv` as `ovira oc`.

Take a backup before you update or change anything large. Do not copy only the live database file while the service runs: recent writes may still sit beside it. `ovira backup` and **Settings → Backup** take a consistent copy. Keep backups private, because they contain credentials and client data.

## Commands on a node

A node has fewer commands. The menu and these commands act on the node service, `ovira-node`.

| Command | What it does |
|---|---|
| `ovira` | Opens the node menu. |
| `ovira status` | Shows the node's state, version, address, who may call it, and the node key. |
| `ovira key` | Prints the node key, for pasting into the panel. `ovira info` prints it too. |
| `ovira update` | Installs the newest release. Running tunnels stay up. |
| `ovira start`, `ovira stop`, `ovira restart` | Control the node service. `stop` asks first. While it is stopped the panel cannot manage the node. |
| `ovira logs [NAME]` | Shows the node log or one inbound's log. `-f` follows. |
| `ovira node reset-key` | Creates a new node key. Restart the node, then paste the new key into the node's editor in the panel. |
| `ovira uninstall [--purge]` | Removes the node. `--purge` deletes its data and key. |

If one server runs both a panel and a node, commands go to the panel first. The menu has an entry that opens the node's menu.

## Lower-level commands

These talk to the program directly. The installer, the menu and systemd call them for you. Use them in scripts or when the menu cannot reach the panel.

```bash
ovira info                                  # panel address, machine ID, license
ovira admin list                            # panel accounts: id, name, role, 2FA, disabled
ovira admin create -username NAME [-password PW] [-role owner|admin|reseller]
ovira admin passwd -username NAME [-password PW]
ovira admin reset-2fa -username NAME        # when the authenticator phone is lost
ovira ssl issue -mode domain -domain panel.example.com [-email you@example.com]
ovira ssl issue -mode ip                    # detects the server's public IPv4
ovira ssl status
ovira ssl off                               # back to plain HTTP; restart the panel
ovira apply                                 # rewrite inbound files from the database
```

Without `-password`, `admin create` and `admin passwd` generate a random one and print it. A password you type must be strong enough, and `admin create` respects the plan's limit on panel accounts. All of these take `-config FILE`, which defaults to `/etc/ovira/config.json`.

After `ovira ssl issue` or `ovira ssl off`, run `systemctl restart ovira` so the panel switches. `ovira ssl domain` and `ovira ssl ip` do the issuing and the restart for you.

## Install options

The panel installer is `install.sh`, and the node installer is `node.sh`. Both ask what they need. Every answer can instead be passed as an option, and `--yes` skips all questions.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) --yes \
  --port 8443 --ssl domain --domain panel.example.com --email you@example.com
```

| Option | Panel | Node | Meaning |
|---|---|---|---|
| `--port N` | Yes | Yes | Panel port (default 2053), or the node's API port (default 62060). |
| `--ssl domain\|ip\|none` | Yes | | How the panel gets HTTPS. |
| `--domain NAME`, `--email ADDRESS` | Yes | | For `--ssl domain`. |
| `--user NAME` | Yes | | Name of the first owner account (default `admin`). |
| `--local-node`, `--no-local-node` | Yes | | Whether this server is a node of its panel (default yes). `--with-openvpn` and `--panel-only` are older names. |
| `--panel-ip IP` | | Yes | The node answers only this panel address. |
| `--beta` | Yes | Yes | Use the newest beta instead of the stable release. |
| `--binary FILE` | Yes | Yes | Use a local build instead of downloading. |
| `--fresh` | Yes | Yes | After a removal that kept its data, start empty instead. A backup of the old data is saved in `/root`. |
| `--purge` | Yes | Yes | With `uninstall`: delete the data too. |
| `--force` | Yes | Yes | With `update`: reinstall even if the version matches. |
| `--yes` | Yes | Yes | Do not ask. |

`--udp-port`, `--tcp-port` and `--tcp` still exist but are ignored: the installer creates no inbounds. Create them in the panel under **Inbounds**. The older forms `install.sh node …`, `--node` and `--uninstall --node` hand over to `node.sh`.

Running either script again on a server where Ovira is installed opens the menu or, with `update`, updates it.

## The menu

On a panel, `ovira` shows these entries. A line at the top shows the state and whether an update is out.

| Section | Entries |
|---|---|
| **PANEL** | **Status & address**, **Change admin password**, **License & machine ID**, **HTTPS certificate** |
| **SERVICES** | **Restart the panel**, **Start the panel**, **Stop the panel**, **Live logs** |
| **THIS SERVER** | **This server as a node: ON** or **OFF**, **Install OpenConnect**, and **Node on this server** if a node is installed here too |
| **MAINTENANCE** | **Update Ovira**, **Back up the database**, **Uninstall Ovira** |

On a node the sections are **NODE** (**Status & node key**, **Show node key**), **SERVICES** (restart, start, stop, **Live logs**) and **MAINTENANCE** (**Update Ovira**, **Uninstall the node**).

Move with the arrow keys or type an entry's number. Ctrl+C closes the menu, or ends the screen you are in.

## Installed before the rename?

The product used to be called Burrow. A server installed under that name keeps its original file and service names, so an update never moves anything. Replace `ovira` with `burrow` in the service names and paths in this documentation: `systemctl status burrow`, `/etc/burrow/config.json`, `/var/lib/burrow/`. The `ovira` command works there too, because it is the same program.

## Related pages

- [Files, services and ports](./files-and-ports): where everything the commands touch lives.
- [Troubleshooting](./troubleshooting): which command to run for which symptom.
- [Install the panel](/start/install-panel): the installer step by step.
- [Update the panel and nodes](/start/update): the update flow.
