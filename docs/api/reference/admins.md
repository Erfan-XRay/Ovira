# Accounts and roles

A panel account is an owner, an admin, a reseller, or an account on a custom role. A role is a set of permission scopes and default limits. These endpoints list and change accounts, set a password or reset a second factor, read an account's usage, apply plan actions, and manage roles.

Times are Unix seconds and traffic is bytes. All endpoints here are owner-only. A full token made by the owner can call the token-enabled endpoints; password and second-factor changes require a browser session. A custom token cannot call owner-only endpoints, even when it carries every permission.

## List accounts

<Endpoint method="GET" path="/api/admins" perm="owner" :token="true" />

Returns every account, the owner included, with its role, state, client count and effective limits.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/admins"
```

```json
[
  {
    "id": 7,
    "username": "shop",
    "role": "reseller",
    "roleId": 2,
    "roleName": "Reseller",
    "state": "active",
    "disabled": false,
    "totpEnabled": false,
    "expireAt": 1796000000,
    "trafficLimit": 1099511627776,
    "usedBytes": 82463372083,
    "clients": 24,
    "online": 3,
    "maxClients": 100,
    "note": "",
    "createdAt": 1793000000,
    "lastLoginAt": 1795915000
  }
]
```

## Create an account

<Endpoint method="POST" path="/api/admins" perm="owner" :token="true" />

| Field | Type | Required | Meaning |
|---|---|---|---|
| `username` | string | yes | 3-32 characters without spaces or quotes. Unique. |
| `password` | string | on create | Initial password. Ignored on update. |
| `role` | string | no | `owner`, `admin` or `reseller`. Used when `roleId` is `0`. |
| `roleId` | integer | no | Any role, built-in or custom. `0` with `role: owner` makes an owner. |
| `overrides` | object | no | Limits that replace the role's defaults for this account. |
| `disabled` | boolean | no | Block sign-in. |
| `expireAt` | integer | no | Account end in Unix seconds. `0` means never. |
| `trafficLimit` | integer | no | Traffic pool in bytes. `0` means unlimited. |
| `note` | string | no | Free text, at most 500 characters. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/admins" \
  -d '{
    "username": "shop",
    "password": "a-long-password",
    "role": "reseller",
    "trafficLimit": 1099511627776,
    "expireAt": 1796000000,
    "overrides": { "maxClients": 100, "maxDevices": 2 }
  }'
```

```json
{
  "id": 7,
  "username": "shop",
  "role": "reseller",
  "roleId": 2,
  "roleName": "Reseller",
  "state": "active",
  "disabled": false,
  "expireAt": 1796000000,
  "trafficLimit": 1099511627776,
  "usedBytes": 0,
  "clients": 0,
  "maxClients": 100
}
```

`400` means a bad field or a taken username. `402` means the licence does not allow another account.

## Get one account

<Endpoint method="GET" path="/api/admins/{id}" perm="owner" :token="true" />

Returns one account. Path parameter `id` is the account id.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/admins/7"
```

`404` means no such account.

## Change an account

<Endpoint method="PUT" path="/api/admins/{id}" perm="owner" :token="true" />

Sends the same fields as create. `password` is ignored here; use the password endpoint. The last owner cannot be removed or turned into another role.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/admins/7" \
  -d '{"username":"shop","roleId":2,"trafficLimit":2199023255552,"expireAt":1798592000,"disabled":false}'
```

The answer is the changed account. `400` means a bad field, a taken username, or a change that would remove the last owner.

## Remove an account

<Endpoint method="DELETE" path="/api/admins/{id}" perm="owner" :token="true" />

Removes an account. Its clients are moved to another account by default, or deleted.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `id` | path | integer | Account id. |
| `clients` | query | string | `delete` deletes the account's clients instead of moving them. |
| `to` | query | integer | Account that receives the clients. Default is the caller. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X DELETE "$BASE/admins/7?to=1"
```

```json
{ "ok": true, "clients": 24 }
```

`clients` is how many clients were moved or deleted. `400` means the account cannot be deleted or the target is not valid.

## Set another account's password

<Endpoint method="POST" path="/api/admins/{id}/password" perm="owner" :token="false" />

Session only. Sets a new password for an account and signs out its other sessions.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `password` | string | yes | The new password, checked for strength. |

```bash
curl -sS -b cookies.txt -X POST "$BASE/admins/7/password" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"password":"a-new-long-password"}'
```

```json
{ "ok": true }
```

`400` means the password is too weak.

## Reset another account's second factor

<Endpoint method="POST" path="/api/admins/{id}/reset-2fa" perm="owner" :token="false" />

Session only. Turns off two-factor sign-in for an account, for example when its phone is lost.

```bash
curl -sS -b cookies.txt -X POST "$BASE/admins/7/reset-2fa" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

`404` means no such account.

## Read an account's traffic

