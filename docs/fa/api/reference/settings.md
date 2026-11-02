# تنظیمات پنل

این مسیرها نمای کلی، آمار میزبان و گزارش فعالیت پنل را می‌خوانند، تنظیمات و گواهی را عوض می‌کنند، پشتیبان می‌گیرند و بازمی‌گردانند، پشتیبان را به Telegram می‌فرستند و به‌روزرسانی را بررسی می‌کنند. زمان با ثانیهٔ یونیکس و ترافیک با بایت است.

تنظیمات، پشتیبان و TLS مخصوص مالک‌اند. توکن سفارشی نمی‌تواند صدایشان بزند؛ توکن کاملِ مالک می‌تواند، جز تغییرهای مخصوص نشست. به‌روزرسانی و گزارش فعالیت حسابی را می‌خواهند که همهٔ کاربران را ببیند (`staff`: مالک، یا `clients.view` برای همه).

## نمای کلی

<Endpoint method="GET" path="/api/overview" perm="any" :token="true" />

شمار داشبورد، سری ترافیک، کاربران نیازمند توجه و فعالیت اخیر را برمی‌گرداند. طرح حساب، اینباندها و آمار میزبان فقط وقتی می‌آیند که دسترسی‌های حساب اجازه بدهند.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `tz` | query | integer | اختلاف زمانی کاربر با UTC به دقیقه، ۸۴۰- تا ۸۴۰، تا بازه‌های روزانه از نیمه‌شب محلی شروع شوند. پیش‌فرض ۰. |

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

پاسخ یک شیء `license` هم دارد که پنل در صفحهٔ لایسنس به کار می‌برد. فیلدهایش داخلی‌اند، ممکن است عوض شوند و جزو این API نیستند.

## آمار میزبان

<Endpoint method="GET" path="/api/system" perm="nodes.view" :token="true" />

CPU، حافظه، دیسک، نرخ شبکه و بار میزبان پنل را برمی‌گرداند. پنل حداکثر هر دو ثانیه یک‌بار نمونه می‌گیرد.

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

## خواندن تنظیمات

<Endpoint method="GET" path="/api/settings" perm="owner" :token="true" />

تنظیمات ذخیره‌شده، پیکربندی پنل روی دیسک، مقدارهای در حال اجرا و اطلاعات میزبان و نسخه را برمی‌گرداند.

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

## تغییر تنظیمات

<Endpoint method="PUT" path="/api/settings" perm="owner" :token="true" />

شیء تنظیمات را می‌فرستد. فیلدی که نمی‌فرستید مقدار ذخیره‌شده را نگه می‌دارد.

| فیلد | نوع | معنی |
|---|---|---|
| `publicHost` | string | آدرسی که در پروفایل کاربران نوشته می‌شود. خالی یعنی host درخواست. |
| `subBaseUrl` | string | مبدأ مطلق لینک‌های اشتراک. خالی یعنی origin درخواست. |
| `brandName` | string | نامی که در صفحه‌های اشتراک نشان داده می‌شود. |
| `supportUrl` | string | لینک پشتیبانی برای کاربران. |
| `supportLabel` | string | متن لینک پشتیبانی. |
| `channelUrl` | string | لینک کانال کنار پشتیبانی. |
| `panelAccent` | string | پیش‌تنظیم رنگ تأکید پنل مدیریت. |
| `subTheme` | string | `night`، `aurora` یا `pop`. |
| `subAccent` | string | رنگ تأکید به شکل `#rrggbb`؛ خالی یعنی رنگ تم. |
| `subProtocols` | object[] | ترتیب زبانه‌ها، نام، یادداشت و برنامه‌های صفحهٔ اشتراک. |
| `defaultLocale` | string | `en` یا `fa`. |
| `expiryWarnDays` | integer | چند روز پیش از پایان توجه لازم است. |
| `trafficWarnPct` | integer | درصد مصرفی که توجه لازم دارد. |
| `usageRetainDays` | integer | چند روز ترافیک ساعتی نگه داشته شود. |
| `sessionRetainDays` | integer | چند روز اتصال بسته نگه داشته شود. |
| `auditRetainDays` | integer | چند روز گزارش فعالیت نگه داشته شود. |
| `adminSessionHours` | integer | مهلت بی‌فعالیتی ورود پنل، به ساعت. |
| `clientNamePrefix` | string | پیشوند پیشنهادی ساخت گروهی کاربر. |
| `updateChannel` | string | `stable` یا `beta`. |
| `autoUpdate` | string | `off`، `notify` یا `auto`. |
| `autoUpdateHour` | integer | ساعت محلی نصب خودکار. |
| `updateNodes` | boolean | نودها همراه پنل به‌روز شوند. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/settings" \
  -d '{"publicHost":"panel.example.com","expiryWarnDays":5,"trafficWarnPct":85,"defaultLocale":"en"}'
