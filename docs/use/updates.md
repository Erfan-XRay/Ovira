# Updates

The **Updates** page shows the version that is installed, tells you when a newer one exists, and lets the owner install it. New versions come from GitHub, through the Ovira mirror when GitHub is not reachable. Every download is checked against the release signature. This page describes the page block by block. For the steps of an update and what to expect, see [Update Ovira](/start/update).

## Who can use it

Owners and roles that see all clients can open the page and see the banner. Only owners can install a version, change the update settings and update nodes. A dot beside **Updates** in the menu means a new version is available.

## The top block

- **Installed** shows the running version.
- One of `{version} is available`, `You are on the latest version` or `Checking…`.
- **Check for updates** asks for the newest release now.
- An install button, `Install {version}`, for owners. It asks for confirmation. The panel restarts on the new version in a few seconds, and OpenVPN keeps running.
- `Checked {when} via {source}` tells you when the last check was and whether it came from GitHub or the Ovira mirror.
- Errors from the last check or the last update are shown in red.

During an update the page shows the stages **Download and verify**, **Install** and **Restart**, then reloads itself on the new version. Every other open panel page reloads too.

## What's new

The release notes of versions newer than yours, newest first. Betas carry a **Beta** tag. A release without notes says `No release notes.`

## Update settings

Owners only.

| Setting | What it does |
|---|---|
| **Channel** | **Stable**: tested releases only. **Beta**: new features first, tested less. You can switch back to stable at any time. |
| **Automatic updates** | **Off**, **Notify me** or **Install automatically**. |
| **Install at** | The hour for automatic installs. The page shows the server's time zone beside it. |
| **Update nodes together with the panel** | Nodes follow the panel after it has started on the new version. The node agent update does not restart OpenVPN. |

## Node versions

One row per node with its version. A node that is behind has an **Update to** button for owners, and one that is current is marked **Up to date**. A node on a different version, ahead of or beside the panel, is marked **Different version**. While a node updates, its row shows the step: **Checking connection**, **Downloading and verifying**, **Installing**, **Waiting for startup confirmation**, then **Version confirmed**, or **Update not confirmed** if it failed. A failed node can be retried. Offline nodes that are behind are checked again by themselves when node updates are on.

## Recent releases

A collapsed list of recent releases with their dates and notes. The one you run is marked **Installed**. The list is for reading; versions are installed from the top block.

## Related pages

- [Update Ovira](/start/update): the update process and the command line.
- [Nodes](/use/nodes): node versions on the node cards.
- [Changelog](/reference/changelog): what changed in each release.
