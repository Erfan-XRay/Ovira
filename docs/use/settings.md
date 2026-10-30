# Settings

**Settings** holds the panel-wide options. It is organised in tabs, and which tabs you see depends on your role. This page lists every tab and, for the **General** tab, every field. The tabs with their own pages are linked.

## The tabs

| Tab | Who sees it | What it holds |
|---|---|---|
| **General** | Owners | Addresses, language, colour, warning thresholds, history retention, version. |
| **Subscription page** | Owners | The look of the client page. See [The subscription page](/use/subscription-page). |
| **Panel access** | Owners | The panel's own address, secret path and HTTPS. |
| **My account** | Everyone | Your password, two-factor sign-in and signed-in devices. See [Panel accounts](/use/admins). |
| **Backup** | Owners | Download and restore. See [Back up and restore](/use/backup). |
| **Activity log** | Owners and roles that see all clients | Who did what. See [Activity log](/use/audit). |

## General

| Field | What it does |
|---|---|
| **Public address** | The domain or IP that client profiles connect to. The installer fills it. An inbound can override it with **Public address override**. |
| **Subscription link address** | Optional, for example `https://sub.example.com`. Empty uses the address you open the panel with. |
| **Default language for client pages** | English or Persian. |
| **Panel colour** | The accent colour of the panel for everyone who signs in: **Lime**, **Cyan**, **Mint**, **Amber**, **Coral**, **Rose**, **Violet** or **Sky**. It previews as you pick and is saved with **Save**. Client pages have their own colour. |
| **Warn when a plan ends within** | Days. Clients closer than this to their end date appear under **Running out**. |
| **Warn when traffic used reaches** | Percent. Clients above it appear under **Running out**. |
| **Sign out after inactivity** | Hours. After this long without activity, a signed-in browser is signed out. |
| **Traffic charts** | Days of usage history kept. |
| **Connection log** | Days of finished connections kept. |
| **Activity log** | Days of the audit log kept. |

The section at the bottom shows the installed version of Ovira and OpenVPN, the operating system and the **Machine ID** of this server, with a copy button. You give it when you buy or renew a license outside the panel.

## Panel access

The block at the top is **HTTPS**, described in [HTTPS for the panel](/start/https). Below it are the fields that decide where the panel answers.

| Field | What it does |
|---|---|
| **Listen address** | The port the panel listens on, for example `:2053`. Use `127.0.0.1:2053` behind a reverse proxy. |
| **Secret path** | The panel answers only under this path. Everything else looks like an empty server. |
| **Subscription path** | The first part of subscription links. |
| **TLS certificate file**, **TLS key file** | Your own certificate as full paths on the server. Empty for plain HTTP or the Ovira-managed certificate. |
| **Behind a reverse proxy (trust X-Forwarded-For)** | Turn on only when a proxy you control sets that header. |

These take effect after a restart. **Save** keeps them, the page tells you `Saved. Restart the panel to apply.`, and **Restart panel** applies them. The page shows the new address in the form `After restart the panel will be at ...`. Write it down before you restart. VPN connections are not affected by the restart.

::: warning
A wrong **Listen address** or **Secret path** makes the panel unreachable after the restart. Check the address under the fields before you restart. If you are locked out, `ovira status` on the server prints the address the panel now uses.
:::

## Related pages

- [Back up and restore](/use/backup): the **Backup** tab.
- [Panel accounts](/use/admins): the **My account** tab.
- [First sign-in](/start/first-sign-in): the first settings to check.
- [Files, services and ports](/reference/files-and-ports): where the same values live on the server.
