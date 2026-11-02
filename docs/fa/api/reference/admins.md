# حساب‌ها و نقش‌ها

حساب پنل مالک، مدیر، نماینده یا حسابی با نقش سفارشی است. نقش مجموعه‌ای از محدوده‌های دسترسی و پیش‌فرض‌های محدودیت است. این مسیرها حساب‌ها را فهرست و تغییر می‌دهند، رمز می‌گذارند یا ورود دومرحله‌ای را بازنشانی می‌کنند، مصرف حساب را می‌خوانند، طرح حساب را تغییر می‌دهند و نقش‌ها را مدیریت می‌کنند.

زمان با ثانیهٔ یونیکس و ترافیک با بایت است. همهٔ این مسیرها مخصوص مالک‌اند. توکن کاملِ مالک به مسیرهای مجاز برای توکن دسترسی دارد؛ تغییر رمز و بازنشانی ورود دومرحله‌ای به نشست مرورگر نیاز دارند. توکن سفارشی حتی با همهٔ دسترسی‌ها نمی‌تواند مسیرهای مخصوص مالک را فراخوانی کند.

## فهرست حساب‌ها

<Endpoint method="GET" path="/api/admins" perm="owner" :token="true" />

همهٔ حساب‌ها، با مالک، نقش، وضعیت، تعداد کاربر و محدودیت‌های مؤثر را برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/admins"
```

```json
[
  {
    "id": 7,
    "username": "shop",
    "role": "reseller",
    "roleId": 2,
    "roleName": "Reseller",
    "state": "active",
    "disabled": false,
    "totpEnabled": false,
    "expireAt": 1796000000,
    "trafficLimit": 1099511627776,
    "usedBytes": 82463372083,
    "clients": 24,
    "online": 3,
    "maxClients": 100,
    "note": "",
    "createdAt": 1793000000,
    "lastLoginAt": 1795915000
  }
]
```

## ساخت حساب

<Endpoint method="POST" path="/api/admins" perm="owner" :token="true" />

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `username` | string | بله | ۳ تا ۳۲ نویسه بدون فاصله یا کوتیشن. یکتا. |
| `password` | string | هنگام ساخت | رمز اولیه. هنگام تغییر نادیده گرفته می‌شود. |
| `role` | string | خیر | `owner`، `admin` یا `reseller`. وقتی `roleId` صفر است استفاده می‌شود. |
| `roleId` | integer | خیر | هر نقش، پیش‌فرض یا سفارشی. `0` با `role: owner` حساب را مالک می‌کند. |
| `overrides` | object | خیر | محدودیت‌هایی که پیش‌فرض نقش را برای این حساب عوض می‌کنند. |
| `disabled` | boolean | خیر | ورود را ببند. |
| `expireAt` | integer | خیر | پایان حساب با ثانیهٔ یونیکس. `0` یعنی هرگز. |
| `trafficLimit` | integer | خیر | سهمیهٔ ترافیک با بایت. `0` یعنی بی‌نهایت. |
| `note` | string | خیر | متن آزاد، حداکثر ۵۰۰ نویسه. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/admins" \
  -d '{
    "username": "shop",
    "password": "a-long-password",
    "role": "reseller",
    "trafficLimit": 1099511627776,
    "expireAt": 1796000000,
    "overrides": { "maxClients": 100, "maxDevices": 2 }
  }'
```

```json
{
  "id": 7,
  "username": "shop",
  "role": "reseller",
  "roleId": 2,
  "roleName": "Reseller",
  "state": "active",
  "disabled": false,
  "expireAt": 1796000000,
  "trafficLimit": 1099511627776,
  "usedBytes": 0,
  "clients": 0,
  "maxClients": 100
}
```

`400` یعنی فیلد اشتباه یا نام کاربری گرفته‌شده. `402` یعنی لایسنس حساب دیگری را اجازه نمی‌دهد.

## خواندن یک حساب

<Endpoint method="GET" path="/api/admins/{id}" perm="owner" :token="true" />

یک حساب را برمی‌گرداند. پارامتر مسیر `id` شناسهٔ حساب است.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/admins/7"
```

`404` یعنی چنین حسابی نیست.

## تغییر حساب

<Endpoint method="PUT" path="/api/admins/{id}" perm="owner" :token="true" />

همان فیلدهای ساخت را می‌فرستد. `password` اینجا نادیده گرفته می‌شود؛ از مسیر تغییر رمز استفاده کنید. آخرین مالک حذف یا به نقش دیگری تبدیل نمی‌شود.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/admins/7" \
  -d '{"username":"shop","roleId":2,"trafficLimit":2199023255552,"expireAt":1798592000,"disabled":false}'
```

