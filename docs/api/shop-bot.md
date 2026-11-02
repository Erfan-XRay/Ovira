# A shop bot

This page shows the panel API calls for a sales bot: a customer pays, the bot creates a client, sends the subscription link and QR code, renews the client later, and disables, rotates or deletes it when the order changes. The example is a reseller bot, because that is the common case.

The recipe uses these calls:

| Step | Call | Permission |
|---|---|---|
| Find an existing client | `GET clients?q=NAME` | `clients.view` |
| Create the client | `POST clients` | `clients.create` |
| Send the link and QR | `GET clients/{id}/qr` | `clients.view` |
| Check usage | `GET clients/{id}/usage` | `clients.view` |
| Renew | `POST clients/{id}/extend` | `clients.edit`, with the account's per-client limits |
| Disable or enable | `POST clients/{id}/disable` or `/enable` | `clients.edit` |
| Replace the link | `POST clients/{id}/rotate-sub` | `clients.edit` |
| Delete | `DELETE clients/{id}` | `clients.delete` |

## The token

Create a custom token on **Settings → API** for the reseller account with:

- `clients.view`
- `clients.create`
- `clients.edit`
- `clients.reset`

Add `clients.delete` only if the bot may delete clients. Set **Allowed IPs** to the bot's address or network, and an **Expiry** that matches how long the bot will run. A token is shown once; store it as a secret.

A reseller token only reaches the reseller's own clients. The account must not be switched off, expired or out of traffic, and it needs at least one allowed group or inbound. Otherwise the API answers `403` with `account_blocked`, or `400` when no group or inbound is allowed.

## Create a client for an order

Send `enabled: true` to allow connections. Omitted or false means disabled. Replace group `3` with a group your account may use.

Pick a name that is stable for the order, for example `order-1042` or the customer's Telegram id. The name is also the VPN user name.

Rules for `name`: 2 to 48 ASCII characters, letters, digits, dot, dash, underscore or `@`, starting with a letter or digit. It is unique across the panel, not only inside the reseller.

The order fields map to the API like this:

| Order value | Field | Notes |
|---|---|---|
| Customer name or order id | `name` | Keep it short and stable. |
| Traffic in GB | `trafficLimit` | Bytes: 50 GB is `50 * 1024**3`. `0` means unlimited, but a reseller may not be allowed to send it. |
| Days of service | `expireAfterDays` | Starts at the first connection. Use `expireAt` with a Unix timestamp to fix the end now. |
| Devices | `maxDevices` | `0` means no cap, subject to the reseller's limit. |
| Group | `groups` | Group ids the reseller was granted. |
| Single inbound | `instances` | Inbound ids the reseller was granted. A reseller must send a group or an inbound. |
| Note | `note` | Free text, at most 500 UTF-8 bytes. |
| Contact | `contact` | At most 120 characters. |

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients" \
  -d '{
    "name": "order-1042",
    "enabled": true,
    "trafficLimit": 53687091200,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3],
    "note": "Telegram 1042",
    "contact": "@customer"
  }'
```

The answer is `201` with the new client. Read `id`, `subUrl`, `status` and `expireAt`.

## Deliver the subscription link and QR

`subUrl` is the link to send. For a QR image, ask the panel for the client's QR:

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o order-1042.png \
  "$BASE/clients/119/qr"
```

The answer is a 320-pixel PNG of the same link. Send the image and `subUrl` together, and tell the customer to keep the link private: it is a sign-in secret for the subscription page.

## Renew an order

`POST clients/{id}/extend` adds days and traffic, and can reset the used traffic in the same call.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients/119/extend" \
  -d '{
    "days": 30,
    "bytes": 53687091200,
    "resetUsage": true
  }'
