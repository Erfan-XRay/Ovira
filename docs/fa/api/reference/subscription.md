# لینک‌های اشتراک

لینک اشتراک آدرسی است که کاربر باز می‌کند تا طرح و پروفایل‌هایش را ببیند. عمومی است: تنها ورودش توکن داخل لینک است. این مسیرها همان صفحه، داده‌هایش، نمودار مصرف و فایل‌های پروفایل، QR و WireGuard پشت آن هستند.

مسیر با **مسیر اشتراک** پنل شروع می‌شود، که در **تنظیمات → دسترسی پنل** تنظیم می‌شود. بخش دوم توکن اشتراک کاربر است که در `subUrl` او هم هست. مسیر مخفی پنل جزو لینک اشتراک نیست.

```text
https://panel.example.com/<subscription-path>/<client-token>/
```

مثال‌ها از `$SUB` برای همین پیشوند استفاده می‌کنند:

```bash
export SUB="https://panel.example.com/sub/6f2a..."
```

این مسیرها هدر `Authorization` نمی‌خواهند. برای توکن ناشناخته `404` و بعد از حدس‌های ناموفق زیاد `429` برمی‌گردانند. ترافیک با بایت و زمان با ثانیهٔ یونیکس است.

## صفحهٔ اشتراک

<Endpoint method="GET" path="/{subPath}/{token}" perm="public" :token="null" />

صفحهٔ HTML کاربر را برمی‌گرداند. کلاینت VPNی که خودش را کاربر OpenVPN معرفی کند پروفایل آماده می‌گیرد، و `?format=ovpn` یا `?format=raw` مستقیم پروفایل می‌خواهد.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `subPath` | path | string | مسیر اشتراک پنل. |
| `token` | path | string | توکن اشتراک کاربر. |
| `format` | query | string | `ovpn` یا `raw` به‌جای صفحه فایل پروفایل را می‌دهد. |

```bash
curl -sS "$SUB/"
curl -sS -o client.ovpn "$SUB/?format=ovpn"
```

```json
{ "error": "not found" }
```

خطای بالا برای توکن ناشناخته است؛ توکن معتبر HTML یا پروفایل OpenVPN می‌دهد.

## داده‌های اشتراک

<Endpoint method="GET" path="/{subPath}/{token}/info" perm="public" :token="null" />

مصرف، پروفایل‌ها، سرورها، تنظیمات صفحه و زبانه‌های پروتکل کاربر را برمی‌گرداند.

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

`username` و `password` وقتی سروری رمز می‌خواهد حاضرند. تنظیمات صفحه همان‌های **تنظیمات → صفحهٔ اشتراک** هستند.

## نمودار مصرف

<Endpoint method="GET" path="/{subPath}/{token}/usage" perm="public" :token="null" />

نقاط ترافیک کاربر را برمی‌گرداند.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `subPath` | path | string | مسیر اشتراک پنل. |
| `token` | path | string | توکن اشتراک کاربر. |
| `range` | query | string | `24h`، `7d`، `30d` یا `90d`. پیش‌فرض `30d`. |
| `tz` | query | integer | اختلاف زمانی کاربر با UTC به دقیقه، ۸۴۰- تا ۸۴۰. پیش‌فرض ۰. |

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

## کد QR لینک

<Endpoint method="GET" path="/{subPath}/{token}/qr" perm="public" :token="null" />

یک PNG ۳۶۰ پیکسلی از لینک اشتراک برمی‌گرداند.

```bash
curl -sS -o subscription.png "$SUB/qr"
```

`404` یعنی چنین توکنی نیست.

## کد QR سرور OpenConnect

<Endpoint method="GET" path="/{subPath}/{token}/qr/{key}" perm="public" :token="null" />

یک PNG ۳۶۰ پیکسلی از آدرس اتصال یک سرور OpenConnect برمی‌گرداند. پارامتر مسیر `key` کلید سرور از `SubInfo.openconnect` است.

```bash
curl -sS -o openconnect.png "$SUB/qr/21-3"
```

`404` یعنی چنین توکن یا سرور OpenConnectی نیست.

## پیکربندی WireGuard

<Endpoint method="GET" path="/{subPath}/{token}/wireguard/{slot}/{key}/{format}" perm="public" :token="null" />

یک پیکربندی WireGuard برای یک جایگاه دستگاه برمی‌گرداند.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `subPath` | path | string | مسیر اشتراک پنل. |
| `token` | path | string | توکن اشتراک کاربر. |
| `slot` | path | integer | جایگاه دستگاه، از ۱ تا سقف دستگاه کاربر. |
| `key` | path | string | کلید سرور از `SubInfo.wireguard`. |
| `format` | path | string | `config.conf` یا `qr`. |

```bash
curl -sS -o wg.conf "$SUB/wireguard/1/21-3/config.conf"
```

`config.conf` فایل را با `application/octet-stream` می‌دهد؛ `qr` یک PNG. `404` یعنی چنین توکن، جایگاه، سرور یا قالبی نیست.

## فایل پروفایل

<Endpoint method="GET" path="/{subPath}/{token}/profile/{file}" perm="public" :token="null" />

یک پروفایل OpenVPN دانلود می‌کند. پارامتر مسیر `file` کلید پروفایل با حداکثر ۲۴ نویسه است، با یا بدون `.ovpn`.

```bash
curl -sS -o client.ovpn "$SUB/profile/12-3.ovpn"
```

پاسخ `application/x-openvpn-profile` است. `404` یعنی چنین توکن یا پروفایلی نیست.

## صفحه‌های مرتبط

- [صفحهٔ اشتراک](/fa/use/subscription-page): تنظیمات و تم‌های صفحه.
- [کاربران](/fa/api/reference/clients): کاربری که `subUrl` از اوست.
- [WireGuard و AmneziaWG](/fa/protocols/wireguard): محتوای پیکربندی دانلودی.
- [نمای کلی API](/fa/api/): شکل مشترک خطا.
