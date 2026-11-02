# Quickstart

This page makes the first three calls with a token: read the account, list clients, and create a client. The same calls are shown in curl, Python with `requests`, and Node with the built-in `fetch`.

Before you start, create a token on **Settings → API** with at least `clients.view` and `clients.create`. A reseller also needs an allowed group or inbound, because a reseller cannot create a client with no access.

## Set the address and token

The base address ends in `/api`, after the panel's secret path:

```bash
export BASE="https://panel.example.com/ovira-7f3c/api"
export OVIRA_TOKEN="ovk_..."
```

Keep the token out of shell history and out of a repository. Read it from an environment variable or a secret store.

## Who am I?

`GET auth/me` returns the account behind the token, its role, its effective permissions and, for a token request, token metadata (id, name, full-access flag and expiry). The token secret is not returned.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/auth/me"
```

```json
{
  "admin": {
    "id": 7,
    "username": "shop",
    "role": "reseller",
    "roleId": 2,
    "totpEnabled": false,
    "disabled": false,
    "expireAt": 1796000000,
    "trafficLimit": 1099511627776,
    "usedBytes": 82463372083
  },
  "csrf": "",
  "roleName": "Reseller",
  "perms": {
    "clients.view": "own",
    "clients.create": "own",
    "clients.edit": "own",
    "clients.reset": "own"
  },
  "account": {
    "state": "active",
    "expireAt": 1796000000,
    "trafficLimit": 1099511627776,
    "usedBytes": 82463372083,
    "clients": 24,
    "maxClients": 100,
    "roleName": "Reseller",
    "canAssign": true
  },
  "token": {
    "id": 4,
    "name": "shop-bot",
    "full": false,
    "expiresAt": 1796000000
  }
}
```

`csrf` is empty for a token request. A browser session returns its CSRF token here.

## List clients

`GET clients` returns a page. The default is page 1 with 50 clients. Search with `q`, filter with `status`, and cap the page with `size`.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients?size=5&q=ali"
```

```json
{
  "items": [
    {
      "id": 118,
      "name": "ali-01",
      "enabled": true,
      "trafficLimit": 53687091200,
      "usedUp": 1073741824,
      "usedDown": 6442450944,
      "expireAt": 1796000000,
      "maxDevices": 2,
      "status": "active",
      "online": 1,
      "subUrl": "https://panel.example.com/sub/6f2a.../",
      "groups": [3]
    }
  ],
  "total": 1,
  "page": 1,
  "size": 5,
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

A reseller sees only its own clients, even without an `owner` filter.

## Create a client

Send `enabled: true` to allow connections; omitting it creates a disabled client. Replace group `3` with a group your account may use.

`POST clients` creates one client. The name is also the VPN user name, so it is unique across the panel.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients" \
  -d '{
    "name": "ali-02",
    "enabled": true,
    "trafficLimit": 53687091200,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3],
    "note": "order 1042"
  }'
```

`trafficLimit` is in bytes, so `53687091200` is 50 GB. `expireAfterDays` starts counting at the client's first connection; use `expireAt` with a Unix timestamp to fix a date now.

The answer is `201` with the new client. Keep `id` and `subUrl`:

```json
{
  "id": 119,
  "name": "ali-02",
  "enabled": true,
  "trafficLimit": 53687091200,
  "expireAt": 0,
  "expireAfterDays": 30,
  "maxDevices": 2,
  "status": "active",
  "subUrl": "https://panel.example.com/sub/9c41.../",
  "groups": [3]
}
```

A reseller must name an allowed group or inbound. Without one, the answer is `400` with `field: instances` and a sentence saying to choose one.

## Python

Install `requests` once, then keep the address and token in the environment.

```python
import os
import requests

BASE = os.environ["BASE"]
HEADERS = {"Authorization": f"Bearer {os.environ['OVIRA_TOKEN']}"}

def call(method: str, path: str, **kwargs):
    response = requests.request(method, f"{BASE}/{path.lstrip('/')}", headers=HEADERS, timeout=30, **kwargs)
    if not response.ok:
        try:
            body = response.json()
        except ValueError:
            body = {"error": response.text}
        raise RuntimeError(f"{response.status_code}: {body.get('error')} (code={body.get('code')}, field={body.get('field')})")
    return response.json()

me = call("GET", "auth/me")
print("acting as", me["admin"]["username"], "as", me["roleName"])

page = call("GET", "clients", params={"size": 5})
for client in page["items"]:
    print(client["id"], client["name"], client["status"])

created = call("POST", "clients", json={
    "name": "ali-03",
    "enabled": True,
    "trafficLimit": 50 * 1024**3,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3],
})
print("created", created["id"], created["subUrl"])
```

## Node

Node 18 and later has `fetch` built in.

```js
const base = process.env.BASE;
const headers = {
  Authorization: `Bearer ${process.env.OVIRA_TOKEN}`,
  "Content-Type": "application/json",
};

async function call(method, path, body) {
  const response = await fetch(`${base}/${path.replace(/^\/+/, "")}`, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(`${response.status}: ${data.error} (code=${data.code}, field=${data.field})`);
  }
  return data;
}

const me = await call("GET", "auth/me");
console.log("acting as", me.admin.username, "as", me.roleName);

const page = await call("GET", "clients?size=5");
for (const client of page.items) {
  console.log(client.id, client.name, client.status);
}

const created = await call("POST", "clients", {
  name: "ali-04",
  enabled: true,
  trafficLimit: 50 * 1024 ** 3,
  expireAfterDays: 30,
  maxDevices: 2,
  groups: [3],
});
console.log("created", created.id, created.subUrl);
```

## Handle errors

Check the HTTP status before reading the body as a success. A failed call has an `error` sentence, often a `code`, and `field` when one request field was wrong.

| What you see | What to do |
|---|---|
| `401` with `token_invalid` | The secret is wrong or the token was revoked. Create a new token. |
| `401` with `token_expired` | Replace the token. |
| `403` with `token_ip` | The caller is outside **Allowed IPs**. Read `params.ip`. |
| `403` with `account_blocked` | The reseller account is off, expired or out of traffic. Ask the owner. |
| `403` without a code | The token lacks the permission for this call. |
| `400` with `field` | Fix that field. The message says what is accepted. |
| `402` | The licence or the account's client or traffic limit refuses the change. |
| `409` | A duplicate name, or an unsupported downgrade. |
| `429` | Too many failed attempts. Wait before retrying. |

For a create call, a duplicate name is safe to resolve: search for the name with `GET clients?q=NAME`, compare `name` exactly, and reuse that client instead of creating a second one.

## Related pages

- [API tokens](/api/tokens): the permission list and token limits.
- [Clients reference](/api/reference/clients): every client field and action.
- [A shop bot](/api/shop-bot): the full order-to-subscription flow.
- [API overview](/api/): error codes and the base address.
