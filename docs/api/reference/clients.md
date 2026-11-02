# Clients

A client is one plan: a traffic allowance, an end date and a device cap. These endpoints list, create, change and act on clients, read their usage, download their profiles and QR codes, and manage WireGuard devices. Client names are unique across the panel.

Traffic values are bytes and times are Unix seconds. `trafficLimit: 0` means unlimited and `expireAt: 0` means no end date.

## List and search clients

<Endpoint method="GET" path="/api/clients" perm="clients.view" :token="true" />

Returns a page of clients and the bucket counts of the filtered list. A reseller sees only its own clients.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `owner` | query | integer | Only this owner's clients. Ignored for an account limited to its own. |
| `q` | query | string | Case-insensitive search in name, note and contact. |
| `status` | query | string | `all`, `active`, `online`, `expiring`, `limited`, `expired` or `disabled`. Default `all`. |
| `group` | query | integer | Only clients in this group; `0` keeps every group. |
| `sort` | query | string | `name`, `used`, `expire`, `online` or `created`. Default `created`. |
| `order` | query | string | `asc` or `desc`. Default `desc`. |
| `page` | query | integer | Page number, from 1. Default 1. |
| `size` | query | integer | Page size, 1-500. Anything else means 50. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients?status=active&sort=expire&order=asc&size=25"
```

```json
{
  "items": [
    {
      "id": 118,
      "ownerId": 7,
      "name": "ali-01",
      "note": "",
      "contact": "@ali",
      "enabled": true,
      "trafficLimit": 53687091200,
      "usedUp": 1073741824,
      "usedDown": 6442450944,
      "expireAt": 1796000000,
      "expireAfterDays": 0,
      "firstUsedAt": 1793400000,
      "maxDevices": 2,
      "status": "active",
      "online": 1,
      "subUrl": "https://panel.example.com/sub/6f2a.../",
      "groups": [3]
    }
  ],
  "total": 1,
  "page": 1,
  "size": 25,
  "counts": {
    "all": 1,
    "active": 1,
    "online": 1,
    "expiring": 0,
    "limited": 0,
    "expired": 0,
    "disabled": 0
  }
}
```

## Create a client

<Endpoint method="POST" path="/api/clients" perm="clients.create" :token="true" />

Creates one client and returns it with `201`. The name is also the OpenVPN user name.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `name` | string | yes | 2-48 ASCII characters: letters, digits, dot, dash, underscore or `@`. Start with a letter or digit. Unique. |
| `note` | string | no | Free text, at most 500 UTF-8 bytes. |
| `contact` | string | no | How to reach the client, at most 120 UTF-8 bytes. |
| `enabled` | boolean | no | `true` enables the client. Omitted or `false` creates it switched off. |
| `password` | string | no | VPN password, 4-64 characters without spaces or quotes. Empty generates one. |
| `trafficLimit` | integer | no | Traffic limit in bytes. `0` means unlimited. |
| `expireAt` | integer | no | End date in Unix seconds. `0` means never. |
| `expireAfterDays` | integer | no | Lifetime in days from the first connection, 0-3650. `0` means none. |
| `maxDevices` | integer | no | Device cap, 0-1000. `0` means no cap. |
| `resetStrategy` | string | no | `none`, `daily`, `weekly` or `monthly`. Empty means `none`. |
| `staticIp` | string | no | Fixed IPv4 inside an inbound's static range. Empty takes the next free address. |
| `instances` | integer[] | no | Inbound ids the client may use. Empty means every inbound it is entitled to. |
| `groups` | integer[] | no | Group ids. A group gives its inbounds. |
| `ownerId` | integer | no | Create the client for another account. Needs `clients.create` for every client. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/clients" \
  -d '{
    "name": "ali-02",
    "enabled": true,
    "trafficLimit": 53687091200,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3]
  }'
```

```json
{
  "id": 119,
  "ownerId": 7,
  "name": "ali-02",
  "enabled": true,
  "trafficLimit": 53687091200,
  "usedUp": 0,
  "usedDown": 0,
  "expireAt": 0,
  "expireAfterDays": 30,
  "maxDevices": 2,
  "status": "active",
  "subUrl": "https://panel.example.com/sub/9c41.../",
  "groups": [3]
}
```

`400` with `field` names the bad field. `402` means the licence or the account's client cap refuses the client.

## Create several clients

<Endpoint method="POST" path="/api/clients/bulk" perm="clients.create" :token="true" />

