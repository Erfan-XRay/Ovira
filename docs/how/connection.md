# The life of a connection

A client connects, the panel decides whether to let it in, and from then on the panel watches the connection until it ends. This page walks through that decision and the ways a connection is cut off, so you can tell why a customer was refused or dropped.

## How a client is let in

For OpenVPN and OpenConnect, every sign-in is checked by the [panel](/reference/glossary#panel), whichever [node](/reference/glossary#node) the client reached. The checks run in this order and stop at the first failure.

| Check | The client is refused when | What the app shows |
|---|---|---|
| Identity | The inbound uses a certificate and none was presented, or the name is not a known client. For **Certificate and password**, the user name must also match the certificate. | Access denied |
| Password | The inbound asks for a password (**Certificate and password**, **Username and password**, or any OpenConnect inbound) and it is wrong or empty. A reconnect with an OpenConnect session cookie skips this check. | Access denied |
| Certificate | The certificate is not the client's current one, for example after the client was renamed. | Access denied |
| Enabled | The client is switched off, or it belongs to a [reseller](/use/resellers) whose account is switched off, expired or out of traffic. | Account disabled |
| End date | The client's end date has passed. | Account expired |
| Traffic | The client has used its whole allowance. | Traffic quota used up |
| Allowed here | The client's [groups](/use/groups) do not include this inbound. | Access denied |
| Plan | The panel has more active clients than the plan allows and this client is past the limit. The most recently created clients are refused first. | Account unavailable: the server's plan limit is reached |
| Devices | The client already has as many open connections as its device limit. | Device limit reached |

The reason is always written to the panel's log as `connection denied`, with the client name and the exact reason, even when the app only shows "Access denied". Read it with `ovira logs`.

Two of those checks need a closer look:

- Allowed here. A client in at least one group gets the inbounds of its enabled groups. A client in no group keeps the inbounds it was created with, which is every inbound unless you narrowed the list. A disabled group gives nothing.
- Devices. The device limit counts every open connection of the client on every inbound, node and protocol together. With a limit of 2, a client may use two devices on one node or one on each of two nodes. A limit of 0 means no limit. A WireGuard device counts while it has completed a handshake in the last three minutes.

When all checks pass, the panel accepts the connection. If the client has a **Fixed tunnel address** inside the inbound's network, it is handed to the client. If the client's end date is set to start **At first connection** and this is its first, the clock starts now: the end date becomes the number of days chosen, counted from this moment.

## How a WireGuard device is let in

WireGuard has no sign-in step, so the panel decides ahead of time. It gives each node the list of devices that may connect: every device of every client that is enabled, not expired, within its traffic and allowed on that inbound. A device that is not on the list gets no answer at all.

The panel updates that list within about a second of a change, such as disabling a client, using up its traffic or editing a group. The device limit works on the list too. If a client has more connected devices than it may have, the ones that connected later are removed from the list.

## While the connection is open

Three things keep checking:

1. **Traffic is counted continuously.** The panel reads each connection's byte counters every two seconds. When saved plus unsaved usage reaches the client's allowance, the client is disconnected at once, without waiting for the next save. See [Traffic, quotas and limits](./traffic).
2. **The panel re-checks everyone every 30 seconds.** Any connection whose client is no longer allowed is cut off: switched off, past its end date, deleted, removed from the inbound by a group change, or beyond the plan's limit. A reseller who runs out of traffic or time, or is switched off, takes all of their clients with them.
3. **Actions in the panel act immediately.** Disabling a client, deleting it, renaming it or pressing **Disconnect** on **Connections** drops its connections right away.

OpenVPN also asks the panel to confirm a client again each time it renegotiates keys, which by default happens hourly (**Key renegotiation**).

## How a connection ends

| Cause | What happens to the app |
|---|---|
| Disabled, expired, used up, deleted, no longer allowed, or the plan limit | Disconnected. OpenVPN apps are told not to reconnect. Anything they try afterwards is refused for the same reason. |
| **Disconnect** on **Connections** | Disconnected. The app tries to reconnect, and succeeds if the client is still allowed. |
| The client's app or network drops | The session ends and its device slot is freed. |
| The inbound, node or panel stops | See [A node and its panel](./nodes). |

An administrator's **Disconnect** is therefore a nudge, not a ban. To keep someone out, disable the client.

## Things operators notice

- A reseller's client can be refused as "Account disabled" even though the client itself is enabled. The reseller's account is the cause. Look at the reseller on **Panel accounts**.
- Raising a limit or extending an end date takes effect for the next sign-in. Customers whose app gave up can reconnect at once.
- A client that is cut off for traffic can connect again as soon as its usage is reset, its allowance raised, or its [periodic reset](./traffic#periodic-resets) happens.
- Changing a group takes connections off an inbound within seconds, not within the next 30-second pass.

## Related pages

- [Traffic, quotas and limits](./traffic): how usage is counted and reset.
- [Clients](/use/clients): the fields that feed these checks.
- [Groups](/use/groups): which inbounds a client gets.
- [Connections](/use/connections): the live list and the **Disconnect** button.
- [Troubleshooting](/reference/troubleshooting): refusals by symptom.
