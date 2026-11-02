# نودها

نود سرور دیگری است که اینباندهای این پنل را اجرا می‌کند. شناسهٔ نود `0` همان سرور پنل است و حذف نمی‌شود. این مسیرها نودها را فهرست و تغییر می‌دهند، فرمان نصب را می‌دهند، نود را هم‌گام می‌کنند، شمارنده‌های ترافیکش را صفر می‌کنند و بسته‌های پروتکل روی آن را مدیریت می‌کنند.

زمان با ثانیهٔ یونیکس است. ترافیک نود بایت واقعی و پیش از ضریب نود است.

## فهرست نودها

<Endpoint method="GET" path="/api/nodes" perm="nodes.view" :token="true" />

همهٔ نودهای قابل مشاهده برای حساب را برمی‌گرداند، سرور پنل اول، همراه با سقف نود لایسنس.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/nodes"
```

```json
{
  "items": [
    {
      "id": 0,
      "name": "this server",
      "kind": "local",
      "enabled": true,
      "address": "",
      "apiPort": 0,
      "ratio": 1,
      "endpoints": [],
      "trafficUp": 0,
      "trafficDown": 0,
      "online": true,
      "instances": 2,
      "sessions": 3,
      "updateAvailable": false
    },
    {
      "id": 4,
      "name": "de-fra-1",
      "kind": "remote",
      "enabled": true,
      "address": "198.51.100.24",
      "apiPort": 62060,
      "ratio": 1.5,
      "endpoints": [
        { "label": "Germany", "host": "de.example.com", "port": 0, "instance": 0 }
      ],
      "trafficUp": 10737418240,
      "trafficDown": 53687091200,
      "online": true,
      "lastSeen": 1795919000,
      "instances": 1,
      "sessions": 2,
      "updateAvailable": false
    }
  ],
  "allowed": true,
  "maxNodes": 10,
  "defaultPort": 62060
}
```

`allowed` می‌گوید لایسنس نود دارد یا نه. `maxNodes: 0` وقتی `allowed` درست باشد یعنی تعداد نود سقف ندارد؛ `allowed: false` یعنی نود راه دور در دسترس نیست.

## افزودن نود

<Endpoint method="POST" path="/api/nodes" perm="owner" :token="true" />

مالک پس از اجرای فرمان نصب روی سرور جدید نود را اضافه می‌کند. پنل یک‌بار آن را بررسی می‌کند و می‌گوید جفت شدن کار می‌کند یا نه.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `name` | string | بله | نام نود. یکتا. |
| `enabled` | boolean | خیر | پنل از نود استفاده کند. پیش‌فرض روشن. |
| `address` | string | بله | جایی که پنل به API نود می‌رسد. |
| `apiPort` | integer | خیر | پورت API نود. پیش‌فرض پورت نود پنل. |
| `key` | string | بله | کلید نودی که نصب‌کننده چاپ می‌کند. |
| `ratio` | number | خیر | ضریب ترافیک برای سهمیه. پیش‌فرض ۱. |
| `endpoints` | object[] | خیر | آدرس‌های کاربران: `label`، `host`، `port`، `instance`. |
| `note` | string | خیر | متن آزاد برای مالک. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/nodes" \
  -d '{
    "name": "de-fra-1",
    "address": "198.51.100.24",
    "apiPort": 62060,
    "key": "NODE_KEY",
    "ratio": 1.5,
    "endpoints": [{"label":"Germany","host":"de.example.com","port":0,"instance":0}]
  }'
```

```json
{
  "node": {
    "id": 4,
    "name": "de-fra-1",
    "kind": "remote",
    "enabled": true,
    "address": "198.51.100.24",
    "apiPort": 62060,
    "ratio": 1.5,
    "online": true,
    "instances": 0,
    "sessions": 0
  }
}
```

`400` با `field: name` یا `address` یعنی مقدار تکراری یا نامعتبر. `402` یعنی لایسنس نود دیگری را اجازه نمی‌دهد.

## خواندن فرمان نصب

<Endpoint method="GET" path="/api/nodes/install" perm="nodes.view" :token="true" />

