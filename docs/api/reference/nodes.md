# Nodes

A node is another server that runs inbounds for this panel. Node id `0` is the panel's own server and cannot be removed. These endpoints list and change nodes, read the install command, sync a node, reset its traffic counters, and manage the protocol packages on it.

Times are Unix seconds. Node traffic is real bytes before the node's multiplier.

## List nodes

<Endpoint method="GET" path="/api/nodes" perm="nodes.view" :token="true" />

Returns every node the account may see, the panel's own server first, with the licence's node allowance.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/nodes"
```

```json
{
  "items": [
    {
      "id": 0,
      "name": "this server",
      "kind": "local",
      "enabled": true,
      "address": "",
      "apiPort": 0,
      "ratio": 1,
      "endpoints": [],
      "trafficUp": 0,
      "trafficDown": 0,
      "online": true,
      "instances": 2,
      "sessions": 3,
      "updateAvailable": false
    },
    {
      "id": 4,
      "name": "de-fra-1",
      "kind": "remote",
      "enabled": true,
      "address": "198.51.100.24",
      "apiPort": 62060,
      "ratio": 1.5,
      "endpoints": [
        { "label": "Germany", "host": "de.example.com", "port": 0, "instance": 0 }
      ],
      "trafficUp": 10737418240,
      "trafficDown": 53687091200,
      "online": true,
      "lastSeen": 1795919000,
      "instances": 1,
      "sessions": 2,
      "updateAvailable": false
    }
  ],
  "allowed": true,
  "maxNodes": 10,
  "defaultPort": 62060
}
```

`allowed` says whether the licence includes nodes. `maxNodes: 0` means no numeric node cap when `allowed` is true; `allowed: false` means remote nodes are unavailable.

## Add a node

<Endpoint method="POST" path="/api/nodes" perm="owner" :token="true" />

The owner adds a node after running the install command on the new server. The panel probes it once and returns whether the pairing works.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `name` | string | yes | Node name. Unique. |
| `enabled` | boolean | no | Let the panel use the node. Default true. |
| `address` | string | yes | Where the panel reaches the node's API. |
| `apiPort` | integer | no | Port of the node's API. The default is the panel's node port. |
| `key` | string | yes | Node key printed by the node's installer. |
| `ratio` | number | no | Traffic multiplier for quota accounting. Default 1. |
| `endpoints` | object[] | no | Addresses clients use: `label`, `host`, `port`, `instance`. |
| `note` | string | no | Free text for the owner. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/nodes" \
  -d '{
    "name": "de-fra-1",
    "address": "198.51.100.24",
    "apiPort": 62060,
    "key": "NODE_KEY",
    "ratio": 1.5,
    "endpoints": [{"label":"Germany","host":"de.example.com","port":0,"instance":0}]
  }'
```

```json
{
  "node": {
    "id": 4,
    "name": "de-fra-1",
    "kind": "remote",
    "enabled": true,
    "address": "198.51.100.24",
    "apiPort": 62060,
    "ratio": 1.5,
    "online": true,
    "instances": 0,
    "sessions": 0
  }
}
```

`400` with `field: name` or `address` means a duplicate or invalid value. `402` means the licence does not allow another node.

## Read the install command

<Endpoint method="GET" path="/api/nodes/install" perm="nodes.view" :token="true" />

Returns the one-line command to run on the new server, the installer address, and this panel's address.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/nodes/install"
```

```json
{
  "command": "bash <(curl -fsSL https://example.com/node.sh) --panel-ip 203.0.113.10",
  "panelIp": "203.0.113.10",
  "script": "https://example.com/node.sh"
}
```

## Install a node on the panel host

<Endpoint method="POST" path="/api/nodes/0/local-install" perm="owner" :token="true" />

Prepares this server to run inbounds as a node too. The answer is `202`; poll `GET nodes` for the result.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/nodes/0/local-install"
```

```json
{ "installing": true, "installError": "" }
```

`400` means the install cannot run on this host.

## Change a node

<Endpoint method="PUT" path="/api/nodes/{id}" perm="owner" :token="true" />

Sends the same fields as create. An empty `key` keeps the saved one. Path parameter `id` is the node id; `0` is this server.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/nodes/4" \
  -d '{"name":"de-fra-1","address":"198.51.100.24","apiPort":62060,"ratio":1.5,"enabled":true}'
```

The answer is the changed node. `400` names the bad field.

## Remove a node

<Endpoint method="DELETE" path="/api/nodes/{id}" perm="owner" :token="true" />

Removes a node. Its inbounds become unassigned, so their profiles stop until you assign them somewhere else. Node `0` cannot be removed.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/nodes/4"
```

The answer is `204`. `400` means the id is the main server or not valid.

## Sync a node or reset its traffic

<Endpoint method="POST" path="/api/nodes/{id}/{action}" perm="nodes.manage" :token="true" />

| Action | What it does |
|---|---|
| `sync` | Pushes the current state to the node. |
| `reset-traffic` | Sets the node's traffic counters to zero. Client quotas and account pools are not changed. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X POST "$BASE/nodes/4/sync"
```

```json
{
  "node": {
    "id": 4,
    "name": "de-fra-1",
    "online": true,
    "trafficUp": 0,
    "trafficDown": 0
  }
}
```

`404` means no such node or action.

## Read protocol packages

<Endpoint method="GET" path="/api/nodes/{id}/protocols" perm="owner" :token="true" />

Returns the package state of `openvpn`, `ocserv` and `wireguard` on a node, and how many inbounds use each.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/nodes/4/protocols"
```

```json
{
  "protocols": {
    "openvpn": {
      "installed": true,
      "owned": true,
      "busy": false,
      "stage": "",
      "logs": []
    },
    "wireguard": {
      "installed": true,
      "owned": true,
      "busy": false,
      "stage": "",
      "logs": []
    }
  },
  "references": { "openvpn": 1, "wireguard": 1 }
}
```

## Remove a protocol from a node

<Endpoint method="DELETE" path="/api/nodes/{id}/protocols/{kind}" perm="owner" :token="false" />

Removes a protocol package the panel installed. Session only: a token answers `token_forbidden`. Path parameters are the node id and `kind`: `openvpn`, `ocserv` or `wireguard`.

```bash
curl -sS -b cookies.txt -X DELETE \
  -H "X-CSRF-Token: $CSRF" \
  "$BASE/nodes/4/protocols/wireguard"
```

```json
{
  "protocols": {
    "wireguard": { "installed": false, "owned": false, "busy": false, "stage": "", "logs": [] }
  },
  "references": { "wireguard": 0 }
}
```

`400` means an inbound still uses the protocol, or the panel did not install it.

## Related pages

- [Inbounds](/api/reference/inbounds): deploying an inbound to nodes.
- [This server as a node](/start/same-server): the local node in the panel.
- [Nodes](/use/nodes): the panel page and its actions.
- [A node and its panel](/how/nodes): how the link works.
