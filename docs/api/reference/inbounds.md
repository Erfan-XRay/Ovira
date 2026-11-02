# Inbounds

An inbound is one VPN service: an OpenVPN, OpenConnect or WireGuard listener on a node. The API calls it `instances`. An inbound with `nodeId: -1` is not assigned yet; `0` is the panel's own server. A multi-node inbound has one deployment per node.

These endpoints list and change inbounds, read their defaults and access, deploy them, override settings per node, start and stop them, and read their logs. Traffic is bytes and times are Unix seconds.

## Brief list

<Endpoint method="GET" path="/api/instances/brief" perm="inbounds.view" :token="true" />

Returns inbounds with names, states and addresses only. Add `?deployments=1` to include the per-node deployments of a multi-node inbound.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/brief?deployments=1"
```

```json
[
  {
    "id": 12,
    "technicalName": "udp1194",
    "nodeId": 0,
    "node": "this server",
    "name": "udp1194",
    "proto": "udp",
    "port": 1194,
    "enabled": true,
    "authMode": "cert",
    "description": "",
    "network": "10.128.0.0/16",
    "staticStart": "10.128.255.0",
    "staticEnd": "10.128.255.255",
    "kind": "openvpn"
  }
]
```

## List inbounds

<Endpoint method="GET" path="/api/instances" perm="inbounds.view" :token="true" />

Requires `inbounds.view: all`. Accounts with `own` scope must use `GET instances/brief`. Returns inbounds with their full settings, link state, address pool, client count and deployments. Add `?deployments=1` for per-node deployments.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances?deployments=1"
```

```json
{
  "items": [
    {
      "id": 12,
      "kind": "openvpn",
      "nodeId": 0,
      "name": "udp1194",
      "enabled": true,
      "proto": "udp",
      "port": 1194,
      "network": "10.128.0.0/16",
      "active": true,
      "state": "active",
      "link": { "connected": true, "online": 3 },
      "clients": 42,
      "settings": { "authMode": "cert", "tlsMode": "tls-crypt" }
    }
  ],
  "system": "Ubuntu",
  "openvpn": "2.6.12",
  "publicHost": "panel.example.com"
}
```

## Create an inbound

<Endpoint method="POST" path="/api/instances" perm="inbounds.manage" :token="true" />

Returns `201` with the new inbound, and a `warning` when part of the change did not apply. Assigning a node is normally a separate call; `nodeIds` deploys right after creation.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `displayName` | string | no | Name shown instead of `name`, when set. |
| `kind` | string | no | `openvpn`, `ocserv` or `wireguard`. Empty means `openvpn`. Fixed after creation. |
| `nodeId` | integer | no | Ignored on create. New inbounds start unassigned (`-1`); use `nodeIds` to deploy. |
| `name` | string | yes | Inbound name and service name. Unique. |
| `enabled` | boolean | no | True to switch it on. |
| `proto` | string | yes | `udp`, `tcp`, `udp6` or `tcp6`. |
| `port` | integer | yes | Port to listen on. |
| `network` | string | yes | Tunnel network in CIDR form. |
| `settings` | object | no | Protocol settings. See below. |
| `accessGroups` | integer[] | no | Groups that may use the inbound. Absent grants every group. |
| `ownListClients` | boolean | no | True to let clients pick this inbound directly. Absent means true. |
| `nodeIds` | integer[] | no | Nodes to deploy to right after creation. |
| `ports` | object | no | Port per deployment node, keyed by node id. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances" \
  -d '{
    "kind": "openvpn",
    "name": "udp1194",
    "enabled": true,
    "proto": "udp",
    "port": 1194,
    "network": "10.128.0.0/16",
    "settings": {
      "authMode": "cert",
      "tlsMode": "tls-crypt",
      "dns": ["1.1.1.1"],
      "redirectGateway": true,
      "maxClients": 0
    },
    "accessGroups": [3]
  }'
