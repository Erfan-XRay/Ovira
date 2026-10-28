# Ovira

**An OpenVPN panel for Linux servers.** One binary with the web UI built in:
create clients with traffic and time limits, give each one a subscription
link, and run OpenVPN on as many servers as you like from one panel.

[Documentation](https://erfan-xray.github.io/Ovira/) ·
[مستندات فارسی](https://erfan-xray.github.io/Ovira/fa/) ·
[Releases](https://github.com/Erfan-XRay/Ovira/releases)

## Install

On a fresh Debian 11+, Ubuntu 20.04+ or AlmaLinux/Rocky 8+ server, as root:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
```

The script downloads Ovira itself and asks what to install: the **panel**, or
a **node** (an extra OpenVPN server for a panel on another server). For the
panel it asks the port, whether this server runs OpenVPN too (or stays an
empty panel that only manages nodes), the OpenVPN ports, and how the panel
gets HTTPS (a Let's Encrypt certificate for your domain, one for the
server's IP, or none), then prints the panel address and password.
Every download is checked against the release signature.

Afterwards `ovira` on the server opens a menu: status, update, change an
admin password, license and machine ID, HTTPS, OpenVPN on this server, logs,
backup and uninstall, each also available as a command (`ovira update`,
`ovira password`...).

## What you get

- **Clients**: traffic allowance, end date or a clock that starts at first
  use, devices at once, periodic resets, fixed IPs, bulk creation.
- **OpenVPN, fully**: UDP and TCP servers side by side, certificate and/or
  password sign-in, tls-crypt, cipher control, split or full tunnel, IPv6.
- **Nodes**: connect more servers to one panel. A client works on all of
  them, its device limit counts across them, each node has its own traffic
  multiplier and its own connect addresses (relays or tunnels in front of it).
  Groups decide which servers each client gets.
- **Subscription page**: remaining traffic, days left, usage chart and
  one-tap import, in English and Persian.
- **Updates from the panel**: stable and beta channels, release notes,
  automatic updates, nodes updated together with the panel.
- **Security**: Argon2id, two-factor sign-in, secret panel path, HTTPS with
  automatic certificates.

## Plans

The free plan runs **5 active clients and 2 nodes** with every feature.
Paid plans start at **$3 a month** and are bought inside the panel with
crypto (USDT TRC20 and other coins); the license activates by itself.

| Plan | Active clients | Nodes | Panels at once | Monthly |
|---|---|---|---|---|
| Free | 5 | 2 | 1 | $0 |
| Starter | 200 | 3 | 1 | $3 |
| Pro | 800 | 10 | 2 | $7 |
| Business | unlimited | unlimited | 3 | $15 |

Three months save about 10%, a year about 25%.

## License

Ovira is proprietary software: the binaries are free to use under the free
plan, paid plans need a license key. See [LICENSE](LICENSE).
