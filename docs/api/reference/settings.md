# Panel settings

These endpoints read the panel's overview, host statistics and audit log, change its settings and certificate, download and restore backups, send backups to Telegram, and check for updates. Times are Unix seconds and traffic is bytes.

Settings, backup and TLS are owner-only. A custom token cannot call them; a full token made by the owner can, except for the session-only changes. Updates and audit need an account that sees every client (`staff`: the owner, or `clients.view` for all clients).

## Overview

<Endpoint method="GET" path="/api/overview" perm="any" :token="true" />

Returns dashboard counts, traffic series, clients needing attention and recent activity. The account's plan, inbounds and host statistics are included only when its permissions allow them.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `tz` | query | integer | Viewer's offset from UTC in minutes, -840 to 840, so day buckets start at local midnight. Default 0. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/overview?tz=210"
```

```json
{
  "clients": {
    "all": 120,
    "active": 98,
    "online": 31,
    "expiring": 7,
    "limited": 3,
    "expired": 12,
    "disabled": 7,
    "pending": 4
  },
  "sessions": 31,
  "throughput": { "up": 1820000.5, "down": 9120000.2 },
  "hourly": [{ "t": 1795912800, "up": 1073741824, "down": 5368709120 }],
  "daily": [{ "t": 1795826400, "up": 21474836480, "down": 107374182400 }],
  "top": [{ "clientId": 119, "name": "ali-02", "up": 1073741824, "down": 6442450944 }],
  "attention": [
    { "id": 118, "name": "ali-01", "reason": "expires", "expireAt": 1796000000, "used": 7516192768, "limit": 53687091200 }
  ],
  "attentionTotal": 1,
  "publicHost": "panel.example.com"
}
```

The response also has a `license` object that the panel uses on its License page. Its fields are internal, may change, and are not part of this API.

## Host statistics

<Endpoint method="GET" path="/api/system" perm="nodes.view" :token="true" />

Returns CPU, memory, disk, network rates and load of the panel host. The panel samples at most every two seconds.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/system"
```

```json
{
  "hostname": "panel",
  "os": "Ubuntu 24.04",
  "cpus": 4,
  "cpu": 12.5,
  "load1": 0.42,
  "memTotal": 8589934592,
  "memUsed": 3221225472,
  "diskTotal": 107374182400,
  "diskUsed": 19327352832,
  "netRx": 1200000.5,
  "netTx": 840000.2,
  "uptime": 864000,
  "goroutines": 64
}
```

## Read settings

<Endpoint method="GET" path="/api/settings" perm="owner" :token="true" />

Returns the saved settings, the panel configuration on disk, the values running now, and the host and version facts.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/settings"
```

```json
{
  "settings": {
    "publicHost": "panel.example.com",
    "brandName": "Ovira",
    "defaultLocale": "en",
    "expiryWarnDays": 3,
    "trafficWarnPct": 80,
    "adminSessionHours": 12
  },
  "panel": { "listen": ":2053", "basePath": "/ovira-7f3c/", "subPath": "sub" },
  "running": { "listen": ":2053", "basePath": "/ovira-7f3c/", "subPath": "sub" },
  "machineId": "...",
  "system": "Ubuntu",
  "openvpn": "2.6.12",
  "version": "0.9.9-beta.6",
  "dataDir": "/var/lib/ovira"
}
```

## Change settings

<Endpoint method="PUT" path="/api/settings" perm="owner" :token="true" />

Sends the settings object. A field you leave out keeps its saved value.

| Field | Type | Meaning |
|---|---|---|
| `publicHost` | string | Address written into client profiles. Empty uses the request's host. |
| `subBaseUrl` | string | Absolute origin for subscription links. Empty uses the request's origin. |
| `brandName` | string | Name shown on subscription pages. |
| `supportUrl` | string | Support link shown to clients. |
| `supportLabel` | string | Text of the support link. |
| `channelUrl` | string | Channel link shown beside support. |
| `panelAccent` | string | Accent preset of the admin panel. |
| `subTheme` | string | `night`, `aurora` or `pop`. |
| `subAccent` | string | Accent colour as `#rrggbb`; empty uses the theme's colour. |
| `subProtocols` | object[] | Tab order, names, notes and apps of the subscription page. |
| `defaultLocale` | string | `en` or `fa`. |
| `expiryWarnDays` | integer | Days before expiry that need attention. |
| `trafficWarnPct` | integer | Used-traffic percentage that needs attention. |
| `usageRetainDays` | integer | Days of hourly traffic kept. |
| `sessionRetainDays` | integer | Days of closed sessions kept. |
| `auditRetainDays` | integer | Days of audit entries kept. |
| `adminSessionHours` | integer | Idle timeout of panel sign-ins, in hours. |
| `clientNamePrefix` | string | Suggested prefix for bulk client creation. |
| `updateChannel` | string | `stable` or `beta`. |
| `autoUpdate` | string | `off`, `notify` or `auto`. |
| `autoUpdateHour` | integer | Local hour for automatic installs. |
| `updateNodes` | boolean | Update nodes together with the panel. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/settings" \
  -d '{"publicHost":"panel.example.com","expiryWarnDays":5,"trafficWarnPct":85,"defaultLocale":"en"}'
