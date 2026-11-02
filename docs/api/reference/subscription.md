# Subscription links

A subscription link is the address a client opens to see their plan and download a profile. It is public: the token in the link is the only sign-in. These endpoints are the page, its data, the usage chart and the profile, QR and WireGuard files behind it.

The path starts with the panel's **Subscription path**, set on **Settings → Panel access**. The second part is the client's subscription token, which is also in the client's `subUrl`. The panel's secret base path is not part of a subscription link.

```text
https://panel.example.com/<subscription-path>/<client-token>/
```

The examples use `$SUB` for that prefix:

```bash
export SUB="https://panel.example.com/sub/6f2a..."
```

These endpoints need no `Authorization` header. They return `404` for an unknown token and `429` after too many failed guesses. Traffic is bytes and times are Unix seconds.

## The subscription page

<Endpoint method="GET" path="/{subPath}/{token}" perm="public" :token="null" />

Returns the HTML page for the client. A VPN client that identifies itself as an OpenVPN user agent gets a ready-made profile instead, and `?format=ovpn` or `?format=raw` asks for the profile directly.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `subPath` | path | string | The panel's subscription path. |
| `token` | path | string | The client's subscription token. |
| `format` | query | string | `ovpn` or `raw` returns the profile file instead of the page. |

```bash
curl -sS "$SUB/"
curl -sS -o client.ovpn "$SUB/?format=ovpn"
```

```json
{ "error": "not found" }
```

The error above is for an unknown token; a valid token returns HTML or an OpenVPN profile.

## Subscription data

<Endpoint method="GET" path="/{subPath}/{token}/info" perm="public" :token="null" />

Returns the client's usage, profiles, servers, page settings and protocol tabs.

```bash
curl -sS "$SUB/info"
```

```json
{
  "name": "ali-02",
  "status": "active",
  "up": 1073741824,
  "down": 6442450944,
  "used": 7516192768,
  "limit": 53687091200,
  "expireAt": 1796000000,
  "expireAfterDays": 0,
  "pending": false,
  "firstUsedAt": 1793400000,
  "online": 1,
  "maxDevices": 2,
  "resetStrategy": "none",
  "lastResetAt": 0,
  "lastOnlineAt": 1795918000,
  "createdAt": 1793400000,
  "profiles": [
    {
      "key": "12-3",
      "name": "udp1194",
      "node": "",
      "label": "",
      "proto": "udp",
      "port": 1194,
      "ratio": 1,
      "description": "",
      "authMode": "cert",
      "file": "12-3.ovpn"
    }
  ],
  "openconnect": [],
  "wireguard": [],
  "combined": true,
  "brand": "Ovira",
  "supportUrl": "",
  "supportLabel": "",
  "channelUrl": "",
  "theme": "aurora",
  "accent": "",
  "protocols": [],
  "locale": "en",
  "subUrl": "https://panel.example.com/sub/6f2a.../",
  "serverTime": 1795919000
}
```

`username` and `password` are present when a server needs a password. The page settings are the ones from **Settings → Subscription page**.

## Usage chart

<Endpoint method="GET" path="/{subPath}/{token}/usage" perm="public" :token="null" />

Returns traffic points for the client.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `subPath` | path | string | The panel's subscription path. |
| `token` | path | string | The client's subscription token. |
| `range` | query | string | `24h`, `7d`, `30d` or `90d`. Default `30d`. |
| `tz` | query | integer | Viewer's offset from UTC in minutes, -840 to 840. Default 0. |

```bash
curl -sS "$SUB/usage?range=7d&tz=210"
```

```json
{
  "points": [
    { "t": 1795912800, "up": 734003200, "down": 4294967296 }
  ],
  "from": 1795312800,
  "to": 1795999200,
  "bucket": 86400,
  "offset": 12600
}
```

## Link QR code

<Endpoint method="GET" path="/{subPath}/{token}/qr" perm="public" :token="null" />

Returns a 360-pixel PNG QR code of the subscription link.

```bash
curl -sS -o subscription.png "$SUB/qr"
```

`404` means no such token.

## OpenConnect QR code

<Endpoint method="GET" path="/{subPath}/{token}/qr/{key}" perm="public" :token="null" />

Returns a 360-pixel PNG QR code of one OpenConnect server's connect URL. Path parameter `key` is the server key from `SubInfo.openconnect`.

```bash
curl -sS -o openconnect.png "$SUB/qr/21-3"
```

`404` means no such token or OpenConnect server.

## WireGuard configuration

<Endpoint method="GET" path="/{subPath}/{token}/wireguard/{slot}/{key}/{format}" perm="public" :token="null" />

Returns one WireGuard configuration for a device slot.

| Parameter | In | Type | Meaning |
|---|---|---|---|
| `subPath` | path | string | The panel's subscription path. |
| `token` | path | string | The client's subscription token. |
| `slot` | path | integer | Device slot, from 1 up to the client's device cap. |
| `key` | path | string | Server key from `SubInfo.wireguard`. |
| `format` | path | string | `config.conf` or `qr`. |

```bash
curl -sS -o wg.conf "$SUB/wireguard/1/21-3/config.conf"
```

`config.conf` returns the file as `application/octet-stream`; `qr` returns a PNG. `404` means no such token, slot, server or format.

## Profile file

<Endpoint method="GET" path="/{subPath}/{token}/profile/{file}" perm="public" :token="null" />

Downloads one OpenVPN profile. Path parameter `file` is a profile key of at most 24 characters, with or without `.ovpn`.

```bash
curl -sS -o client.ovpn "$SUB/profile/12-3.ovpn"
```

The answer is `application/x-openvpn-profile`. `404` means no such token or profile.

## Related pages

- [The subscription page](/use/subscription-page): the page settings and themes.
- [Clients](/api/reference/clients): the client whose `subUrl` this is.
- [WireGuard and AmneziaWG](/protocols/wireguard): what the downloaded configuration contains.
- [API overview](/api/): the shared error shape.
