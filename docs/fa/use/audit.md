# گزارش فعالیت

گزارش فعالیت آنچه افراد در پنل کرده‌اند را ثبت می‌کند: چه کسی وارد شد، چه کسی کاربری ساخت یا تغییر داد، چه کسی پشتیبانی را بازگرداند. به این پرسش جواب می‌دهد که «چه کسی این را عوض کرد و کی». این صفحه ستون‌های گزارش، آنچه ثبت می‌شود و مدت نگهداری آن را توضیح می‌دهد.

## کجا پیدایش کنید

**تنظیمات ← گزارش فعالیت** را باز کنید. مالک‌ها و نقش‌هایی که همهٔ کاربران را می‌بینند می‌توانند آن را باز کنند. حساب نماینده این زبانه را ندارد.

## ستون‌ها

| ستون | چه نشان می‌دهد |
|---|---|
| **زمان** | تاریخ و ساعت عمل. |
| **چه کسی** | حساب پنل. اگر رویداد حسابی نداشته باشد خط تیره. |
| **عمل** | یک کد کوتاه مثل `client.create` یا `login.failed`. کدهایی که `failed` دارند قرمز نشان داده می‌شوند. |
| **مورد** | عمل دربارهٔ چه چیزی بود، مثلاً نام یک کاربر، با جزئیات زیر آن. |
| **IP** | آدرسی که درخواست از آن آمد. در صفحه‌های باریک پنهان است. |

تازه‌ترین ورودی‌ها اول می‌آیند. فهرست صفحه‌صفحه بارگذاری می‌شود؛ برای ورودی‌های قدیمی‌تر **بیشتر** را بزنید. گزارش خالی می‌گوید «هنوز فعالیتی ثبت نشده.»

## چه چیزی ثبت می‌شود

کدها بر اساس موضوع گروه‌بندی شده‌اند:

| گروه | نمونه‌ها |
|---|---|
| ورود | `login`، `login.failed`، `login.recovery-code`، `login.refused` |
| حساب شما | `account.password`، `account.2fa.enable`، `account.2fa.disable`، `account.sessions.revoke` |
| حساب‌های پنل و نقش‌ها | `admin.create`، `admin.update`، `admin.password`، `admin.reset-2fa`، `admin.delete`، `role.create`، `role.update`، `role.delete` |
| کاربران | `client.create`، `client.bulk-create`، `client.update`، `client.delete`، `client.wg-reset` |
| اتصال‌ها | `connection.kick` |
| گروه‌ها | `group.create`، `group.update`، `group.assign` |
| اینباندها و نودها | `instance.create`، `instance.update`، `instance.assign`، `instance.unassign`، `instance.delete`، `node.create`، `node.update`، `node.delete` |
| تنظیمات و نگهداری | `settings.update`، `settings.panel`، `settings.tls`، `panel.restart`، `backup.download`، `backup.restore`، `update.start`، `update.install` |
| لایسنس | `license.install`، `license.remove`، `license.order` |

گزارش، ترافیک VPN را ثبت نمی‌کند. برای اینکه چه کسی متصل بوده [اتصال‌ها](/fa/use/connections) را ببینید.

## تا کی نگه داشته می‌شود

**گزارش فعالیت** را زیر **مدت نگهداری تاریخچه** در **تنظیمات ← عمومی** به روز تعیین کنید. ورودی‌های قدیمی‌تر حذف می‌شوند.

## صفحه‌های مرتبط

- [تنظیمات](/fa/use/settings): تنظیم مدت نگهداری.
- [حساب‌های پنل](/fa/use/admins): حساب‌هایی که ستون **چه کسی** به آن‌ها اشاره می‌کند.
- [اتصال‌ها](/fa/use/connections): اتصال‌های VPN زنده و تمام‌شده.
