<div align="center">

<a href="https://erfan-xray.github.io/Ovira/fa/"><img src="assets/hero.webp" alt="اویرا: پنل VPN روی سرورهای خودتان" width="100%"></a>

<br>

[![Release](https://img.shields.io/github/v/release/Erfan-XRay/Ovira?style=for-the-badge&color=c4f82a&labelColor=0b1300&label=release)](https://github.com/Erfan-XRay/Ovira/releases/latest) [![Downloads](https://img.shields.io/github/downloads/Erfan-XRay/Ovira/total?style=for-the-badge&color=46d6e6&labelColor=0b1300)](https://github.com/Erfan-XRay/Ovira/releases) [![Platform](https://img.shields.io/badge/linux-amd64%20%C2%B7%20arm64-c4f82a?style=for-the-badge&labelColor=0b1300)](#نصب) [![Free plan](https://img.shields.io/badge/free%20plan-5%20clients%20%C2%B7%202%20nodes-46d6e6?style=for-the-badge&labelColor=0b1300)](#پلنها)

**[سایت و مستندات](https://erfan-xray.github.io/Ovira/fa/)** &nbsp;·&nbsp; **[Documentation](https://erfan-xray.github.io/Ovira/)** &nbsp;·&nbsp; **[English README](README.md)** &nbsp;·&nbsp; **[Releases](https://github.com/Erfan-XRay/Ovira/releases)**

</div>

<br>

<div dir="rtl">

**اویرا** (Ovira) یک پنل VPN برای سرورهای لینوکسی خودتان است: یک فایل اجرایی که رابط وب هم داخلش است. کاربر بسازید با محدودیت حجم و زمان، به هر کدام یک لینک اشتراک بدهید و **OpenVPN، WireGuard / AmneziaWG، OpenConnect، IKEv2، L2TP/IPsec و Xray (‏VLESS، VMess، Trojan، Shadowsocks)** را روی سرور خود پنل و روی هر تعداد نودی که پلنتان اجازه می‌دهد اجرا کنید. با **مسیریابی خروجی** ترافیک را از سرورهای دیگر بیرون بفرستید. بدون داکر، بدون راه‌اندازی دیتابیس، بدون ویرایش فایل تنظیمات.

> **اویرا ۲٫۰ منتشر شد.** اینباندهای Xray با VLESS، VMess، Trojan و Shadowsocks، لینک اشتراک برای برنامه‌های پراکسی، اعلان تلگرام و وب‌هوک، قالب کاربر، بکاپ زمان‌بندی‌شده به S3 و SFTP و سلامت نودها. [تازه‌های ۲٫۰](#تازههای-۲۰) را ببینید.

<table dir="rtl">
<tr>
<td width="33%" valign="top">

### ⚡ یک دستور
یک اسکریپت پنل (یا نود) را نصب می‌کند، گواهی HTTPS می‌گیرد و اطلاعات ورود را چاپ می‌کند. بعد از آن دستور `ovira` روی سرور، منوی کنترل شماست.

</td>
<td width="33%" valign="top">

### 🌍 چند سرور
در چند دقیقه نود اضافه کنید. یک کاربر روی همهٔ آن‌ها کار می‌کند و سقف دستگاهش روی همهٔ سرورها و همهٔ پروتکل‌ها با هم شمرده می‌شود.

</td>
<td width="33%" valign="top">

### 📱 کاربران دوستش دارند
هر کاربر صفحه‌ای دارد با حجم باقی‌مانده، روزهای مانده، اتصال با یک لمس و فایل‌های آمادهٔ تنظیم، به فارسی و انگلیسی.

</td>
</tr>
</table>

## نصب

روی یک سرور تازه با **اوبونتو 22.04 یا جدیدتر** (22.04، 24.04، 26.04) و با دسترسی root:

</div>

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh)
```

<div dir="rtl">

اسکریپت خودش اویرا را می‌گیرد، پس لازم نیست چیزی از قبل کپی کنید، و می‌پرسد چه چیزی نصب شود:

| انتخاب | چیست |
|---|---|
| **پنل** | پنل وب. پورت پنل (پیش‌فرض `2053`)، پورت جداگانهٔ اختیاری برای ساب، اینکه این سرور خودش هم نود باشد یا نه، و روش HTTPS را می‌پرسد: گواهی Let's Encrypt برای دامنه، برای آی‌پی سرور، یا هیچ. بعد آدرس و رمز را چاپ می‌کند. |
| **نود** | یک سرور VPN اضافه برای پنلی که جای دیگر اجرا می‌شود. در پنل، **نودها ← اتصال نود** دستور دقیق را آمادهٔ کپی نشان می‌دهد. |

دانلودها با چک‌سام نسخه، و اگر سرور OpenSSL 3 داشته باشد با امضای نسخه هم، بررسی می‌شوند. سؤال نمی‌خواهید؟ همه‌چیز را می‌شود به‌صورت گزینه داد؛ [راهنمای نصب](https://erfan-xray.github.io/Ovira/fa/start/install-panel) را ببینید.

</div>

<details>
<summary><b>نصب نود، پنل خالی یا اسکریپتی</b></summary>

<br>

```bash
# یک نود که فقط به پنل شما جواب می‌دهد
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/node.sh) --panel-ip PANEL_IP

# پنل خالی که فقط نودها را مدیریت می‌کند
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) panel --panel-only

# بدون هیچ سؤالی، لینک‌های ساب روی پورت جدا
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) panel --yes \
  --port 8443 --sub-port 2096 --ssl domain --domain panel.example.com --email you@example.com
