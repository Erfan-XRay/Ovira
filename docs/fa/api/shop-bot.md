# ربات فروش

این صفحه درخواست‌های API پنل برای یک ربات فروش را نشان می‌دهد: مشتری پرداخت می‌کند، ربات کاربر می‌سازد، لینک اشتراک و کد QR را می‌فرستد، بعداً تمدید می‌کند و در پایان سفارش کاربر را خاموش یا حذف می‌کند، یا لینک اشتراکش را عوض می‌کند. مثال برای ربات نماینده است، چون حالت رایج همین است.

دستور کار از این درخواست‌ها استفاده می‌کند:

| مرحله | درخواست | دسترسی |
|---|---|---|
| پیدا کردن کاربر موجود | `GET clients?q=NAME` | `clients.view` |
| ساخت کاربر | `POST clients` | `clients.create` |
| فرستادن لینک و QR | `GET clients/{id}/qr` | `clients.view` |
| خواندن مصرف | `GET clients/{id}/usage` | `clients.view` |
| تمدید | `POST clients/{id}/extend` | `clients.edit`، با محدودیت‌های هر کاربر حساب |
| خاموش یا روشن کردن | `POST clients/{id}/disable` یا `/enable` | `clients.edit` |
| تعویض لینک | `POST clients/{id}/rotate-sub` | `clients.edit` |
| حذف | `DELETE clients/{id}` | `clients.delete` |

## توکن

در **تنظیمات → API** برای حساب نماینده یک توکن سفارشی با این دسترسی‌ها بسازید:

- `clients.view`
- `clients.create`
- `clients.edit`
- `clients.reset`

`clients.delete` را فقط وقتی اضافه کنید که ربات اجازهٔ حذف داشته باشد. **آی‌پی‌های مجاز** را روی آدرس یا شبکهٔ ربات بگذارید و **انقضا** را به اندازهٔ عمر ربات انتخاب کنید. توکن یک‌بار نشان داده می‌شود؛ آن را مثل یک رمز نگه دارید.

توکن نماینده فقط به کاربران خودش می‌رسد. حساب نباید خاموش، منقضی یا بدون ترافیک باشد و باید حداقل یک گروه یا اینباند مجاز داشته باشد. در غیر این صورت API پاسخ `403` با `account_blocked`، یا `400` وقتی هیچ گروه یا اینباندی مجاز نیست، می‌دهد.

## ساخت کاربر برای سفارش

برای اجازهٔ اتصال، `enabled: true` بفرستید. اگر ارسال نشود یا false باشد، کاربر خاموش ساخته می‌شود. گروه `3` را با یکی از گروه‌های مجاز حساب عوض کنید.

نامی انتخاب کنید که برای سفارش ثابت بماند، مثلاً `order-1042` یا شناسهٔ Telegram مشتری. نام، نام کاربری VPN هم هست.

قواعد `name`: ۲ تا ۴۸ نویسهٔ ASCII؛ حروف لاتین، رقم، نقطه، خط تیره، زیرخط یا `@`، با حرف یا رقم در ابتدا. در کل پنل یکتاست، نه فقط داخل نماینده.

فیلدهای سفارش این‌طور به API وصل می‌شوند:

| مقدار سفارش | فیلد | توضیح |
|---|---|---|
| نام مشتری یا شناسهٔ سفارش | `name` | کوتاه و ثابت نگه دارید. |
| ترافیک به گیگابایت | `trafficLimit` | بایت: ۵۰ گیگابایت برابر `50 * 1024**3` است. `0` یعنی بدون محدودیت، ولی ممکن است نماینده اجازهٔ فرستادنش را نداشته باشد. |
| روزهای سرویس | `expireAfterDays` | از اولین اتصال شروع می‌شود. برای تاریخ ثابت از `expireAt` با زمان یونیکس استفاده کنید. |
| دستگاه‌ها | `maxDevices` | `0` یعنی بدون سقف، تا اندازهٔ محدودیت نماینده. |
| گروه | `groups` | شناسهٔ گروه‌هایی که به نماینده داده شده. |
| اینباند تکی | `instances` | شناسهٔ اینباندهایی که به نماینده داده شده. نماینده باید گروه یا اینباند بدهد. |
| یادداشت | `note` | متن آزاد، حداکثر ۵۰۰ بایت UTF-8. |
| تماس | `contact` | حداکثر ۱۲۰ بایت UTF-8. |

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients" \
  -d '{
    "name": "order-1042",
    "enabled": true,
    "trafficLimit": 53687091200,
    "expireAfterDays": 30,
    "maxDevices": 2,
    "groups": [3],
    "note": "Telegram 1042",
    "contact": "@customer"
  }'
