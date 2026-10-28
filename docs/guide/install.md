# Install

## Requirements

- A server with **Debian 11+**, **Ubuntu 20.04+** or **AlmaLinux / Rocky 8+**, amd64 or arm64
- Root access and a public IPv4 address
- 512 MB of RAM is enough for a few hundred clients

## One command

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
```

The installer asks four things; press Enter to keep a default:

| Question | Default | Notes |
|---|---|---|
| Panel port | `2053` | Any free TCP port |
| OpenVPN UDP port | `1194` | The main OpenVPN server |
| Also run OpenVPN over TCP? | no | For networks that block UDP; asks for the port (default `443`) |
| HTTPS for the panel | server IP | Domain, server IP or none, see [HTTPS](./https) |

At the end it prints the panel address, user name and password:

```
Panel      https://203.0.113.10:2053/k3x9qa7bd1/
Username   admin
Password   Zp8...
OpenVPN    udp/1194
```

::: tip Keep the panel path secret
Everything on the panel port except that path answers *404*, so scanners do not even see a login page.
:::

## Without questions

Every answer can be passed as an option, which is handy for scripts:

```bash
bash install.sh --yes --port 8443 --udp-port 1194 --tcp --tcp-port 443 \
  --ssl domain --domain panel.example.com --email you@example.com
```

| Option | Meaning |
|---|---|
| `--port N` | Panel port |
| `--udp-port N` | OpenVPN UDP port |
| `--tcp` / `--tcp-port N` | Start the TCP server too, on this port |
| `--ssl domain\|ip\|none` | How the panel gets HTTPS |
| `--domain`, `--email` | For `--ssl domain` |
| `--beta` | Install the newest beta instead of the stable release |
| `--binary FILE` | Use a downloaded binary instead of fetching one |
| `--yes` | Never ask |

## What the installer does

1. Installs OpenVPN (2.5 or newer), iptables and curl.
2. Downloads the release, checks it against `SHA256SUMS` and the **release signature**, and refuses anything that does not match.
3. Creates the `ovira` service and one `ovira-ovpn@NAME` service per OpenVPN server.
4. Turns on IPv4 forwarding and NAT, opens the ports in ufw or firewalld when they are active.
5. Gets a Let's Encrypt certificate when you chose HTTPS.

If GitHub is slow or blocked from your server, downloads fall back to the Ovira mirror automatically.

## Update

Run the same command again, or use **Updates** inside the panel. See [Updates](./updates).

## Uninstall

```bash
bash install.sh --uninstall           # keeps /var/lib/ovira and /etc/ovira
bash install.sh --uninstall --purge   # removes everything
```
