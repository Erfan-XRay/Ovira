# Install the panel

The panel installs with one command that asks four short questions. It creates no inbounds and no clients; you create those in the panel afterwards. This page covers the command, the questions, the options for unattended installs and what ends up on the server.

## Run the installer

Log in as root and run:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
```

Press Enter to keep the default in an answer. The installer asks, in this order:

| Question | Default | What it does |
|---|---|---|
| **Panel port** | `2053` | The TCP port the panel listens on. The installer stops if the port is already in use. |
| **Use this server as a node too?** | yes | Yes: the server also runs VPN inbounds and appears under **Nodes** as **This server**. No: panel only, and you [add nodes](/start/add-node) on other servers. You can change this later, see [This server as a node](/start/same-server). |
| HTTPS | the server's IP | A Let's Encrypt certificate for a domain, for the server's IP, or none. See [HTTPS for the panel](/start/https). |
| Email for certificate notices | empty | Optional. Let's Encrypt writes to it only when the certificate needs attention. |

The email question is skipped when you choose no HTTPS. Before it installs anything, the installer prints a summary and asks **Start installation?**.

When it finishes, it prints a card with the panel address, the user name `admin` and a random password:

```text
Username   admin
Panel address (open it in your browser)
https://203.0.113.10:2053/k3x9qa7bd1/
Password (shown once; change it in the panel)
Zp8...
```

The password appears once. The address ends in a random secret path, and the panel answers only under that path. Copy both before you close the terminal. If you lose them, [the first sign-in page](/start/first-sign-in) shows how to recover.

::: warning
If the certificate cannot be issued, the installer does not stop. The panel starts on plain HTTP and the address begins with `http://`. Passwords then cross the network unencrypted until you fix it with [`ovira ssl`](/start/https).
:::

## Unattended install

Every answer can be given as an option. With `--yes` the installer never asks, and uses the options and the defaults:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) --yes \
  --port 8443 --ssl domain --domain panel.example.com --email you@example.com
```

| Option | What it does |
|---|---|
| `--port N` | Panel port. |
| `--local-node` | This server is also a node (the default). |
| `--no-local-node` | Panel only. |
| `--ssl domain`, `--ssl ip`, `--ssl none` | How the panel gets HTTPS. Unattended, the default is `ip`. |
| `--domain NAME`, `--email ADDRESS` | The domain and the notice address for `--ssl domain`. |
| `--user NAME` | Name of the first account. Default `admin`. |
| `--beta` | Install the newest beta instead of the stable release. |
| `--binary FILE` | Use a binary you already downloaded. |
| `--fresh` | After a removal that kept its data, start empty instead of reusing the data. |
| `--yes` | Do not ask anything. |

`--udp-port`, `--tcp-port` and `--tcp` from older versions are still accepted and ignored. Inbounds and their ports are set in the panel.

## What the installer does

1. Checks the system (Debian, Ubuntu, AlmaLinux, Rocky or CentOS Stream), root access and systemd.
2. Installs the packages it needs. When the server is also a node, that includes OpenVPN 2.5 or newer; on Debian-based systems with an older OpenVPN it adds the OpenVPN community repository.
3. Downloads the release from GitHub, and from the Ovira mirror when GitHub is slow or blocked. It verifies the download against the release signature and checksums, and stops if they do not match.
4. Creates the `ovira` service and starts the panel. Each inbound you create later gets its own service.
5. Turns on IPv4 forwarding when the server is a node, and opens the panel port in `ufw` or `firewalld` if one is active.
6. Requests the HTTPS certificate you chose.
7. Leaves the `ovira` command on the server.

The files you may need later:

| Path | Contents |
|---|---|
| `/usr/local/bin/ovira` | The program and the `ovira` command. |
| `/etc/ovira/config.json` | Panel port, secret path, subscription path and certificate files. |
| `/var/lib/ovira` | The database: clients, inbounds, nodes, certificates, settings. |
| `/var/log/ovira-install.log` | The installer's log. |

## Run it again

Running the same command on a server that already has Ovira opens the `ovira` menu, from which you can update. If Ovira was removed but its data is still on the server, the installer offers three choices: reinstall and keep the data, install fresh (a backup of the old data is saved in `/root`), or cancel.

## The `ovira` menu

Type `ovira` on the server for a menu: status and address, change an admin password, license and machine ID, HTTPS certificate, restart, start and stop, live logs, this server as a node, install OpenConnect, update, back up the database and uninstall. Each entry is also a command such as `ovira status` or `ovira update`. See [the command line reference](/reference/cli).

## Related pages

- [Sign in for the first time](/start/first-sign-in): the address, the password and the first settings to check.
- [HTTPS for the panel](/start/https): domain or IP certificates and what to do when issuing fails.
- [Files, services and ports](/reference/files-and-ports): everything the installer creates.
- [Remove Ovira](/start/uninstall): keeping or deleting the data.
