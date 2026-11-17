# Xray

اینباندهای Xray اینباند معمولی با `kind: "xray"` هستند، پس با مسیرهای [اینباندها](/fa/api/reference/inbounds) ساخته، فهرست و ویرایش می‌شوند. مسیرهای این صفحه فهرست سناریوها، فهرست سایت‌های پوششی، ابزارهای هر اینباند، لینک‌های کاربر و تنظیم برنامه‌های پروکسی را اضافه می‌کنند.

## ساخت اینباند

فقط یک سناریو بفرستید. سرور بقیه را پر می‌کند.

<Endpoint method="POST" path="/api/instances" perm="inbounds.manage" :token="true" />

```bash
curl -sS -X POST -H "Authorization: Bearer $OVIRA_TOKEN" -H "Content-Type: application/json" \
  -d '{"kind":"xray","name":"de-1","nodeId":3,"preset":"direct"}' "$BASE/instances"
```

`preset` یکی از `direct`، `cdn`، `relay`، `vmess-classic`، `trojan`، `shadowsocks` یا `manual` است. `GET xray/presets` می‌گوید هر سناریو چه فیلد اضافه‌ای می‌خواهد.

## مسیرها

| متد و مسیر | مجوز | کار |
|---|---|---|
| `GET /api/xray/presets` | `inbounds.view` | سناریوها و آنچه هرکدام می‌خواهد. |
| `GET /api/xray/combos` | `inbounds.view` | ترکیب‌های مجاز پروتکل، انتقال و امنیت. |
| `GET /api/xray/sni` | `inbounds.view` | فهرست سایت‌های پوششی. |
| `POST /api/xray/sni/test` | `inbounds.manage` | آزمایش یک سایت. |
| `POST /api/xray/sni/scan` | `inbounds.manage` | شروع جستجوی سایت‌های مناسب. یک کار برمی‌گرداند. |
| `GET /api/xray/sni/jobs/{job}` | `inbounds.manage` | وضعیت و نتیجهٔ یک کار. |
| `POST /api/instances/{id}/xray/reality-keys` | `inbounds.manage` | ساخت کلیدهای تازه برای اینباند. |
| `GET /api/instances/{id}/xray/proxy-check` | `inbounds.manage` | بررسی اینباند پشت رله. |
| `POST /api/instances/{id}/xray/sni/replace` | `inbounds.manage` | عوض کردن سایت پوششی اینباند. |
| `POST /api/instances/{id}/xray/certificate` | `inbounds.manage` | تلاش دوباره برای گواهی. |
| `GET /api/clients/{id}/xray` | `clients.view` | لینک‌های Xray یک کاربر. |
| `GET /api/clients/{id}/xray/{instance}/qr` | `clients.view` | کد QR یک لینک. |
| `POST /api/clients/{id}/xray/rotate` | `clients.edit` | عوض کردن لینک‌های Xray کاربر. |
| `GET` و `PUT /api/settings/sub-apps` | مالک | برنامه‌های پروکسی صفحه‌های اشتراک. |

مالک می‌تواند برنامه‌های پروکسی را برای هر حساب با `/api/admins/{id}/sub-apps` هم تنظیم کند، و حسابی با `subdomains.manage` برای خودش با `/api/account/sub-apps`.
