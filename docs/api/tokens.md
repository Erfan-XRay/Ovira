# API tokens

An API token is a secret that lets a script act as a panel account. You create it on **Settings → API**, choose how far it reaches, and send it with every request. This page covers creating a token, the permission choices, expiry and allowed addresses, revoking one, and the token endpoints themselves.

## Create a token

1. Open **Settings → API**.
2. Press **Create API token**.
3. Give it a **Name**. The name is 1 to 64 characters and unique for the account.
4. Choose **Full access**, or turn it off and tick the permissions under **Permissions**.
5. Choose an **Expiry**: **Never**, **30 days**, **90 days** or **1 year**.
6. Optionally add **Allowed IPs**, one address or CIDR range per line.
7. Enter your **Current password**. If the account has two-factor sign-in on, enter the **2FA code** too.
8. Press **Create API token**.

The panel shows the **Token secret** once. Copy it before you close the dialog; it cannot be shown again. The list keeps only a short prefix so you can tell tokens apart.

Each admin may hold 25 tokens. A token name is unique for that admin, not for the panel.

## Full or custom

A **Full access** token uses every permission the account has, including ones added to its role later. A **Custom** token carries only the permissions you tick, and each one is capped at what the account itself has at that moment.

| Choice | What it means |
|---|---|
| **Full** | The token follows the account. Owner accounts keep owner rights, except for the session-only actions. |
| **Custom** | The token carries the chosen permissions only. It is never treated as the owner, even when the owner created it. |

If the account is a reseller, a custom token can only reach the reseller's own clients. It cannot be given **All** for a permission the account holds only for its own clients.

## Permissions

The permission keys are the same ones the roles editor uses. Traffic resets and disconnects have their own permissions, separate from edit.

| Key | What it allows |
|---|---|
| `clients.view` | List and search clients, read one client, read usage, download a profile and a QR code. |
| `clients.create` | Create one client or several from a plan. |
| `clients.edit` | Change a client, enable or disable it, extend it, replace its certificate, replace its subscription link, and run the same actions in bulk. |
| `clients.delete` | Delete a client, alone or in bulk. |
| `clients.reset` | Reset a client's used traffic, alone or in bulk. |
| `clients.kick` | Close a client's open sessions, alone or in bulk. |
| `connections.view` | List live connections and connection history. |
| `connections.kick` | Close one open connection. |
| `groups.view` | List groups. On a reseller, only the groups it was granted. |
| `groups.manage` | Create and change groups, run bulk actions, and add or remove groups for clients. |
| `inbounds.view` | `own`: brief list of granted inbounds. `all`: full list, details, deployments and logs. |
| `inbounds.manage` | Create and change inbounds, deploy them, assign them to nodes, and start or stop them. |
| `nodes.view` | List nodes, read the install command, and read host statistics. |
| `nodes.manage` | Sync a node and reset its traffic counters. |

A custom token needs at least one permission. A permission the account does not have cannot be chosen.

## Expiry

**Never** means the token works until it is revoked. Otherwise it stops at the chosen time and answers `401` with `token_expired`.

Expiry is counted from creation. A token cannot be extended; make a new one and revoke the old one.

## Allowed IPs

**Allowed IPs** limits where the token may be used. Add an IPv4 or IPv6 address, or a CIDR range. The list accepts up to 32 entries. An empty list allows any address.

A request from another address answers `403` with `token_ip` and the address in `params.ip`. Put the public address of the bot's host or network here. If the panel is behind a proxy, the panel must trust that proxy's forwarded address for this check to see the real client.

## Revoke a token

On **Settings → API**, find the token and press **Revoke**. It stops working at once. A script that uses it starts receiving `401` with `token_invalid`.

Revoking is final. Make a new token and update the script.

### Revoke a reseller's token

An owner can see and revoke another account's tokens. Open the account under **Panel accounts**; its **API Tokens** section lists them with **Revoke**. The owner cannot create a token for another account.

