# خط فرمان

همهٔ دستورها با root روی سرور اجرا می‌شوند. `ovira` را تنها بنویسید تا منو باز شود؛ هر گزینهٔ منو یک دستور هم هست.

## دستورهای روزمره

| دستور | کار |
|---|---|
| `ovira` | منو |
| `ovira status` | چه چیزی در حال اجراست: نسخه، آدرس پنل، شناسهٔ دستگاه، لایسنس، سرویس‌های OpenVPN. اگر نسخهٔ جدیدی باشد خبر می‌دهد |
| `ovira update` | نصب جدیدترین نسخه (`--beta` برای کانال بتا، `--force` برای نصب دوباره) |
| `ovira restart` / `start` / `stop` | کنترل سرویس پنل (یا نود) |
| `ovira logs` | ۱۰۰ خط آخر لاگ؛ `-f` دنبالش می‌کند؛ `ovira logs udp1194` لاگ یک اینباند OpenVPN را نشان می‌دهد |
| `ovira password [USER]` | رمز جدید برای یک ادمین پنل: خودتان بنویسید یا Enter بزنید تا رمز تصادفی قوی ساخته شود. نشست‌های دیگر آن ادمین بسته می‌شوند |
| `ovira license` | لایسنس و شناسهٔ دستگاه (لایسنس در پنل، بخش **لایسنس** فعال می‌شود) |
| `ovira ssl [status\|domain\|ip\|off]` | گواهی HTTPS پنل؛ [HTTPS](./https) را ببینید |
| `ovira openvpn enable\|disable\|status` | روی سرور خود پنل هم OpenVPN اجرا کنید، یا متوقفش کنید. [نصب](./install#پنل-با-openvpn-یا-پنل-خالی) را ببینید |
| `ovira backup [FILE]` | دیتابیس و تنظیمات را در یک فایل `.tar.gz` خصوصی ذخیره می‌کند (پیش‌فرض `/root/ovira-backup-DATE.tar.gz`) |
| `ovira key` | روی نود: کلید نود را دوباره چاپ می‌کند |
| `ovira uninstall [--purge]` | حذف اویرا؛ `--purge` داده‌ها را هم پاک می‌کند |

## پنل، سطح پایین

```bash
ovira info                                   # آدرس پنل، شناسهٔ دستگاه، لایسنس
ovira admin list
ovira admin passwd -username admin           # رمز تصادفی جدید
ovira admin reset-2fa -username admin        # اگر گوشی برنامهٔ احراز هویت گم شده
ovira ssl issue -mode domain -domain panel.example.com
ovira apply                                  # بازنویسی فایل‌های OpenVPN از دیتابیس
ovira version
```

## نود

```bash
ovira key                                    # چاپ دوبارهٔ کلید نود
ovira node reset-key                         # کلید API جدید؛ کلید جدید را در پنل وارد کنید
```

## سرویس‌ها و لاگ

```bash
systemctl status ovira                       # پنل
systemctl status 'ovira-ovpn@*'              # اینباندهای OpenVPN روی سرور پنل
systemctl status ovira-node 'ovira-node-ovpn@*'   # روی نود
journalctl -u ovira -u 'ovira-ovpn@*' -f    # دنبال کردن لاگ‌ها
```

## فایل‌ها

| مسیر | محتوا |
|---|---|
| `/etc/ovira/config.json` | پورت پنل، مسیر مخفی، HTTPS |
| `/var/lib/ovira/` | دیتابیس، PKI، کانفیگ‌های OpenVPN، گواهی‌ها |
| `/etc/ovira-node/` | کانفیگ نود، هویت TLS، کلید API |
| `/var/lib/ovira-node/` | فایل‌های OpenVPN که پنل فرستاده |
| `/usr/local/lib/ovira/manage.sh` | اسکریپت پشت منوی `ovira` |
| `/var/log/ovira-install.log` | خروجی نصب‌کننده و به‌روزرسان |

از **تنظیمات ← پشتیبان** یا با `ovira backup` نسخهٔ پشتیبان بگیرید. هنگام اجرای سرویس فقط فایل دیتابیس SQLite را کپی نکنید؛ نوشته‌های جدید ممکن است در WAL باشند. از روش پشتیبان‌گیری برنامه استفاده کنید یا پیش از پشتیبان‌گیری کامل فایل‌ها، سرویس را متوقف کنید. نسخهٔ پشتیبان شامل اطلاعات ورود و داده‌های کاربران است و باید خصوصی بماند.

## قبل از تغییر اسم نصب کرده‌اید؟

این محصول قبلاً «بارو» (Burrow) نام داشت. سروری که با آن اسم نصب شده، نام فایل‌ها و سرویس‌های قبلی را نگه می‌دارد تا هیچ‌چیز هنگام به‌روزرسانی جابه‌جا نشود: در نام سرویس‌ها و مسیرهای بالا به‌جای `ovira` بنویسید `burrow` (مثلاً `systemctl status burrow` و `/etc/burrow/config.json` و `/var/lib/burrow/`). دستور `ovira` هم آنجا کار می‌کند؛ همان برنامه است. اگر `ovira` در چنین سروری منو نشان نداد، یک بار دستور نصب را اجرا کنید: منو را اضافه می‌کند.
