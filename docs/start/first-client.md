# Your first client

This page takes a fresh panel to a connected client: an inbound, a client, a subscription link and a check that it works. It assumes the panel is installed and the server is a node (**This server**) or you have [connected a node](/start/add-node). The steps use OpenVPN, the default choice; WireGuard and OpenConnect differ only in the inbound form and in the app the client uses.

## 1. Create an inbound

An [inbound](/reference/glossary) is one protocol with its own port and tunnel network.

1. Open **Inbounds** and press **New inbound**.
2. Under **Protocol**, choose **OpenVPN**. The choice is fixed once the inbound exists. [Choosing a protocol](/protocols/) compares the three.
3. Keep the suggested **Name**, **Port** and **Tunnel network**, or change them. The name cannot be changed later.
4. Create the inbound.

The inbound is saved under **Not on a node** and is not running yet.

## 2. Attach it to a node

1. Open **Nodes**.
2. On the card of **This server** (or the node you connected), press **Attach inbound**.
3. In **Choose an inbound**, select the inbound and confirm.

Ovira checks the node before it starts anything: the port must be free, the tunnel network must not overlap another inbound or a route already on that server, and for OpenConnect the software and a certificate must be available. If a check fails, nothing changes and the dialog shows why. When the checks pass, the inbound starts, and on **Inbounds** it shows **Running**.

## 3. Create a client

1. Open **Clients** and press **New client**.
2. Enter a **Name**. It is also the VPN user name: letters, digits, dot, dash and underscore.
3. Under **Plan**, set **Traffic allowance** (the form starts at 50 GB; leave it empty for unlimited), **Duration** (30 days to start with) and **Start the clock**. **At first connection** keeps the days unused until the client first connects.
4. Set **Devices at once**. The form starts at 2; `0` means no limit.
5. Press **Create**.

When the panel has more than one inbound, the form also asks which ones the client may use. All inbounds is the default.

## 4. Send the link

Open the client. Under **Send to the client**, copy the subscription link. It looks like `https://panel.example.com:2053/sub/...`, and opens a page with the remaining traffic, the end date and the profile to import. Send the link by any messenger. Next to it there is a QR code for opening it on a phone.

If the link leaks, choose **New subscription link** from the client's menu. The old link stops working.

## 5. Connect

The client opens the link and follows the page:

1. **Install the app** shows the recommended app for their device. For OpenVPN that is OpenVPN Connect.
2. **Add your configuration** imports the profile: **Open in OpenVPN Connect** on a phone, or **Download profile** and open the file.
3. **Sign in** appears when the inbound asks for a user name and password. The page shows them.

## 6. Check that it works

Open **Connections**. The client appears in the **Live** list with its inbound, address and speed. The client's own page shows **Connected now**, and **Overview** counts them under **Online now**.

## If something is wrong

| Symptom | Likely cause |
|---|---|
| **Attach inbound** refuses | The port is busy on that server, or the tunnel network overlaps another one. The dialog names the problem. |
| The profile points at the wrong address | **Public address** under **Settings → General** is empty or wrong. Fix it, then download the profile again. |
| The app connects but there is no internet | **NAT client traffic to the internet** is off on the inbound, or the server forwards nothing. See [OpenVPN](/protocols/openvpn). |
| The app cannot reach the server at all | A firewall at the hosting provider blocks the inbound's port. Ovira opens it only in `ufw` or `firewalld`. |

## Related pages

- [Clients](/use/clients): every field of the client form and the client page.
- [Inbounds](/use/inbounds): the inbound list and its settings.
- [The subscription page](/use/subscription-page): what the client sees and how to brand it.
- [Client apps](/protocols/apps): apps by platform and protocol.