```

<div dir="rtl">

نصب‌کننده هیچ اینباندی نمی‌سازد؛ اینباندها را در پنل، بخش «اینباندها»، بسازید و به یک نود وصل کنید. سرور فقط‌پنل را بعداً با `ovira local-node enable` می‌شود نود هم کرد.

</div>

</details>

<div dir="rtl">

## تازه‌های ۲٫۰

| | |
|---|---|
| **اینباندهای Xray** | ‏VLESS، VMess، Trojan و Shadowsocks با Reality، TLS و transportهای رایج. یک سناریو (مستقیم، پشت CDN، پشت سرور واسط) انتخاب کنید یا فرم کامل تنظیمات را پر کنید؛ چند آدرس اتصال برای هر اینباند و محدودیت سرعت و دستگاه برای هر کاربر. |
| **لینک اشتراک برای برنامه‌ها** | همان لینک اشتراک در Happ، v2rayNG، Hiddify و برنامه‌های مشابه کار می‌کند و حجم، تاریخ انقضا و دکمهٔ پشتیبانی را نشان می‌دهد. |
| **مسیریابی برای Xray** | اینباندهای Xray هم مثل بقیهٔ اینباندها با خروجی‌ها و قانون‌های مسیریابی کار می‌کنند. |
| **اعلان‌ها** | زنگولهٔ اعلان در پنل، اعلان تلگرام برای ادمین‌ها و نماینده‌ها، و وب‌هوک امضاشده برای ربات یا فروشگاه خودتان. |
| **قالب‌ها و عملیات گروهی** | پلن‌های آماده، فروش فقط از روی قالب برای نماینده‌ها، انتقال کاربران، تنظیم گروهی سرعت و دستگاه، و دانلود فایل TXT لینک‌ها بعد از ساخت گروهی. |
| **چرخه‌های ریست جدید** | سالانه، هر چند روز، و ماهانه و سالانهٔ شمسی، همراه با منطقهٔ زمانی. |
| **دامنه‌های اشتراک** | چند دامنه برای لینک اشتراک، دامنهٔ جدا برای هر نماینده، و فیلد آدرس پنل. |
| **بکاپ زمان‌بندی‌شده** | به تلگرام، S3 یا SFTP، با رمزگذاری اختیاری و مدت نگهداری. |
| **سلامت نودها** | نوار uptime و نمودار برای هر نود، و `/metrics` برای Prometheus. |
| **پالت فرمان** | با Ctrl+K به هر صفحه، کاربر یا نود بروید. |
| **یک پنل برای هر لایسنس** | هر پلن فقط روی یک پنل کار می‌کند. برای سرور دیگر، «حذف لایسنس» را بزنید. |

پنل و نودها را با هم به‌روزرسانی کنید. یادداشت کامل در [صفحهٔ نسخه‌ها](https://github.com/Erfan-XRay/Ovira/releases/tag/v2.0.0) است.

## دستور `ovira`

بعد از نصب، `ovira` روی سرور یک منو باز می‌کند و هر گزینه یک دستور هم هست.

<p align="center"><img src="assets/terminal.webp" alt="منوی ovira در ترمینال" width="100%"></p>

| دستور | کار |
|---|---|
| `ovira status` | نسخه، آدرس پنل، لایسنس، سرویس‌های در حال اجرا؛ خبر نسخهٔ جدید را هم می‌دهد |
| `ovira update` | نصب جدیدترین نسخه (پایدار یا `--beta`) |
| `ovira password` | رمز جدید برای یک ادمین: خودتان بنویسید یا یک رمز تصادفی قوی |
| `ovira license` | لایسنس و شناسهٔ دستگاه |
| `ovira ssl` | گواهی HTTPS برای دامنه یا آی‌پی |
| `ovira local-node enable` | سرور خود پنل را هم نود کنید (`disable` برای برگشت) |
| `ovira logs` · `restart` · `backup` · `uninstall` | همان‌طور که اسمشان می‌گوید |

## چه چیزی می‌گیرید

<table dir="rtl">
<tr>
<td width="50%" valign="top">

### 👥 کاربران
سهمیهٔ حجم، تاریخ پایان یا ساعتی که از اولین استفاده شروع می‌شود، دستگاه هم‌زمان، محدودیت سرعت، ریست دوره‌ای (از جمله شمسی)، آی‌پی ثابت، **قالب**‌های آماده و ساخت گروهی. کاربران را در **گروه** بگذارید تا تعیین شود کدام اینباندها را می‌گیرند.

### 🔐 شش پروتکل، یک کاربر
| پروتکل | برنامه‌ها |
|---|---|
| **OpenVPN** (UDP / TCP) | OpenVPN Connect و برنامه‌های OpenVPN |
| **WireGuard / AmneziaWG** | WireGuard، AmneziaVPN |
| **OpenConnect** | Cisco Secure Client، برنامه‌های OpenConnect |
| **IKEv2** | داخلی در iOS، macOS، ویندوز، اندروید ۱۱ به بعد، strongSwan |
| **L2TP/IPsec** | داخلی در iOS، macOS و ویندوز |
| **Xray** (‏VLESS، VMess، Trojan، Shadowsocks) | Happ، v2rayNG، Hiddify و برنامه‌های پراکسی دیگر |

</td>
<td width="50%" valign="top">

### 🧭 مسیریابی خروجی
برای هر نود انتخاب کنید کدام اینباندها مسیریابی شوند و ترافیکشان از کجا خارج شود: مستقیم، از طریق یک خروجی، یا مسدود. الگوهای آماده مثل «Gemini از خروجی» و «ایران مستقیم»؛ DNS و آدرس‌های خصوصی همیشه مستقیم می‌روند.

### 🛰️ نودها و سرورهای واسط
سرورهای بیشتری به یک پنل وصل کنید. هر نود ضریب ترافیک و آدرس‌های اتصال خودش را دارد، پس سرور واسطِ جلوی آن به پروفایل‌هایی تبدیل می‌شود که کاربر انتخاب می‌کند. پروتکل‌ها با وصل کردن اولین اینباند از خود پنل روی نود نصب می‌شوند.

### 🪪 گواهی‌ها
گواهی HTTPS پنل و همهٔ گواهی‌های OpenConnect و IKEv2 در یک صفحه، با تاریخ انقضا و تمدید خودکار.

</td>
</tr>
<tr>
<td valign="top">

### 🔄 به‌روزرسانی که خبر می‌دهد
وقتی نسخهٔ جدید بیاید یک بنر در پنل ظاهر می‌شود و با یک کلیک نصب می‌شود. کانال پایدار و بتا، به‌روزرسانی خودکار، نودها همراه پنل.

### 🧑‍💼 حساب‌های پنل و نمایندگان
به نماینده‌ها ورود جدا با سهمیهٔ ترافیک، تاریخ پایان و سقف کاربر بدهید و تعیین کنید کدام گروه‌ها، اینباندها و قالب‌ها را بفروشند.

</td>
<td valign="top">

### 🎨 صفحهٔ اشتراک
نام و رنگ خودتان، دکمهٔ پشتیبانی، فارسی و انگلیسی، تب‌های پروتکل با ترتیب و نام دلخواه. حجم باقی‌مانده، روزهای مانده، نمودار مصرف، اتصال با یک لمس و فایل‌های تنظیم.

### 🛡️ امن به‌صورت پیش‌فرض
رمزها با Argon2id، ورود دومرحله‌ای، مسیر مخفی پنل (هر چیز دیگر *404* می‌دهد)، HTTPS خودکار، نسخه‌های امضاشده، پشتیبان‌گیری زمان‌بندی‌شده در تلگرام، S3 یا SFTP و API با توکن‌های محدود.

</td>
</tr>
<tr>
<td valign="top">

### 🔔 اعلان‌ها
زنگوله در پنل، پیام تلگرام برای ادمین‌ها و نماینده‌ها، و وب‌هوک برای ربات یا فروشگاه خودتان.

</td>
<td valign="top">

### 📈 سلامت نودها
نوار uptime و نمودار برای هر نود، متریک Prometheus و پالت فرمان با Ctrl+K.

</td>
</tr>
</table>

## ببینید

این تصاویر نمونه‌هایی از رابط کاربری‌اند. داده‌های کاربران و نام تجاری نمونه هستند.

</div>

<p align="center">
  <img src="assets/clients.webp" alt="فهرست کاربران با حجم، وضعیت و تاریخ پایان" width="100%">
</p>

<p align="center">
  <img src="assets/nodes.webp" alt="نودها با ضریب، آدرس‌های واسط و سرورها" width="100%">
</p>

<p align="center">
  <img src="assets/subscription.webp" alt="صفحهٔ اشتراک" width="100%">
</p>

<table>
<tr>
<td width="50%"><img src="assets/overview-light.webp" alt="نمای کلی در حالت روشن"></td>
<td width="50%"><img src="assets/overview-fa.webp" alt="نمای کلی به فارسی، راست‌به‌چپ"></td>
</tr>
<tr>
<td align="center"><sub>حالت روشن (پیش‌فرض تیره است)</sub></td>
<td align="center"><sub>فارسی، راست‌به‌چپ</sub></td>
</tr>
</table>

<div dir="rtl">

## اجزا چطور کنار هم قرار می‌گیرند

</div>

```mermaid
flowchart LR
    C["👤 Clients<br/>OpenVPN · WireGuard · Cisco · IKEv2 · L2TP · Xray"]
    P["🖥️ Panel<br/>web UI · clients · licenses"]
    subgraph S["Your servers"]
        direction TB
        N1["🌍 Node"]
        N2["🌍 Node"]
        L["⚙️ Panel's own server<br/>(optional)"]
    end
    O["🧭 Outbounds<br/>WARP · NordVPN · VLESS · …"]
    I(("🌐 Internet"))
    C -- "subscription link" --> P
    P -- "manages over TLS,<br/>key-pinned API" --> S
    C == "VPN tunnels" ==> S
    S -- "routing rules" --> O
    S -- "direct" --> I
    O --> I
