# Updates

Open **Updates** in the panel to see the installed version, what is new and the release notes.

## You are told in the panel

When a new version is out, every admin sees a banner at the top of the panel and a dot on **Updates** in the menu, without opening the Updates page. The owner can press **Update now** right there; **Remind me with the next version** hides the banner until the following release.

## Channels

- **Stable**: tested releases only.
- **Beta**: new features first. Switch back to stable at any time; you stay on your version until the next stable release passes it.

## Automatic updates

| Setting | Behaviour |
|---|---|
| Off | Never checks by itself; use **Check for updates** |
| Notify me | Checks every hour and tells you what is available (default) |
| Install automatically | Installs new releases at the hour you choose |

## What happens during an update

1. The panel downloads the release from the Ovira mirror (or GitHub), checks it against the **signed** checksum list, and refuses anything that does not match.
2. It replaces its binary and restarts, which takes a few seconds. A progress window follows the steps.
3. OpenVPN keeps running; a server is restarted only if the new version changes its settings.
4. When the new version is running, every open panel page **reloads by itself**, including pages of other admins and after an automatic update, and says which version it is now on. Nobody has to refresh.
5. With **Update nodes together with the panel** on, every node gets the same version right after. Tunnels on a node stay up while it updates.

The Updates page also lists node versions with an **Update** button for any node that is behind.

## From the command line

Running the installer again updates the panel or node in place:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
```
