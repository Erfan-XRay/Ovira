# خط فرمان

دستور `ovira` اویرا را از شل سرور مدیریت می‌کند. آن را با کاربر root اجرا کنید. اگر تنهایی بزنیدش یک منو باز می‌شود و هر گزینهٔ منو یک دستور هم هست. همین دستور هم روی سرور پنل هست و هم روی سرور نود، و خودش می‌فهمد روی کدام است. این صفحه همهٔ دستورها، گزینه‌های اسکریپت‌های نصب و منو را فهرست می‌کند.

## دستورهای روزمره روی پنل

| دستور | کاربرد |
|---|---|
| `ovira` | منو را باز می‌کند. |
| `ovira status` | وضعیت پنل، نسخه، آدرس، روشن بودن HTTPS، وضعیت لایسنس، نود بودن این سرور، شناسهٔ دستگاه و اینباندهای در حال اجرا را نشان می‌دهد. اگر نسخهٔ جدیدتری باشد هم می‌گوید. |
| `ovira update` | جدیدترین نسخه را نصب می‌کند. `--beta` کانال بتا، `--force` نصب دوبارهٔ نسخهٔ فعلی، `--binary FILE` نصب فایلی که خودتان می‌دهید. |
| `ovira start`، `ovira stop`، `ovira restart` | سرویس پنل را کنترل می‌کنند. `stop` اول می‌پرسد. |
| `ovira logs` | ۱۰۰ خط آخر لاگ پنل را نشان می‌دهد. `-f` دنبالش می‌کند. |
| `ovira logs NAME` | لاگ یک اینباند را با نامش نشان می‌دهد، مثلاً `udp1194`. برای اینباندهای OpenVPN، OpenConnect و WireGuard کار می‌کند. |
| `ovira password [USER]` | رمز تازه برای یک حساب پنل می‌گذارد. یکی تایپ کنید، یا Enter بزنید تا یک رمز قوی تصادفی ساخته و یک بار نشان داده شود. نشست‌های دیگر آن حساب بسته می‌شوند. |
| `ovira license` | شناسهٔ دستگاه و وضعیت لایسنس را نشان می‌دهد. لایسنس را در پنل، زیر **لایسنس** فعال یا عوض کنید. |
| `ovira ssl [status\|domain\|ip\|off]` | گواهی HTTPS پنل را مدیریت می‌کند. [HTTPS پنل](/fa/start/https) را ببینید. |
| `ovira local-node enable\|disable\|status` | خود سرور پنل را نود هم می‌کند، یا فقط پنل. `disable` اینباندهایش را برای بعد نگه می‌دارد. [همین سرور به‌عنوان نود](/fa/start/same-server) را ببینید. |
| `ovira ocserv install` | نرم‌افزار سرور OpenConnect را روی خود سرور پنل نصب می‌کند. `ovira ocserv status` نسخهٔ پیداشده را نشان می‌دهد. |
| `ovira backup [FILE]` | پایگاه داده و `config.json` را در یک فایل `.tar.gz` خصوصی ذخیره می‌کند. پیش‌فرض `/root/ovira-backup-DATE.tar.gz` است. |
| `ovira uninstall [--purge]` | اویرا را حذف می‌کند. می‌پرسد دادهٔ آن نگه داشته شود یا نه. `--purge` دادهٔ آن را هم پاک می‌کند. |
| `ovira version` | نسخهٔ نصب‌شده را چاپ می‌کند. |
| `ovira help` | خلاصه‌ای از این دستورها را چاپ می‌کند. |

`ovira local-node` با نام `ovira openvpn` و `ovira ocserv` با نام `ovira oc` هم در دسترس است.

پیش از به‌روزرسانی یا هر تغییر بزرگ پشتیبان بگیرید. فقط فایل زندهٔ پایگاه داده را وقتی سرویس کار می‌کند کپی نکنید: ممکن است نوشته‌های اخیر هنوز کنار آن مانده باشند. `ovira backup` و **تنظیمات ← پشتیبان** یک نسخهٔ سازگار می‌گیرند. پشتیبان‌ها را خصوصی نگه دارید، چون رمزها و اطلاعات کاربران در آن‌هاست.

