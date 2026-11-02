# گروه‌ها

گروه اینباندهایش را به همهٔ کاربران عضو می‌دهد. کاربری که در یک یا چند گروه است، اجتماع اینباندهای آن گروه‌ها را می‌گیرد. این مسیرها گروه‌ها را فهرست، ایجاد، تغییر و گروهی مدیریت می‌کنند و گروه کاربران را اضافه یا حذف می‌کنند.

گروهی با **همهٔ اینباندها** (`allServers`) اینباندهایی را که بعداً اضافه می‌شوند هم شامل می‌شود. گروه خاموش دسترسی نمی‌دهد. زمان با ثانیهٔ یونیکس است.

## فهرست گروه‌ها

<Endpoint method="GET" path="/api/groups" perm="groups.view" :token="true" />

گروه‌های قابل مشاهده برای حساب را برمی‌گرداند. نماینده فقط گروه‌هایی را می‌بیند که به او داده شده.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/groups"
```

```json
{
  "items": [
    {
      "id": 3,
      "name": "Iran",
      "note": "Low-latency inbounds",
      "disabled": false,
      "allServers": false,
      "instances": [12, 21],
      "clients": 42,
      "createdAt": 1793000000
    }
  ]
}
```

## ساخت گروه

<Endpoint method="POST" path="/api/groups" perm="groups.manage" :token="true" />

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `name` | string | بله | ۱ تا ۴۰ نویسه. یکتا. |
| `note` | string | خیر | متن آزاد، حداکثر ۲۰۰ نویسه. |
| `disabled` | boolean | خیر | `true` گروه را بدون دسترسی می‌کند. |
| `allServers` | boolean | خیر | `true` همهٔ اینباندها، حتی بعداً اضافه‌شده‌ها را شامل می‌شود. |
| `instances` | integer[] | خیر | شناسهٔ اینباندهایی که گروه می‌دهد. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/groups" \
  -d '{"name":"Iran","note":"Low-latency inbounds","instances":[12,21]}'
```

```json
{
  "id": 3,
  "name": "Iran",
  "note": "Low-latency inbounds",
  "disabled": false,
  "allServers": false,
  "instances": [12, 21],
  "clients": 0,
  "createdAt": 1795919000
}
```

`400` با `field: name` یعنی نام خالی، بلند یا تکراری است.

## تغییر گروه

<Endpoint method="PUT" path="/api/groups/{id}" perm="groups.manage" :token="true" />

همان فیلدهای ساخت را می‌فرستد. تغییر همان لحظه به همهٔ کاربران گروه می‌رسد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/groups/3" \
  -d '{"name":"Iran","note":"Updated","allServers":true}'
```

```json
{
  "id": 3,
  "name": "Iran",
  "note": "Updated",
  "disabled": false,
  "allServers": true,
  "instances": [],
  "clients": 42,
  "createdAt": 1793000000
}
```

`404` یعنی چنین گروهی نیست یا خارج از دسترس حساب است.

## روشن، خاموش یا حذف چند گروه

<Endpoint method="POST" path="/api/groups/bulk" perm="groups.manage" :token="true" />

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `ids` | integer[] | بله | شناسهٔ گروه‌ها. |
| `action` | string | بله | `enable`، `disable` یا `delete`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/groups/bulk" \
  -d '{"ids":[3,4],"action":"disable"}'
```

پاسخ `204` بدون بدنه است. `400` یعنی کار یکی از آن سه نیست.

## افزودن یا حذف گروه کاربران

<Endpoint method="POST" path="/api/groups/assign" perm="groups.manage" :token="true" />

عضویت گروهی چند کاربر را در یک درخواست تغییر می‌دهد. گروه‌های دیگر کاربر می‌مانند.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `clients` | integer[] | بله | شناسهٔ کاربران. |
| `add` | integer[] | خیر | شناسهٔ گروه‌هایی که اضافه می‌شوند. |
| `remove` | integer[] | خیر | شناسهٔ گروه‌هایی که حذف می‌شوند. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/groups/assign" \
  -d '{"clients":[118,119],"add":[3],"remove":[2]}'
```

پاسخ `204` بدون بدنه است. `400` یعنی شناسهٔ کاربر یا گروه برای حساب معتبر نیست.

## صفحه‌های مرتبط

- [کاربران](/fa/api/reference/clients): فیلد `groups` روی کاربر.
- [اینباندها](/fa/api/reference/inbounds): اینباندهایی که گروه می‌دهد.
- [گروه‌ها](/fa/use/groups): صفحهٔ پنل و قواعدش.
- [نقش‌ها و نماینده‌های فروش](/fa/use/resellers): گروه‌های قابل استفادهٔ نماینده.