فرمان یک‌خطی برای سرور جدید، آدرس نصب‌کننده و آدرس این پنل را برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/nodes/install"
```

```json
{
  "command": "bash <(curl -fsSL https://example.com/node.sh) --panel-ip 203.0.113.10",
  "panelIp": "203.0.113.10",
  "script": "https://example.com/node.sh"
}
```

## نصب نود روی میزبان پنل

<Endpoint method="POST" path="/api/nodes/0/local-install" perm="owner" :token="true" />

این سرور را آماده می‌کند تا اینباندها را به‌عنوان نود هم اجرا کند. پاسخ `202` است؛ نتیجه را از `GET nodes` بخوانید.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/nodes/0/local-install"
```

```json
{ "installing": true, "installError": "" }
```

`400` یعنی نصب روی این میزبان ممکن نیست.

## تغییر نود

<Endpoint method="PUT" path="/api/nodes/{id}" perm="owner" :token="true" />

همان فیلدهای ساخت را می‌فرستد. `key` خالی کلید ذخیره‌شده را نگه می‌دارد. پارامتر مسیر `id` شناسهٔ نود است؛ `0` همین سرور.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/nodes/4" \
  -d '{"name":"de-fra-1","address":"198.51.100.24","apiPort":62060,"ratio":1.5,"enabled":true}'
```

پاسخ نود تغییرکرده است. `400` فیلد اشتباه را می‌گوید.

## حذف نود

<Endpoint method="DELETE" path="/api/nodes/{id}" perm="owner" :token="true" />

نود را حذف می‌کند. اینباندهایش بدون نود می‌مانند، پس پروفایل‌هایشان تا تخصیص دوباره از کار می‌افتند. نود `0` حذف نمی‌شود.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/nodes/4"
```

پاسخ `204` است. `400` یعنی شناسه سرور اصلی یا نامعتبر است.

## هم‌گام کردن یا صفر کردن ترافیک نود

<Endpoint method="POST" path="/api/nodes/{id}/{action}" perm="nodes.manage" :token="true" />

| کار | چه می‌کند |
|---|---|
| `sync` | وضعیت فعلی را به نود می‌فرستد. |
| `reset-traffic` | شمارنده‌های ترافیک نود را صفر می‌کند. سهمیهٔ کاربران و استخر حساب تغییر نمی‌کند. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X POST "$BASE/nodes/4/sync"
```

```json
{
  "node": {
    "id": 4,
    "name": "de-fra-1",
    "online": true,
    "trafficUp": 0,
    "trafficDown": 0
  }
}
```

`404` یعنی چنین نود یا کاری نیست.

## خواندن بسته‌های پروتکل

<Endpoint method="GET" path="/api/nodes/{id}/protocols" perm="owner" :token="true" />

وضعیت بستهٔ `openvpn`، `ocserv` و `wireguard` روی نود و تعداد اینباندهای هر کدام را برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/nodes/4/protocols"
```

```json
{
  "protocols": {
    "openvpn": {
      "installed": true,
      "owned": true,
      "busy": false,
      "stage": "",
      "logs": []
    },
    "wireguard": {
      "installed": true,
      "owned": true,
      "busy": false,
      "stage": "",
      "logs": []
    }
  },
  "references": { "openvpn": 1, "wireguard": 1 }
}
```

## حذف پروتکل از نود

<Endpoint method="DELETE" path="/api/nodes/{id}/protocols/{kind}" perm="owner" :token="false" />

بستهٔ پروتکلی را که پنل نصب کرده حذف می‌کند. مخصوص نشست است: توکن `token_forbidden` می‌گیرد. پارامترهای مسیر شناسهٔ نود و `kind` (`openvpn`، `ocserv` یا `wireguard`) هستند.

```bash
curl -sS -b cookies.txt -X DELETE \
  -H "X-CSRF-Token: $CSRF" \
  "$BASE/nodes/4/protocols/wireguard"
```

```json
{
  "protocols": {
    "wireguard": { "installed": false, "owned": false, "busy": false, "stage": "", "logs": [] }
  },
  "references": { "wireguard": 0 }
}
```

`400` یعنی اینباندی هنوز از پروتکل استفاده می‌کند، یا پنل آن را نصب نکرده.

## صفحه‌های مرتبط

- [اینباندها](/fa/api/reference/inbounds): استقرار اینباند روی نودها.
- [همین سرور به‌عنوان نود](/fa/start/same-server): نود محلی در پنل.
- [نودها](/fa/use/nodes): صفحهٔ پنل و کارهایش.
- [نود و پنلش](/fa/how/nodes): نحوهٔ کار پیوند.
