# IKEv2 and L2TP/IPsec

IKEv2 and L2TP/IPsec are the VPN types built into phones and computers. Your customers need no extra app: they add a VPN in their device settings, or install a ready-made setup file from their subscription page. Both arrived in Ovira 1.0 and are available on every plan, on the panel's own server and on nodes.

| | IKEv2 | L2TP/IPsec |
|---|---|---|
| Sign-in | User name and password (EAP-MSCHAPv2), server checked by certificate | Shared key for the server, then user name and password |
| Ports | UDP 500 and 4500 | UDP 500, 4500 and 1701 |
| Built into | iOS, iPadOS, macOS, Windows, Android 11 and later | iOS, iPadOS, macOS, Windows |
| Also works with | strongSwan on Android | Older Android versions |
| Per node | Any number of inbounds | One inbound |

Prefer IKEv2. It reconnects quickly when a phone moves between Wi-Fi and mobile data, and it checks the server's certificate. Offer L2TP/IPsec only for devices that cannot use IKEv2; recent Android versions no longer include L2TP at all.

## Before you start

- The node runs Ubuntu with `apt`, `dpkg` and systemd. Ovira installs strongSwan (and, for L2TP, the PPP packages) on the node when the first IPsec inbound is attached. Other distributions need compatible packages installed beforehand.
- UDP 500 and 4500 (and UDP 1701 for L2TP) are free on the node and open in any firewall in front of it. These ports are shared by every IPsec inbound on that node.
- Every client that should use IPsec has a **password**. IKEv2 and L2TP sign in with the client's name and password; a client without one sees a note asking the administrator to set it.
- The node runs Ovira 1.0 or newer. Update the panel and its nodes together.

## Create an inbound

1. Open **Inbounds** and press **New inbound**.
2. Under **Protocol**, pick **IKEv2** or **L2TP/IPsec**.
3. Set the **Name**, the client address pool and DNS servers (up to four for IKEv2, up to two for L2TP).
4. Fill **Server identity**: the domain or IP address clients connect to. Leave it empty to use the node's address.
5. For L2TP, leave **Pre-shared key** empty to have one generated, or enter your own (16–128 characters).
6. Press **Create**, then attach the inbound to a node from **Nodes**, as with any other inbound.

::: warning Restarts on shared changes
IPsec services are shared by all IKEv2 and L2TP inbounds on a node. Changing one of them, or attaching and detaching, restarts IPsec on that node and briefly disconnects its IKEv2 and L2TP clients. The panel says so before it saves.
:::

## Certificates for IKEv2

The IKEv2 server proves who it is with a certificate for its **Server identity**. You have two choices:

- **Ovira CA** (the default). Ovira issues a server certificate signed by its own CA. Devices must install and trust that CA once; the setup files on the subscription page do this for Apple devices and Windows.
- **Let's Encrypt.** Request a certificate for the node's domain on the [Certificates](/use/certificates) page and pick it in the inbound. Devices trust it without installing anything. Renewals reach running IKEv2 servers without dropping connected users.

## Advanced settings

| Field | What it does |
|---|---|
| **IKE proposals**, **ESP proposals** | The encryption suites the server offers. Clients must support a matching IKE and ESP pair. Keep the defaults unless a device cannot connect. |
| **IKE rekey interval** | Seconds between IKE rekeys (300–604800). |
| **Child SA rekey interval** | Seconds between tunnel rekeys. `0` turns off server-started rekeying, which can help Windows clients behind NAT. |
| **Dead peer detection** | Seconds of silence before a client is considered gone (10–3600). |
| **IKE fragmentation**, **Force UDP encapsulation** | Help on networks that drop large or unusual UDP packets. |
| **Routes** | IKEv2 only. Split tunnelling: up to 64 IPv4 ranges sent through the VPN instead of all traffic. |
| **PPP MTU / MRU**, **LCP echo**, **Idle timeout** | L2TP only. Link tuning; `0` turns off the idle timeout. |

## What your customers do

The client's subscription page has an **IKEv2** and an **L2TP/IPsec** tab with the server address, user name, password (and the shared key for L2TP), plus **Setup files**:

- **iPhone, iPad and Mac:** a profile. On iOS, open Settings, tap *Profile Downloaded*, then *Install*. The profile is unsigned, so iOS shows *Not Verified*; that is expected. It installs the Ovira CA too, and contains the password, so it must stay private.
- **Android:** a strongSwan profile for IKEv2 (the app asks for the password), or the built-in client on Android 11 and later with type *IKEv2/IPSec MSCHAPv2*.
- **Windows:** a PowerShell script that creates the connection and trusts the Ovira CA. For L2TP behind NAT it also sets the registry value Windows needs; restart Windows if it says so.

Manual steps for every platform are shown on the same tab.

## Troubleshooting

- **Nothing connects:** check that UDP 500 and 4500 reach the node. Many cloud providers block them in their own firewall.
- **Certificate errors on IKEv2:** the identity typed on the device must match **Server identity** exactly. With the Ovira CA, make sure it is installed and fully trusted (iOS: *Settings → General → About → Certificate Trust Settings*).
- **Windows rejects the panel certificate:** an ECDSA panel certificate may be refused by the built-in Windows client. Use the Ovira CA or a Let's Encrypt certificate for the node.
- **IPsec install fails on a node:** the details show the package manager's output. A broken or blocked APT mirror on the node is the most common cause.

## Related pages

- [Choosing a protocol](./): how IPsec compares with the others.
- [Certificates](/use/certificates): Let's Encrypt for nodes and the main server.
- [Client apps](./apps): which app goes on which device.
