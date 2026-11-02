# ورود و حساب

این مسیرها اطلاعات پنل را می‌خوانند، وارد و خارج می‌شوند، حساب فعلی را توصیف می‌کنند و رمز، ورود دومرحله‌ای، مرورگرهای واردشده و توکن‌های API خودتان را عوض می‌کنند. بیشترشان برای نشست مرورگرند؛ توکن نشست و مقدار CSRF ندارد.

زمان با ثانیهٔ یونیکس است. درخواست توکن از `Authorization: Bearer` استفاده می‌کند، هدر CSRF نمی‌خواهد و مسیرهای مخصوص نشست را صدا نمی‌زند. مرورگر با کوکی وارد می‌شود و در هر نوشتن `X-CSRF-Token` می‌فرستد.

## اطلاعات پنل

<Endpoint method="GET" path="/api/meta" perm="public" :token="null" />

نام پنل، نسخه، زبان پیش‌فرض و گزینه‌های ورود را برای صفحهٔ ورود برمی‌گرداند.

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

## سند OpenAPI

<Endpoint method="GET" path="/api/openapi.json" perm="public" :token="null" />

همین سند OpenAPI 3.1 را با نسخهٔ در حال اجرا در `info.version` برمی‌گرداند.

```bash
curl -sS "$BASE/openapi.json"
```

## ورود

<Endpoint method="POST" path="/api/auth/login" perm="public" :token="null" />

مرورگر را وارد می‌کند و کوکی نشست می‌گذارد. وقتی ورود دومرحله‌ای روشن است، پاسخ یک چالش است، نه نشست.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `username` | string | بله | نام کاربری حساب. |
| `password` | string | بله | رمز حساب. |
| `remember` | boolean | خیر | مرورگر را ۳۰ روز وارد نگه دار، نه تا مهلت بی‌فعالیتی. |

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

بدون عامل دوم، پاسخ شیء `Me` و کوکی است. با عامل دوم، پاسخ این است:

```json
{ "mfa": true, "ticket": "ticket-value", "remember": false }
```

`401` یعنی نام کاربری یا رمز اشتباه. `403` یعنی حساب مسدود است یا لایسنس آن را رد می‌کند. `429` یعنی تلاش ناموفق زیاد.

## تمام کردن ورود دومرحله‌ای

<Endpoint method="POST" path="/api/auth/mfa" perm="public" :token="null" />

ورود را با کد TOTP یا کد بازیابی تمام می‌کند.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `ticket` | string | بله | تیکت `auth/login`. پنج دقیقه اعتبار دارد. |
| `code` | string | بله | کد TOTP یا یکی از کدهای بازیابی. |
| `remember` | boolean | خیر | مرورگر را ۳۰ روز وارد نگه دار. |

```bash
curl -sS -c cookies.txt -X POST "$BASE/auth/mfa" \
  -H "Content-Type: application/json" \
  -d '{"ticket":"ticket-value","code":"123456"}'
```

پاسخ شیء `Me` و کوکی نشست است. `401` یعنی کد کار نکرد یا تیکت منقضی شد.

## خروج

<Endpoint method="POST" path="/api/auth/logout" perm="any" :token="false" />

مرورگر را خارج و کوکی را پاک می‌کند. مخصوص نشست.

```bash
curl -sS -b cookies.txt -X POST "$BASE/auth/logout" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

## من کی هستم

<Endpoint method="GET" path="/api/auth/me" perm="any" :token="true" />

حساب پشت درخواست، نقش، دسترسی‌ها و محدودیت‌های مؤثر، طرح و، وقتی درخواست با توکن است، توکن را برمی‌گرداند. برای مرورگر `csrf` مقدار لازم برای نوشتن را دارد؛ برای درخواست توکن خالی است.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/auth/me"
```

`401` یعنی نشست یا توکن معتبر نیست.

## سهمیهٔ ترافیک من

<Endpoint method="GET" path="/api/auth/usage" perm="any" :token="true" />

سهمیهٔ ترافیک فعلی حساب را برمی‌گرداند. مالک همیشه برای سقف و تاریخ پایان `0` می‌خواند.

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

## تغییر رمز من

<Endpoint method="POST" path="/api/account/password" perm="any" :token="false" />