```

```json
{
  "instance": {
    "id": 12,
    "kind": "openvpn",
    "nodeId": -1,
    "name": "udp1194",
    "enabled": true,
    "proto": "udp",
    "port": 1194,
    "network": "10.128.0.0/16",
    "active": false,
    "state": "inactive",
    "clients": 0
  }
}
```

`400` names the bad field, including a used port or an overlapping tunnel network. `402` means the licence does not allow another inbound.

## Settings object

Every field is optional; the panel fills the ones you leave out with its defaults. Send back the object you read from `GET instances/defaults` or `GET instances/{id}` after editing.

| Field | Type | Meaning |
|---|---|---|
| `authMode` | string | `cert`, `cert+pass` or `pass`: how clients prove themselves. |
| `tlsMode` | string | `tls-crypt`, `tls-auth` or `none`: control-channel protection. |
| `dataCiphers` | string[] | Negotiated AEAD ciphers. |
| `fallbackCipher` | string | Cipher for pre-2.4 clients; empty means none. |
| `authDigest` | string | HMAC digest. |
| `tlsMinVersion` | string | `1.2` or `1.3`. |
| `dns` | string[] | Resolvers pushed to clients. |
| `searchDomain` | string | `DOMAIN` pushed to clients. |
| `redirectGateway` | boolean | Send every packet through the tunnel. |
| `blockOutsideDns` | boolean | Block DNS outside the tunnel (Windows leak fix). |
| `pushRoutes` | string[] | CIDRs routed through the tunnel. |
| `ipv6` | boolean | Offer tunnel addresses from `network6`. |
| `network6` | string | IPv6 tunnel network in CIDR form. |
| `clientToClient` | boolean | Let clients reach each other. |
| `maxClients` | integer | Concurrent client cap; `0` means none. |
| `keepaliveInterval` | integer | Keepalive interval in seconds. |
| `keepaliveTimeout` | integer | Keepalive timeout in seconds. |
| `tunMtu` | integer | Tunnel MTU; `0` means the default. |
| `mssFix` | integer | MSS clamping value; `0` means off. |
| `fragment` | integer | UDP fragment size; `0` means off. |
| `sndRcvBuf` | integer | Socket buffer size; `0` means the system default. |
| `compression` | string | `off`, `lz4-v2` or `lzo`. |
| `renegSec` | integer | Key renegotiation interval in seconds. |
| `portShare` | string | Host port to share with another service; TCP only. |
| `exitNotify` | boolean | Tell clients when the server stops. |
| `multihome` | boolean | Answer UDP from the address the packet arrived on. |
| `remotes` | object[] | Client addresses: `label`, `host`, `port`. Empty uses the node's addresses. |
| `remote` | string | The first of `remotes`, kept for older versions. |
| `verb` | integer | Log verbosity, 0-11. |
| `nat` | boolean | Keep a NAT rule for the tunnel network. |
| `serverCustom` | string | Extra server configuration lines, checked against a denylist. |
| `clientCustom` | string | Extra client configuration lines, checked against a denylist. |
| `description` | string | Text shown with the inbound's profiles. |
| `oc` | object | OpenConnect settings. |
| `wg` | object | WireGuard settings. |

### OpenConnect settings (`oc`)

| Field | Type | Meaning |
|---|---|---|
| `dtls` | boolean | Also listen on UDP on the same port. |
| `camouflage` | boolean | Answer browser probes with a decoy page; needs ocserv 1.2.0 or newer. |
| `camouflageSecret` | string | Secret in the connect URL: `https://host:port/?SECRET`. |
| `camouflageRealm` | string | Realm shown to browsers that probe the port. |
| `certSource` | string | `pki`, `panel` or `acme`: where the server certificate comes from. |
| `acmeHost` | string | ACME DNS name; empty uses the node's public address. |
| `idleTimeout` | integer | Idle timeout for desktop clients, in seconds. |
| `mobileIdleTimeout` | integer | Idle timeout for mobile clients, in seconds. |
| `cookieTimeout` | integer | How long a session cookie stays resumable, in seconds. |
| `dpd` | integer | Dead peer detection interval, in seconds. |
| `mobileDpd` | integer | Dead peer detection interval for mobile clients, in seconds. |
| `ciscoCompat` | boolean | Accept old Cisco clients. |
| `tlsPriorities` | string | GnuTLS priority string. |
| `proxyProtocol` | boolean | Accept PROXY protocol headers from a relay. |
| `serverCustom` | string | Extra `ocserv.conf` lines, checked against a denylist. |

### WireGuard settings (`wg`)

| Field | Type | Meaning |
|---|---|---|
| `filenameTemplate` | string | Client download filename: fixed text or `{username}`, `{device}`, `{inbound}` placeholders. Empty keeps automatic naming. WireGuard and AmneziaWG. |
| `privateKey` | string | Server private key. Never returned by the API. |
| `publicKey` | string | Server public key. |
| `obfuscation` | string | Obfuscation mode; empty means plain WireGuard. |
| `amnezia` | object | AmneziaWG parameters: `jc`, `jmin`, `jmax`, `s1`, `s2`, `h1`-`h4`, `i1`-`i5`, `j1`-`j3`, `itime`. |
| `mtu` | integer | Tunnel MTU. |
| `keepalive` | integer | Persistent keepalive in seconds; `0` means off. |
| `allowedIPs` | string[] | CIDRs routed through the tunnel. |

## Preflight an inbound

<Endpoint method="POST" path="/api/instances/preflight" perm="inbounds.manage" :token="true" />