Creates clients named `prefix` followed by a number. All of them share `plan`, the same object as a single create. `staticIp` and `password` are ignored in the plan.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `prefix` | string | yes | Start of every name. |
| `start` | integer | no | First number; `0` starts at 1. |
| `count` | integer | yes | How many clients, 1-500. |
| `plan` | object | yes | A client body without `name`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/clients/bulk" \
  -d '{"prefix":"ali-","start":1,"count":10,"plan":{"enabled":true,"trafficLimit":53687091200,"expireAfterDays":30,"maxDevices":2,"groups":[3]}}'
```

```json
{
  "items": [
    { "id": 120, "name": "ali-01", "status": "active" },
    { "id": 121, "name": "ali-02", "status": "active" }
  ],
  "error": "created 2 of 10: your account may own 100 clients"
}
```

`error` is present only when the run stopped early. The clients before it were created.

## Apply one action to many clients

<Endpoint method="POST" path="/api/clients/bulk-action" perm="clients.edit" :token="true" />

Applies one action to up to 1000 clients. The token needs the permission of the chosen action, rather than every permission listed for this route: `clients.reset` for `reset`, `clients.kick` for `kick`, `clients.delete` for `delete`, `clients.edit` for the rest.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `ids` | integer[] | yes | 1-1000 client ids. |
| `action` | string | yes | `enable`, `disable`, `reset`, `extend`, `delete` or `kick`. |
| `days` | integer | for `extend` | Days to add. |
| `bytes` | integer | for `extend` | Bytes of traffic to add. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/clients/bulk-action" \
  -d '{"ids":[118,119],"action":"extend","days":30,"bytes":10737418240}'
```

```json
{ "done": 2, "failed": [] }
```

`failed` holds a client id or an error message for each client that did not change.

## Get one client

<Endpoint method="GET" path="/api/clients/{id}" perm="clients.view" :token="true" />

Returns the client with its open sessions, its last 30 closed sessions, its certificate and the profiles it can download. Path parameter `id` is the client id.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/clients/119"
```

```json
{
  "client": {
    "id": 119,
    "name": "ali-02",
    "status": "active",
    "trafficLimit": 53687091200,
    "usedUp": 0,
    "usedDown": 0,
    "expireAt": 0,
    "expireAfterDays": 30,
    "subUrl": "https://panel.example.com/sub/9c41.../"
  },
  "live": [],
  "history": [],
  "cert": {
    "subject": "ali-02",
    "serial": "3f9a...",
    "notBefore": 1793400000,
    "notAfter": 1825000000
  },
  "profiles": [
    {
      "key": "12-3",
      "instanceId": 12,
      "instance": "udp1194",
      "kind": "openvpn",
      "nodeId": 0,
      "node": "this server",
      "label": "",
      "host": "panel.example.com",
      "port": 1194,
      "proto": "udp",
      "authMode": "cert"
    }
  ]
}
```

`404` means no such client, or it is outside the account's reach.

## Change a client

<Endpoint method="PUT" path="/api/clients/{id}" perm="clients.edit" :token="true" />

Sends the same fields as create. An empty `password` keeps the current one. Omitting `groups` leaves the client's groups alone. Every other omitted field takes its zero value, so read the client, change what you need, and send the whole body back. Renaming issues a new certificate and makes old OpenVPN profiles stop working.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/clients/119" \
  -d '{
    "name": "ali-02",
    "enabled": true,
    "trafficLimit": 107374182400,
    "expireAt": 1798675200,
    "maxDevices": 3,
    "groups": [3]
  }'
```

The answer is the changed client. `400` names the bad field; `404` means it is not available to this account.

## Delete a client

<Endpoint method="DELETE" path="/api/clients/{id}" perm="clients.delete" :token="true" />

Deletes the client, revokes its certificate and closes its sessions at once.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/clients/119"
```

```json
{ "ok": true }
```

## Run an action on a client

<Endpoint method="POST" path="/api/clients/{id}/{action}" perm="clients.edit" :token="true" />

Path parameter `id` is the client id. `action` is one of `enable`, `disable`, `reset`, `extend`, `reissue`, `rotate-sub` or `kick`.

The token needs the permission of the chosen action, rather than every permission listed for this route: `clients.reset` for `reset`, `clients.kick` for `kick`, and `clients.edit` for the rest.

| Action | What it does | Body |
|---|---|---|
| `enable` | Lets the client connect again. | None |
| `disable` | Switches the client off and closes its sessions. | None |
| `reset` | Sets used upload and download back to zero. | None |
| `extend` | Adds days and traffic; optionally resets usage. | `days`, `bytes`, `resetUsage` |
| `reissue` | Issues a new certificate. Every OpenVPN profile the client downloaded stops working. | None |
| `rotate-sub` | Replaces the subscription token. The old `subUrl` stops working. | None |
| `kick` | Closes the client's open sessions. | None |

The body of `extend`:

| Field | Type | Meaning |
|---|---|---|
| `days` | integer | Days to add, 0-3650, counted from the later of now and the current end. |
| `bytes` | integer | Bytes to add to the limit. No effect when the limit is `0`. |
| `resetUsage` | boolean | Also zero the used traffic. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients/119/extend" \
  -d '{"days":30,"bytes":53687091200,"resetUsage":true}'
```

