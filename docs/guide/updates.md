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
| Install automatically | Installs new releases during the chosen hour in the panel server's time zone, shown on the page |

## What happens during an update

1. The panel downloads the release from the Ovira mirror (or GitHub), checks it against the **signed** checksum list, and refuses anything that does not match.
2. It checks the downloaded executable's version, keeps a backup, replaces the binary and restarts. The progress window waits for the requested version to confirm startup; download and startup time vary.
3. OpenVPN keeps running; an inbound is restarted only if the new version changes its settings.
4. When the new version is running, every open panel page **reloads by itself**, including pages of other admins and after an automatic update, and says which version it is now on. Nobody has to refresh.
5. With **Update nodes together with the panel** on, node updates follow only after the panel confirms successful startup. Each node downloads and verifies the release and reports its own progress or error. Updating the agent does not intentionally stop OpenVPN, but uninterrupted tunnels are not guaranteed if a host, VPN process or changed configuration needs restarting.

The Updates page also lists node versions with an **Update** button for any node that is behind.

## Startup recovery and retries

On supported systemd installations, an independent recovery timer can restore the previous executable if the new one fails startup confirmation. This restores the binary only: database or configuration changes are not rolled back, and the transient recovery timer does not survive a host reboot. Older versions use their existing updater for the first upgrade into this mechanism.

Failed automatic panel updates have a six-hour retry cooldown. When node updates are enabled, the panel also checks for older nodes every 30 minutes. An offline node may therefore catch up later; inspect its individual result instead of assuming that all nodes updated with the panel.

## From the command line

`ovira update` updates the panel or node in place (add `--beta` for the beta channel). Running the install command again opens the management menu on an installed server; choose **Update**:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
```