پاسخ حساب تغییرکرده است. `400` یعنی فیلد اشتباه، نام گرفته‌شده، یا تغییری که آخرین مالک را برمی‌دارد.

## حذف حساب

<Endpoint method="DELETE" path="/api/admins/{id}" perm="owner" :token="true" />

حساب را حذف می‌کند. کاربرانش به‌طور پیش‌فرض به حساب دیگری منتقل می‌شوند یا حذف می‌شوند.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `id` | path | integer | شناسهٔ حساب. |
| `clients` | query | string | `delete` کاربران حساب را حذف می‌کند، نه منتقل. |
| `to` | query | integer | حسابی که کاربران را می‌گیرد. پیش‌فرض خود صداکننده است. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X DELETE "$BASE/admins/7?to=1"
```

```json
{ "ok": true, "clients": 24 }
```

`clients` تعداد کاربران منتقل یا حذف‌شده است. `400` یعنی حساب حذف نمی‌شود یا مقصد معتبر نیست.

## گذاشتن رمز حساب دیگر

<Endpoint method="POST" path="/api/admins/{id}/password" perm="owner" :token="false" />

مخصوص نشست. رمز تازه برای یک حساب می‌گذارد و نشست‌های دیگرش را می‌بندد.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `password` | string | بله | رمز تازه، بررسی‌شده از نظر قدرت. |

```bash
curl -sS -b cookies.txt -X POST "$BASE/admins/7/password" \
  -H "Content-Type: application/json" -H "X-CSRF-Token: $CSRF" \
  -d '{"password":"a-new-long-password"}'
```

```json
{ "ok": true }
```

`400` یعنی رمز ضعیف است.

## بازنشانی ورود دومرحله‌ای حساب دیگر

<Endpoint method="POST" path="/api/admins/{id}/reset-2fa" perm="owner" :token="false" />

مخصوص نشست. ورود دومرحله‌ای حساب را خاموش می‌کند، مثلاً وقتی گوشی‌اش گم شده.

```bash
curl -sS -b cookies.txt -X POST "$BASE/admins/7/reset-2fa" \
  -H "X-CSRF-Token: $CSRF"
```

```json
{ "ok": true }
```

`404` یعنی چنین حسابی نیست.

## خواندن ترافیک حساب

<Endpoint method="GET" path="/api/admins/{id}/usage" perm="owner" :token="true" />

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `id` | path | integer | شناسهٔ حساب. |
| `range` | query | string | `24h`، `7d`، `30d` یا `90d`. پیش‌فرض `30d`. |
| `tz` | query | integer | اختلاف زمانی کاربر با UTC به دقیقه، ۸۴۰- تا ۸۴۰. پیش‌فرض ۰. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/admins/7/usage?range=30d"
```

پاسخ یک سری مصرف با `points`، `from`، `to`، `bucket` و `offset` است. `404` یعنی چنین حسابی نیست.

## تغییر طرح حساب

<Endpoint method="POST" path="/api/admins/{id}/{action}" perm="owner" :token="true" />

سهمیهٔ ترافیک، تاریخ پایان یا وضعیت حساب را عوض می‌کند. کار در مسیر بر `body.action` مقدم است.

| کار | چه می‌کند |
|---|---|
| `add-traffic` | `bytes` را به سهمیه اضافه می‌کند. |
| `extend` | `days` را از حالا یا پایان فعلی، هر کدام دیرتر باشد، اضافه می‌کند. `bytes` بیشتر از صفر سهمیه را عوض می‌کند. `resetUsage` مصرف را هم صفر می‌کند. |
| `reset-usage` | مصرف حساب را صفر می‌کند. |
| `disable` یا `enable` | ورود را می‌بندد یا برمی‌گرداند. |
| `disable-clients` یا `enable-clients` | همهٔ کاربران حساب را می‌بندد یا برمی‌گرداند. |

| فیلد | نوع | معنی |
|---|---|---|
| `action` | string | همان کار. وقتی مسیر کار را گفته، نادیده گرفته می‌شود. |
| `bytes` | integer | بایت‌های اضافه، یا سهمیهٔ تازه برای `extend` وقتی بیشتر از صفر است. |
| `days` | integer | روزهای اضافه برای `extend`، ۰ تا ۳۶۵۰. |
| `resetUsage` | boolean | برای `extend`: مصرف را هم صفر کن. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/admins/7/add-traffic" \
  -d '{"bytes":1099511627776}'
