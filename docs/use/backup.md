# Back up and restore

A backup is one file holding the panel's database: every client, certificate, inbound, node, account and setting. The **Backup** tab under **Settings** downloads it and restores from it, and the `ovira backup` command makes one on the server. This page covers both, what a backup does not hold, and what happens on restore.

## Download a backup

Only owners see the tab.

1. Open **Settings → Backup**.
2. Press **Download backup**.

The browser saves a file named like `ovira-20261030-1415.db`. It can be made while the panel is running. The file holds client secrets and certificates, so keep it private and store it away from the server.

## Restore from a backup

1. Open **Settings → Backup**.
2. Under **Restore from backup**, press **Choose file** and select a `.db` file.
3. The panel checks that it is an Ovira backup, and answers `Backup uploaded. Restart the panel to switch to it.` Otherwise it refuses the file.
4. Open **Settings → Panel access** and press **Restart panel**.

On restart the uploaded file replaces the current database. The previous database stays on the server next to it, with `.before-restore-` and the time added to its name, so you can go back by hand.

::: warning
Restoring replaces everything that changed after the backup was made: clients created, traffic used, accounts and settings.
:::

## What a backup does not hold

The database does not hold the files that decide how the panel is served: the port, the secret path and the HTTPS certificate files. After a restore on the same server these stay as they were. The license is tied to the server and is not moved by a backup, see [License](/use/license).

## From the command line

On the panel server, as root:

```bash
ovira backup                       # saves to /root/ovira-backup-DATE.tar.gz
ovira backup /root/panel.tar.gz    # saves to a path you choose
```

This file is a `.tar.gz` with `ovira.db` and `config.json` inside. It is the better copy for disaster recovery, because it includes the panel's configuration. To restore it through the panel, extract `ovira.db` and upload that file. Run the command from cron to schedule backups.

## Related pages

- [Move the panel](/start/move-server): restoring a backup onto a new server.
- [Update Ovira](/start/update): take a backup first.
- [Settings](/use/settings): the other tabs.
