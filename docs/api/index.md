# API overview

The Ovira API is an HTTP JSON interface to the panel. You can use it to run a shop or sales bot, build reseller tools, watch traffic and connections from another system, or script the jobs you repeat in the panel. This page covers the base address, sign-in, the shape of requests and errors, and what a token cannot do.

API tokens are available starting with **Ovira v0.9.9-beta.6**. This is a beta feature; stable v0.9.8 and earlier v0.9.9 betas do not include the **Settings → API** tab.

## What you can build

- A sales bot that creates a client for an order, sends the subscription link and QR code, renews it later, and disables or deletes it when the order ends.
- A reseller tool that works inside one reseller account and its traffic pool.
- Monitoring that reads clients, live connections, node state and traffic history.
- Scripts that bulk-create clients, assign groups, or keep an external CRM in step.

The API can do what the signed-in account can do in the panel, with two limits: it never reaches the panel's own session-only actions, and a custom token only carries the permissions chosen for it.

## Base URL

The API lives under the panel's own address, its secret base path, and `api/`:

```text
https://panel.example.com/<secret-path>/api/
```

The exact address is on **Settings → API**, in **API base URL**, with a copy button. Use that value as the base and drop the `/api` prefix shown in the reference; `$BASE` below already contains it. The examples below shorten it to `$BASE`:

```bash
export BASE="https://panel.example.com/ovira-7f3c/api"
export OVIRA_TOKEN="ovk_..."
```

A reverse proxy in front of the panel changes the public scheme and host, not the path after `<secret-path>`. If the panel sits behind a proxy, use the public HTTPS address of the proxy.

## Sign in with a token

Create a token on **Settings → API**. Send its secret in the `Authorization` header:

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/auth/me"
```

A token request needs no CSRF header. When the header is present, the panel ignores the browser cookie, so a bad token cannot fall back to a signed-in session.

A token acts as the account that created it. A **Full access** token uses the account's rights as they are at that moment. A **Custom** token carries only the permissions chosen when it was created, and never more than the account has now. If the account loses a permission later, the token loses it too.

A custom token is never the owner, even when the owner created it. It cannot call owner-only endpoints. A full token of an owner keeps the owner's rights, except for the session-only actions below.

## Requests and responses

Send and receive JSON. Set `Content-Type: application/json` when you send a body. Paths and field names are case-sensitive.

Two units appear everywhere:

- Traffic is in bytes: `trafficLimit`, `usedUp`, `usedDown`, `bytes`.
- Times are Unix seconds: `expireAt`, `createdAt`, `lastOnlineAt`, `from`, `to`, `t`.

An empty traffic limit (`0`) means unlimited. An end date of `0` means no end date.

## Errors

A failed request returns a JSON object:

```json
{
  "error": "a client with this name already exists",
  "field": "name"
}
```

`error` is a sentence for the operator. `field` names the request field that was wrong. `code` is present when a program can act on the reason, and `params` carries details for it:

```json
{
  "error": "this API token is not allowed from your address",
  "code": "token_ip",
  "params": { "ip": "203.0.113.9" }
}
```

| Status | Meaning |
|---|---|
| `200` | The request worked. |
| `201` | Something was created. |
| `202` | A job started; poll the resource or the list for the result. |
| `204` | The request worked and has no body. |
| `400` | The body or a field is not valid. Check `field`. |
| `401` | No valid session or token. |
| `402` | The licence, the traffic pool or an account limit refuses the change. |
| `403` | The account or the token may not do this. |
| `404` | No such record, or it is outside the account's reach. |
| `409` | A conflict, such as a duplicate name or an unsupported downgrade. |
| `429` | Too many failed attempts; wait and retry. |
| `500` | The panel failed to finish the request. |
| `502` | Telegram could not be reached during a backup request. |

### Token error codes

| `code` | What it means | What to do |
|---|---|---|
| `token_invalid` | The header is missing `Bearer`, the secret does not start with `ovk_`, or no token matches it. | Check the secret and that the token was not revoked. |
| `token_expired` | The token passed its expiry date. | Create a new token. |
| `token_ip` | The request came from an address outside **Allowed IPs**. `params.ip` has the address the panel saw. | Call from an allowed address, or make a new token with the right list. |
| `token_forbidden` | The endpoint is session-only. | Sign in to the panel and use the web app. |
| `account_blocked` | The account behind the token is switched off, expired or out of traffic. `params.reason` says which. | Ask the panel owner to top up or extend the account. |
| `token_limit` | The account already holds 25 API tokens. | Revoke one token first. |

A request with a token the account no longer has permission for returns `403` without a code. The same happens when a custom token was not given that permission.

## What a token cannot do

These endpoints act on the panel itself or on the signed-in browser, and refuse every token with `403` and `token_forbidden`:

- Signing out of the panel (`POST auth/logout`).
- All of `account/`: password, two-factor setup and recovery, signed-in sessions, and your own tokens.
- An owner listing or revoking another account's tokens, setting another account's password, or resetting another account's second factor.
- Removing a protocol package from a node (`DELETE nodes/{id}/protocols/{kind}`).
- Changing the panel's listen address, base path or TLS files, and changing its certificate.
- Restoring a backup, from an upload or from Telegram.

A custom token also cannot call owner-only endpoints: settings, accounts, roles, backup download and the rest of the panel's own administration. Only a full token made by the owner keeps those rights.

## Use HTTPS

Send tokens over HTTPS. A token is a password for the account: anyone who reads it in transit can use it until it is revoked or expires. If the panel is on plain HTTP, put it behind an HTTPS reverse proxy before you connect a bot from outside the server.

## OpenAPI document

The same API is described in an OpenAPI 3.1 document:

- The copy served with these docs: [openapi.json](/openapi.json).
- The exact copy for a running panel: `<base>/api/openapi.json`, where `<base>` is the panel address and secret path.

See [OpenAPI document](/api/openapi) for importing it into Postman, Insomnia or Bruno, and for generating a client.

## Related pages

- [API tokens](/api/tokens): create, scope, expire and revoke a token.
- [Quickstart](/api/quickstart): the first calls in curl, Python and Node.
- [A shop bot](/api/shop-bot): a complete sales-bot recipe.
- [Endpoint reference](/api/reference/): every endpoint, its permission and its body.
