# خط فرمان

همهٔ دستورها با root روی سرور اجرا می‌شوند.

## پنل

```bash
ovira info                                   # آدرس پنل، شناسهٔ دستگاه، لایسنس
ovira admin passwd -username admin           # رمز تصادفی جدید
ovira admin reset-2fa -username admin        # اگر گوشی برنامهٔ احراز هویت گم شده
ovira admin list
ovira ssl issue -mode domain -domain panel.example.com
ovira ssl issue -mode ip
ovira ssl status | off
ovira apply                                  # بازنویسی فایل‌های OpenVPN از دیتابیس
ovira version
```

## نود

```bash
ovira node key                               # چاپ دوبارهٔ کلید نود
ovira node reset-key                         # کلید API جدید؛ کلید جدید را در پنل وارد کنید
```

## سرویس‌ها و لاگ

```bash
systemctl status ovira                       # پنل
systemctl status 'ovira-ovpn@*'              # سرورهای OpenVPN روی سرور پنل
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

از **تنظیمات ← پشتیبان** نسخهٔ پشتیبان بگیرید یا `/var/lib/ovira/ovira.db` را کپی کنید.

## قبل از تغییر اسم نصب کرده‌اید؟

این محصول قبلاً «بارو» (Burrow) نام داشت. سروری که با آن اسم نصب شده، نام فایل‌ها و سرویس‌های قبلی را نگه می‌دارد تا هیچ‌چیز هنگام به‌روزرسانی جابه‌جا نشود: در نام سرویس‌ها و مسیرهای بالا به‌جای `ovira` بنویسید `burrow` (مثلاً `systemctl status burrow` و `/etc/burrow/config.json` و `/var/lib/burrow/`). دستور `ovira` هم آنجا کار می‌کند؛ همان برنامه است.
