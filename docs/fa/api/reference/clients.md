# کاربران

کاربر یک طرح است: سقف ترافیک، تاریخ پایان و سقف دستگاه. این مسیرها کاربران را فهرست، ایجاد، تغییر و مدیریت می‌کنند، مصرفشان را می‌خوانند، پروفایل و کد QR می‌دهند و دستگاه‌های WireGuard را مدیریت می‌کنند. نام کاربر در کل پنل یکتاست.

ترافیک با بایت و زمان با ثانیهٔ یونیکس است. `trafficLimit: 0` یعنی بی‌نهایت و `expireAt: 0` یعنی بدون تاریخ پایان.

## فهرست و جست‌وجوی کاربران

<Endpoint method="GET" path="/api/clients" perm="clients.view" :token="true" />

یک صفحهٔ کاربران و شمار هر دسته از فهرست فیلترشده را برمی‌گرداند. نماینده فقط کاربران خودش را می‌بیند.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `owner` | query | integer | فقط کاربران این مالک. برای حسابی که فقط کاربران خودش را می‌بیند نادیده گرفته می‌شود. |
| `q` | query | string | جست‌وجوی بدون حساسیت به بزرگی حرف در نام، یادداشت و تماس. |
| `status` | query | string | `all`، `active`، `online`، `expiring`، `limited`، `expired` یا `disabled`. پیش‌فرض `all`. |
| `group` | query | integer | فقط کاربران این گروه؛ `0` همهٔ گروه‌ها. |
| `sort` | query | string | `name`، `used`، `expire`، `online` یا `created`. پیش‌فرض `created`. |
| `order` | query | string | `asc` یا `desc`. پیش‌فرض `desc`. |
| `page` | query | integer | شمارهٔ صفحه، از ۱. پیش‌فرض ۱. |
| `size` | query | integer | اندازهٔ صفحه، ۱ تا ۵۰۰. مقدار دیگر یعنی ۵۰. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients?status=active&sort=expire&order=asc&size=25"
```

```json
{
  "items": [
    {
      "id": 118,
      "ownerId": 7,
      "name": "ali-01",
      "note": "",
      "contact": "@ali",
      "enabled": true,
      "trafficLimit": 53687091200,
      "usedUp": 1073741824,
      "usedDown": 6442450944,
      "expireAt": 1796000000,
      "expireAfterDays": 0,
      "firstUsedAt": 1793400000,
      "maxDevices": 2,
      "status": "active",
      "online": 1,
      "subUrl": "https://panel.example.com/sub/6f2a.../",
      "groups": [3]
    }
  ],
  "total": 1,
  "page": 1,
  "size": 25,
  "counts": {
    "all": 1,
    "active": 1,
    "online": 1,
    "expiring": 0,
    "limited": 0,
    "expired": 0,
    "disabled": 0
  }
}
```

## ساخت کاربر

<Endpoint method="POST" path="/api/clients" perm="clients.create" :token="true" />

یک کاربر می‌سازد و با `201` برمی‌گرداند. نام، نام کاربری OpenVPN هم هست.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `name` | string | بله | ۲ تا ۴۸ نویسهٔ ASCII؛ حروف لاتین، رقم، نقطه، خط تیره، زیرخط یا `@`، با حرف یا رقم در ابتدا. یکتا. |
| `note` | string | خیر | متن آزاد، حداکثر ۵۰۰ بایت UTF-8. |
| `contact` | string | خیر | راه تماس با کاربر، حداکثر ۱۲۰ بایت UTF-8. |
| `enabled` | boolean | خیر | `true` کاربر را روشن می‌کند. مقدار ارسال‌نشده یا `false` کاربر خاموش می‌سازد. |
| `password` | string | خیر | رمز VPN، ۴ تا ۶۴ نویسه بدون فاصله یا کوتیشن. خالی یعنی ساخت خودکار. |
| `trafficLimit` | integer | خیر | سقف ترافیک با بایت. `0` یعنی بی‌نهایت. |
| `expireAt` | integer | خیر | تاریخ پایان با ثانیهٔ یونیکس. `0` یعنی هرگز. |
| `expireAfterDays` | integer | خیر | عمر به روز از اولین اتصال، ۰ تا ۳۶۵۰. `0` یعنی بدون عمر. |
| `maxDevices` | integer | خیر | سقف دستگاه، ۰ تا ۱۰۰۰. `0` یعنی بی‌سقف. |
| `resetStrategy` | string | خیر | `none`، `daily`، `weekly` یا `monthly`. خالی یعنی `none`. |
| `staticIp` | string | خیر | IPv4 ثابت داخل محدودهٔ ثابت یک اینباند. خالی یعنی آدرس آزاد بعدی. |
| `instances` | integer[] | خیر | شناسهٔ اینباندهایی که کاربر می‌تواند استفاده کند. خالی یعنی هر اینباندی که حقش است. |
| `groups` | integer[] | خیر | شناسهٔ گروه‌ها. گروه، اینباندهایش را می‌دهد. |
| `ownerId` | integer | خیر | ساخت کاربر برای حساب دیگر. به `clients.create` برای همهٔ کاربران نیاز دارد. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/clients" \
  -d '{
    "name": "ali-02",
    "enabled": true,
    "trafficLimit": 53687091200,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3]
  }'
```

