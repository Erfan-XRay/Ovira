# شروع سریع

این صفحه سه درخواست اول را با توکن انجام می‌دهد: خواندن حساب، فهرست کاربران و ساخت یک کاربر. همین درخواست‌ها با curl، Python و `requests`، و Node با `fetch` داخلی نشان داده شده‌اند.

پیش از شروع، در **تنظیمات → API** توکنی با حداقل `clients.view` و `clients.create` بسازید. نماینده به یک گروه یا اینباند مجاز هم نیاز دارد، چون نماینده نمی‌تواند کاربر بدون دسترسی بسازد.

## آدرس و توکن را بگذارید

آدرس پایه به `/api` ختم می‌شود، بعد از مسیر مخفی پنل:

```bash
export BASE="https://panel.example.com/ovira-7f3c/api"
export OVIRA_TOKEN="ovk_..."
```

توکن را از تاریخچهٔ شل و از مخزن بیرون نگه دارید. آن را از متغیر محیطی یا مخزن کلید بخوانید.

## من کی هستم؟

`GET auth/me` حساب پشت توکن، نقش، دسترسی‌های مؤثر و، برای درخواست توکن، مشخصات آن (شناسه، نام، دسترسی کامل و انقضا) را برمی‌گرداند. کلید توکن در پاسخ نیست.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/auth/me"
```

```json
{
  "admin": {
    "id": 7,
    "username": "shop",
    "role": "reseller",
    "roleId": 2,
    "totpEnabled": false,
    "disabled": false,
    "expireAt": 1796000000,
    "trafficLimit": 1099511627776,
    "usedBytes": 82463372083
  },
  "csrf": "",
  "roleName": "Reseller",
  "perms": {
    "clients.view": "own",
    "clients.create": "own",
    "clients.edit": "own",
    "clients.reset": "own"
  },
  "account": {
    "state": "active",
    "expireAt": 1796000000,
    "trafficLimit": 1099511627776,
    "usedBytes": 82463372083,
    "clients": 24,
    "maxClients": 100,
    "roleName": "Reseller",
    "canAssign": true
  },
  "token": {
    "id": 4,
    "name": "shop-bot",
    "full": false,
    "expiresAt": 1796000000
  }
}
```

برای درخواست توکن `csrf` خالی است. نشست مرورگر مقدار CSRF را اینجا برمی‌گرداند.

## فهرست کاربران

`GET clients` یک صفحه برمی‌گرداند. پیش‌فرض صفحهٔ ۱ با ۵۰ کاربر است. با `q` جست‌وجو کنید، با `status` فیلتر بزنید و با `size` اندازهٔ صفحه را تعیین کنید.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients?size=5&q=ali"
```

```json
{
  "items": [
    {
      "id": 118,
      "name": "ali-01",
      "enabled": true,
      "trafficLimit": 53687091200,
      "usedUp": 1073741824,
      "usedDown": 6442450944,
      "expireAt": 1796000000,
      "maxDevices": 2,
      "status": "active",
      "online": 1,
      "subUrl": "https://panel.example.com/sub/6f2a.../",
      "groups": [3]
    }
  ],
  "total": 1,
  "page": 1,
  "size": 5,
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

نماینده فقط کاربران خودش را می‌بیند، حتی بدون فیلتر `owner`.

## ساخت کاربر

برای اجازهٔ اتصال، `enabled: true` بفرستید. اگر ارسال نشود یا false باشد، کاربر خاموش ساخته می‌شود. گروه `3` را با یکی از گروه‌های مجاز حساب عوض کنید.

`POST clients` یک کاربر می‌سازد. نام، همان نام کاربری VPN هم هست، پس در کل پنل یکتاست.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients" \
  -d '{
    "name": "ali-02",
    "enabled": true,
    "trafficLimit": 53687091200,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3],
    "note": "order 1042"
  }'
```

`trafficLimit` با بایت است، پس `53687091200` یعنی ۵۰ گیگابایت. `expireAfterDays` از اولین اتصال کاربر شمرده می‌شود؛ برای تاریخ ثابت از `expireAt` با زمان یونیکس استفاده کنید.

پاسخ `201` با کاربر تازه است. `id` و `subUrl` را نگه دارید:

```json
{
  "id": 119,
  "name": "ali-02",
  "enabled": true,
  "trafficLimit": 53687091200,
  "expireAt": 0,
  "expireAfterDays": 30,
  "maxDevices": 2,
  "status": "active",
  "subUrl": "https://panel.example.com/sub/9c41.../",
  "groups": [3]
}
```

