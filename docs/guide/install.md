# Install

## Requirements

- A server with **Debian 11+**, **Ubuntu 20.04+** or **AlmaLinux / Rocky 8+**, amd64 or arm64
- Root access and a public IPv4 address
- Size RAM, CPU and bandwidth for your simultaneous connections and encryption workload; there is no guaranteed client capacity for a fixed RAM size
- Outbound HTTPS for downloads and paid online license renewal; inbound access to the selected panel, VPN and certificate-validation ports

## One command

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
```

The script downloads Ovira from GitHub, so nothing has to be copied to the server first. On a new server it asks what to install:

| Choice | What it is |
|---|---|
| **Panel** (recommended) | The web panel that manages everything |
| **Node** | An extra OpenVPN server controlled by a panel on another server, see [Nodes](./nodes) |

## Installing the panel

Press Enter to keep a default:

| Question | Default | Notes |
|---|---|---|
| Panel port | `2053` | Any free TCP port |
| Run OpenVPN on this server too? | yes | See below |
| OpenVPN UDP port | `1194` | Only if OpenVPN runs here |
| Also run OpenVPN over TCP? | no | For networks that block UDP; asks for the port (default `443`) |
| HTTPS for the panel | server IP | Domain, server IP or none, see [HTTPS](./https) |

### Panel with OpenVPN, or an empty panel

- **Yes**: this one server is both the panel and an OpenVPN server. Right for a single VPS.
- **No**: an *empty panel* that only manages nodes. Nothing OpenVPN-related is installed on it; add servers under **Nodes**.

You can change your mind at any time. On a panel-only server, `ovira openvpn enable` installs OpenVPN and makes the panel's own server a node too. `ovira openvpn disable` turns it off again and keeps its servers for later.

At the end the script prints the panel address, user name and password:

```
Panel      https://203.0.113.10:2053/k3x9qa7bd1/
Username   admin
Password   Zp8...
OpenVPN    udp/1194 on this server
```

::: tip Keep the panel path secret
Everything on the panel port except that path answers *404*, so the normal login page is not exposed at arbitrary paths. This is an extra layer; keep HTTPS and two-factor sign-in enabled.
:::

## Without questions

Every answer can be passed as an option, which is handy for scripts:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) panel --yes \
  --port 8443 --udp-port 1194 --tcp --tcp-port 443 \
  --ssl domain --domain panel.example.com --email you@example.com
```

| Option | Meaning |
|---|---|
| `panel` / `node` | What to install (default: panel) |
| `--panel-only` | Empty panel: no OpenVPN on this server |
| `--with-openvpn` | The panel's server runs OpenVPN too (default) |
| `--port N` | Panel port (node: API port, default `62060`) |
| `--udp-port N` | OpenVPN UDP port |
| `--tcp` / `--tcp-port N` | Start the TCP server too, on this port |
| `--ssl domain\|ip\|none` | How the panel gets HTTPS |
| `--domain`, `--email` | For `--ssl domain` |
| `--user NAME` | Name of the first admin (default `admin`) |
| `--panel-ip IP` | Node only: answer calls from this panel address only |
| `--beta` | Install the newest beta instead of the stable release |
| `--binary FILE` | Use a downloaded binary instead of fetching one |
| `--yes` | Never ask |

## What the script does

1. Installs the packages it needs (OpenVPN 2.5 or newer and iptables only when this server runs OpenVPN).
2. Downloads the release, checks it against `SHA256SUMS` and the **release signature**, and refuses anything that does not match.
3. Creates the `ovira` service and, with OpenVPN, one `ovira-ovpn@NAME` service per OpenVPN server.
4. Turns on IPv4 forwarding, opens the ports in ufw or firewalld when they are active.
5. Gets a Let's Encrypt certificate when you chose HTTPS.
6. Leaves itself on the server as the **`ovira` command**.

If GitHub is slow or blocked from your server, downloads fall back to the Ovira mirror automatically. Downloaded releases require OpenSSL 3 or newer to verify their signature; installation stops if verification cannot be completed. An explicitly supplied `--binary` file is local input rather than a verified release download.

## The `ovira` command

After installing, type `ovira` for a menu:

```
  OVIRA  OpenVPN panel
  ──────────────────────────────────────────────
  ●  Ovira VERSION panel   running

     1  Status and address
     2  Update
     3  Restart the panel
     4  Show the log
     5  Change an admin password
     6  License and machine ID
     7  HTTPS certificate
     8  OpenVPN on this server: on  (turn off)
     9  Back up the database
    10  Uninstall
     0  Exit
```

Each entry is also a command (`ovira status`, `ovira update`, `ovira password`...). See [Command line](./cli).

Running the install command again on a server that already has Ovira opens the same menu.

## Update

`ovira update`, or run the install command again, or use **Updates** inside the panel. See [Updates](./updates).

## Uninstall

```bash
ovira uninstall            # keeps /var/lib/ovira and /etc/ovira
ovira uninstall --purge    # removes everything, data included
```