## دستورها روی نود

نود دستورهای کمتری دارد. منو و این دستورها روی سرویس نود، یعنی `ovira-node`، اثر می‌گذارند.

| دستور | کاربرد |
|---|---|
| `ovira` | منوی نود را باز می‌کند. |
| `ovira status` | وضعیت نود، نسخه، آدرس، اینکه چه کسی می‌تواند به آن وصل شود، و کلید نود را نشان می‌دهد. |
| `ovira key` | کلید نود را برای چسباندن در پنل چاپ می‌کند. `ovira info` هم آن را چاپ می‌کند. |
| `ovira update` | جدیدترین نسخه را نصب می‌کند. تونل‌های در حال کار باز می‌مانند. |
| `ovira start`، `ovira stop`، `ovira restart` | سرویس نود را کنترل می‌کنند. `stop` اول می‌پرسد. تا وقتی متوقف است پنل نمی‌تواند نود را مدیریت کند. |
| `ovira logs [NAME]` | لاگ نود یا یک اینباند را نشان می‌دهد. `-f` دنبالش می‌کند. |
| `ovira node reset-key` | کلید جدید نود می‌سازد. نود را دوباره راه بیندازید، بعد کلید جدید را در ویرایش نود در پنل وارد کنید. |
| `ovira uninstall [--purge]` | نود را حذف می‌کند. `--purge` دادهٔ آن و کلیدش را هم پاک می‌کند. |

اگر یک سرور هم پنل داشته باشد هم نود، دستورها اول به پنل می‌روند. منو گزینه‌ای دارد که منوی نود را باز می‌کند.

## دستورهای سطح پایین

این‌ها مستقیم با خود برنامه حرف می‌زنند. نصب‌کننده، منو و systemd آن‌ها را برای شما صدا می‌زنند. در اسکریپت‌ها یا وقتی منو به پنل نمی‌رسد از آن‌ها استفاده کنید.

```bash
ovira info                                  # panel address, machine ID, license
ovira admin list                            # panel accounts: id, name, role, 2FA, disabled
ovira admin create -username NAME [-password PW] [-role owner|admin|reseller]
ovira admin passwd -username NAME [-password PW]
ovira admin reset-2fa -username NAME        # when the authenticator phone is lost
ovira ssl issue -mode domain -domain panel.example.com [-email you@example.com]
ovira ssl issue -mode ip                    # detects the server's public IPv4
ovira ssl status
ovira ssl off                               # back to plain HTTP; restart the panel
ovira apply                                 # rewrite inbound files from the database
```

اگر `-password` ندهید، `admin create` و `admin passwd` یک رمز تصادفی می‌سازند و چاپ می‌کنند. رمزی که خودتان تایپ می‌کنید باید به اندازهٔ کافی قوی باشد، و `admin create` به سقف حساب‌های پنل در پلن شما احترام می‌گذارد. همهٔ این‌ها `-config FILE` می‌گیرند که پیش‌فرضش `/etc/ovira/config.json` است.

بعد از `ovira ssl issue` یا `ovira ssl off`، دستور `systemctl restart ovira` را بزنید تا پنل عوض شود. `ovira ssl domain` و `ovira ssl ip` صدور و راه‌اندازی مجدد را خودشان انجام می‌دهند.

## گزینه‌های نصب

نصب‌کنندهٔ پنل `install.sh` و نصب‌کنندهٔ نود `node.sh` است. هر دو آنچه لازم دارند می‌پرسند. هر پاسخ را می‌شود به‌جای آن به‌صورت گزینه داد و `--yes` همهٔ پرسش‌ها را رد می‌کند.

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/Erfan-XRay/Ovira/main/install.sh) --yes \
  --port 8443 --ssl domain --domain panel.example.com --email you@example.com