Checks a draft before creating it. The body is the create body plus `nodeIds` and per-node `ports`; `nodeId` is ignored. The answer has one finding per node, with an empty `error` when the node is ready.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances/preflight" \
  -d '{"kind":"openvpn","name":"udp1194","proto":"udp","port":1194,"network":"10.128.0.0/16","nodeIds":[0,4]}'
```

```json
{
  "items": [
    { "nodeId": 0, "error": "" },
    { "nodeId": 4, "error": "port udp/1194 is already used by udp1194" }
  ]
}
```

`400` means the draft itself is not valid.

## Read defaults

<Endpoint method="GET" path="/api/instances/defaults" perm="inbounds.manage" :token="true" />

Returns the default settings for a new inbound. For OpenConnect it also returns the install state of the node.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `kind` | query | string | `openvpn`, `ocserv` or `wireguard`. Default `openvpn`. |
| `nodeId` | query | integer | Node the defaults are for. `-1`, the default, is an unassigned inbound. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/instances/defaults?kind=openvpn&nodeId=0"
```

```json
{
  "authMode": "cert",
  "tlsMode": "tls-crypt",
  "dataCiphers": ["AES-256-GCM", "CHACHA20-POLY1305"],
  "fallbackCipher": "",
  "authDigest": "SHA256",
  "tlsMinVersion": "1.2",
  "dns": ["1.1.1.1"],
  "redirectGateway": false,
  "blockOutsideDns": false,
  "pushRoutes": [],
  "ipv6": false,
  "network6": "",
  "clientToClient": false,
  "maxClients": 0,
  "keepaliveInterval": 10,
  "keepaliveTimeout": 60,
  "tunMtu": 0,
  "mssFix": 0,
  "fragment": 0,
  "sndRcvBuf": 0,
  "compression": "off",
  "renegSec": 0,
  "portShare": "",
  "exitNotify": false,
  "multihome": false,
  "remotes": [],
  "remote": "",
  "verb": 3,
  "nat": true,
  "serverCustom": "",
  "clientCustom": "",
  "description": ""
}
```

For `kind=ocserv`, the answer is an object with `settings` plus `supported`, `installed`, `version`, `installing`, `installError`, `camouflageMin`, `camouflageOk`, `certSource`, `panelCert` and `acme`.

## Read inbound access

<Endpoint method="GET" path="/api/instances/access" perm="inbounds.manage" :token="true" />

Returns the groups that may use each inbound, and how many clients have their own inbound list instead of a group.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/access"
```

```json
{
  "groups": [
    { "id": 3, "name": "Iran", "instances": [12, 21], "clients": 42 }
  ],
  "ownListClients": 7
}
```

## Install OpenConnect on this server

<Endpoint method="POST" path="/api/ocserv/install" perm="inbounds.manage" :token="true" />

Starts installing `ocserv` on the panel host. The answer is `202`; poll `GET instances/defaults?kind=ocserv&nodeId=0` for the outcome on this server.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/ocserv/install"
```

`400` means the install cannot run on this host.

## Get one inbound

<Endpoint method="GET" path="/api/instances/{id}" perm="inbounds.view" :token="true" />

Returns the inbound, the configuration file rendered for it, where that file lives, and its deployments and overrides. The account needs `inbounds.view` for all inbounds.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/12"
```

```json
{
  "instance": {
    "id": 12,
    "kind": "openvpn",
    "nodeId": 0,
    "name": "udp1194",
    "enabled": true,
    "proto": "udp",
    "port": 1194,
    "network": "10.128.0.0/16",
    "active": true,
    "state": "active",
    "clients": 42,
    "settings": { "authMode": "cert", "tlsMode": "tls-crypt" }
  },
  "config": "port 1194\nproto udp\n...",
  "path": "/etc/ovira/instances/udp1194/server.conf",
  "shared": { "name": "udp1194", "port": 1194 },
  "overrides": {},
  "deployments": []
}
```

## Change an inbound

<Endpoint method="PUT" path="/api/instances/{id}" perm="inbounds.manage" :token="true" />

Sends the same fields as create, without `accessGroups`, `nodeIds` and `ports`. The answer is the changed inbound with a `warning` when part of the change did not apply.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/instances/12" \
  -d '{"name":"udp1194","enabled":true,"proto":"udp","port":1194,"network":"10.128.0.0/16","settings":{"authMode":"cert+pass","tlsMode":"tls-crypt"}}'
```

```json
{
  "instance": {
    "id": 12,
    "name": "udp1194",
    "enabled": true,
    "port": 1194,
    "settings": { "authMode": "cert+pass", "tlsMode": "tls-crypt" }
  }
}
```

`400` names the bad field. Changing a port or a network restarts the inbound and disconnects its users.

## Delete an inbound

<Endpoint method="DELETE" path="/api/instances/{id}" perm="inbounds.manage" :token="true" />

