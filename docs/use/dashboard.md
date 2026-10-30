# Overview

**Overview** is the first page after sign-in. It shows who is connected, how much traffic moved, which plans are about to run out and how the panel's server is doing. The page refreshes itself every few seconds. This page describes each block and what it counts.

## The top line

Under the title a sentence summarises the state, for example `3 online now. 2 plans run out soon.` The **New client** button opens the client form for roles that may create clients.

Notices can appear above the blocks:

- **Set the server's public address so client profiles know where to connect.** Owners only. **Set it** opens the settings, where **Public address** is filled in.
- **Free plan: up to 5 active clients and 2 nodes.** Shown while the free limits apply, with a link to the plans.
- **Your license ends in N days.** Shown in the last two weeks of a paid license.

## The blocks

| Block | What it shows |
|---|---|
| **Online now** | Clients with at least one open tunnel, and the number of tunnels. |
| **Active clients** | The number of active clients, out of all clients. |
| **Traffic today** | Download and upload since midnight, with the 30-day total beneath. |
| **Throughput now** | The current speed, up and down. |
| **Traffic, last 24 hours** | Bars per hour, split into **Download** and **Upload**. |
| **Running out** | Clients whose plan ends or whose traffic is nearly used. Each row says why: **Ends** with a date, a percentage of traffic used, **Ended**, or **Traffic used up**. **Extend** adds days or traffic right there, and **View all** opens the matching client list. |
| **Inbounds** | Each inbound with its protocol, port, state (**Running**, **Stopped** or **Disabled**) and how many clients are online on it. Owners and roles that see all clients get this block. |
| **Heaviest users, 30 days** | The clients that moved the most traffic in the last 30 days. |
| **This server** | CPU, memory, disk and network of the panel's server and its uptime. Owners and roles that see all clients get this block. |
| **Traffic, last 30 days** | Bars per day. |

When **Running out** counts a client depends on two settings under **Settings → General**: **Warn when a plan ends within** (days) and **Warn when traffic used reaches** (percent).

## Resellers

A reseller sees **Your account** instead of the server blocks. It shows the traffic pool used and left, the end date, the number of clients out of the limit, and warnings when the pool is above 80 percent or 95 percent, or the account ends in a week. The owner sets these in [Roles and resellers](/use/resellers).

## Related pages

- [Clients](/use/clients): the lists behind the counts.
- [Connections](/use/connections): who is online, and from where.
- [Settings](/use/settings): the warning thresholds.