```

| Field | Type | Meaning |
|---|---|---|
| `days` | integer | Days to add, 0-3650. Counting starts from now or the current end date, whichever is later. |
| `bytes` | integer | Bytes to add to the client's traffic limit. It has no effect when the limit is `0` (unlimited). |
| `resetUsage` | boolean | Also set used upload and download back to zero. |

The answer is the client after the change. A reseller's per-client traffic and day limits still apply; a request over them answers `400` with `field: bytes` or `field: days`.

`days` does nothing to a client with no end date and no lifetime. `bytes` does nothing to an unlimited client. Check the client first if the order can have either shape.

## Check usage

`GET clients/{id}` wraps the client in a `client` object. Read `response.client` for `usedUp`, `usedDown`, `trafficLimit`, `status`, `online` and `lastOnlineAt`. `GET clients/{id}/usage` returns points over 24 hours, 7, 30 or 90 days.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients/119/usage?range=7d"
```

Used traffic is `usedUp + usedDown`. A client with `status: "limited"` has used its allowance, `expired` has passed its end date, and `disabled` was switched off. `ownerBlock` on the client says when the reseller's own pool or end date is blocking it.

## Disable and enable

A disabled client cannot connect and its open sessions are closed. Enable it when the order resumes.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/clients/119/disable"
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/clients/119/enable"
```

Both return the client. Enabling can fail with `402` when the account or client cap is full.

## Replace the subscription link

If a link leaked, rotate it. The old link stops at once.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/clients/119/rotate-sub"
```

The answer has the client with a new `subUrl`. Send the new link and QR to the customer; the old one no longer works.

## Delete

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/clients/119"
```

```json
{ "ok": true }
```

Deleting revokes the certificate and closes open sessions immediately. A customer who kept the profile cannot connect again.

## Retries and order tracking

Keep a durable order record in the bot: order id, client id, requested change and whether it completed. Serialize work for the same order. The API does not provide idempotency keys or an order ledger.

1. **Create:** use a stable name unique to this bot and order. After a timeout or `400` with `field: name`, search with `GET clients?q=NAME`, page through all results and compare `name` exactly. Reuse only the client that belongs to that order. No result does not prove the first request failed: it may still be running. Retry creation with the same name, never a new one; the panel's unique-name rule prevents a second client with that name.
2. **Extend:** this adds days and bytes. A blind retry can apply the renewal twice. After an uncertain result, read `GET clients/{id}` and inspect its `client` object, then reconcile it with your stored order. A changed end date alone does not prove which order changed it. If the outcome remains uncertain, pause the order for review.
3. **Reset, rotate and kick:** do not blindly retry. A reset can discard traffic recorded since the first attempt; rotation creates another link; a kick can close a newly reconnected session. Read the current state first. Enable and disable can be repeated when they still match the intended state. A repeated delete can return `404` once the client is gone.

## Reseller errors a bot must handle

| Answer | What it means | What the bot should do |
|---|---|---|
| `400`, `field: name` | The name is taken or invalid. | Search for the name and reuse the client, or correct the name. |
| `400`, `field: instances` | No group or inbound was chosen, or one is not allowed. | Use one of the account's allowed groups or inbounds. |
| `400`, `field: trafficLimit` | The client has no cap, is over the per-client cap, or the value is negative. | Use a limit within the account's rules. |
| `400`, `field: expireAt` or `days` | The client has no end date, or is longer than the account allows. | Set a date inside the allowed days. |
| `400`, `field: maxDevices` | The device cap is over the account's limit or out of range. | Use 1 up to the account's cap. |
| `402` | The licence, the reseller pool, or the account's client cap refuses the client. | Stop and ask the panel owner for more pool or a higher cap. |
| `403`, `code: account_blocked` | The reseller is disabled, expired or out of traffic. `params.reason` says which. | Stop creating or renewing; tell the operator. |
| `403`, no code | The token lacks a permission, or the client is outside the reseller's reach. | Fix the token or the order. |
| `404` | The client was deleted or is outside the reseller's reach. | Treat the order as gone. |
| `429` | Too many failed attempts from this address. | Wait, then retry. |

## One complete script

This runnable API example uses `requests` (`python -m pip install requests`). It reads the token from the environment, finds a client before creating one, and downloads a QR image. Replace `GROUP_ID` with an allowed group. Upload the returned `qr_file` through your bot platform. Payment verification, message delivery and durable order tracking belong in your bot; this script does not implement them.

```python
import os
from pathlib import Path
import requests