<Endpoint method="GET" path="/api/admins/{id}/usage" perm="owner" :token="true" />

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `id` | path | integer | Account id. |
| `range` | query | string | `24h`, `7d`, `30d` or `90d`. Default `30d`. |
| `tz` | query | integer | Viewer's offset from UTC in minutes, -840 to 840. Default 0. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/admins/7/usage?range=30d"
```

The answer is a usage series with `points`, `from`, `to`, `bucket` and `offset`. `404` means no such account.

## Apply a plan action

<Endpoint method="POST" path="/api/admins/{id}/{action}" perm="owner" :token="true" />

Changes an account's traffic pool, end date or state. The action in the path wins over `body.action`.

| Action | What it does |
|---|---|
| `add-traffic` | Adds `bytes` to the pool. |
| `extend` | Adds `days` from the later of now and the current end. A `bytes` value above 0 replaces the pool. `resetUsage` also zeroes used traffic. |
| `reset-usage` | Sets the account's used traffic to zero. |
| `disable` or `enable` | Blocks or restores sign-in. |
| `disable-clients` or `enable-clients` | Blocks or restores all clients the account owns. |

| Field | Type | Meaning |
|---|---|---|
| `action` | string | The same action. Ignored when the path already names one. |
| `bytes` | integer | Bytes to add, or a new pool for `extend` when above 0. |
| `days` | integer | Days to add for `extend`, 0-3650. |
| `resetUsage` | boolean | For `extend`: also zero the used traffic. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/admins/7/add-traffic" \
  -d '{"bytes":1099511627776}'
```

The answer is the account after the action. `400` means the action is not valid or the last owner cannot be disabled.

## List roles

<Endpoint method="GET" path="/api/admin-roles" perm="owner" :token="true" />

Returns every role, built-in first, and the permission keys a role may grant.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/admin-roles"
```

```json
{
  "items": [
    {
      "id": 2,
      "name": "Reseller",
      "builtin": true,
      "perms": { "clients.view": "own", "clients.create": "own", "connections.view": "own" },
      "limits": { "maxClients": 0, "maxDevices": 0, "allowUnlimited": true },
      "createdAt": 0,
      "admins": 4
    }
  ],
  "perms": [
    { "key": "clients.view", "scoped": true },
    { "key": "groups.manage", "scoped": false }
  ]
}
```

A scope is `none`, `own` or `all`. For `groups.view` and `inbounds.view`, `own` means only the granted groups or inbounds.

## Create a role

<Endpoint method="POST" path="/api/admin-roles" perm="owner" :token="true" />

| Field | Type | Required | Meaning |
|---|---|---|---|
| `name` | string | yes | 1-40 characters. Unique. |
| `perms` | object | no | Permission key to scope. Missing keys are `none`. |
| `limits` | object | no | Defaults for accounts on this role. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/admin-roles" \
  -d '{
    "name": "Support",
    "perms": {
      "clients.view": "all",
      "clients.edit": "all",
      "connections.view": "all",
      "connections.kick": "all"
    },
    "limits": { "maxClients": 0, "allowUnlimited": true }
  }'
```

The answer is the new role. `400` means a bad field or a taken name.

## Change a role

<Endpoint method="PUT" path="/api/admin-roles/{id}" perm="owner" :token="true" />

Sends the same fields as create. Built-in roles cannot be changed.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/admin-roles/5" \
  -d '{"name":"Support","perms":{"clients.view":"all","clients.edit":"all"}}'
```

`400` means a bad field, a built-in role, or a taken name.

## Remove a role

<Endpoint method="DELETE" path="/api/admin-roles/{id}" perm="owner" :token="true" />

Removes a custom role. A role that accounts still use cannot be removed.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/admin-roles/5"
```

```json
{ "ok": true }
```

`400` means the role is built-in. `409` means accounts still use it.

## Limits object

`limits` and `overrides` use these fields. In `overrides`, only the fields you send replace the role's value; `0` means no cap.

| Field | Type | Meaning |
|---|---|---|
| `maxClients` | integer | Client cap; `0` means no cap. |
| `allowedGroups` | integer[] | Group ids the account may use. |
| `allowedInbounds` | integer[] | Inbound ids the account may use. |
| `requireGroup` | boolean | Clients must join an allowed group instead of single inbounds. |
| `maxClientTraffic` | integer | Per-client traffic cap in bytes; `0` means no cap. |
| `maxClientDays` | integer | Per-client lifetime in days; `0` means no cap. |
| `maxDevices` | integer | Per-client device cap; `0` means no cap. |
| `allowUnlimited` | boolean | The account may create clients without a traffic cap. |
| `trafficLimit` | integer | Default pool for new accounts on the role, in bytes. |

## Related pages

- [Roles and resellers](/use/resellers): the panel's wording for each permission and limit.
- [Panel accounts](/use/admins): the account page and the token section.
- [API tokens](/api/tokens): tokens an account holds.
- [Clients](/api/reference/clients): the clients an account owns.
