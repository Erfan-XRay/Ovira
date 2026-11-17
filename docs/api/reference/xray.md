# Xray

Xray inbounds are ordinary inbounds with `kind: "xray"`, so they are created, listed and changed with the [Inbounds](/api/reference/inbounds) endpoints. These endpoints add the scenario lists, the camouflage-site list, per-inbound helpers, client links and the proxy-app settings.

## Create an inbound

Send only a scenario. The server fills in the rest.

<Endpoint method="POST" path="/api/instances" perm="inbounds.manage" :token="true" />

```bash
curl -sS -X POST -H "Authorization: Bearer $OVIRA_TOKEN" -H "Content-Type: application/json" \
  -d '{"kind":"xray","name":"de-1","nodeId":3,"preset":"direct"}' "$BASE/instances"
```

`preset` is one of `direct`, `cdn`, `relay`, `vmess-classic`, `trojan`, `shadowsocks` or `manual`. `GET xray/presets` says which extra fields a scenario needs.

## Routes

| Method and path | Permission | What it does |
|---|---|---|
| `GET /api/xray/presets` | `inbounds.view` | The scenarios and what each needs. |
| `GET /api/xray/combos` | `inbounds.view` | The allowed protocol, transport and security combinations. |
| `GET /api/xray/sni` | `inbounds.view` | The list of camouflage sites. |
| `POST /api/xray/sni/test` | `inbounds.manage` | Test one site. |
| `POST /api/xray/sni/scan` | `inbounds.manage` | Start a search for good sites. Returns a job. |
| `GET /api/xray/sni/jobs/{job}` | `inbounds.manage` | The state and result of a job. |
| `POST /api/instances/{id}/xray/reality-keys` | `inbounds.manage` | Make new keys for an inbound. |
| `GET /api/instances/{id}/xray/proxy-check` | `inbounds.manage` | Check an inbound behind a relay. |
| `POST /api/instances/{id}/xray/sni/replace` | `inbounds.manage` | Replace an inbound's camouflage site. |
| `POST /api/instances/{id}/xray/certificate` | `inbounds.manage` | Retry a certificate. |
| `GET /api/clients/{id}/xray` | `clients.view` | A client's Xray links. |
| `GET /api/clients/{id}/xray/{instance}/qr` | `clients.view` | The QR code of one link. |
| `POST /api/clients/{id}/xray/rotate` | `clients.edit` | Replace a client's Xray links. |
| `GET` and `PUT /api/settings/sub-apps` | owner | The proxy apps shown on subscription pages. |

The owner can also set the proxy apps per account with `/api/admins/{id}/sub-apps`, and an account with `subdomains.manage` can set its own with `/api/account/sub-apps`.