```

پاسخ `201` با کاربر تازه است. `id`، `subUrl`، `status` و `expireAt` را بخوانید.

## فرستادن لینک اشتراک و QR

`subUrl` لینکی است که می‌فرستید. برای تصویر QR، کد QR کاربر را از پنل بگیرید:

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -o order-1042.png \
  "$BASE/clients/119/qr"
```

پاسخ یک PNG ۳۲۰ پیکسلی از همان لینک است. تصویر و `subUrl` را با هم بفرستید و به مشتری بگویید لینک را خصوصی نگه دارد: لینک، رمز ورود صفحهٔ اشتراک است.

## تمدید سفارش

`POST clients/{id}/extend` روز و ترافیک اضافه می‌کند و می‌تواند مصرف را در همان درخواست صفر کند.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/clients/119/extend" \
  -d '{
    "days": 30,
    "bytes": 53687091200,
    "resetUsage": true
  }'
```

| فیلد | نوع | معنی |
|---|---|---|
| `days` | integer | روزهای اضافه، ۰ تا ۳۶۵۰. شمارش از حالا یا تاریخ پایان فعلی، هر کدام دیرتر باشد، شروع می‌شود. |
| `bytes` | integer | بایت‌هایی که به سقف ترافیک کاربر اضافه می‌شود. وقتی سقف `0` (بی‌نهایت) باشد اثری ندارد. |
| `resetUsage` | boolean | مصرف آپلود و دانلود را هم صفر می‌کند. |

پاسخ کاربر پس از تغییر است. محدودیت ترافیک و روز هر کاربر حساب هنوز اعمال می‌شود؛ درخواست بیشتر از آن‌ها `400` با `field: bytes` یا `field: days` می‌دهد.

روی کاربری که نه تاریخ پایان دارد و نه عمر، `days` کاری نمی‌کند. روی کاربر بی‌نهایت، `bytes` کاری نمی‌کند. اگر سفارش می‌تواند هر کدام از این دو حالت باشد، اول کاربر را بخوانید.

## خواندن مصرف

`GET clients/{id}` کاربر را در شیء `client` برمی‌گرداند. فیلدهای `usedUp`، `usedDown`، `trafficLimit`، `status`، `online` و `lastOnlineAt` را از `response.client` بخوانید. `GET clients/{id}/usage` نقاط مصرف را در ۲۴ ساعت، ۷، ۳۰ یا ۹۰ روز برمی‌گرداند.

```bash
curl -sS \
  -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/clients/119/usage?range=7d"
```

ترافیک مصرف‌شده برابر `usedUp + usedDown` است. کاربر با `status: "limited"` سقفش را مصرف کرده، با `expired` از تاریخ پایان گذشته و با `disabled` خاموش شده. فیلد `ownerBlock` روی کاربر می‌گوید سهمیه یا تاریخ پایان خود نماینده مانع است.

## خاموش و روشن کردن

کاربر خاموش نمی‌تواند وصل شود و اتصال‌های بازش بسته می‌شود. وقتی سفارش ادامه پیدا کرد روشنش کنید.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/clients/119/disable"
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/clients/119/enable"
```

هر دو کاربر را برمی‌گردانند. روشن کردن وقتی سهمیه یا سقف کاربر پر است ممکن است `402` بدهد.

## تعویض لینک اشتراک

اگر لینک لو رفت، آن را تعویض کنید. لینک قدیمی همان لحظه از کار می‌افتد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/clients/119/rotate-sub"
```

پاسخ کاربر با `subUrl` تازه است. لینک و QR تازه را برای مشتری بفرستید؛ لینک قبلی دیگر کار نمی‌کند.

## حذف

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/clients/119"
```

```json
{ "ok": true }
```

حذف همان لحظه گواهی را باطل و اتصال‌های باز را می‌بندد. مشتری‌ای که پروفایل را نگه داشته دیگر وصل نمی‌شود. این مرحله به `clients.delete` نیاز دارد.

## تلاش دوباره و ثبت سفارش