```

<div dir="rtl">

پنل ترافیک کاربران شما را عبور نمی‌دهد، مگر اینکه بگذارید سرور خودش هم نود باشد. تونل‌ها و قوانین مسیریابی روی نودهاست؛ کاربران، محدودیت‌ها و لایسنس‌ها پیش پنل.

## پلن‌ها

پلن رایگان **۵ کاربر فعال، ۲ نود راه دور و ۱ حساب پنل** دارد. پلن‌های پولی کاربر، نود و حساب پنل بیشتری برای نمایندگان می‌دهند و از **۱ دلار در ماه** شروع می‌شوند. خرید داخل پنل با یکی از روش‌های پرداخت فعال انجام می‌شود و پس از تأیید پرداخت فعال‌سازی صورت می‌گیرد.

| پلن | کاربر فعال | نود | حساب پنل | ماهانه |
|---|---|---|---|---|
| **رایگان** | ۵ | ۲ | ۱ | ۰ دلار |
| **Starter** | ۲۰۰ | ۳ | ۲ | ۱ دلار |
| **Pro** | ۸۰۰ | ۱۰ | ۵ | ۳ دلار |
| **Business** | نامحدود | نامحدود | نامحدود | ۱۰ دلار |

هر لایسنس در همه‌ی پلن‌ها فقط روی یک پنل فعال می‌شود. برای انتقال به سرور دیگر، اول در صفحه‌ی لایسنس پنل قبلی «حذف لایسنس» را بزنید؛ لایسنس همان لحظه آزاد می‌شود. حذف پنل به‌تنهایی لایسنس را آزاد نمی‌کند. اگر سرور قبلی دیگر در دسترس نیست، لایسنس ۷۲ ساعت بعد از آخرین اتصال آن پنل به‌طور خودکار آزاد می‌شود.

همهٔ پروتکل‌ها و مسیریابی خروجی در همهٔ پلن‌ها، حتی رایگان، هستند. این‌ها پلن‌های پیش‌فرض‌اند؛ پیشنهادها، روش‌های پرداخت و سقف‌های فعلی را در صفحهٔ **لایسنس** پنل ببینید. [راهنمای لایسنس](https://erfan-xray.github.io/Ovira/fa/use/license) را بخوانید.

## مستندات

| | |
|---|---|
| 🚀 [نصب پنل](https://erfan-xray.github.io/Ovira/fa/start/install-panel) | پیش‌نیازها، گزینه‌ها، پورت‌ها، کار اسکریپت |
| 🧭 [اولین کاربر](https://erfan-xray.github.io/Ovira/fa/start/first-client) | اولین کاربر و لینک اشتراک |
| 🛰️ [اینباندهای Xray](https://erfan-xray.github.io/Ovira/fa/use/xray-inbounds) | ‏VLESS، VMess، Trojan و Shadowsocks برای برنامه‌های پراکسی |
| 🔔 [اعلان‌ها و وب‌هوک](https://erfan-xray.github.io/Ovira/fa/use/notifications) | زنگوله، پیام تلگرام و وب‌هوک |
| 🔐 [انتخاب پروتکل](https://erfan-xray.github.io/Ovira/fa/protocols/) | OpenVPN، WireGuard، OpenConnect، IKEv2، L2TP/IPsec |
| 🧭 [مسیریابی خروجی](https://erfan-xray.github.io/Ovira/fa/use/routing) | خروجی‌ها، WARP، NordVPN، قوانین و تست |
| 🌍 [نودها](https://erfan-xray.github.io/Ovira/fa/use/nodes) | سرورهای بیشتر، ضریب، آدرس‌های اتصال |
| 🪪 [گواهی‌ها](https://erfan-xray.github.io/Ovira/fa/use/certificates) | Let's Encrypt برای نودها و پنل |
| 🔌 [API](https://erfan-xray.github.io/Ovira/fa/api/) | توکن‌ها، endpointها و نمونهٔ ربات فروش |
| 🛠️ [عیب‌یابی](https://erfan-xray.github.io/Ovira/fa/reference/troubleshooting) | مشکل‌های رایج و راه‌حل |

## مجوز

اویرا نرم‌افزار اختصاصی است: فایل‌های اجرایی با پلن رایگان آزادانه قابل استفاده‌اند و پلن‌های پولی کلید لایسنس می‌خواهند. [LICENSE](LICENSE) را ببینید.

</div>

<div align="center">
<br>
<sub>ساخته‌شده با دقت توسط <a href="https://github.com/Erfan-XRay">Erfan-XRay</a> &nbsp;·&nbsp; <a href="https://github.com/Erfan-XRay/Ovira/releases">Releases</a> &nbsp;·&nbsp; <a href="https://erfan-xray.github.io/Ovira/fa/">مستندات</a></sub>
</div>
