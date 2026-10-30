# Add a node

A [node](/reference/glossary) is another server that runs inbounds for your panel. A client is created once in the panel and works on every node. This page covers installing the node program on the new server and connecting it to the panel. To use the panel's own server instead, see [This server as a node](/start/same-server).

## Before you start

- A second server with the same system requirements as the panel server, and root access.
- A TCP port on the node that the panel can reach. The default is `62060`.
- A license that allows another node. The free plan allows 2; the **License** page shows your limit. Only owner accounts can connect nodes.

## Connect a node

1. In the panel, open **Nodes** and press **Connect a node**.
2. Under **Install the node on the new server**, copy the command. It carries `--panel-ip` with your panel's IP address, worked out from **Public address** in the settings. If the panel cannot work out its IP, the dialog asks you to add `--panel-ip PANEL_IP` yourself.
3. On the new server, as root, run it:

   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/node.sh) --panel-ip PANEL_IP
   ```

   With `--panel-ip` given, the installer only asks for the port the panel connects to (default `62060`), then shows a summary. It installs OpenVPN and the node service, opens the port in `ufw` or `firewalld` if one is active, and prints a node key that starts with `BNK1-`.
4. Back in the dialog, paste the key into **Node key**. The panel confirms it with `Key recognised` and fills **Node address** and **Node port** from the key. Change them if the panel must reach the node by another name.
5. Under **Name and options**, give the node a **Name**. It appears on subscription pages, for example `Germany` or `Frankfurt-2`.
6. Press **Connect**. The panel connects within seconds and shows the node as **Connected**.

If the node does not answer yet, the panel still saves it and shows the error. Check that the node port is open on the node's firewall and at the hosting provider.

The node is empty until you attach an inbound. Create one under **Inbounds**, then press **Attach inbound** on the node's card. [Your first client](/start/first-client) walks through it.

## The other fields

| Field | What it does |
|---|---|
| **Traffic multiplier** | How much of a client's quota the traffic on this node uses. `1` is the real amount, `2` doubles it, `0` makes the node free. The traffic shown on the node stays real. |
| **Connect addresses** | Extra addresses that clients should use instead of the node's own, for example relay servers. See [Nodes](/use/nodes). |
| **Note** | Free text for you. |
| **Enabled** | When off, the panel stops managing the node and its inbounds leave every profile. Tunnels already open stay up. |

## What the key does

The key tells the panel which node to trust. It holds the node's secret and the fingerprint of its certificate, so the panel talks only to that node. Treat it as a password. If you reinstall the node, it gets a new key: open the node's **Edit** dialog and paste the new key into **Node key**. `ovira key`, run on the node, prints the key again.

The `--panel-ip` option makes the node answer only to your panel's address. If you leave the address empty at the prompt, the node accepts calls from any address and relies on the key alone. When the panel's IP changes, update the allowed address on the node. See [Move the panel](/start/move-server).

## Update or remove a node

- To update, use **Updates** in the panel or run `ovira update` on the node. See [Update Ovira](/start/update).
- To remove a node from the panel, use **Nodes → ⋯ → Remove node**. Its inbounds stop and go back to **Not on a node**, and clients keep their access. The software stays on the node. To remove it, run `ovira uninstall` there. See [Remove Ovira](/start/uninstall).

## Related pages

- [Nodes](/use/nodes): the node cards, connect addresses and the node menu.
- [Same server as a node](/start/same-server): the panel's own server as a node.
- [How a node and its panel work together](/how/nodes): what a node does when the panel is away.
- [Files, services and ports](/reference/files-and-ports): the node's paths and ports.