```

| گزینه | پنل | نود | معنی |
|---|---|---|---|
| `--port N` | بله | بله | پورت پنل (پیش‌فرض ۲۰۵۳)، یا پورت API نود (پیش‌فرض ۶۲۰۶۰). |
| `--ssl domain\|ip\|none` | بله | | پنل HTTPS را چطور بگیرد. |
| `--domain NAME`، `--email ADDRESS` | بله | | برای `--ssl domain`. |
| `--user NAME` | بله | | نام اولین حساب مالک (پیش‌فرض `admin`). |
| `--local-node`، `--no-local-node` | بله | | این سرور نودِ پنل خودش باشد یا نه (پیش‌فرض بله). `--with-openvpn` و `--panel-only` نام‌های قدیمی‌اند. |
| `--panel-ip IP` | | بله | نود فقط به این آدرس پنل جواب می‌دهد. |
| `--beta` | بله | بله | جدیدترین بتا را به‌جای نسخهٔ پایدار نصب کن. |
| `--binary FILE` | بله | بله | به‌جای دانلود، یک فایل محلی را استفاده کن. |
| `--fresh` | بله | بله | بعد از حذفی که داده را نگه داشته بود، از صفر شروع کن. یک نسخهٔ پشتیبان از دادهٔ قبلی در `/root` ذخیره می‌شود. |
| `--purge` | بله | بله | همراه `uninstall`: داده را هم پاک کن. |
| `--force` | بله | بله | همراه `update`: حتی اگر نسخه یکی است دوباره نصب کن. |
| `--yes` | بله | بله | نپرس. |

`--udp-port`، `--tcp-port` و `--tcp` هنوز پذیرفته می‌شوند ولی نادیده گرفته می‌شوند: نصب‌کننده اینباندی نمی‌سازد. آن‌ها را در پنل زیر **اینباندها** بسازید. شکل‌های قدیمی `install.sh node …`، `--node` و `--uninstall --node` کار را به `node.sh` می‌سپارند.

اجرای دوبارهٔ هر کدام از اسکریپت‌ها روی سروری که اویرا نصب دارد، منو را باز می‌کند، یا با `update` آن را به‌روز می‌کند.

## منو

روی پنل، `ovira` این گزینه‌ها را نشان می‌دهد. خطی در بالا وضعیت و وجود نسخهٔ جدید را می‌گوید.

| بخش | گزینه‌ها |
|---|---|
| **PANEL** | **Status & address**، **Change admin password**، **License & machine ID**، **HTTPS certificate** |
| **SERVICES** | **Restart the panel**، **Start the panel**، **Stop the panel**، **Live logs** |
| **THIS SERVER** | **This server as a node: ON** یا **OFF**، **Install OpenConnect**، و اگر نود هم نصب است **Node on this server** |
| **MAINTENANCE** | **Update Ovira**، **Back up the database**، **Uninstall Ovira** |

منوی نصب‌کننده به انگلیسی است. روی نود بخش‌ها **NODE** (**Status & node key**، **Show node key**)، **SERVICES** (راه‌اندازی مجدد، اجرا، توقف، **Live logs**) و **MAINTENANCE** (**Update Ovira**، **Uninstall the node**) هستند.

با کلیدهای جهت‌نما حرکت کنید یا شمارهٔ گزینه را تایپ کنید. Ctrl+C منو را می‌بندد، یا صفحه‌ای را که در آن هستید تمام می‌کند.

## قبل از تغییر نام نصب کرده‌اید؟ {#installed-before-the-rename}

نام محصول قبلاً Burrow بود. سروری که با آن نام نصب شده نام فایل‌ها و سرویس‌های اولیه‌اش را نگه می‌دارد، پس به‌روزرسانی چیزی را جابه‌جا نمی‌کند. در نام سرویس‌ها و مسیرهای این مستندات `ovira` را با `burrow` عوض کنید: `systemctl status burrow`، `/etc/burrow/config.json`، `/var/lib/burrow/`. دستور `ovira` آنجا هم کار می‌کند، چون همان برنامه است.

## صفحه‌های مرتبط

- [فایل‌ها، سرویس‌ها و پورت‌ها](./files-and-ports): هر چیزی که این دستورها به آن دست می‌زنند کجاست.
- [عیب‌یابی](./troubleshooting): برای هر نشانه کدام دستور را بزنید.
- [نصب پنل](/fa/start/install-panel): نصب‌کننده قدم‌به‌قدم.
- [به‌روزرسانی پنل و نودها](/fa/start/update): روند به‌روزرسانی.
