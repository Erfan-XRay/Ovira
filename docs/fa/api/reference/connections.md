# اتصال‌ها

اتصال یک نشست VPN باز یا تمام‌شده است. این مسیرها اتصال‌های باز، اتصال‌های تمام‌شده و بستن یک اتصال باز را پوشش می‌دهند. زمان با ثانیهٔ یونیکس و ترافیک با بایت است.

## فهرست اتصال‌های باز

<Endpoint method="GET" path="/api/connections" perm="connections.view" :token="true" />

نشست‌های باز قابل مشاهده برای حساب و سقف دستگاهشان را برمی‌گرداند.

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

نشست WireGuard فیلد `lastHandshake` هم دارد. نشستی با `clientId: 0` از نام مشترکی آمده که پنل نمی‌شناسد.

## تاریخچهٔ اتصال‌ها

<Endpoint method="GET" path="/api/connections/history" perm="connections.view" :token="true" />

نشست‌های بسته را از جدید به قدیم برمی‌گرداند.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `limit` | query | integer | چند نشست، ۱ تا ۱۰۰۰. مقدار دیگر یعنی ۲۰۰. |
| `client` | query | integer | فقط نشست‌های این کاربر؛ `0` همهٔ کاربران. |
| `q` | query | string | جست‌وجو در نام کاربر و آدرس. |
| `kind` | query | string | `openvpn`، `ocserv` یا `wireguard`. مقدار ناشناخته همهٔ پروتکل‌ها را نگه می‌دارد. |
| `node` | query | integer | فقط نشست‌های این نود. `0` همین سرور؛ نبودنش یعنی همهٔ نودها. |

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

## بستن یک اتصال

<Endpoint method="POST" path="/api/connections/kick" perm="connections.kick" :token="true" />

یک نشست باز را می‌بندد. `instanceId` و `cid` را از فهرست اتصال‌های باز بخوانید.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `instanceId` | integer | بله | اینباندی که اتصال رویش است. |
| `cid` | integer | بله | شناسهٔ اتصال در سطح پروتکل از `LiveSession.cid`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/connections/kick" \
  -d '{"instanceId":12,"cid":17}'
```

```json
{ "ok": true }
```

`404` یعنی اتصال قبلاً بسته شده یا خارج از دسترس حساب است. کاربر اگر طرحش اجازه بدهد می‌تواند فوراً دوباره وصل شود؛ برای جلوگیری از اتصال دوباره، کاربر را خاموش کنید. بستن یک یا همهٔ نشست‌ها مانع اتصال دوباره نمی‌شود.

## صفحه‌های مرتبط

- [کاربران](/fa/api/reference/clients): خاموش کردن کاربر یا بستن همهٔ نشست‌هایش.
- [اینباندها](/fa/api/reference/inbounds): اینباندی که نشست رویش اجرا می‌شود.
- [ترافیک، سهمیه و محدودیت‌ها](/fa/how/traffic): نحوهٔ حساب شدن نشست‌ها.