BASE = os.environ["BASE"]
TOKEN = os.environ["OVIRA_TOKEN"]
GROUP_ID = int(os.environ.get("OVIRA_GROUP_ID", "3"))
GB = 1024 ** 3  # 1 GiB; the panel labels this as GB

session = requests.Session()
session.headers.update({"Authorization": f"Bearer {TOKEN}"})


class ApiError(Exception):
    def __init__(self, status, body):
        self.status = status
        self.body = body
        super().__init__(f"{status}: {body.get('error')} (code={body.get('code')}, field={body.get('field')})")


def call(method, path, **kwargs):
    response = session.request(method, f"{BASE}/{path.lstrip('/')}", timeout=30, **kwargs)
    try:
        body = response.json()
    except ValueError:
        body = {"error": response.text}
    if not response.ok:
        raise ApiError(response.status_code, body)
    return body


def find_client(name):
    page_number = 1
    while True:
        page = call("GET", "clients", params={"q": name, "page": page_number, "size": 100})
        for client in page["items"]:
            if client["name"] == name:
                return client
        if not page["items"] or page_number * page["size"] >= page["total"]:
            return None
        page_number += 1


def ensure_client(order):
    name = f"order-{order['id']}"
    found = find_client(name)
    if found:
        return found, False
    try:
        client = call("POST", "clients", json={
            "name": name,
            "enabled": True,
            "trafficLimit": order["gb"] * GB,
            "expireAfterDays": order["days"],
            "maxDevices": order.get("devices", 2),
            "groups": [GROUP_ID],
            "note": order.get("note", ""),
            "contact": order.get("contact", ""),
        })
        return client, True
    except ApiError as error:
        if error.status == 400 and error.body.get("field") == "name":
            found = find_client(name)
            if found:
                return found, False
        raise
    except requests.RequestException:
        # The request may have reached the panel. Search before trying again.
        found = find_client(name)
        if found:
            return found, False
        raise


def deliver(client):
    response = session.get(f"{BASE}/clients/{client['id']}/qr", timeout=30)
    response.raise_for_status()
    if not response.headers.get("Content-Type", "").startswith("image/png"):
        raise ValueError("Expected a PNG QR image")
    qr_file = Path(f"client-{client['id']}.png")
    qr_file.write_bytes(response.content)
    # Upload this file with your messaging platform; never send the API token.
    return {"link": client["subUrl"], "qr_file": str(qr_file)}


def renew(client, days=30, gb=50, reset=False):
    return call("POST", f"clients/{client['id']}/extend", json={
        "days": days,
        "bytes": gb * GB,
        "resetUsage": reset,
    })


def usage(client):
    data = call("GET", f"clients/{client['id']}/usage", params={"range": "7d"})
    used = sum(point["up"] + point["down"] for point in data["points"])
    return {"used": used, "points": data["points"]}


def set_enabled(client, on):
    action = "enable" if on else "disable"
    return call("POST", f"clients/{client['id']}/{action}")


def rotate(client):
    return call("POST", f"clients/{client['id']}/rotate-sub")


def delete(client):
    return call("DELETE", f"clients/{client['id']}")


if __name__ == "__main__":
    order = {"id": 1042, "gb": 50, "days": 30, "devices": 2, "contact": "@customer"}
    client, created = ensure_client(order)
    print("created" if created else "already existed", client["id"])
    print(deliver(client))
    print("usage", usage(client)["used"])
    # renew(client, days=30, gb=50, reset=True)
    # set_enabled(client, False)
    # client = rotate(client)
    # delete(client)
```

## Related pages

- [Clients reference](/api/reference/clients): every client field and action.
- [API tokens](/api/tokens): the permissions and the allowed-address list.
- [Quickstart](/api/quickstart): the same calls in curl, Python and Node.
- [Traffic, quotas and limits](/how/traffic): how the panel counts traffic.
- [Roles and resellers](/use/resellers): the pool and per-client rules.