```

The answer is the saved settings. `400` names the bad field.

The `subProtocols` array holds one object per tab on the subscription page:

| Field | Type | Meaning |
|---|---|---|
| `key` | string | `openvpn`, `wireguard`, `amnezia` or `openconnect`. |
| `hidden` | boolean | Hide the tab. |
| `label` | string | Tab name; empty uses the default. |
| `note` | string | Plain text at the top of the tab, at most 500 characters. |
| `customApps` | boolean | Use `apps` instead of the built-in app suggestions. |
| `apps` | object | `android`, `ios` and `desktop`, each an array of `{ "name": "...", "url": "..." }`. |

## Change the panel address

<Endpoint method="PUT" path="/api/settings/panel" perm="owner" :token="false" />

Session only. Changes the listen address, secret path, subscription path or TLS files. It applies on restart.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `listen` | string | yes | Address the panel listens on, for example `:2053`. |
| `basePath` | string | no | Secret path in front of the panel API. |
| `subPath` | string | no | Path of the public subscription links. |
| `tlsCert` | string | no | Certificate file. Empty means plain HTTP. |
| `tlsKey` | string | no | Key file of `tlsCert`. |
| `trustProxy` | boolean | no | Take the client address and scheme from `X-Forwarded-*` headers. |

```bash
curl -sS -b cookies.txt -X PUT "$BASE/settings/panel" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"listen":":2053","basePath":"/ovira-7f3c/","subPath":"sub","tlsCert":"","tlsKey":"","trustProxy":true}'
```

```json
{
  "panel": { "listen": ":2053", "basePath": "/ovira-7f3c/", "subPath": "sub" },
  "restartRequired": true
}
```

`400` means a value is not valid or a TLS file is missing.

## Restart the panel

<Endpoint method="POST" path="/api/settings/restart" perm="owner" :token="true" />

Schedules a restart so saved panel changes apply. The panel stops answering shortly.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/settings/restart"
```

```json
{
  "ok": true,
  "panel": { "listen": ":2053", "basePath": "/ovira-7f3c/", "subPath": "sub" }
}
```

`400` means restart is not available in this mode. VPN connections are not affected.

## Read the certificate

<Endpoint method="GET" path="/api/settings/tls" perm="owner" :token="true" />

Returns the certificate the panel serves, whether HTTPS is on, and the address written into client profiles.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/settings/tls"
```

```json
{
  "cert": {
    "mode": "domain",
    "domain": "panel.example.com",
    "email": "admin@example.com",
    "subject": "panel.example.com",
    "issuer": "Let's Encrypt",
    "notAfter": 1801000000
  },
  "serving": true,
  "publicHost": "panel.example.com"
}
```

## Change the certificate

<Endpoint method="PUT" path="/api/settings/tls" perm="owner" :token="false" />

Session only. Gets a Let's Encrypt certificate for a domain or an IP, or turns HTTPS off. The new certificate applies on restart.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `mode` | string | yes | `domain`, `ip` or `none`. |
| `domain` | string | for `domain` | The name to certify. For `ip`, it defaults to the public address. |
| `email` | string | no | Contact address of the ACME account. |

```bash
curl -sS -b cookies.txt -X PUT "$BASE/settings/tls" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"mode":"domain","domain":"panel.example.com","email":"admin@example.com"}'
```

```json
{
  "cert": {
    "mode": "domain",
    "domain": "panel.example.com",
    "subject": "panel.example.com",
    "issuer": "Let's Encrypt",
    "notAfter": 1801000000
  },
  "restartRequired": true
}
```

`400` means the mode is not valid or the certificate could not be issued.

## Download a backup

<Endpoint method="GET" path="/api/backup" perm="owner" :token="true" />

Returns a consistent SQLite snapshot of the panel database as `application/vnd.sqlite3`.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o ovira-backup.db "$BASE/backup"
```

Keep the file private: it contains credentials and client data.

## Restore a backup

<Endpoint method="POST" path="/api/backup/restore" perm="owner" :token="false" />

Session only. Uploads a `.db` or `.db.gz` backup of an Ovira panel. The backup is staged and replaces the database on the next restart.

```bash
curl -sS -b cookies.txt -X POST "$BASE/backup/restore" \
  -H "X-CSRF-Token: $CSRF" \
  -F "file=@ovira-backup.db"
```

```json
{ "ok": true, "restartRequired": true }
```

