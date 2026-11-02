# Connections

A connection is one open or finished VPN session. These endpoints list what is open now, read finished sessions, and close one open session. Times are Unix seconds and traffic is bytes.

## List open connections

<Endpoint method="GET" path="/api/connections" perm="connections.view" :token="true" />

Returns the open sessions the account may see, with their device caps.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/connections"
```

```json
[
  {
    "sessionId": 9041,
    "instanceId": 12,
    "instance": "udp1194",
    "kind": "openvpn",
    "nodeId": 0,
    "node": "this server",
    "cid": 17,
    "clientId": 119,
    "name": "ali-02",
    "realAddr": "203.0.113.9",
    "vpnIp": "10.128.0.7",
    "platform": "Android",
    "version": "3.4.1",
    "connectedAt": 1795915000,
    "up": 104857600,
    "down": 734003200,
    "rateUp": 18200.5,
    "rateDown": 121000.2,
    "maxDevices": 2
  }
]
```

A WireGuard session also has `lastHandshake`. A session with `clientId: 0` came from a common name the panel does not know.

## Read connection history

<Endpoint method="GET" path="/api/connections/history" perm="connections.view" :token="true" />

Returns closed sessions, newest first.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `limit` | query | integer | How many sessions, 1-1000. Anything else means 200. |
| `client` | query | integer | Only this client's sessions; `0` keeps every client. |
| `q` | query | string | Search in client name and address. |
| `kind` | query | string | `openvpn`, `ocserv` or `wireguard`. An unknown value keeps every protocol. |
| `node` | query | integer | Only sessions on this node. `0` is this server; absent means every node. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/connections/history?limit=50&kind=openvpn"
```

```json
[
  {
    "id": 9040,
    "clientId": 119,
    "clientName": "ali-02",
    "instanceId": 12,
    "cid": 16,
    "commonName": "ali-02",
    "realAddr": "203.0.113.9",
    "vpnIp": "10.128.0.7",
    "platform": "Android",
    "clientVersion": "3.4.1",
    "connectedAt": 1795900000,
    "endedAt": 1795910000,
    "bytesUp": 20971520,
    "bytesDown": 104857600,
    "endReason": "client disconnect",
    "kind": "openvpn"
  }
]
```

## Close one connection

<Endpoint method="POST" path="/api/connections/kick" perm="connections.kick" :token="true" />

Closes one open session. Read `instanceId` and `cid` from the open connections list.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `instanceId` | integer | yes | Inbound the connection runs on. |
| `cid` | integer | yes | Protocol-level connection id from `LiveSession.cid`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/connections/kick" \
  -d '{"instanceId":12,"cid":17}'
```

```json
{ "ok": true }
```

`404` means the connection is already closed, or it is outside the account's reach. The client may reconnect at once if its plan still allows it; disable the client to prevent it from reconnecting. Kicking one or all sessions allows reconnection.

## Related pages

- [Clients](/api/reference/clients): disable a client or close all of its sessions.
- [Inbounds](/api/reference/inbounds): the inbound a session runs on.
- [Traffic, quotas and limits](/how/traffic): how sessions count against a plan.