```

پاسخ حساب پس از کار است. `400` یعنی کار معتبر نیست یا آخرین مالک خاموش نمی‌شود.

## فهرست نقش‌ها

<Endpoint method="GET" path="/api/admin-roles" perm="owner" :token="true" />

همهٔ نقش‌ها، پیش‌فرض اول، و کلیدهای دسترسی‌ای که نقش می‌تواند بدهد را برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/admin-roles"
```

```json
{
  "items": [
    {
      "id": 2,
      "name": "Reseller",
      "builtin": true,
      "perms": { "clients.view": "own", "clients.create": "own", "connections.view": "own" },
      "limits": { "maxClients": 0, "maxDevices": 0, "allowUnlimited": true },
      "createdAt": 0,
      "admins": 4
    }
  ],
  "perms": [
    { "key": "clients.view", "scoped": true },
    { "key": "groups.manage", "scoped": false }
  ]
}
```

محدوده `none`، `own` یا `all` است. برای `groups.view` و `inbounds.view`، `own` یعنی فقط گروه‌ها یا اینباندهای داده‌شده.

## ساخت نقش

<Endpoint method="POST" path="/api/admin-roles" perm="owner" :token="true" />

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `name` | string | بله | ۱ تا ۴۰ نویسه. یکتا. |
| `perms` | object | خیر | کلید دسترسی به محدوده. کلید ارسال‌نشده `none` است. |
| `limits` | object | خیر | پیش‌فرض حساب‌های این نقش. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/admin-roles" \
  -d '{
    "name": "Support",
    "perms": {
      "clients.view": "all",
      "clients.edit": "all",
      "connections.view": "all",
      "connections.kick": "all"
    },
    "limits": { "maxClients": 0, "allowUnlimited": true }
  }'
```

پاسخ نقش تازه است. `400` یعنی فیلد اشتباه یا نام گرفته‌شده.

## تغییر نقش

<Endpoint method="PUT" path="/api/admin-roles/{id}" perm="owner" :token="true" />

همان فیلدهای ساخت را می‌فرستد. نقش‌های پیش‌فرض تغییر نمی‌کنند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/admin-roles/5" \
  -d '{"name":"Support","perms":{"clients.view":"all","clients.edit":"all"}}'
```

`400` یعنی فیلد اشتباه، نقش پیش‌فرض یا نام گرفته‌شده.

## حذف نقش

<Endpoint method="DELETE" path="/api/admin-roles/{id}" perm="owner" :token="true" />

نقش سفارشی را حذف می‌کند. نقشی که حساب‌ها هنوز استفاده می‌کنند حذف نمی‌شود.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/admin-roles/5"
```

```json
{ "ok": true }
```

`400` یعنی نقش پیش‌فرض است. `409` یعنی حساب‌ها هنوز از آن استفاده می‌کنند.

## شیء محدودیت‌ها

`limits` و `overrides` این فیلدها را دارند. در `overrides` فقط فیلدهایی که می‌فرستید مقدار نقش را عوض می‌کنند؛ `0` یعنی بی‌سقف.

| فیلد | نوع | معنی |
|---|---|---|
| `maxClients` | integer | سقف کاربر؛ `0` یعنی بی‌سقف. |
| `allowedGroups` | integer[] | شناسهٔ گروه‌های قابل استفادهٔ حساب. |
| `allowedInbounds` | integer[] | شناسهٔ اینباندهای قابل استفادهٔ حساب. |
| `requireGroup` | boolean | کاربر باید در گروه مجاز باشد، نه اینباند تکی. |
| `maxClientTraffic` | integer | سقف ترافیک هر کاربر با بایت؛ `0` یعنی بی‌سقف. |
| `maxClientDays` | integer | عمر هر کاربر به روز؛ `0` یعنی بی‌سقف. |
| `maxDevices` | integer | سقف دستگاه هر کاربر؛ `0` یعنی بی‌سقف. |
| `allowUnlimited` | boolean | حساب می‌تواند کاربر بدون سقف ترافیک بسازد. |
| `trafficLimit` | integer | سهمیهٔ پیش‌فرض حساب‌های تازهٔ این نقش، با بایت. |

## صفحه‌های مرتبط

- [نقش‌ها و نماینده‌های فروش](/fa/use/resellers): واژه‌های پنل برای هر دسترسی و محدودیت.
- [حساب‌های پنل](/fa/use/admins): صفحهٔ حساب و بخش توکن.
- [توکن‌های API](/fa/api/tokens): توکن‌های یک حساب.
- [کاربران](/fa/api/reference/clients): کاربرانی که حساب دارد.
