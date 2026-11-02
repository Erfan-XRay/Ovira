# Auth and account

These endpoints read the panel's metadata, sign in and out, describe the current account, and change your own password, second factor, signed-in browsers and API tokens. Most are for the browser session; a token has no session and no CSRF value.

Times are Unix seconds. Token requests use `Authorization: Bearer`, need no CSRF header, and cannot call the session-only endpoints. A browser signs in with a cookie and sends `X-CSRF-Token` on every write.

## Panel metadata

<Endpoint method="GET" path="/api/meta" perm="public" :token="null" />

Returns the panel name, version, default language and sign-in options for the sign-in page.

```bash
curl -sS "$BASE/meta"
```

```json
{
  "version": "0.9.9-beta.6",
  "updatePending": false,
  "locale": "en",
  "brand": "Ovira",
  "panelAccent": "lime"
}
```

## The OpenAPI document

<Endpoint method="GET" path="/api/openapi.json" perm="public" :token="null" />

Returns this OpenAPI 3.1 document, with the running version in `info.version`.

```bash
curl -sS "$BASE/openapi.json"
```

## Sign in

<Endpoint method="POST" path="/api/auth/login" perm="public" :token="null" />

Signs a browser in and sets the session cookie. With two-factor sign-in on, the answer is a challenge instead of a session.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `username` | string | yes | Account username. |
| `password` | string | yes | Account password. |
| `remember` | boolean | no | Keep the browser signed in for 30 days instead of the idle timeout. |

```bash
curl -sS -c cookies.txt -X POST "$BASE/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"owner","password":"your-password","remember":false}'
```

```json
{
  "admin": { "id": 1, "username": "owner", "role": "owner" },
  "csrf": "csrf-value",
  "roleName": "Owner",
  "perms": { "clients.view": "all" }
}
```

Without a second factor, the answer is the `Me` object and the cookie. With one, the answer is:

```json
{ "mfa": true, "ticket": "ticket-value", "remember": false }
```

`401` means a wrong username or password. `403` means the account is blocked or the licence refuses it. `429` means too many failed attempts.

## Finish two-factor sign-in

<Endpoint method="POST" path="/api/auth/mfa" perm="public" :token="null" />

Finishes sign-in with a TOTP code or a recovery code.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `ticket` | string | yes | The ticket from `auth/login`. It lasts five minutes. |
| `code` | string | yes | A TOTP code or one recovery code. |
| `remember` | boolean | no | Keep the browser signed in for 30 days. |

```bash
curl -sS -c cookies.txt -X POST "$BASE/auth/mfa" \
  -H "Content-Type: application/json" \
  -d '{"ticket":"ticket-value","code":"123456"}'
```

The answer is the `Me` object and the session cookie. `401` means the code did not work or the ticket expired.

## Sign out

<Endpoint method="POST" path="/api/auth/logout" perm="any" :token="false" />

Signs the browser out and clears the cookie. Session only.

```bash
curl -sS -b cookies.txt -X POST "$BASE/auth/logout" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

## Who am I

<Endpoint method="GET" path="/api/auth/me" perm="any" :token="true" />

Returns the account behind the request, its role, effective permissions and limits, its plan, and the token when the request used one. For a browser, `csrf` holds the token to send on writes; for a token request it is empty.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/auth/me"
```

`401` means no valid session or token.

## My traffic pool

<Endpoint method="GET" path="/api/auth/usage" perm="any" :token="true" />

Returns the account's own current traffic pool. An owner always reads `0` for the limit and the end date.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/auth/usage"
```

```json
{
  "usedBytes": 82463372083,
  "trafficLimit": 1099511627776,
  "expireAt": 1796000000
}
```

## Change my password

<Endpoint method="POST" path="/api/account/password" perm="any" :token="false" />

Session only. Changes your password and signs out your other browsers.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `current` | string | yes | The password in use now. |
| `new` | string | yes | The new password, checked for strength. |

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/password" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"current":"old-password","new":"a-new-long-password"}'
```

```json
{ "ok": true }
```

`400` means the current password is wrong or the new one is not acceptable.

## Two-factor sign-in

All of these are session-only.

<Endpoint method="POST" path="/api/account/2fa/setup" perm="any" :token="false" />

Starts setup and returns the pending secret, its `otpauth://` URI and a PNG data URL for a QR code.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/2fa/setup" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{
  "secret": "JBSWY3DPEHPK3PXP",
  "uri": "otpauth://totp/Ovira:owner?secret=...",
  "qr": "data:image/png;base64,..."
}
```

`400` means two-factor sign-in is already on.

<Endpoint method="POST" path="/api/account/2fa/enable" perm="any" :token="false" />

Turns the second factor on. The body has one required field, `code`, from the authenticator app. The answer holds ten recovery codes, shown once.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/2fa/enable" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"code":"123456"}'
```

```json
{ "recoveryCodes": ["abcd-efgh", "ijkl-mnop"] }
```

`400` means setup was not started or the code did not match.

<Endpoint method="POST" path="/api/account/2fa/disable" perm="any" :token="false" />

Turns the second factor off. The body has one required field, `password`.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/2fa/disable" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"password":"your-password"}'
```

```json
{ "ok": true }
```

`400` means the password is wrong.

<Endpoint method="POST" path="/api/account/2fa/recovery" perm="any" :token="false" />

Replaces the recovery codes. The body has one required field, `password`. The answer holds the new codes, shown once.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/2fa/recovery" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"password":"your-password"}'
```

`400` means two-factor sign-in is off or the password is wrong.

## Signed-in browsers

<Endpoint method="GET" path="/api/account/sessions" perm="any" :token="false" />

Lists your sessions, newest activity first, with the current one marked. Session only.

```bash
curl -sS -b cookies.txt "$BASE/account/sessions"
```

```json
[
  {
    "id": "9f3a...",
    "createdAt": 1795800000,
    "expiresAt": 1796000000,
    "lastSeenAt": 1795919000,
    "ip": "203.0.113.9",
    "userAgent": "Mozilla/5.0 ...",
    "current": true,
    "ref": "9f3a2b7c8d1e4f60"
  }
]
```

<Endpoint method="DELETE" path="/api/account/sessions/{id}" perm="any" :token="false" />

Signs one browser out. Path parameter `id` is the session `ref`, or its id with at least 16 characters. Session only.

```bash
curl -sS -b cookies.txt -X DELETE "$BASE/account/sessions/9f3a2b7c8d1e4f60" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

`404` means no such session.

<Endpoint method="POST" path="/api/account/sessions/revoke-others" perm="any" :token="false" />

Signs out every browser except this one. Session only.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/sessions/revoke-others" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

## API tokens

These are session-only and are described in full on [API tokens](/api/tokens).

<Endpoint method="GET" path="/api/account/tokens" perm="any" :token="false" />

List your tokens.

<Endpoint method="POST" path="/api/account/tokens" perm="any" :token="false" />

Create a token.

<Endpoint method="DELETE" path="/api/account/tokens/{id}" perm="any" :token="false" />

Revoke one of your tokens.

<Endpoint method="GET" path="/api/admins/{id}/tokens" perm="owner" :token="false" />

Owner only. List one account's tokens.

<Endpoint method="DELETE" path="/api/admins/{id}/tokens/{tid}" perm="owner" :token="false" />

Owner only. Revoke one token of one account.

## Related pages

- [API tokens](/api/tokens): creating, scoping and revoking a token.
- [Panel accounts](/use/admins): the account page, password and second factor.
- [API overview](/api/): token errors and the session-only list.
- [Settings](/use/settings): where **My account** sits.
