# Move the panel to a new server

You can move the panel to another server by installing Ovira there and restoring a backup. The backup carries your clients, certificates, inbounds, nodes, accounts and settings, so nothing is created again. This page covers the whole move, in order, and the things that do not travel with the backup.

## What moves and what does not

The backup is the panel's database. It includes the panel accounts and their passwords, the clients and their subscription links, the inbounds and the node list.

It does not include the files that decide how the panel is served: the port, the secret path and the HTTPS certificate. The new server keeps what its own installer created. The license does not travel either, because it belongs to a server.

## Move the panel

1. On the old panel, open **Settings → Backup** and press **Download backup**. Keep the `.db` file private. It holds every client and certificate.
2. Install the panel on the new server, as in [Install the panel](/start/install-panel). Note the address and the password it prints.
3. Sign in to the new panel. Open **Settings → Backup**, press **Choose file**, and select the `.db` file.
4. Open **Settings → Panel access** and press **Restart panel**. On restart the uploaded file replaces the database, and the old database stays beside it on the server.
5. Sign in again. The accounts and passwords are now those of the old panel, and the new installer's password no longer applies. The address and secret path stay the ones the new installer printed.
6. Open **License** and enter the license key. If the key is still active on the old panel, remove it there first with **Remove license**. Do this when you are ready to switch, because a panel without a license falls back to the free plan, and clients above its limit cannot connect.
7. Open **Settings → General** and set **Public address** to the new server's domain or IP.
8. Open **Inbounds** and **Nodes**. Inbounds that ran on the old server's own node are now on **This server** of the new panel. Start any that show **Stopped**.
9. Stop the old panel with `ovira stop` once you have checked the new one.

The file from `ovira backup` on the server is a `.tar.gz`. It holds `ovira.db` and `config.json`; upload only the `ovira.db` file.

::: tip Use a domain as the public address
Client profiles contain the **Public address**. If it is a domain, moving the panel needs only a DNS change. If it is an IP address, every client has to download a new profile.
:::

## Nodes

Nodes keep their keys, so the new panel connects to them again without reinstalling them. A node installed with `--panel-ip` answers only the old panel's address. Add the new panel's IP to the `allowFrom` list in `/etc/ovira-node/node.json` on each such node, then run `ovira restart` there.

## Related pages

- [Back up and restore](/use/backup): the backup tab and what the file contains.
- [License](/use/license): moving a license between panels.
- [Add a node](/start/add-node): reconnecting a node whose key changed.
- [Remove Ovira](/start/uninstall): clean up the old server.
