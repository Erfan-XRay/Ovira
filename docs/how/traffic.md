# Traffic, quotas and limits

Ovira counts the bytes every client sends and receives, charges them against the client's allowance, and cuts the client off when the allowance is gone. This page explains how that counting works, where the [node multiplier](/reference/glossary#traffic-multiplier) comes in, when a client's clock starts and how allowances reset. It ends with the traffic pool of a [reseller](/reference/glossary#reseller).

## What is counted

A client's **Traffic allowance** is a single number. Upload and download are added together, on every inbound, node and protocol the client uses. Leaving the field empty means unlimited.


## How counting works

1. The panel reads the byte counters of every open connection every two seconds.
2. It takes the difference since the last reading, applies the node's multiplier and adds the result to the client's pending usage.
3. About every ten seconds the pending usage is written to the database, together with the traffic history behind the graphs.
4. Whenever the saved usage plus the pending usage reaches the allowance, the panel saves at once and disconnects the client. It does not wait for the ten-second save.

A fast connection can therefore go over the allowance by a few seconds' worth of traffic before it is cut. The extra is counted too, so the client does not get it back.

When a connection ends, its last counters are added. OpenConnect sessions can report their final bytes a moment after they close, and the panel adds those as well. If the panel was away while a connection stayed up, the next time it connects to the node it adds the traffic that passed in the meantime. See [A node and its panel](./nodes).

## The node multiplier

Each node, including **This server**, has a **Traffic multiplier**. It changes how much of a client's allowance the traffic on that node uses.

| Multiplier | 1 GB used on the node counts as |
|---|---|
| 1 | 1 GB |
| 1.5 | 1.5 GB |
| 0.5 | 0.5 GB |
| 0 | Nothing |

- The traffic shown on the node's card is always the real amount. Only the client's quota uses the multiplied figure.
- The multiplier applies when the traffic is counted. Changing it does not recalculate what was counted before.
- A multiplier of 0 makes a node free: traffic there never reduces any allowance, and never reduces a reseller's pool.
- The subscription page shows the multiplier next to the inbound.

Use a multiplier above 1 for an expensive route, such as a node with metered bandwidth, and below 1 for a cheap one.

## When the clock starts

A client's end date can be set in two ways under **Start the clock**:

- **Now**: the end date is fixed when you save.
- **At first connection**: the page shows "N days from first connection". The end date is set the first time the client connects, to that many days after.

Until then the client's status is **Not started**. The first connection can be on any inbound. The clock starts when the panel accepts that connection, not when the client is created.

## Periodic resets

**Reset traffic** on a client can be **Never**, **Every day**, **Every week** or **Every month**. When a new period begins, the panel sets the client's used traffic back to zero.

- A day starts at midnight, a week on Monday, a month on the first.
- Time is the time zone of the panel's server.
- The panel checks every 30 seconds, so a reset happens within half a minute of the boundary.
- A client that was cut off for traffic can connect again after the reset.

You can also reset a client by hand, from the client's page or with **Reset traffic** on a selection in the list. That does not change the schedule.

## Reseller pools

A reseller account can have a **Traffic pool** instead of, or as well as, limits on single clients. The pool is shared by all the reseller's clients.

- Every byte a client of the reseller uses is charged to the pool after the node multiplier, on top of the client's own allowance.
- Deleting a client does not give its traffic back.
- When the pool is used up, the end date passes, or the account is switched off, all of the reseller's clients stop at once. They look disabled to the app. See [The life of a connection](./connection).
- Unused traffic is lost at the end of the end date.
- On **Panel accounts** you can **Add traffic…**, **Extend…** or **Reset used traffic**. Clients work again as soon as the account is no longer blocked.
- The reseller's **Overview** warns at 80% and 95% of the pool.

The built-in **Reseller** role and custom roles are described under [Resellers](/use/resellers).

## Related pages

- [The life of a connection](./connection): what happens at the moment the allowance runs out.
- [Clients](/use/clients): the allowance, start and reset fields.
- [Resellers](/use/resellers): roles, pools and end dates.
- [Nodes](/use/nodes): setting a node's multiplier.
