# Endpoint reference

Every documented endpoint is on one of these pages, grouped by what it acts on. Each endpoint shows its method and path, the permission it needs, whether a token may call it, its parameters and body, a curl example and a response example.

Response examples show selected fields; the [OpenAPI document](/api/openapi) defines the complete response schemas.

Traffic is in bytes. Times are Unix seconds. A traffic limit of `0` means unlimited and an end date of `0` means never.

## How to read an endpoint

<Endpoint method="POST" path="/api/clients" perm="clients.create" :token="true" />

- The method and path are the spec path. In the examples, `$BASE` already ends in `/api`, so `$BASE/clients` is `<panel-base>/api/clients`.
- **permission** is the permission the account needs. A custom token must also hold it. `any` means any signed-in account, `staff` means the owner or an account with `clients.view` for all clients, and `public` means no sign-in at all.
- **session only** means a token is refused with `403` and `token_forbidden`; use the browser session.
- A token with the permission can call the endpoint unless it says **session only**. Owner-only endpoints also refuse a custom token, even one made by the owner.

Path parameters are written in braces, for example `{id}`. Query parameters go after `?` and are optional unless the table says otherwise. A request body is JSON unless the endpoint says multipart or binary.

## Groups

| Page | What it covers |
|---|---|
| [Clients](/api/reference/clients) | Clients, bulk create and actions, usage, profiles, QR codes, WireGuard devices. |
| [Connections](/api/reference/connections) | Live connections, history and closing one. |
| [Inbounds](/api/reference/inbounds) | Inbounds, defaults, preflight, deployments, overrides, control and logs. |
| [Groups](/api/reference/groups) | Groups, bulk actions and assigning groups to clients. |
| [Nodes](/api/reference/nodes) | Nodes, installation, actions, protocols and package removal. |
| [Accounts and roles](/api/reference/admins) | Panel accounts, roles, plan actions and per-account usage. |
| [Panel settings](/api/reference/settings) | Overview, system, settings, TLS, backup, Telegram backup, updates and audit. |
| [Auth and account](/api/reference/account) | Panel metadata, sign-in, your account, sessions and tokens. |
| [Subscription links](/api/reference/subscription) | The public pages and files behind a client's subscription link. |

## Common answers

| Status | Body |
|---|---|
| Success with data | A JSON object or array. |
| `204` | No body. |
| Error | `{ "error": "...", "code": "...", "field": "...", "params": {...} }`, with `code` and `field` only when they apply. |

`GET` lists return the records the account may see. A reseller sees its own clients, and only the groups and inbounds it was granted.

Node id `0` is the panel's own server. An inbound with `nodeId: -1` is not assigned to a node yet.

## Related pages

- [API overview](/api/): base address, tokens and error codes.
- [API tokens](/api/tokens): the permission list.
- [OpenAPI document](/api/openapi): import or generate a client.