```json
{
  "id": 119,
  "ownerId": 7,
  "name": "ali-02",
  "enabled": true,
  "trafficLimit": 53687091200,
  "usedUp": 0,
  "usedDown": 0,
  "expireAt": 0,
  "expireAfterDays": 30,
  "maxDevices": 2,
  "status": "active",
  "subUrl": "https://panel.example.com/sub/9c41.../",
  "groups": [3]
}
```

`400` با `field` فیلد اشتباه را می‌گوید. `402` یعنی لایسنس یا سقف کاربر حساب ساخت را رد می‌کند.

## ساخت چند کاربر

<Endpoint method="POST" path="/api/clients/bulk" perm="clients.create" :token="true" />

کاربرانی با نام `prefix` و یک شماره می‌سازد. همه `plan` را دارند، همان شیء ساخت یک کاربر. `staticIp` و `password` در طرح نادیده گرفته می‌شوند.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `prefix` | string | بله | شروع هر نام. |
| `start` | integer | خیر | شمارهٔ اول؛ `0` از ۱ شروع می‌کند. |
| `count` | integer | بله | چند کاربر، ۱ تا ۵۰۰. |
| `plan` | object | بله | بدنهٔ کاربر بدون `name`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/clients/bulk" \
  -d '{"prefix":"ali-","start":1,"count":10,"plan":{"enabled":true,"trafficLimit":53687091200,"expireAfterDays":30,"maxDevices":2,"groups":[3]}}'
```

```json
{
  "items": [
    { "id": 120, "name": "ali-01", "status": "active" },
    { "id": 121, "name": "ali-02", "status": "active" }
  ],
  "error": "created 2 of 10: your account may own 100 clients"
}
```

`error` فقط وقتی می‌آید که کار زودتر متوقف شود. کاربران پیش از آن ساخته شده‌اند.

## یک کار روی چند کاربر

<Endpoint method="POST" path="/api/clients/bulk-action" perm="clients.edit" :token="true" />

یک کار را روی حداکثر ۱۰۰۰ کاربر انجام می‌دهد. توکن به دسترسی همان عملیات نیاز دارد، نه همهٔ دسترسی‌های این مسیر: `clients.reset` برای `reset`، `clients.kick` برای `kick`، `clients.delete` برای `delete` و `clients.edit` برای بقیه.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `ids` | integer[] | بله | ۱ تا ۱۰۰۰ شناسهٔ کاربر. |
| `action` | string | بله | `enable`، `disable`، `reset`، `extend`، `delete` یا `kick`. |
| `days` | integer | برای `extend` | روزهای اضافه. |
| `bytes` | integer | برای `extend` | بایت‌های ترافیک اضافه. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/clients/bulk-action" \
  -d '{"ids":[118,119],"action":"extend","days":30,"bytes":10737418240}'
```

```json
{ "done": 2, "failed": [] }
```

`failed` برای هر کاربری که تغییر نکرد، شناسهٔ کاربر یا پیام خطا دارد.

## خواندن یک کاربر

<Endpoint method="GET" path="/api/clients/{id}" perm="clients.view" :token="true" />