Removes the inbound and its service. Clients that used it lose that profile.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/instances/12"
```

```json
{ "ok": true }
```

## List deployments

<Endpoint method="GET" path="/api/instances/{id}/deployments" perm="inbounds.view" :token="true" />

Returns one entry per node where the inbound is deployed, with the deployment job. The account needs `inbounds.view` for all inbounds.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/12/deployments"
```

```json
{
  "items": [
    {
      "nodeId": 4,
      "node": "de-fra-1",
      "instance": { "id": 27, "parentId": 12, "nodeId": 4, "name": "udp1194" },
      "job": {
        "serviceId": 12,
        "nodeId": 4,
        "instanceId": 27,
        "status": "done",
        "stage": "running",
        "logs": [],
        "updatedAt": 1795919000
      }
    }
  ]
}
```

## Deploy an inbound

<Endpoint method="POST" path="/api/instances/{id}/deployments" perm="inbounds.manage" :token="true" />

Queues a deployment to one or more nodes.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `nodeIds` | integer[] | yes | 1-100 nodes to deploy to. |
| `ports` | object | no | Port per node, keyed by node id. |

Add `?check=1` to check the nodes instead of deploying: the answer is `200` with one finding per node and nothing changes. Without it the answer is `202` and the deployments are queued.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/instances/12/deployments?check=1" \
  -d '{"nodeIds":[4],"ports":{"4":1194}}'
```

```json
{
  "items": [
    { "nodeId": 4, "error": "" }
  ]
}
```

`400` means no node, too many nodes or an invalid body.

## Remove a deployment

<Endpoint method="DELETE" path="/api/instances/{id}/deployments/{node}" perm="inbounds.manage" :token="true" />

Removes the inbound from one node. Path parameters are the inbound id and the node id; `0` is this server.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X DELETE "$BASE/instances/12/deployments/4"
```

```json
{ "ok": true }
```

`400` means the id or node is not valid, or the inbound is not deployed there.

## Change one node's overrides

<Endpoint method="PUT" path="/api/instances/{id}/deployments/{node}/overrides" perm="inbounds.manage" :token="true" />

Sets what one node overrides for a multi-node inbound. The answer is `202` and the node redeploys.

| Field | Type | Meaning |
|---|---|---|
| `port` | integer | Port on this node instead of the shared one. |
| `network` | string | Tunnel network on this node instead of the shared one. |
| `remotes` | object[] | Client addresses for this node instead of the shared ones: `label`, `host`, `port`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT "$BASE/instances/12/deployments/4/overrides" \
  -d '{"port":443,"remotes":[{"label":"Germany","host":"de.example.com","port":443}]}'
```

```json
{ "ok": true }
```

`400` means the inbound is not deployed on that node.

<Endpoint method="DELETE" path="/api/instances/{id}/deployments/{node}/overrides" perm="inbounds.manage" :token="true" />

Clears that node's overrides and redeploys it. The answer is `202`.

## Assign an inbound to a node

<Endpoint method="POST" path="/api/instances/{id}/node" perm="inbounds.manage" :token="true" />

Moves an inbound to a node, including from one node to another. The body has one required field:

| Field | Type | Required | Meaning |
|---|---|---|---|
| `nodeId` | integer | yes | Node to assign. `0` is the panel's own server. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances/12/node" \
  -d '{"nodeId":4}'
```

The answer is the inbound and a `warning` when part of it did not apply. `400` means no node was chosen or it is not valid.

<Endpoint method="DELETE" path="/api/instances/{id}/node" perm="inbounds.manage" :token="true" />

Removes the inbound from its node and leaves it unassigned. Its profiles stop until it is assigned again.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/instances/12/node"
```

`400` means the inbound cannot be unassigned.

## Start, stop or restart an inbound

<Endpoint method="POST" path="/api/instances/{id}/control" perm="inbounds.manage" :token="true" />

| Field | Type | Required | Meaning |
|---|---|---|---|
| `action` | string | yes | `start`, `stop` or `restart`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances/12/control" \
  -d '{"action":"restart"}'
```

The answer is the inbound after the action. `400` means the action is not valid.

## Read inbound logs

Requires `inbounds.view: all`.

<Endpoint method="GET" path="/api/instances/{id}/logs" perm="inbounds.view" :token="true" />

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `id` | path | integer | Inbound id. |
| `lines` | query | integer | How many lines, 10-2000. Anything else means 200. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/instances/12/logs?lines=100"
```

```json
{
  "logs": "2026-11-02 12:00:01 TLS: Initial packet from 203.0.113.9:51820\n..."
}
```

`404` means no such inbound.

## Related pages

- [Nodes](/api/reference/nodes): the servers an inbound can run on.
- [Groups](/api/reference/groups): the groups that may use an inbound.
- [Inbounds](/use/inbounds): the panel page and its fields.
- [Choosing a protocol](/protocols/): what each kind is good for.