```

پاسخ تنظیمات ذخیره‌شده است. `400` فیلد اشتباه را می‌گوید.

آرایهٔ `subProtocols` برای هر زبانهٔ صفحهٔ اشتراک یک شیء دارد:

| فیلد | نوع | معنی |
|---|---|---|
| `key` | string | `openvpn`، `wireguard`، `amnezia` یا `openconnect`. |
| `hidden` | boolean | زبانه پنهان شود. |
| `label` | string | نام زبانه؛ خالی یعنی پیش‌فرض. |
| `note` | string | متن سادهٔ بالای زبانه، حداکثر ۵۰۰ نویسه. |
| `customApps` | boolean | از `apps` به‌جای پیشنهادهای پیش‌فرض استفاده شود. |
| `apps` | object | `android`، `ios` و `desktop`، هر کدام آرایه‌ای از `{ "name": "...", "url": "..." }`. |

## تغییر آدرس پنل

<Endpoint method="PUT" path="/api/settings/panel" perm="owner" :token="false" />

مخصوص نشست. آدرس شنود، مسیر مخفی، مسیر اشتراک یا فایل‌های TLS را عوض می‌کند و پس از راه‌اندازی مجدد اعمال می‌شود.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `listen` | string | بله | آدرس شنود پنل، مثلاً `:2053`. |
| `basePath` | string | خیر | مسیر مخفی جلوی API پنل. |
| `subPath` | string | خیر | مسیر لینک‌های اشتراک عمومی. |
| `tlsCert` | string | خیر | فایل گواهی. خالی یعنی HTTP ساده. |
| `tlsKey` | string | خیر | فایل کلید `tlsCert`. |
| `trustProxy` | boolean | خیر | آدرس و scheme کاربر را از هدرهای `X-Forwarded-*` بگیر. |

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

`400` یعنی مقداری معتبر نیست یا فایل TLS نیست.

## راه‌اندازی مجدد پنل

<Endpoint method="POST" path="/api/settings/restart" perm="owner" :token="true" />

راه‌اندازی مجدد را زمان‌بندی می‌کند تا تغییرهای ذخیره‌شدهٔ پنل اعمال شوند. پنل کمی بعد پاسخ نمی‌دهد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/settings/restart"
```

```json
{
  "ok": true,
  "panel": { "listen": ":2053", "basePath": "/ovira-7f3c/", "subPath": "sub" }
}
```

`400` یعنی راه‌اندازی مجدد در این حالت ممکن نیست. اتصال‌های VPN از آن تأثیر نمی‌گیرند.

## خواندن گواهی

<Endpoint method="GET" path="/api/settings/tls" perm="owner" :token="true" />

گواهی‌ای که پنل ارائه می‌کند، روشن بودن HTTPS و آدرس نوشته‌شده در پروفایل کاربران را برمی‌گرداند.

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

## تغییر گواهی

<Endpoint method="PUT" path="/api/settings/tls" perm="owner" :token="false" />

مخصوص نشست. گواهی Let's Encrypt برای یک دامنه یا IP می‌گیرد، یا HTTPS را خاموش می‌کند. گواهی تازه پس از راه‌اندازی مجدد اعمال می‌شود.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `mode` | string | بله | `domain`، `ip` یا `none`. |
| `domain` | string | برای `domain` | نامی که گواهی می‌گیرد. برای `ip` پیش‌فرض آدرس عمومی است. |
| `email` | string | خیر | آدرس تماس حساب ACME. |

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

`400` یعنی حالت معتبر نیست یا گواهی صادر نشد.

## دانلود پشتیبان

<Endpoint method="GET" path="/api/backup" perm="owner" :token="true" />

یک نسخهٔ سازگار از وضعیت فعلی پایگاه‌دادهٔ پنل به شکل SQLite و با `application/vnd.sqlite3` برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o ovira-backup.db "$BASE/backup"
```

فایل را خصوصی نگه دارید: رمزها و داده‌های کاربران در آن است.

## بازگردانی پشتیبان

<Endpoint method="POST" path="/api/backup/restore" perm="owner" :token="false" />

مخصوص نشست. پشتیبان `.db` یا `.db.gz` یک پنل اویرا را آپلود می‌کند. پشتیبان موقتاً ذخیره می‌شود و در راه‌اندازی مجدد بعدی جای پایگاه‌داده را می‌گیرد.

```bash
curl -sS -b cookies.txt -X POST "$BASE/backup/restore" \
  -H "X-CSRF-Token: $CSRF" \
  -F "file=@ovira-backup.db"
