# First steps

## 1. Secure your account

Sign in with the password the installer printed, then open **Settings → My account**:

- change the password;
- turn on **two-factor sign-in** and keep the recovery codes somewhere safe.

## 2. Check the public address

**Settings → General → Panel colour** picks one of eight colour presets for the admin panel. **Settings → General → Public address** supplies the panel server's public address. The installer sets it to your server's IP (or your domain). Remote nodes use their own addresses or their configured connect addresses; check those under **Nodes** too.

## 3. Create a client

**Clients → New client**:

| Field | What it does |
|---|---|
| Traffic | Allowance in GB; empty means unlimited |
| Ends | A date, or *N days after first use* so the clock starts when the client first connects |
| Devices at once | How many tunnels may be open together, counted across all inbounds and nodes |
| Reset | Daily, weekly or monthly traffic reset |
| Inbounds | All inbounds, or only some of them |

Need many? **Clients → Bulk create** makes `user-01 … user-50` with the same plan.

## 4. Hand over the subscription link

Each client has a private link, `https://your-panel/sub/…`. It shows remaining traffic, days left, a usage chart and buttons to import the profile into **OpenVPN Connect**. OpenVPN apps that open the same link receive the `.ovpn` directly.

The subscription path is configurable; copy the actual link from the panel. You can set the subscription page's brand, theme and optional support link in settings. The page uses the **Aurora** look and shows a tab per protocol (OpenVPN, WireGuard, AmneziaWG, Cisco) with only what the client has; the owner can reorder, hide or rename the tabs, add a short note per tab and edit the recommended apps under **Settings → Subscription page → Protocols**. That support link is your contact channel for your clients, not an official Ovira support service.

Send the link, or the QR code next to it, to the user. Rotate it from the client page if it leaks.

## 5. Watch it run

- **Overview** shows traffic, online clients and clients that need attention.
- **Connections** lists open tunnels, live rates and history; disconnect anyone with one click. Search it, filter by protocol or node, or switch to **By client** to see who has more devices or IPs than allowed.
- If other people help run the panel, see [Panel accounts and resellers](./resellers).
- Clients over quota or past their end date are disconnected on their own.
