# سند OpenAPI

همهٔ مسیرهای این صفحه‌ها در یک سند OpenAPI 3.1 توصیف شده‌اند. می‌توانید آن را در کلاینت API وارد کنید، کلاینت تایپ‌دار بسازید، یا به ابزار تست بدهید. این صفحه محل دانلود، نحوهٔ وارد کردن و ساختن کلاینت را توضیح می‌دهد.

## دانلود

نسخه‌ای که با این مستندات می‌خواند:

[openapi.json](/openapi.json)

با curl یا مرورگر ذخیره کنید:

```bash
curl -fsSL -o openapi.json https://erfan-xray.github.io/Ovira/openapi.json
```

هر پنل هم سند دقیق نسخهٔ در حال اجرای خودش را می‌دهد:

```text
https://panel.example.com/<secret-path>/api/openapi.json
```

`info.version` آنجا نسخهٔ پنل است، پس کلاینتی که از یک پنل ساخته می‌شود با همان پنل می‌خواند. نسخهٔ سند این مستندات `0.9.9-beta.6` است. برای اتصال به پنل نصب‌شده، سند همان پنل را بگیرید.

## پیش از وارد کردن

مسیرهای سند با `/api/` شروع می‌شوند و server آن ریشهٔ پنل است. آدرس پایهٔ ابزار را آدرس پنل و مسیر مخفی بگذارید، **بدون** `api/` انتهایی:

```text
https://panel.example.com/<secret-path>/
```

آن‌وقت `/api/clients` درست حل می‌شود. **آدرس پایه API** را از تنظیمات اینجا نگذارید: آن مقدار خودش به `/api` ختم می‌شود و مسیرهای سند دوباره اضافه‌اش می‌کنند. اگر ابزار متغیر می‌خواهد، آدرس پنل و مسیر مخفی را برای `baseUrl` یا `host` بگذارید.

توکن bearer را به‌عنوان متغیر محیطی یا متغیر collection بگذارید، نه داخل فایل. سند `bearerAuth` را با `Authorization: Bearer ovk_...` اعلام می‌کند. درخواست توکن هدر CSRF نمی‌خواهد.

مسیرهای اشتراک (`/{subPath}/{token}/...`) از آدرس عمومی بدون مسیر مخفی پنل استفاده می‌کنند. برای فراخوانی آن‌ها در کلاینت واردشده یا تولیدشده، آدرس سرور را جداگانه تنظیم کنید.

## Postman

1. **Import** را باز کنید.
2. **File** را بزنید و `openapi.json` را انتخاب کنید.
3. به‌صورت collection وارد کنید.
4. **Variables** مجموعه را باز کنید و آدرس پایه را آدرس پنل و مسیر مخفی بگذارید.
5. یک هدر **Authorization** با `Bearer ovk_...` در سطح مجموعه اضافه کنید، یا از **Bearer Token** خود Postman استفاده کنید.

Postman پارامترهای مسیر، query و بدنه‌های JSON را از سند می‌خواند.

## Insomnia

1. **Import** را باز کنید.
2. **From File** را بزنید و `openapi.json` را انتخاب کنید.
3. collection یا پوشهٔ درخواست را برای ورود انتخاب کنید.
4. آدرس پایهٔ محیط را آدرس پنل و مسیر مخفی بگذارید.
5. توکن bearer را در محیط بگذارید و در زبانهٔ **Auth** استفاده کنید.

## Bruno

1. منوی collection را باز کنید و **Import Collection** را بزنید.
2. **OpenAPI V3** را انتخاب و `openapi.json` را باز کنید.
3. متغیر محیطی آدرس پایه را بگذارید.
4. در سطح collection احراز هویت **Bearer** با `{{token}}` بگذارید.

Bruno درخواست‌های واردشده را فایل نگه می‌دارد، پس می‌توانند بدون کلید محرمانه در مخزن نگهداری شوند.

## ساخت کلاینت

[OpenAPI Generator](https://openapi-generator.tech/docs/installation/) می‌تواند برای زبان دلخواه کلاینت بسازد. بستهٔ npm آن به Java نیاز دارد. پشتیبانی از OpenAPI 3.1 به مولد و نسخهٔ آن بستگی دارد؛ کلاینت تولیدشده را پیش از استفاده بازبینی و آزمایش کنید. با Node:

```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g python \
  -o ./ovira-client
```

`python` را با مولد دیگری عوض کنید، مثلاً `typescript-fetch`، `go` یا `csharp`. گزینه‌های خود مولد نام بسته، کتابخانه و نوع تاریخ را تعیین می‌کنند:

```bash
npx @openapitools/openapi-generator-cli generate \
  -i openapi.json \
  -g typescript-fetch \
  -o ./ovira-client \
  --additional-properties=npmName=ovira-client,supportsES6=true
```

بعد `README.md` تولیدشده را برای نام دقیق کلاس‌ها و متدها بخوانید. بیشتر مولدها شیء `Configuration` یا `ApiClient` با base path و توکن bearer می‌سازند؛ base path را مثل بالا آدرس پنل و مسیر مخفی بگذارید.

کلاینت تولیدشده از سند پیروی می‌کند. گروه‌ها و اینباندهای مجاز نماینده را نمی‌داند، پس ساخت کاربر هنوز به شناسهٔ گروه یا اینباندی نیاز دارد که حساب مجاز است.

## هم‌گام نگه داشتن

اگر به فیلد یا مسیر تازه‌تری وابسته‌اید، پس از به‌روزرسانی، `api/openapi.json` خود پنل را دوباره دانلود کنید. نسخهٔ این مستندات با انتشار مستندات عوض می‌شود، نه با هر ساخت پنل.

## صفحه‌های مرتبط

- [نمای کلی API](/fa/api/): آدرس پایه، ورود و خطاها.
- [توکن‌های API](/fa/api/tokens): ساختن توکنی که سند انتظار دارد.
- [مرجع API](/fa/api/reference/): همان مسیرها با متن و مثال.

راهنمای وارد کردن: [Postman](https://learning.postman.com/docs/integrations/available-integrations/working-with-openAPI/)، [Insomnia](https://developer.konghq.com/insomnia/import-export/)، [Bruno](https://blog.usebruno.com/keep-your-api-collections-in-sync-with-openapi-sync). نام منوها ممکن است در نسخه‌های مختلف فرق کند.