```

```json
{ "ok": true, "restartRequired": true }
```

`400` یعنی فایل آپلودی پشتیبان اویرا نیست.

## خواندن تنظیمات پشتیبان Telegram

<Endpoint method="GET" path="/api/backup/telegram" perm="owner" :token="true" />

تنظیمات ربات بدون توکن، زمان‌بندی و فهرست پشتیبان‌های ثبت‌شده در گفتگو را برمی‌گرداند.

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

## ذخیرهٔ تنظیمات پشتیبان Telegram

<Endpoint method="PUT" path="/api/backup/telegram" perm="owner" :token="true" />

| فیلد | نوع | معنی |
|---|---|---|
| `enabled` | boolean | پشتیبان زمان‌بندی‌شده فرستاده شود. |
| `token` | string | توکن ربات از `@BotFather`. خالی یعنی ذخیره‌شده بماند. |
| `chatId` | string | شناسهٔ عددی گفتگویی که پشتیبان را می‌گیرد. |
| `intervalHours` | integer | فاصلهٔ پشتیبان به ساعت، ۱ تا ۱۶۸. `0` یعنی ۲۴. |
| `proxy` | string | آدرس پراکسی `http`، `https` یا `socks5` برای رسیدن به Bot API. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/backup/telegram" \
  -d '{"enabled":true,"chatId":"-1001234567890","intervalHours":24,"proxy":""}'
```

پاسخ وضعیت ذخیره‌شده است. `400` یعنی توکن ربات یا گفتگو معتبر نیست.

## فهرست گفتگوهای دیده‌شده

<Endpoint method="POST" path="/api/backup/telegram/chats" perm="owner" :token="true" />

گفتگوهایی که ربات می‌تواند در آن‌ها بنویسد را فهرست می‌کند. بدنه اختیاری است.

| فیلد | نوع | معنی |
|---|---|---|
| `token` | string | توکن ربات برای جست‌وجو. خالی یعنی ذخیره‌شده. |

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

`400` یعنی توکن ربات ذخیره یا داده نشده. `502` یعنی Telegram در دسترس نبود.

## فرستادن پشتیبان همین حالا

<Endpoint method="POST" path="/api/backup/telegram/send" perm="owner" :token="true" />

پشتیبان را فوراً به گفتگوی ذخیره‌شده می‌فرستد.

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

`400` یعنی پشتیبان در دسترس نیست یا فرستادن شکست خورد. `409` یعنی ارسال دیگری در حال انجام است.

## بازگردانی از Telegram

<Endpoint method="POST" path="/api/backup/telegram/restore" perm="owner" :token="false" />

مخصوص نشست. پشتیبانی را که ربات به گفتگو فرستاده بازمی‌گرداند. فایل موقتاً ذخیره می‌شود و در راه‌اندازی مجدد بعدی جای پایگاه‌داده را می‌گیرد.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `fileId` | string | بله | شناسهٔ فایل پشتیبانی که ربات به گفتگو فرستاده. |

```bash
curl -sS -b cookies.txt -X POST "$BASE/backup/telegram/restore" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"fileId":"BQAC..."}'
```

```json
{ "ok": true, "restartRequired": true }
```

`400` یعنی شناسهٔ فایل پشتیبان این پنل نیست.

## خواندن وضعیت به‌روزرسانی

<Endpoint method="GET" path="/api/updates" perm="staff" :token="true" />

نسخه، کانال، تنظیم خودکار و نسخه‌های شناخته‌شدهٔ پنل را برمی‌گرداند.

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

## بررسی نسخهٔ تازه

<Endpoint method="POST" path="/api/updates/check" perm="staff" :token="true" />

از سرور به‌روزرسانی نسخهٔ تازه می‌خواهد و وضعیت به‌روزرسانی پس از بررسی را برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/updates/check"
```

پاسخ وضعیت به‌روزرسانی با `checkedAt` است. نصب به‌روزرسانی کاری مخصوص نشست است و جزو این API نیست.

## خواندن گزارش فعالیت

<Endpoint method="GET" path="/api/audit" perm="staff" :token="true" />

حداکثر ۱۰۰ ورودی گزارش فعالیت را از جدید به قدیم برمی‌گرداند.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `before` | query | integer | فقط ورودی‌هایی با شناسهٔ کمتر. `0` یا نبودنش از جدیدترین شروع می‌کند. |

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

آخرین `id` را به‌عنوان `before` بعدی بفرستید.

## صفحه‌های مرتبط

- [تنظیمات](/fa/use/settings): صفحهٔ پنل و فیلدهایش.
- [پشتیبان‌گیری و بازگردانی](/fa/use/backup): پشتیبان چه چیزی دارد.
- [گزارش فعالیت](/fa/use/audit): کارهایی که یک ورودی می‌تواند نام ببرد.
- [نمای کلی API](/fa/api/): شکل مشترک خطا.
