# Hosts

A **host** is how one OpenVPN server is shown to clients: the name they see, the addresses it answers on, and the client settings that go with them. It is the same idea as hosts in PasarGuard, with OpenVPN's settings instead of Xray's.

A server with no host is shown under its own name at its node's address. Create hosts when you want to rename a server, put relays in front of it, or give some clients different settings.

## Create a host

**Hosts → Create host**:

| Field | What it does |
|---|---|
| Server | The OpenVPN server this host presents. |
| Name | What clients see. Empty uses the default name. Can contain variables, see below. |
| Addresses | Each address becomes **its own profile**. Empty uses the server's own address. |
| Client settings | MSS fix, tunnel MTU, connect timeout, an HTTP or SOCKS proxy and further OpenVPN client directives. Added to this host's profiles only. |
| Who sees it | Only clients with one of the chosen statuses, and only clients in one of the chosen groups. Leave both empty for everyone who has the server. |
| Show in subscriptions | Turn it off to hide the host without deleting it. |

Drag hosts to change their order; subscriptions list them in this order. Select several to enable, disable or delete them together.

## Addresses, relays and tunnels

Put each relay or tunnel in front of a server as one address:

| Field | Example |
|---|---|
| Label | `Tehran relay` |
| Host | `ir1.example.com` (empty = the server's own address) |
| Port | empty = the server's own port, or the relay's port |

Four relays in front of one server give clients four profiles to choose from, and a failover `remote` line in the all-in-one profile. Profiles whose hosts have different client settings are never merged into one file.

## Name variables

The name is filled in per client. Click a variable in the editor to add it; a preview shows the result.

| Variable | Shows |
|---|---|
| `{USERNAME}` | The client's name |
| `{SERVER}` / `{NODE}` | The OpenVPN server and its node |
| `{LABEL}` / `{ADDRESS}` | The address's label and host |
| `{PROTOCOL}` / `{PORT}` | UDP or TCP, and the port |
| `{DATA_USAGE}` / `{DATA_LIMIT}` / `{DATA_LEFT}` | Used, allowed and remaining traffic |
| `{USAGE_PERCENTAGE}` | Share of the traffic used |
| `{DAYS_LEFT}` / `{TIME_LEFT}` | Time until the end date |
| `{EXPIRE_DATE}` / `{JALALI_EXPIRE_DATE}` | End date, Gregorian and Persian |
| `{STATUS_EMOJI}` | An emoji for the client's status |

Unlimited traffic or time shows as `∞`, a missing date as `-`. A name such as `🇩🇪 {SERVER} · {DATA_LEFT} · {DAYS_LEFT}d` becomes the profile's name on the subscription page, so clients see what is left without opening the page.

## Hosts that appear only sometimes

- **Client status** shows a host only to clients who are active, used up, expired or disabled. A host for expired clients can carry a renewal reminder in its name.
- **Groups** show a host only to clients in those groups, so one server can be presented in different ways to different customers.

::: tip
A server shows only the hosts a client is allowed to see. If every host of a server is hidden for a client, that server does not appear for them. Delete a server's last host and it goes back to its node's address.
:::

## From connect addresses

Versions before 0.4 kept relay addresses on the node. On update they became hosts, one per server, and the node's list was emptied. Nothing changes for clients.
