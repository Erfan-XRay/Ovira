# وب‌هوک

وب‌هوک رویدادهایی را که یک حساب می‌تواند ببیند به یک آدرس وب می‌فرستد تا ربات یا فروشگاه شما به آن‌ها واکنش نشان دهد. آن را در **تنظیمات ← وب‌هوک** بسازید، یا با `POST webhooks` و دسترسی `webhooks.manage`. هر وب‌هوک فقط چیزی را می‌گیرد که صاحبش می‌تواند ببیند؛ نماینده هرگز کاربران نمایندهٔ دیگر را نمی‌گیرد.

راز امضا یک بار نشان داده می‌شود: هنگام ساخت وب‌هوک یا تعویض راز. آن را مثل رمز نگه دارید.

## درخواست

پنل یک `POST` با بدنهٔ JSON می‌فرستد:

```json
{
  "id": 1042,
  "type": "client.expired",
  "version": 1,
  "at": 1794844424,
  "data": { "clientId": 35, "name": "order-1042" }
}
```

| فیلد | معنی |
|---|---|
| `id` | شناسهٔ رویداد. تلاش دوباره برای همان رویداد همان شناسه را دارد. |
| `type` | چه اتفاقی افتاده؛ فهرست پایین را ببینید. |
| `version` | نسخهٔ قالب، `1`. |
| `at` | زمان رویداد، ثانیهٔ یونیکس. |
| `data` | جزئیات که به نوع بستگی دارد. هرگز توکن، رمز یا کلید نیست. |

هدرها:

| هدر | مقدار |
|---|---|
| `Content-Type` | `application/json` |
| `User-Agent` | `Ovira-Webhook/<نسخهٔ پنل>` |
| `X-Ovira-Event` | نوع رویداد. |
| `X-Ovira-Delivery` | `<شناسهٔ رویداد>-<شناسهٔ وب‌هوک>`؛ برای همهٔ تلاش‌های دوباره یکی است. |
| `X-Ovira-Signature` | `t=<زمان یونیکس>,v1=<HMAC-SHA256 به‌صورت hex>` |

در ۱۰ ثانیه با یک پاسخ `2xx` جواب بدهید. شکست بعد از ۱ دقیقه، ۵ دقیقه، ۳۰ دقیقه، ۲ ساعت و ۶ ساعت دوباره امتحان می‌شود و بعد رها می‌شود. رویدادها به ترتیب به وب‌هوک می‌رسند: رویداد بعدی منتظر قبلی می‌ماند. پاسخ `429` همراه هدر `Retry-After` رعایت می‌شود و `410 Gone` وب‌هوک را خاموش می‌کند. ریدایرکت دنبال نمی‌شود.

آدرس باید `http` یا `https` باشد. آدرس‌های داخل شبکهٔ خصوصی، روی خود سرور پنل یا نودهایش رد می‌شوند؛ فقط مالک پنل می‌تواند برای یک وب‌هوک آن‌ها را مجاز کند.

## نوع رویدادها

| گروه | نوع‌ها |
|---|---|
| کاربران | `client.created`، `client.bulk_created`، `client.deleted`، `client.renewed`، `client.quota_warning`، `client.limited`، `client.expiring`، `client.expired`، `client.first_connect`، `client.reset` |
| نماینده‌ها | `reseller.pool_low`، `reseller.expiring` |
| سرورها | `node.disconnected`، `node.connected`، `node.disk_high`، `node.memory_high` |
| سیستم | `admin.login_new_ip`، `backup.failed`، `license.expiring` |

نوع‌های تازه ممکن است اضافه شوند؛ نوع‌های ناشناس را نادیده بگیرید. می‌توان وب‌هوک را به چند نوع مشخص محدود کرد. دکمهٔ **ارسال آزمایشی** یک رویداد `webhook.test` می‌فرستد.

## لینک اشتراک

به‌طور پیش‌فرض خاموش است. وقتی **افزودن لینک اشتراک** روشن باشد، رویدادهای مربوط به کاربری که هنوز وجود دارد `data.subLink` را دارند. این لینک به اتصال کاربر دسترسی می‌دهد، پس فقط برای گیرنده‌ای که به آن اعتماد دارید روشن کنید. اگر پنل هنوز آدرس خودش را نداند لینک نمی‌آید؛ یک بار پنل را به‌عنوان مالک باز کنید یا آدرس اشتراک را در تنظیمات پنل بگذارید.

## بررسی امضا

رشتهٔ `"<t>.<بدنهٔ خام>"` را با راز و HMAC-SHA256 امضا کنید و با `v1` به‌صورت زمان‌ثابت مقایسه کنید. بایت‌های خام بدنه را به کار ببرید، نه نسخهٔ دوباره‌کدشده، و `t` قدیمی‌تر از ۵ دقیقه را رد کنید.

Python:

```python
import hashlib, hmac, time

def verify(secret: str, header: str, body: bytes) -> bool:
    parts = dict(p.split("=", 1) for p in header.split(","))
    t, v1 = parts.get("t", ""), parts.get("v1", "")
    if not t.isdigit() or abs(time.time() - int(t)) > 300:
        return False
    want = hmac.new(secret.encode(), t.encode() + b"." + body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(want, v1)
```

Node:

```js
import { createHmac, timingSafeEqual } from "node:crypto";

export function verify(secret, header, body /* Buffer */) {
  const parts = Object.fromEntries(header.split(",").map((p) => p.split("=")));
  const t = parts.t, v1 = parts.v1 ?? "";
  if (!/^\d+$/.test(t ?? "") || Math.abs(Date.now() / 1000 - Number(t)) > 300) return false;
  const want = createHmac("sha256", secret).update(`${t}.`).update(body).digest("hex");
  return v1.length === want.length && timingSafeEqual(Buffer.from(want), Buffer.from(v1));
}
```

## درخواست‌ها

| درخواست | کار |
|---|---|
| `GET webhooks` | وب‌هوک‌های شما. مالک همه را می‌بیند. |
| `POST webhooks` | ساخت وب‌هوک. راز را یک بار برمی‌گرداند. |
| `PUT webhooks/{id}` | تغییر `url`، `events`، `includeSubLink` و `enabled`. |
| `DELETE webhooks/{id}` | حذف. |
| `POST webhooks/{id}/test` | فرستادن رویداد آزمایشی و برگرداندن پاسخ. |
| `POST webhooks/{id}/rotate-secret` | تعویض راز و برگرداندن راز جدید، یک بار. |
| `GET webhooks/{id}/deliveries` | ۵۰ ارسال آخر با وضعیت و خطا. |

همهٔ آن‌ها دسترسی `webhooks.manage` می‌خواهند که مثل هر دسترسی دیگر می‌توان به توکن داد. فیلدهای دقیق را در [سند OpenAPI](./openapi) ببینید.
