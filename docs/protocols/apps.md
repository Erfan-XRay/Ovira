# Client apps

Each protocol has its own client apps. This page lists the apps the subscription page recommends for every platform, and how a client imports a connection into each. You do not have to hand the list to customers: their [subscription page](/use/subscription-page) shows the right apps for their device.

## Apps by protocol and platform

| Protocol | Android | iPhone and iPad | Windows, macOS, Linux |
|---|---|---|---|
| OpenVPN | OpenVPN Connect | OpenVPN Connect | OpenVPN Connect |
| WireGuard | WireGuard | WireGuard | WireGuard |
| AmneziaWG | AmneziaWG, AmneziaVPN | AmneziaWG, AmneziaVPN | AmneziaWG, AmneziaVPN |
| OpenConnect | Cisco Secure Client, OpenConnect, F-Droid build of OpenConnect | Cisco Secure Client | Cisco Secure Client, OpenConnect-GUI, `openconnect` |

These are the defaults. The owner can change the recommended apps, rename a protocol's tab, add a short note and hide a protocol under **Settings → Subscription page → Protocols**. Other apps that speak the same protocol work too, but the Amnezia parameters only work in Amnezia apps.

## Import a connection

### OpenVPN

1. Install OpenVPN Connect.
2. On the phone, tap **Open in OpenVPN Connect** on the subscription page. On a computer, press **Download profile** and open the `.ovpn` file with the app.
3. If the inbound asks for a name and password, the page shows them. Enter them when the app asks.
4. Connect.

### WireGuard and AmneziaWG

1. Install WireGuard for a plain inbound, or AmneziaVPN or AmneziaWG for an Amnezia inbound.
2. On the subscription page, pick a device if there is more than one, then scan the QR code with the app or download the `.conf` file and import it.
3. Connect.

Each phone or computer needs its own device. Importing one device's configuration on two machines makes them disconnect each other.

### OpenConnect

1. Install Cisco Secure Client or an OpenConnect app.
2. Add a new connection with the **Server address** from the **Cisco** tab.
3. Sign in with the user name and password on the page.

Cisco Secure Client refuses a self-signed server unless **Block untrusted servers** is off in its settings. See [OpenConnect](./openconnect#certificate) for the alternatives.

## Related pages

- [Choosing a protocol](./index): which protocol suits which network.
- [Subscription page](/use/subscription-page): what customers see and how the owner customizes it.
- [Troubleshooting](/reference/troubleshooting): an app that connects but has no internet.
