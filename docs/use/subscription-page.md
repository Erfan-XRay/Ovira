# The subscription page

Each client has a private link that opens a page made for them. The page shows how much traffic and time are left, helps them install an app, and gives them the profile to import. This page covers what the client sees and the settings that change how the page looks.

## What the client sees

The link has the form `https://panel.example.com:2053/sub/...`. It works without signing in. The page shows:

- **Traffic left** and **Days left**, or `Unlimited traffic` and `No end date`. For a client that has not connected yet it says the days start at the first connection.
- How many devices are connected, the device limit, and when the traffic next resets.
- One tab per protocol the client can use: OpenVPN, WireGuard, AmneziaWG and Cisco (OpenConnect). A tab appears only if the client has an inbound of that protocol. The first tab opens first, and the number on the tab counts servers or devices.
- In each tab, **Install the app** with the app recommended for the visitor's device and an **Other devices** list, then **Add your configuration** or **Add the server**, then **Sign in** when the inbound asks for a user name and password.
- **Your usage**, with download and upload.
- **Open on another device**, a QR code that opens the same page on a phone.
- A support button and a channel button, if you set them.

When the plan is over, the page says so: the plan ended on a date, all traffic is used, or the account is paused. It tells the client to contact support to renew.

If the link is wrong or has been replaced, the page says `This link is not valid. Ask for a new one.` Replace a link from the client's page with **New subscription link**.

## Where the link points

The link starts with the address you opened the panel with. To use another address, for example a separate domain for client pages, set **Subscription link address** under **Settings → General**, such as `https://sub.example.com`. The part after the address is the **Subscription path** under **Settings → Panel access**, `sub` by default.

**Default language for client pages** under **Settings → General** sets the language client pages open in, English or Persian.

## The look of the page

Open **Settings → Subscription page**. A live preview shows a client's real page and follows every change. It needs at least one client to exist. The tab has three parts.

### Appearance

| Field | What it does |
|---|---|
| **Look** | **Night shift** (a dark control room with glowing lamps), **Aurora** (soft colour glow and frosted-glass cards) or **Pop** (loud, playful cards with thick outlines). |
| **Accent colour** | Buttons, highlights and charts. **Theme colour** uses the look's own colour. Pick a swatch or **Custom colour** for another one; light and dark versions are worked out for you. |

### Shop

| Field | What it does |
|---|---|
| **Shop name** | Shown at the top and bottom of the page. Empty shows nothing. |
| **Support link** | A Telegram, WhatsApp, Instagram or e-mail link, a website, or a phone number written as `tel:+98...`. The page shows `Shown as` the kind it recognised, and styles the button to match. |
| **Button text (optional)** | The text on the support button. |
| **Channel link** | Your shop's Telegram channel, for news. |

The support link is your contact for your clients. It is not a channel to the Ovira developers.

### Protocols

**Protocols** lists the four tabs. For each you can:

- Move it up or down. The first one **Opens first**.
- Switch it between **Shown** and **Hidden**. If you hide all of them, the page warns you that clients would have no way to connect.
- Set a **Tab name**. Empty uses the default name.
- Write a **Guide note**, plain text up to 500 characters, shown at the top of the tab.
- Edit **Recommended apps** per platform: Android, iPhone and iPad, and Windows, macOS and Linux. **Use recommended apps** keeps Ovira's own list. Turn it off to **Add app** with an **App name** and a **Download link** that must start with `https://`, reorder the apps, or remove one. The first app is shown as recommended. **Reset to recommended** restores the list.

## Related pages

- [Clients](/use/clients): where the link and QR code are copied from.
- [Client apps](/protocols/apps): which app suits which protocol and platform.
- [Settings](/use/settings): the address and language fields.