نماینده باید یک گروه یا اینباند مجاز بدهد. بدون آن، پاسخ `400` با `field: instances` و جمله‌ای است که می‌گوید یکی را انتخاب کنید.

## Python

یک‌بار `requests` را نصب کنید، بعد آدرس و توکن را در محیط نگه دارید.

```python
import os
import requests

BASE = os.environ["BASE"]
HEADERS = {"Authorization": f"Bearer {os.environ['OVIRA_TOKEN']}"}

def call(method: str, path: str, **kwargs):
    response = requests.request(method, f"{BASE}/{path.lstrip('/')}", headers=HEADERS, timeout=30, **kwargs)
    if not response.ok:
        try:
            body = response.json()
        except ValueError:
            body = {"error": response.text}
        raise RuntimeError(f"{response.status_code}: {body.get('error')} (code={body.get('code')}, field={body.get('field')})")
    return response.json()

me = call("GET", "auth/me")
print("acting as", me["admin"]["username"], "as", me["roleName"])

page = call("GET", "clients", params={"size": 5})
for client in page["items"]:
    print(client["id"], client["name"], client["status"])

created = call("POST", "clients", json={
    "name": "ali-03",
    "enabled": True,
    "trafficLimit": 50 * 1024**3,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3],
})
print("created", created["id"], created["subUrl"])
```

## Node

Node ۱۸ و بعد `fetch` داخلی دارد.

```js
const base = process.env.BASE;
const headers = {
  Authorization: `Bearer ${process.env.OVIRA_TOKEN}`,
  "Content-Type": "application/json",
};

async function call(method, path, body) {
  const response = await fetch(`${base}/${path.replace(/^\/+/, "")}`, {
    method,
    headers,
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(`${response.status}: ${data.error} (code=${data.code}, field=${data.field})`);
  }
  return data;
}

const me = await call("GET", "auth/me");
console.log("acting as", me.admin.username, "as", me.roleName);

const page = await call("GET", "clients?size=5");
for (const client of page.items) {
  console.log(client.id, client.name, client.status);
}

const created = await call("POST", "clients", {
  name: "ali-04",
  enabled: true,
  trafficLimit: 50 * 1024 ** 3,
  expireAfterDays: 30,
  maxDevices: 2,
  groups: [3],
});
console.log("created", created.id, created.subUrl);
```

## خطاها را مدیریت کنید

پیش از خواندن پاسخ به‌عنوان موفقیت، وضعیت HTTP را بررسی کنید. درخواست ناموفق یک جملهٔ `error`، اغلب یک `code`، و وقتی یک فیلد اشتباه باشد `field` دارد.

| چه می‌بینید | چه کنید |
|---|---|
| `401` با `token_invalid` | کلید اشتباه است یا توکن لغو شده. توکن تازه بسازید. |
| `401` با `token_expired` | توکن را عوض کنید. |
| `403` با `token_ip` | فرستنده خارج از **آی‌پی‌های مجاز** است. `params.ip` را ببینید. |
| `403` با `account_blocked` | حساب نماینده خاموش، منقضی یا بدون ترافیک است. از مالک بخواهید. |
| `403` بدون کد | توکن دسترسی این درخواست را ندارد. |
| `400` با `field` | همان فیلد را درست کنید. پیام می‌گوید چه چیزی پذیرفته می‌شود. |
| `402` | لایسنس یا سقف کاربر یا ترافیک حساب تغییر را رد می‌کند. |
| `409` | نام تکراری یا برگشت نسخهٔ پشتیبانی‌نشده. |
| `429` | تلاش ناموفق زیاد. پیش از تلاش دوباره صبر کنید. |

برای ساخت، نام تکراری را می‌توان بی‌خطر حل کرد: با `GET clients?q=NAME` نام را جست‌وجو کنید، `name` را دقیق مقایسه کنید و همان کاربر را دوباره به کار ببرید، نه اینکه دومی بسازید.

## صفحه‌های مرتبط

- [توکن‌های API](/fa/api/tokens): فهرست دسترسی‌ها و محدودیت توکن.
- [مرجع کاربران](/fa/api/reference/clients): همهٔ فیلدها و کارهای کاربر.
- [ربات فروش](/fa/api/shop-bot): جریان کامل سفارش تا اشتراک.
- [نمای کلی API](/fa/api/): کدهای خطا و آدرس پایه.
