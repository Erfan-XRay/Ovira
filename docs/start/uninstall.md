# Remove Ovira

You can remove the panel, or a node, from a server with one command. By default the command keeps your data, so installing again picks up where you left off. This page covers removing, keeping or deleting the data, and what stays behind.

## Before you remove the panel

- If you want to use the license on another panel, open **License** and press **Remove license** first. See [License](/use/license).
- Download a backup under **Settings → Backup** if you may need the data later. Deleting the data cannot be undone.
- Clients lose their connection when the inbounds stop. Tell them first.

## Remove the panel

On the panel server, as root:

```bash
ovira uninstall            # removes Ovira, keeps the data
ovira uninstall --purge    # removes Ovira and deletes the data
```

On a terminal, the command asks what to do: **Remove, keep data (recommended)**, **Remove and delete all data (clients, keys, certificates)**, or **Cancel**. Deleting asks you to type `delete` to confirm. Without a terminal, add `--yes`; `--purge` then deletes the data without asking.

The command stops the panel and every inbound, removes the services, the `ovira` command and the management scripts, and leaves the data in `/var/lib/ovira` and `/etc/ovira` unless you purge.

## Install again

Run the installer. It sees the data left behind and offers to reinstall and keep it, to install fresh (the old data is saved as a `.tar.gz` in `/root` first), or to cancel. After a reinstall with the data kept, your clients, keys and settings are back, and so are the accounts. Use the old password, or `ovira password` if you forgot it.

## Remove a node

On the node server, as root:

```bash
ovira uninstall            # keeps the node's data and key
ovira uninstall --purge    # deletes them too
```

Removing the software does not remove the node from the panel. In the panel, use **Nodes → ⋯ → Remove node**; its inbounds go back to **Not on a node**. See [Nodes](/use/nodes).

## What stays behind

The command does not remove packages the installer added, such as OpenVPN, or the firewall rules it opened. Remove those yourself if you no longer need them.

## Related pages

- [Back up and restore](/use/backup): keep a copy before you delete anything.
- [Move the panel](/start/move-server): the same data on a different server.
- [Install the panel](/start/install-panel): what a fresh install asks.