مخصوص نشست. رمز شما را عوض می‌کند و مرورگرهای دیگرتان را خارج می‌کند.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `current` | string | بله | رمز فعلی. |
| `new` | string | بله | رمز تازه، بررسی‌شده از نظر قدرت. |

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/password" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"current":"old-password","new":"a-new-long-password"}'
```

```json
{ "ok": true }
```

`400` یعنی رمز فعلی اشتباه است یا رمز تازه پذیرفته نمی‌شود.

## ورود دومرحله‌ای

همهٔ این مسیرها مخصوص نشست‌اند.

<Endpoint method="POST" path="/api/account/2fa/setup" perm="any" :token="false" />

راه‌اندازی را شروع و کلید راه‌اندازی، URI با `otpauth://` و یک data URL از تصویر QR را برمی‌گرداند.

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

`400` یعنی ورود دومرحله‌ای از قبل روشن است.

<Endpoint method="POST" path="/api/account/2fa/enable" perm="any" :token="false" />

عامل دوم را روشن می‌کند. بدنه یک فیلد لازم `code` از برنامهٔ احراز هویت دارد. پاسخ ده کد بازیابی دارد که یک‌بار نشان داده می‌شود.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/2fa/enable" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"code":"123456"}'
```

```json
{ "recoveryCodes": ["abcd-efgh", "ijkl-mnop"] }
```

`400` یعنی راه‌اندازی شروع نشده یا کد مطابقت ندارد.

<Endpoint method="POST" path="/api/account/2fa/disable" perm="any" :token="false" />

عامل دوم را خاموش می‌کند. بدنه یک فیلد لازم `password` دارد.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/2fa/disable" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"password":"your-password"}'
```

```json
{ "ok": true }
```

`400` یعنی رمز اشتباه است.

<Endpoint method="POST" path="/api/account/2fa/recovery" perm="any" :token="false" />

کدهای بازیابی را عوض می‌کند. بدنه یک فیلد لازم `password` دارد. پاسخ کدهای تازه است که یک‌بار نشان داده می‌شوند.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/2fa/recovery" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"password":"your-password"}'
```

`400` یعنی ورود دومرحله‌ای خاموش است یا رمز اشتباه است.

## مرورگرهای واردشده

<Endpoint method="GET" path="/api/account/sessions" perm="any" :token="false" />

نشست‌های شما را از جدیدترین فعالیت به قدیم‌ترین، با نشانهٔ نشست فعلی، فهرست می‌کند. مخصوص نشست.

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

یک مرورگر را خارج می‌کند. پارامتر مسیر `id` مقدار `ref` نشست، یا شناسهٔ آن با حداقل ۱۶ نویسه است. مخصوص نشست.

```bash
curl -sS -b cookies.txt -X DELETE "$BASE/account/sessions/9f3a2b7c8d1e4f60" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

`404` یعنی چنین نشستی نیست.

<Endpoint method="POST" path="/api/account/sessions/revoke-others" perm="any" :token="false" />

همهٔ مرورگرها جز این یکی را خارج می‌کند. مخصوص نشست.

```bash
curl -sS -b cookies.txt -X POST "$BASE/account/sessions/revoke-others" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

## توکن‌های API

این مسیرها مخصوص نشست‌اند و در [توکن‌های API](/fa/api/tokens) کامل توضیح داده شده‌اند.

<Endpoint method="GET" path="/api/account/tokens" perm="any" :token="false" />

توکن‌های شما را فهرست می‌کند.

<Endpoint method="POST" path="/api/account/tokens" perm="any" :token="false" />

توکن می‌سازد.

<Endpoint method="DELETE" path="/api/account/tokens/{id}" perm="any" :token="false" />

یکی از توکن‌های شما را لغو می‌کند.

<Endpoint method="GET" path="/api/admins/{id}/tokens" perm="owner" :token="false" />

فقط مالک. توکن‌های یک حساب را فهرست می‌کند.

<Endpoint method="DELETE" path="/api/admins/{id}/tokens/{tid}" perm="owner" :token="false" />

فقط مالک. یک توکن از یک حساب را لغو می‌کند.

## صفحه‌های مرتبط

- [توکن‌های API](/fa/api/tokens): ساخت، محدود کردن و لغو توکن.
- [حساب‌های پنل](/fa/use/admins): صفحهٔ حساب، رمز و عامل دوم.
- [نمای کلی API](/fa/api/): خطاهای توکن و فهرست مخصوص نشست.
- [تنظیمات](/fa/use/settings): جای **حساب من**.
