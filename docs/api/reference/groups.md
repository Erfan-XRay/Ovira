# Groups

A group gives its inbounds to every client in it. A client in one or more groups gets the union of those groups' inbounds. These endpoints list, create, change and bulk-edit groups, and add or remove groups for clients.

A group with **All inbounds** (`allServers`) includes inbounds added later. A disabled group gives no access. Times are Unix seconds.

## List groups

<Endpoint method="GET" path="/api/groups" perm="groups.view" :token="true" />

Returns the groups the account may see. A reseller sees only the groups it was granted.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/groups"
```

```json
{
  "items": [
    {
      "id": 3,
      "name": "Iran",
      "note": "Low-latency inbounds",
      "disabled": false,
      "allServers": false,
      "instances": [12, 21],
      "clients": 42,
      "createdAt": 1793000000
    }
  ]
}
```

## Create a group

<Endpoint method="POST" path="/api/groups" perm="groups.manage" :token="true" />

| Field | Type | Required | Meaning |
|---|---|---|---|
| `name` | string | yes | 1-40 characters. Unique. |
| `note` | string | no | Free text, at most 200 characters. |
| `disabled` | boolean | no | `true` gives the group no access. |
| `allServers` | boolean | no | `true` includes every inbound, even ones added later. |
| `instances` | integer[] | no | Inbound ids the group grants. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/groups" \
  -d '{"name":"Iran","note":"Low-latency inbounds","instances":[12,21]}'
```

```json
{
  "id": 3,
  "name": "Iran",
  "note": "Low-latency inbounds",
  "disabled": false,
  "allServers": false,
  "instances": [12, 21],
  "clients": 0,
  "createdAt": 1795919000
}
```

`400` with `field: name` means the name is empty, too long or already used.

## Change a group

<Endpoint method="PUT" path="/api/groups/{id}" perm="groups.manage" :token="true" />

Sends the same fields as create. A change reaches every client in the group at once.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/groups/3" \
  -d '{"name":"Iran","note":"Updated","allServers":true}'
```

```json
{
  "id": 3,
  "name": "Iran",
  "note": "Updated",
  "disabled": false,
  "allServers": true,
  "instances": [],
  "clients": 42,
  "createdAt": 1793000000
}
```

`404` means no such group or it is outside the account's reach.

## Enable, disable or delete several groups

<Endpoint method="POST" path="/api/groups/bulk" perm="groups.manage" :token="true" />

| Field | Type | Required | Meaning |
|---|---|---|---|
| `ids` | integer[] | yes | Group ids. |
| `action` | string | yes | `enable`, `disable` or `delete`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/groups/bulk" \
  -d '{"ids":[3,4],"action":"disable"}'
```

The answer is `204` with no body. `400` means the action is not one of the three.

## Add or remove groups for clients

<Endpoint method="POST" path="/api/groups/assign" perm="groups.manage" :token="true" />

Changes group membership for many clients in one call. A client keeps its other groups.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `clients` | integer[] | yes | Client ids to change. |
| `add` | integer[] | no | Group ids to add. |
| `remove` | integer[] | no | Group ids to remove. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/groups/assign" \
  -d '{"clients":[118,119],"add":[3],"remove":[2]}'
```

The answer is `204` with no body. `400` means a client or group id is not valid for the account.

## Related pages

- [Clients](/api/reference/clients): the `groups` field on a client.
- [Inbounds](/api/reference/inbounds): the inbounds a group can grant.
- [Groups](/use/groups): the panel page and its rules.
- [Roles and resellers](/use/resellers): the groups a reseller can use.