`400` means the upload is not an Ovira backup.

## Read Telegram backup settings

<Endpoint method="GET" path="/api/backup/telegram" perm="owner" :token="true" />

Returns the bot settings without the token, the schedule, and the backups remembered in the chat.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/backup/telegram"
```

```json
{
  "enabled": true,
  "hasToken": true,
  "chatId": "-1001234567890",
  "intervalHours": 24,
  "proxy": "",
  "lastAt": 1795830000,
  "lastError": "",
  "lastErrorAt": 0,
  "nextAt": 1795916400,
  "sending": false,
  "entries": [
    {
      "messageId": 812,
      "fileId": "BQAC...",
      "fileName": "ovira-20261102.db.gz",
      "size": 4194304,
      "at": 1795830000
    }
  ]
}
```

## Save Telegram backup settings

<Endpoint method="PUT" path="/api/backup/telegram" perm="owner" :token="true" />

| Field | Type | Meaning |
|---|---|---|
| `enabled` | boolean | Send scheduled backups. |
| `token` | string | Bot token from `@BotFather`. Empty keeps the saved one. |
| `chatId` | string | Numeric chat id that receives the backups. |
| `intervalHours` | integer | Hours between backups, 1-168. `0` means 24. |
| `proxy` | string | `http`, `https` or `socks5` proxy URL to reach the Bot API. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/backup/telegram" \
  -d '{"enabled":true,"chatId":"-1001234567890","intervalHours":24,"proxy":""}'
```

The answer is the saved state. `400` means the bot token or chat is not valid.

## List chats the bot has seen

<Endpoint method="POST" path="/api/backup/telegram/chats" perm="owner" :token="true" />

Lists the chats the bot can post in. The body is optional.

| Field | Type | Meaning |
|---|---|---|
| `token` | string | Bot token to look up. Empty uses the saved one. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/backup/telegram/chats" \
  -d '{}'
```

```json
{
  "chats": [
    { "id": "-1001234567890", "title": "Ovira backups", "type": "supergroup" }
  ]
}
```

`400` means no bot token is saved or given. `502` means Telegram could not be reached.

## Send a backup now

<Endpoint method="POST" path="/api/backup/telegram/send" perm="owner" :token="true" />

Sends a backup to the saved chat immediately.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/backup/telegram/send"
```

```json
{
  "ok": true,
  "entry": {
    "messageId": 813,
    "fileId": "BQAC...",
    "fileName": "ovira-20261102.db.gz",
    "size": 4194304,
    "at": 1795919000
  },
  "state": { "sending": false, "lastAt": 1795919000 }
}
```

`400` means backups are not available or the send failed. `409` means a send is already running.

## Restore from Telegram

<Endpoint method="POST" path="/api/backup/telegram/restore" perm="owner" :token="false" />

Session only. Restores a backup the bot sent to the chat. The file is staged and replaces the database on the next restart.

| Field | Type | Required | Meaning |
|---|---|---|---|
| `fileId` | string | yes | File id of a backup the bot sent to the chat. |

```bash
curl -sS -b cookies.txt -X POST "$BASE/backup/telegram/restore" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"fileId":"BQAC..."}'
```

```json
{ "ok": true, "restartRequired": true }
```

`400` means the file id is not a backup of this panel.

## Read the update state

<Endpoint method="GET" path="/api/updates" perm="staff" :token="true" />

Returns the panel's version, channel, automatic setting and known releases.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/updates"
```

```json
{
  "current": "0.9.9-beta.6",
  "channel": "stable",
  "auto": "notify",
  "autoHour": 4,
  "latest": null,
  "newer": [],
  "recent": [],
  "checkedAt": 1795919000,
  "timezone": "Asia/Tehran"
}
```

## Check for a newer release

<Endpoint method="POST" path="/api/updates/check" perm="staff" :token="true" />

Asks the update server for a newer release and returns the update state after checking.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/updates/check"
```

The answer is an update state with `checkedAt` set. Installing an update is a session-only panel action and is not part of this API.

## Read the audit log

<Endpoint method="GET" path="/api/audit" perm="staff" :token="true" />

Returns up to 100 audit entries, newest first.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `before` | query | integer | Only entries with a lower id. `0` or absent starts from the newest. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/audit?before=1200"
```

```json
[
  {
    "id": 1199,
    "adminId": 7,
    "adminName": "shop",
    "action": "client.create",
    "target": "ali-02",
    "detail": "",
    "ip": "203.0.113.9",
    "at": 1795919000
  }
]
```

Use the last `id` as the next `before` cursor.

## Related pages

- [Settings](/use/settings): the panel page and its fields.
- [Back up and restore](/use/backup): what a backup holds.
- [Activity log](/use/audit): the actions an entry can name.
- [API overview](/api/): the shared error shape.