کاربر را با اتصال‌های باز، ۳۰ اتصال بستهٔ آخر، گواهی و پروفایل‌های قابل دانلود برمی‌گرداند. پارامتر مسیر `id` شناسهٔ کاربر است.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/clients/119"
```

```json
{
  "client": {
    "id": 119,
    "name": "ali-02",
    "status": "active",
    "trafficLimit": 53687091200,
    "usedUp": 0,
    "usedDown": 0,
    "expireAt": 0,
    "expireAfterDays": 30,
    "subUrl": "https://panel.example.com/sub/9c41.../"
  },
  "live": [],
  "history": [],
  "cert": {
    "subject": "ali-02",
    "serial": "3f9a...",
    "notBefore": 1793400000,
    "notAfter": 1825000000
  },
  "profiles": [
    {
      "key": "12-3",
      "instanceId": 12,
      "instance": "udp1194",
      "kind": "openvpn",
      "nodeId": 0,
      "node": "this server",
      "label": "",
      "host": "panel.example.com",
      "port": 1194,
      "proto": "udp",
      "authMode": "cert"
    }
  ]
}
```

`404` یعنی چنین کاربری نیست، یا خارج از دسترس حساب است.

## تغییر کاربر

<Endpoint method="PUT" path="/api/clients/{id}" perm="clients.edit" :token="true" />

همان فیلدهای ساخت را می‌فرستد. `password` خالی رمز فعلی را نگه می‌دارد. نبودن `groups` گروه‌های کاربر را تغییر نمی‌دهد. هر فیلد ارسال‌نشدهٔ دیگر مقدار صفر می‌گیرد، پس کاربر را بخوانید، فقط چیزی را که لازم است عوض کنید و کل بدنه را بفرستید. تغییر نام گواهی تازه صادر می‌کند و پروفایل‌های OpenVPN قدیمی را از کار می‌اندازد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/clients/119" \
  -d '{
    "name": "ali-02",
    "enabled": true,
    "trafficLimit": 107374182400,
    "expireAt": 1798675200,
    "maxDevices": 3,
    "groups": [3]
  }'
```

پاسخ کاربر تغییرکرده است. `400` فیلد اشتباه را می‌گوید؛ `404` یعنی برای این حساب در دسترس نیست.

## حذف کاربر

<Endpoint method="DELETE" path="/api/clients/{id}" perm="clients.delete" :token="true" />

کاربر را حذف، گواهی‌اش را باطل و اتصال‌هایش را همان لحظه می‌بندد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/clients/119"
```

```json
{ "ok": true }
```

## اجرای یک کار روی کاربر

<Endpoint method="POST" path="/api/clients/{id}/{action}" perm="clients.edit" :token="true" />

پارامتر مسیر `id` شناسهٔ کاربر است. `action` یکی از `enable`، `disable`، `reset`، `extend`، `reissue`، `rotate-sub` یا `kick` است.

توکن به دسترسی همان عملیات نیاز دارد، نه همهٔ دسترسی‌های این مسیر: `clients.reset` برای `reset`، `clients.kick` برای `kick` و `clients.edit` برای بقیه.

| کار | چه می‌کند | بدنه |
|---|---|---|
| `enable` | کاربر دوباره می‌تواند وصل شود. | ندارد |
| `disable` | کاربر را خاموش و اتصال‌هایش را می‌بندد. | ندارد |
| `reset` | مصرف آپلود و دانلود را صفر می‌کند. | ندارد |
| `extend` | روز و ترافیک اضافه می‌کند؛ در صورت تمایل مصرف را صفر می‌کند. | `days`، `bytes`، `resetUsage` |
| `reissue` | گواهی تازه صادر می‌کند. هر پروفایل OpenVPN که کاربر گرفته از کار می‌افتد. | ندارد |
| `rotate-sub` | توکن اشتراک را عوض می‌کند. `subUrl` قبلی از کار می‌افتد. | ندارد |
| `kick` | اتصال‌های باز کاربر را می‌بندد. | ندارد |

بدنهٔ `extend`:

| فیلد | نوع | معنی |
|---|---|---|
| `days` | integer | روزهای اضافه، ۰ تا ۳۶۵۰، از حالا یا تاریخ پایان فعلی، هر کدام دیرتر باشد. |
| `bytes` | integer | بایت‌هایی که به سقف اضافه می‌شود. وقتی سقف `0` باشد اثری ندارد. |
| `resetUsage` | boolean | مصرف را هم صفر می‌کند. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients/119/extend" \
  -d '{"days":30,"bytes":53687091200,"resetUsage":true}'
```

`days` فقط کاربری را عوض می‌کند که از قبل تاریخ پایان دارد، یا عمری دارد که هنوز شروع نشده. کاربر بدون تاریخ پایان و بدون عمر، بدون تاریخ می‌ماند.

```json
{
  "id": 119,
  "name": "ali-02",
  "enabled": true,
  "trafficLimit": 107374182400,
  "usedUp": 0,
  "usedDown": 0,
  "expireAt": 1798675200,
  "status": "active"
}
```

`400` فیلد بدنه را می‌گوید. `403` یعنی توکن دسترسی آن کار را ندارد. `404` یعنی چنین کاربر یا کاری نیست، یا کاربر خارج از دسترس حساب است.