`days` only changes a client that already has an end date, or a lifetime that has not started yet. A client with no end date and no lifetime stays without one.

```json
{
  "id": 119,
  "name": "ali-02",
  "enabled": true,
  "trafficLimit": 107374182400,
  "usedUp": 0,
  "usedDown": 0,
  "expireAt": 1798675200,
  "status": "active"
}
```

`400` names a bad body field. `403` means the token lacks the action's permission. `404` means no such client, action, or client outside the account's reach.

## Read traffic over time

<Endpoint method="GET" path="/api/clients/{id}/usage" perm="clients.view" :token="true" />

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `id` | path | integer | Client id. |
| `range` | query | string | `24h`, `7d`, `30d` or `90d`. Default `30d`. `24h` is bucketed by hour, the rest by day. |
| `tz` | query | integer | Viewer's offset from UTC in minutes, -840 to 840, so days start at local midnight. Default 0. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients/119/usage?range=7d&tz=210"
```

```json
{
  "points": [
    { "t": 1795912800, "up": 734003200, "down": 4294967296 },
    { "t": 1795999200, "up": 104857600, "down": 524288000 }
  ],
  "from": 1795312800,
  "to": 1795999200,
  "bucket": 86400,
  "offset": 12600
}
```

## Download a profile

<Endpoint method="GET" path="/api/clients/{id}/profile" perm="clients.view" :token="true" />

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `id` | path | integer | Client id. |
| `key` | query | string | Profile key from `ClientDetail.profiles`. Empty or `all` combines every compatible server. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o ali-02.ovpn "$BASE/clients/119/profile?key=12-3"
```

The answer is an OpenVPN profile file (`application/x-openvpn-profile`). `404` means no such client or profile.

## Get the subscription QR code

<Endpoint method="GET" path="/api/clients/{id}/qr" perm="clients.view" :token="true" />

Returns a 320-pixel PNG QR code of the client's subscription link.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o ali-02.png "$BASE/clients/119/qr"
```

## WireGuard devices

These endpoints need an account that sees every client (`staff`: the owner, or an account with `clients.view` for all clients). They are not limited to one client's owner.

<Endpoint method="GET" path="/api/clients/{id}/wireguard" perm="staff" :token="true" />

Lists one row per device slot of the client, plus the WireGuard inbounds it may use.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/clients/119/wireguard"
```

```json
{
  "devices": [
    {
      "slot": 1,
      "publicKey": "9f3a...",
      "lastHandshake": 1795915000,
      "endpoint": "203.0.113.9:51820",
      "instance": "wg51820",
      "instanceId": 21,
      "up": 104857600,
      "down": 734003200,
      "live": true
    }
  ],
  "servers": [
    { "key": "21-3", "instanceId": 21, "instance": "wg51820", "kind": "wireguard" }
  ]
}
```

<Endpoint method="POST" path="/api/clients/{id}/wireguard/{slot}/reset" perm="staff" :token="true" />

Replaces the key of one device slot. Path parameters are the client id and the slot number, from 1 up to the client's device cap. The old device stops connecting.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X POST "$BASE/clients/119/wireguard/1/reset"
```

```json
{
  "slot": 1,
  "publicKey": "3b7c...",
  "createdAt": 1795919000
}
```

<Endpoint method="GET" path="/api/clients/{id}/wireguard/{slot}/{key}/{format}" perm="staff" :token="true" />

Downloads one WireGuard configuration. `slot` is the device slot, `key` is a profile key from the server list, and `format` is `config.conf` or `qr`.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o wg.conf "$BASE/clients/119/wireguard/1/21-3/config.conf"
```

`config.conf` returns the file as `application/octet-stream`; `qr` returns a PNG. `404` means no such client, slot, profile or format.

## Related pages

- [A shop bot](/api/shop-bot): the create, deliver and renew flow.
- [Connections](/api/reference/connections): the live sessions this client opens.
- [Groups](/api/reference/groups): adding clients to groups in bulk.
- [Traffic, quotas and limits](/how/traffic): how usage and reset work.
