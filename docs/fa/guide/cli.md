# خط فرمان

همهٔ دستورها با root روی سرور اجرا می‌شوند.

## پنل

```bash
burrow info                                   # آدرس پنل، شناسهٔ دستگاه، لایسنس
burrow admin passwd -username admin           # رمز تصادفی جدید
burrow admin reset-2fa -username admin        # اگر گوشی برنامهٔ احراز هویت گم شده
burrow admin list
burrow ssl issue -mode domain -domain panel.example.com
burrow ssl issue -mode ip
burrow ssl status | off
burrow apply                                  # بازنویسی فایل‌های OpenVPN از دیتابیس
burrow version
```

## نود

```bash
burrow node key                               # چاپ دوبارهٔ کلید نود
burrow node reset-key                         # کلید API جدید؛ کلید جدید را در پنل وارد کنید
```

## سرویس‌ها و لاگ

```bash
systemctl status burrow                       # پنل
systemctl status 'burrow-ovpn@*'              # سرورهای OpenVPN روی سرور پنل
systemctl status burrow-node 'burrow-node-ovpn@*'   # روی نود
journalctl -u burrow -u 'burrow-ovpn@*' -f    # دنبال کردن لاگ‌ها
```

## فایل‌ها

| مسیر | محتوا |
|---|---|
| `/etc/burrow/config.json` | پورت پنل، مسیر مخفی، HTTPS |
| `/var/lib/burrow/` | دیتابیس، PKI، کانفیگ‌های OpenVPN، گواهی‌ها |
| `/etc/burrow-node/` | کانفیگ نود، هویت TLS، کلید API |
| `/var/lib/burrow-node/` | فایل‌های OpenVPN که پنل فرستاده |

از **تنظیمات ← پشتیبان** نسخهٔ پشتیبان بگیرید یا `/var/lib/burrow/burrow.db` را کپی کنید.