ربات باید هر سفارش را ماندگار ثبت کند: شناسهٔ سفارش، شناسهٔ کاربر، تغییر درخواستی و نتیجهٔ آن. درخواست‌های یک سفارش را هم‌زمان اجرا نکنید. API کلید idempotency یا دفتر ثبت سفارش ندارد.

1. **ساخت:** نامی ثابت و مختص همین ربات و سفارش انتخاب کنید. پس از timeout یا `400` با `field: name`، با `GET clients?q=NAME` جست‌وجو کنید، همهٔ صفحه‌ها را بخوانید و `name` را دقیق مقایسه کنید. فقط کاربری را به کار ببرید که متعلق به همان سفارش است. خالی بودن نتیجه ثابت نمی‌کند درخواست اول شکست خورده؛ ممکن است هنوز در حال اجرا باشد. ساخت را فقط با همان نام تکرار کنید؛ یکتا بودن نام مانع ساخت کاربر دوم با همان نام می‌شود.
2. **تمدید:** روز و ترافیک اضافه می‌کند؛ تکرار کور ممکن است تمدید را دو بار اعمال کند. پس از نتیجهٔ نامعلوم، شیء `client` در پاسخ `GET clients/{id}` را با سفارش ثبت‌شده تطبیق دهید. تغییر تاریخ پایان به‌تنهایی ثابت نمی‌کند کدام سفارش آن را عوض کرده. اگر نتیجه روشن نیست، سفارش را برای بررسی متوقف کنید.
3. **صفر کردن مصرف، تعویض لینک و قطع اتصال:** کورکورانه تکرار نکنید. بازنشانی ممکن است مصرف پس از درخواست اول را پاک کند؛ تعویض، لینک دیگری می‌سازد؛ قطع اتصال ممکن است نشست تازه‌ای را ببندد. اول وضعیت فعلی را بخوانید. روشن و خاموش کردن وقتی هنوز با وضعیت دلخواه مطابقت دارد قابل تکرار است. حذف دوباره، پس از حذف کاربر، ممکن است `404` بدهد.

## خطاهای نماینده که ربات باید مدیریت کند

| پاسخ | معنی | کار ربات |
|---|---|---|
| `400`، `field: name` | نام گرفته شده یا نامعتبر است. | نام را جست‌وجو و همان کاربر را به کار ببرید، یا نام را درست کنید. |
| `400`، `field: instances` | گروه یا اینباند انتخاب نشده، یا مجاز نیست. | از گروه یا اینباند مجاز حساب استفاده کنید. |
| `400`، `field: trafficLimit` | کاربر سقف ندارد، از سقف هر کاربر بیشتر است، یا مقدار منفی است. | سقفی داخل قواعد حساب بگذارید. |
| `400`، `field: expireAt` یا `days` | کاربر تاریخ پایان ندارد یا از روزهای مجاز حساب بیشتر است. | تاریخی داخل روزهای مجاز بگذارید. |
| `400`، `field: maxDevices` | سقف دستگاه از محدودیت حساب بیشتر یا خارج از بازه است. | از ۱ تا سقف حساب بگذارید. |
| `402` | لایسنس، سهمیهٔ نماینده یا سقف کاربر حساب، کاربر را رد می‌کند. | متوقف شوید و از مالک پنل سهمیه یا سقف بیشتر بخواهید. |
| `403`، `code: account_blocked` | نماینده خاموش، منقضی یا بدون ترافیک است. `params.reason` می‌گوید کدام. | ساخت و تمدید را متوقف کنید و به اپراتور بگویید. |
| `403` بدون کد | توکن دسترسی را ندارد، یا کاربر خارج از دسترس نماینده است. | توکن یا سفارش را درست کنید. |
| `404` | کاربر حذف شده یا خارج از دسترس نماینده است. | سفارش را تمام‌شده بدانید. |
| `429` | تلاش ناموفق زیاد از این آدرس. | صبر کنید و دوباره بفرستید. |

## یک اسکریپت کامل

این نمونهٔ اجرایی API از `requests` استفاده می‌کند (`python -m pip install requests`). توکن را از محیط می‌خواند، پیش از ساخت کاربر را جست‌وجو می‌کند و تصویر QR را دانلود می‌کند. `GROUP_ID` را با گروه مجاز عوض کنید و فایل `qr_file` را از طریق پلتفرم ربات بفرستید. تأیید پرداخت، ارسال پیام و ثبت ماندگار سفارش باید در ربات شما پیاده شود؛ این اسکریپت آن‌ها را انجام نمی‌دهد.

