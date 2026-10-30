# Connections

**Connections** shows who is connected right now and who was connected before. It covers all protocols and all nodes on one page. This page describes the two tabs, the filters, the **By client** view that finds clients sharing an account, and disconnecting a user.

## Live

The **Live** tab lists open tunnels and refreshes every few seconds. The subtitle gives the count, for example `12 open tunnels`.

| Column | What it shows |
|---|---|
| **Client** | The client's name. Hidden in the **By client** view, where the client heads a group. |
| **Inbound** | The inbound the tunnel is on. |
| **From** | The address the client connected from. |
| **Tunnel IP** | The client's address inside the tunnel. |
| **Device** | The client's platform, when it is known. |
| **Connected** | How long the tunnel has been open. |
| **Traffic** | Bytes moved in this tunnel. |
| **Speed** | The current rate. |

The icon at the end of a row is **Disconnect**.

## Filters

- The search box matches a client name or an IP.
- **Protocol** limits the list to one protocol, or **All protocols**.
- **Node** limits it to one node, or **All nodes**.
- **Clear filters** resets them. If nothing matches, the page says `No connection matches these filters.`

## Sessions or By client

The **View** switch has two modes. **Sessions** lists one row per tunnel. **By client** groups tunnels under each client and shows three figures: `Devices`, `IPs` and `Allowed`.

A client is flagged when it has **More devices than allowed**, or **More IPs than devices allowed**. The subtitle counts how many clients are over the limit. The flags tell you which clients are sharing one account between many people, even when the client's device limit has not cut them off. The device limit itself counts open tunnels across all inbounds and nodes together.

## History

The **History** tab lists finished connections: **Client**, **Connected**, **Duration**, **From**, **Device**, **Traffic** and **Reason** for the end. It has the same filters. How long history is kept is set under **Settings → General → Keep history for → Connection log**.

## Disconnect a user

Press **Disconnect** on a row and confirm. The question warns that the app will try to reconnect unless the plan has ended. To keep a client out, disable it, or let its plan end, from [Clients](/use/clients). Disconnecting only drops the current tunnel.

## Related pages

- [Clients](/use/clients): disable or extend a client.
- [The life of a connection](/how/connection): how Ovira decides to let a client in, and how it cuts one off.
- [Settings](/use/settings): the history retention setting.