## خواندن ترافیک در زمان

<Endpoint method="GET" path="/api/clients/{id}/usage" perm="clients.view" :token="true" />

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `id` | path | integer | شناسهٔ کاربر. |
| `range` | query | string | `24h`، `7d`، `30d` یا `90d`. پیش‌فرض `30d`. `24h` ساعتی و بقیه روزانه دسته‌بندی می‌شوند. |
| `tz` | query | integer | اختلاف زمانی کاربر با UTC به دقیقه، ۸۴۰- تا ۸۴۰، تا روزها از نیمه‌شب محلی شروع شوند. پیش‌فرض ۰. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients/119/usage?range=7d&tz=210"
```

```json
{
  "points": [
    { "t": 1795912800, "up": 734003200, "down": 4294967296 },
    { "t": 1795999200, "up": 104857600, "down": 524288000 }
  ],
  "from": 1795312800,
  "to": 1795999200,
  "bucket": 86400,
  "offset": 12600
}
```

## دانلود پروفایل

<Endpoint method="GET" path="/api/clients/{id}/profile" perm="clients.view" :token="true" />

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `id` | path | integer | شناسهٔ کاربر. |
| `key` | query | string | کلید پروفایل از `ClientDetail.profiles`. خالی یا `all` همهٔ سرورهای سازگار را یکی می‌کند. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o ali-02.ovpn "$BASE/clients/119/profile?key=12-3"
```

پاسخ یک فایل پروفایل OpenVPN است (`application/x-openvpn-profile`). `404` یعنی چنین کاربر یا پروفایلی نیست.

## کد QR اشتراک

<Endpoint method="GET" path="/api/clients/{id}/qr" perm="clients.view" :token="true" />

یک PNG ۳۲۰ پیکسلی از لینک اشتراک کاربر برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o ali-02.png "$BASE/clients/119/qr"
```

## دستگاه‌های WireGuard

این مسیرها حسابی می‌خواهند که همهٔ کاربران را ببیند (`staff`: مالک، یا حسابی با `clients.view` برای همهٔ کاربران). به مالک یک کاربر محدود نیستند.

<Endpoint method="GET" path="/api/clients/{id}/wireguard" perm="staff" :token="true" />

یک ردیف برای هر جایگاه دستگاه کاربر و اینباندهای WireGuard قابل استفاده را برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/clients/119/wireguard"
```

```json
{
  "devices": [
    {
      "slot": 1,
      "publicKey": "9f3a...",
      "lastHandshake": 1795915000,
      "endpoint": "203.0.113.9:51820",
      "instance": "wg51820",
      "instanceId": 21,
      "up": 104857600,
      "down": 734003200,
      "live": true
    }
  ],
  "servers": [
    { "key": "21-3", "instanceId": 21, "instance": "wg51820", "kind": "wireguard" }
  ]
}
```

<Endpoint method="POST" path="/api/clients/{id}/wireguard/{slot}/reset" perm="staff" :token="true" />

کلید یک جایگاه دستگاه را عوض می‌کند. پارامترهای مسیر شناسهٔ کاربر و شمارهٔ جایگاه، از ۱ تا سقف دستگاه کاربر، هستند. دستگاه قبلی دیگر وصل نمی‌شود.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X POST "$BASE/clients/119/wireguard/1/reset"
```

```json
{
  "slot": 1,
  "publicKey": "3b7c...",
  "createdAt": 1795919000
}
```

<Endpoint method="GET" path="/api/clients/{id}/wireguard/{slot}/{key}/{format}" perm="staff" :token="true" />

یک پیکربندی WireGuard را دانلود می‌کند. `slot` جایگاه دستگاه، `key` کلید پروفایل از فهرست سرورها و `format` یکی از `config.conf` یا `qr` است.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o wg.conf "$BASE/clients/119/wireguard/1/21-3/config.conf"
```

`config.conf` فایل را با `application/octet-stream` می‌دهد؛ `qr` یک PNG. `404` یعنی چنین کاربر، جایگاه، پروفایل یا قالبی نیست.

## صفحه‌های مرتبط

- [ربات فروش](/fa/api/shop-bot): جریان ساخت، تحویل و تمدید.
- [اتصال‌ها](/fa/api/reference/connections): اتصال‌های زندهٔ همین کاربر.
- [گروه‌ها](/fa/api/reference/groups): افزودن گروهی کاربران به گروه.
- [ترافیک، سهمیه و محدودیت‌ها](/fa/how/traffic): نحوهٔ شمارش و صفر شدن مصرف.