A reseller can revoke its own tokens on **Settings → API**. Its **Settings** page shows only **My account** and **API**.

## Token endpoints

These endpoints manage tokens. They are session-only: they answer `token_forbidden` to a token request, so call them with the browser session. The browser also needs its CSRF header for writes.

<Endpoint method="GET" path="/api/account/tokens" perm="any" :token="false" />

List your tokens. Secrets are never returned.

```bash
curl -sS -b cookies.txt "$BASE/account/tokens"
```

```json
[
  {
    "id": 4,
    "name": "shop-bot",
    "prefix": "ovk_7f3c9a",
    "full": false,
    "perms": { "clients.view": "own", "clients.create": "own", "clients.edit": "own", "clients.reset": "own" },
    "allowIps": ["203.0.113.0/24"],
    "createdAt": 1793500000,
    "expiresAt": 1796000000,
    "lastUsedAt": 1793512345,
    "lastUsedIp": "203.0.113.9"
  }
]
```

<Endpoint method="POST" path="/api/account/tokens" perm="any" :token="false" />

Create a token.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `name` | string | yes | 1-64 characters, unique for the account. |
| `full` | boolean | no | Give the token every permission the account has. `perms` is ignored when true. |
| `perms` | object | for a custom token | Permission key to scope: `none`, `own` or `all`. A custom token needs at least one. |
| `allowIps` | string[] | no | Up to 32 addresses or networks. Empty means any address. |
| `expiresInDays` | integer | no | `0` for never, otherwise 1-3650. |
| `password` | string | yes | The account's current password. |
| `code` | string | when 2FA is on | A current authenticator code. |

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/tokens" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-Token: $CSRF" \
  -d '{
    "name": "shop-bot",
    "full": false,
    "perms": {
      "clients.view": "own",
      "clients.create": "own",
      "clients.edit": "own",
      "clients.reset": "own"
    },
    "allowIps": ["203.0.113.0/24"],
    "expiresInDays": 90,
    "password": "your-password"
  }'
```

```json
{
  "token": "ovk_7f3c9a...",
  "item": {
    "id": 4,
    "name": "shop-bot",
    "prefix": "ovk_7f3c9a",
    "full": false,
    "perms": { "clients.view": "own", "clients.create": "own", "clients.edit": "own", "clients.reset": "own" },
    "allowIps": ["203.0.113.0/24"],
    "createdAt": 1793500000,
    "expiresAt": 1796000000,
    "lastUsedAt": 0,
    "lastUsedIp": ""
  }
}
```

Failures: `400` with `field: name`, `perms`, `allowIps` or `expiresInDays`; `400` with `code: token_limit` at 25 tokens; `409` with `field: name` for a duplicate name; `429` after too many wrong passwords or codes.

<Endpoint method="DELETE" path="/api/account/tokens/{id}" perm="any" :token="false" />

Revoke one of your tokens. Path parameter `id` is the token id from the list. A token of another account answers `404`.

```bash
curl -sS -b cookies.txt -X DELETE \
  -H "X-CSRF-Token: $CSRF" \
  "$BASE/account/tokens/4"
```

```json
{ "ok": true }
```

<Endpoint method="GET" path="/api/admins/{id}/tokens" perm="owner" :token="false" />

Owner only. List the tokens of one account. Path parameter `id` is the account id. Secrets are not returned.

<Endpoint method="DELETE" path="/api/admins/{id}/tokens/{tid}" perm="owner" :token="false" />

Owner only. Revoke one token of one account. `id` is the account id and `tid` is the token id.

## Related pages

- [Roles and resellers](/use/resellers): the same permission keys with the panel's wording.
- [Panel accounts](/use/admins): creating accounts and their token section.
- [API overview](/api/): base address, errors and what tokens cannot do.
- [Quickstart](/api/quickstart): the first authenticated call.