```python
import os
from pathlib import Path
import requests

BASE = os.environ["BASE"]
TOKEN = os.environ["OVIRA_TOKEN"]
GROUP_ID = int(os.environ.get("OVIRA_GROUP_ID", "3"))
GB = 1024 ** 3  # 1 GiB; the panel labels this as GB

session = requests.Session()
session.headers.update({"Authorization": f"Bearer {TOKEN}"})


class ApiError(Exception):
    def __init__(self, status, body):
        self.status = status
        self.body = body
        super().__init__(f"{status}: {body.get('error')} (code={body.get('code')}, field={body.get('field')})")


def call(method, path, **kwargs):
    response = session.request(method, f"{BASE}/{path.lstrip('/')}", timeout=30, **kwargs)
    try:
        body = response.json()
    except ValueError:
        body = {"error": response.text}
    if not response.ok:
        raise ApiError(response.status_code, body)
    return body


def find_client(name):
    page_number = 1
    while True:
        page = call("GET", "clients", params={"q": name, "page": page_number, "size": 100})
        for client in page["items"]:
            if client["name"] == name:
                return client
        if not page["items"] or page_number * page["size"] >= page["total"]:
            return None
        page_number += 1


def ensure_client(order):
    name = f"order-{order['id']}"
    found = find_client(name)
    if found:
        return found, False
    try:
        client = call("POST", "clients", json={
            "name": name,
            "enabled": True,
            "trafficLimit": order["gb"] * GB,
            "expireAfterDays": order["days"],
            "maxDevices": order.get("devices", 2),
            "groups": [GROUP_ID],
            "note": order.get("note", ""),
            "contact": order.get("contact", ""),
        })
        return client, True
    except ApiError as error:
        if error.status == 400 and error.body.get("field") == "name":
            found = find_client(name)
            if found:
                return found, False
        raise
    except requests.RequestException:
        # ممکن است درخواست به پنل رسیده باشد. پیش از تلاش دوباره جست‌وجو کنید.
        found = find_client(name)
        if found:
            return found, False
        raise


def deliver(client):
    response = session.get(f"{BASE}/clients/{client['id']}/qr", timeout=30)
    response.raise_for_status()
    if not response.headers.get("Content-Type", "").startswith("image/png"):
        raise ValueError("Expected a PNG QR image")
    qr_file = Path(f"client-{client['id']}.png")
    qr_file.write_bytes(response.content)
    # Upload this file with your messaging platform; never send the API token.
    return {"link": client["subUrl"], "qr_file": str(qr_file)}


def renew(client, days=30, gb=50, reset=False):
    return call("POST", f"clients/{client['id']}/extend", json={
        "days": days,
        "bytes": gb * GB,
        "resetUsage": reset,
    })


def usage(client):
    data = call("GET", f"clients/{client['id']}/usage", params={"range": "7d"})
    used = sum(point["up"] + point["down"] for point in data["points"])
    return {"used": used, "points": data["points"]}


def set_enabled(client, on):
    action = "enable" if on else "disable"
    return call("POST", f"clients/{client['id']}/{action}")


def rotate(client):
    return call("POST", f"clients/{client['id']}/rotate-sub")


def delete(client):
    return call("DELETE", f"clients/{client['id']}")


if __name__ == "__main__":
    order = {"id": 1042, "gb": 50, "days": 30, "devices": 2, "contact": "@customer"}
    client, created = ensure_client(order)
    print("created" if created else "already existed", client["id"])
    print(deliver(client))
    print("usage", usage(client)["used"])
    # renew(client, days=30, gb=50, reset=True)
    # set_enabled(client, False)
    # client = rotate(client)
    # delete(client)
```

## صفحه‌های مرتبط

- [مرجع کاربران](/fa/api/reference/clients): همهٔ فیلدها و کارهای کاربر.
- [توکن‌های API](/fa/api/tokens): دسترسی‌ها و فهرست آدرس‌های مجاز.
- [شروع سریع](/fa/api/quickstart): همین درخواست‌ها با curl، Python و Node.
- [ترافیک، سهمیه و محدودیت‌ها](/fa/how/traffic): نحوهٔ شمارش ترافیک.
- [نقش‌ها و نماینده‌های فروش](/fa/use/resellers): سهمیه و قواعد هر کاربر.
