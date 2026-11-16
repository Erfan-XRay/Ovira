# Webhooks

A webhook posts the events an account can see to a web address you choose, so your own bot or shop can react to them. Add one on **Settings → Webhooks**, or with `POST webhooks` and the `webhooks.manage` permission. A webhook only receives what its owner can see: a reseller never gets another reseller's clients.

The signing secret is shown once, when the webhook is created or its secret is rotated. Keep it like a password.

## The request

The panel sends a `POST` with a JSON body:

```json
{
  "id": 1042,
  "type": "client.expired",
  "version": 1,
  "at": 1794844424,
  "data": { "clientId": 35, "name": "order-1042" }
}
```

| Field | Meaning |
|---|---|
| `id` | The event id. A retry of the same event has the same id. |
| `type` | What happened, see the list below. |
| `version` | The envelope version, `1`. |
| `at` | When it happened, Unix seconds. |
| `data` | Details that depend on the type. Never a token, password or key. |

Headers:

| Header | Value |
|---|---|
| `Content-Type` | `application/json` |
| `User-Agent` | `Ovira-Webhook/<panel version>` |
| `X-Ovira-Event` | The event type. |
| `X-Ovira-Delivery` | `<event id>-<webhook id>`, the same for every retry. |
| `X-Ovira-Signature` | `t=<unix time>,v1=<hex HMAC-SHA256>` |

Answer with any `2xx` within 10 seconds. A failure is retried after 1 minute, 5 minutes, 30 minutes, 2 hours and 6 hours, then dropped. Events reach a webhook in order: a later event waits for an earlier one. `429` with a `Retry-After` header is waited out, and `410 Gone` turns the webhook off. Redirects are not followed.

The address must be `http` or `https`. Addresses inside private networks, on the panel's own server or on its nodes are refused; only the panel owner can allow them for one webhook.

## Event types

| Group | Types |
|---|---|
| Clients | `client.created`, `client.bulk_created`, `client.deleted`, `client.renewed`, `client.quota_warning`, `client.limited`, `client.expiring`, `client.expired`, `client.first_connect`, `client.reset` |
| Resellers | `reseller.pool_low`, `reseller.expiring` |
| Servers | `node.disconnected`, `node.connected`, `node.disk_high`, `node.memory_high` |
| System | `admin.login_new_ip`, `backup.failed`, `license.expiring` |

New types may appear; ignore the ones you do not know. A webhook can be limited to chosen types. The **Send test** button posts a `webhook.test` event.

## Subscription link

Off by default. When **Include the subscription link** is on, events about a client that still exists carry `data.subLink`. The link gives access to the client's connection, so turn it on only for a receiver you trust. It is left out when the panel does not know its own address yet; open the panel once as the owner, or set the subscription address in the panel settings.

## Check the signature

Sign `"<t>.<raw body>"` with the secret using HMAC-SHA256 and compare it with `v1` in constant time. Use the raw bytes of the body, not a re-encoded copy, and reject a `t` older than 5 minutes.

Python:

```python
import hashlib, hmac, time

def verify(secret: str, header: str, body: bytes) -> bool:
    parts = dict(p.split("=", 1) for p in header.split(","))
    t, v1 = parts.get("t", ""), parts.get("v1", "")
    if not t.isdigit() or abs(time.time() - int(t)) > 300:
        return False
    want = hmac.new(secret.encode(), t.encode() + b"." + body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(want, v1)
```

Node:

```js
import { createHmac, timingSafeEqual } from "node:crypto";

export function verify(secret, header, body /* Buffer */) {
  const parts = Object.fromEntries(header.split(",").map((p) => p.split("=")));
  const t = parts.t, v1 = parts.v1 ?? "";
  if (!/^\d+$/.test(t ?? "") || Math.abs(Date.now() / 1000 - Number(t)) > 300) return false;
  const want = createHmac("sha256", secret).update(`${t}.`).update(body).digest("hex");
  return v1.length === want.length && timingSafeEqual(Buffer.from(want), Buffer.from(v1));
}
```

## Calls

| Call | What it does |
|---|---|
| `GET webhooks` | Your webhooks. The owner sees all of them. |
| `POST webhooks` | Add one. Returns the secret once. |
| `PUT webhooks/{id}` | Change `url`, `events`, `includeSubLink`, `enabled`. |
| `DELETE webhooks/{id}` | Delete it. |
| `POST webhooks/{id}/test` | Send a test event and return the answer. |
| `POST webhooks/{id}/rotate-secret` | Replace the secret and return the new one once. |
| `GET webhooks/{id}/deliveries` | The last 50 deliveries with status and error. |

All of them need the `webhooks.manage` permission, which a token can be given like any other. See the [OpenAPI document](./openapi) for the exact fields.
