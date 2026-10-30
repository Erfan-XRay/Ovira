# Update Ovira

Ovira updates from the panel or from the command line. The panel and each node update separately, and clients stay connected while they do. This page covers the three ways to update, what happens during an update, and how nodes follow.

## Update from the panel

When a new version is out, every admin sees a banner at the top of the panel and a dot next to **Updates** in the menu. The owner can press **Update now** in the banner. **Remind me with the next version** hides it until the following release.

On the **Updates** page:

1. Press **Check for updates** if the page does not already show a version.
2. Read **What's new**.
3. Press the install button for the version, then **Install** to confirm.
4. Keep the page open. It shows the stages **Download and verify**, **Install** and **Restart**.

The panel is unreachable for a few seconds while it restarts. Every open panel page then reloads by itself and says which version it is on. OpenVPN stays up, and an inbound restarts only when the new version changes its settings.

Only the owner can install. Other admins see the page and the banner.

## Update from the command line

On the panel server, as root:

```bash
ovira update            # newest stable release
ovira update --beta     # newest beta
```

Running the installer command again does the same: on a server that has Ovira, it opens the `ovira` menu, where you choose the update entry. The same commands work on a node, where they update the node program and leave the tunnels up.

## Channels and automatic updates

Under **Update settings** on the **Updates** page, the owner chooses:

| Setting | What it does |
|---|---|
| **Channel** | **Stable** has tested releases only. **Beta** gets new features first and is tested less. You can switch back to stable at any time. |
| **Automatic updates** | **Off** never installs. **Notify me** shows the banner. **Install automatically** installs a new release at the hour set in **Install at**, in the server's time zone, which the page shows. |
| **Update nodes together with the panel** | Nodes follow the panel once it has started on the new version. |

## Update the nodes

The **Node versions** list on the **Updates** page shows each node's version. A node that is behind has an **Update to** button. With **Update nodes together with the panel** on, nodes follow the panel by themselves. A node that is offline at that moment is checked again later, so look at each node's own result instead of assuming that every node updated.

The node program restarts without stopping its OpenVPN processes. Tunnels normally stay up, but an update that changes an inbound's configuration can restart that inbound.

## What the update checks

- Every download is verified against the signed release list, and the panel refuses a file that does not match.
- The page refuses to install an older version that lacks a feature you use: WireGuard, OpenConnect, roles and reseller limits, or inbounds that are not on a node. It names the first version that supports the feature, and asks you to delete the feature's data or choose a newer version.
- If the new version does not come up, the panel shows `The panel did not come back on the new version. Check the server log.` Look at `ovira logs`.

::: warning
Take a [backup](/use/backup) before you update. It is your way back if something goes wrong.
:::

## Related pages

- [Updates](/use/updates): the **Updates** page field by field.
- [Back up and restore](/use/backup): the file to keep before an update.
- [Add a node](/start/add-node): nodes are separate installs with their own `ovira` command.
- [Changelog](/reference/changelog): what changed in each release.
