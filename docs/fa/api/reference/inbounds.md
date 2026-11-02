# اینباندها

اینباند یک سرویس VPN است: شنوندهٔ OpenVPN، OpenConnect یا WireGuard روی یک نود. API آن را `instances` می‌نامد. اینباندی با `nodeId: -1` هنوز تخصیص نیافته؛ `0` سرور پنل است. اینباند چندنودی برای هر نود یک استقرار دارد.

این مسیرها اینباندها را فهرست و تغییر می‌دهند، پیش‌فرض و دسترسی‌شان را می‌خوانند، مستقرشان می‌کنند، تنظیمات هر نود را بازنویسی می‌کنند، روشن و خاموششان می‌کنند و گزارششان را می‌خوانند. ترافیک با بایت و زمان با ثانیهٔ یونیکس است.

## فهرست کوتاه

<Endpoint method="GET" path="/api/instances/brief" perm="inbounds.view" :token="true" />

اینباندها را فقط با نام، وضعیت و آدرس برمی‌گرداند. `?deployments=1` استقرارهای هر نود را هم برای اینباند چندنودی می‌آورد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/brief?deployments=1"
```

```json
[
  {
    "id": 12,
    "technicalName": "udp1194",
    "nodeId": 0,
    "node": "this server",
    "name": "udp1194",
    "proto": "udp",
    "port": 1194,
    "enabled": true,
    "authMode": "cert",
    "description": "",
    "network": "10.128.0.0/16",
    "staticStart": "10.128.255.0",
    "staticEnd": "10.128.255.255",
    "kind": "openvpn"
  }
]
```

## فهرست اینباندها

<Endpoint method="GET" path="/api/instances" perm="inbounds.view" :token="true" />

به `inbounds.view: all` نیاز دارد. حساب با محدودهٔ `own` باید از `GET instances/brief` استفاده کند. اینباندها را با تنظیمات کامل، وضعیت پیوند، استخر آدرس، تعداد کاربر و استقرارها برمی‌گرداند. `?deployments=1` استقرار هر نود را می‌آورد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances?deployments=1"
```

```json
{
  "items": [
    {
      "id": 12,
      "kind": "openvpn",
      "nodeId": 0,
      "name": "udp1194",
      "enabled": true,
      "proto": "udp",
      "port": 1194,
      "network": "10.128.0.0/16",
      "active": true,
      "state": "active",
      "link": { "connected": true, "online": 3 },
      "clients": 42,
      "settings": { "authMode": "cert", "tlsMode": "tls-crypt" }
    }
  ],
  "system": "Ubuntu",
  "openvpn": "2.6.12",
  "publicHost": "panel.example.com"
}
```

## ساخت اینباند

<Endpoint method="POST" path="/api/instances" perm="inbounds.manage" :token="true" />

پاسخ `201` با اینباند تازه است، و اگر بخشی از تغییر اعمال نشود `warning` دارد. تخصیص نود معمولاً درخواست جداست؛ `nodeIds` بلافاصله پس از ساخت مستقر می‌کند.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `displayName` | string | خیر | نامی که به‌جای `name` نشان داده می‌شود. |
| `kind` | string | خیر | `openvpn`، `ocserv` یا `wireguard`. خالی یعنی `openvpn`. بعد از ساخت ثابت است. |
| `nodeId` | integer | خیر | هنگام ساخت نادیده گرفته می‌شود. اینباند تازه تخصیص‌نیافته (`-1`) است؛ برای استقرار از `nodeIds` استفاده کنید. |
| `name` | string | بله | نام اینباند و نام سرویس. یکتا. |
| `enabled` | boolean | خیر | روشن باشد. |
| `proto` | string | بله | `udp`، `tcp`، `udp6` یا `tcp6`. |
| `port` | integer | بله | پورت شنود. |
| `network` | string | بله | شبکهٔ تونل به شکل CIDR. |
| `settings` | object | خیر | تنظیمات پروتکل. پایین را ببینید. |
| `accessGroups` | integer[] | خیر | گروه‌هایی که می‌توانند از اینباند استفاده کنند. نبودنش همهٔ گروه‌ها را می‌دهد. |
| `ownListClients` | boolean | خیر | کاربر بتواند مستقیم این اینباند را انتخاب کند. نبودنش یعنی بله. |
| `nodeIds` | integer[] | خیر | نودهایی که بلافاصله پس از ساخت مستقر می‌شوند. |
| `ports` | object | خیر | پورت هر نود استقرار، با کلید شناسهٔ نود. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances" \
  -d '{
    "kind": "openvpn",
    "name": "udp1194",
    "enabled": true,
    "proto": "udp",
    "port": 1194,
    "network": "10.128.0.0/16",
    "settings": {
      "authMode": "cert",
      "tlsMode": "tls-crypt",
      "dns": ["1.1.1.1"],
      "redirectGateway": true,
      "maxClients": 0
    },
    "accessGroups": [3]
  }'
```

```json
{
  "instance": {
    "id": 12,
    "kind": "openvpn",
    "nodeId": -1,
    "name": "udp1194",
    "enabled": true,
    "proto": "udp",
    "port": 1194,
    "network": "10.128.0.0/16",
    "active": false,
    "state": "inactive",
    "clients": 0
  }
}
```

`400` فیلد اشتباه، پورت استفاده‌شده یا شبکهٔ تونل هم‌پوشان را می‌گوید. `402` یعنی لایسنس اینباند دیگری را اجازه نمی‌دهد.

## شیء تنظیمات

همهٔ فیلدها اختیاری‌اند؛ پنل مقدار ارسال‌نشده را با پیش‌فرض پر می‌کند. همان شیئی را که از `GET instances/defaults` یا `GET instances/{id}` خوانده‌اید پس از ویرایش بفرستید.

| فیلد | نوع | معنی |
|---|---|---|
| `authMode` | string | `cert`، `cert+pass` یا `pass`: نحوهٔ اثبات هویت کاربر. |
| `tlsMode` | string | `tls-crypt`، `tls-auth` یا `none`: حفاظت کانال کنترل. |
| `dataCiphers` | string[] | رمزهای AEAD مذاکره‌شده. |
| `fallbackCipher` | string | رمز کلاینت‌های پیش از ۲.۴؛ خالی یعنی هیچ. |
| `authDigest` | string | خلاصهٔ HMAC. |
| `tlsMinVersion` | string | `1.2` یا `1.3`. |
| `dns` | string[] | resolverهایی که به کاربران داده می‌شود. |
| `searchDomain` | string | `DOMAIN` که به کاربران داده می‌شود. |
| `redirectGateway` | boolean | همهٔ بسته‌ها از تونل بروند. |
| `blockOutsideDns` | boolean | DNS بیرون تونل بسته شود (رفع نشتی ویندوز). |
| `pushRoutes` | string[] | CIDRهایی که از تونل می‌روند. |
| `ipv6` | boolean | آدرس تونل از `network6` بده. |
| `network6` | string | شبکهٔ تونل IPv6 به شکل CIDR. |
| `clientToClient` | boolean | کاربران به هم برسند. |
| `maxClients` | integer | سقف کاربر هم‌زمان؛ `0` یعنی بی‌سقف. |
| `keepaliveInterval` | integer | فاصلهٔ keepalive به ثانیه. |
| `keepaliveTimeout` | integer | مهلت keepalive به ثانیه. |
| `tunMtu` | integer | MTU تونل؛ `0` یعنی پیش‌فرض. |
| `mssFix` | integer | مقدار MSS clamping؛ `0` یعنی خاموش. |
| `fragment` | integer | اندازهٔ قطعهٔ UDP؛ `0` یعنی خاموش. |
| `sndRcvBuf` | integer | اندازهٔ بافر سوکت؛ `0` یعنی پیش‌فرض سیستم. |
| `compression` | string | `off`، `lz4-v2` یا `lzo`. |
| `renegSec` | integer | فاصلهٔ تمدید کلید به ثانیه. |
| `portShare` | string | پورت میزبان برای اشتراک با سرویس دیگر؛ فقط TCP. |
| `exitNotify` | boolean | هنگام توقف سرور به کاربران بگو. |
| `multihome` | boolean | به UDP از همان آدرسی پاسخ بده که بسته رسیده. |
| `remotes` | object[] | آدرس کاربران: `label`، `host`، `port`. خالی یعنی آدرس‌های نود. |
| `remote` | string | اولین `remotes`، برای نسخه‌های قدیمی‌تر. |
| `verb` | integer | سطح گزارش، ۰ تا ۱۱. |
| `nat` | boolean | قاعدهٔ NAT برای شبکهٔ تونل نگه داشته شود. |
| `serverCustom` | string | خطوط اضافهٔ تنظیمات سرور، بررسی‌شده با فهرست ممنوع. |
| `clientCustom` | string | خطوط اضافهٔ تنظیمات کاربر، بررسی‌شده با فهرست ممنوع. |
| `description` | string | متنی که با پروفایل‌های اینباند نشان داده می‌شود. |
| `oc` | object | تنظیمات OpenConnect. |
| `wg` | object | تنظیمات WireGuard. |

### تنظیمات OpenConnect (`oc`)

| فیلد | نوع | معنی |
|---|---|---|
| `dtls` | boolean | روی همان پورت UDP هم گوش بده. |
| `camouflage` | boolean | به کاوش مرورگر با صفحهٔ فریبنده پاسخ بده؛ ocserv 1.2.0 یا جدیدتر لازم است. |
| `camouflageSecret` | string | راز داخل آدرس اتصال: `https://host:port/?SECRET`. |
| `camouflageRealm` | string | قلمرویی که به مرورگر کاوشگر نشان داده می‌شود. |
| `certSource` | string | `pki`، `panel` یا `acme`: منبع گواهی سرور. |
| `acmeHost` | string | نام DNS برای ACME؛ خالی یعنی آدرس عمومی نود. |
| `idleTimeout` | integer | مهلت بی‌فعالیتی کلاینت دسکتاپ، به ثانیه. |
| `mobileIdleTimeout` | integer | مهلت بی‌فعالیتی کلاینت موبایل، به ثانیه. |
| `cookieTimeout` | integer | مدت قابل‌ادامه بودن کوکی نشست، به ثانیه. |
| `dpd` | integer | فاصلهٔ تشخیص همتای مرده، به ثانیه. |
| `mobileDpd` | integer | همان مقدار برای کلاینت موبایل، به ثانیه. |
| `ciscoCompat` | boolean | کلاینت‌های قدیمی Cisco را بپذیر. |
| `tlsPriorities` | string | رشتهٔ اولویت GnuTLS. |
| `proxyProtocol` | boolean | هدرهای PROXY protocol از رله را بپذیر. |
| `serverCustom` | string | خطوط اضافهٔ `ocserv.conf`، بررسی‌شده با فهرست ممنوع. |

### تنظیمات WireGuard (`wg`)

| فیلد | نوع | معنی |
|---|---|---|
| `filenameTemplate` | string | نام فایل دانلودی کاربر: متن ثابت یا الگو با `{username}`، `{device}` و `{inbound}`. خالی یعنی نام‌گذاری خودکار. برای WireGuard و AmneziaWG. |
| `privateKey` | string | کلید خصوصی سرور. API هرگز برنمی‌گرداند. |
| `publicKey` | string | کلید عمومی سرور. |
| `obfuscation` | string | حالت پوشش؛ خالی یعنی WireGuard ساده. |
| `amnezia` | object | پارامترهای AmneziaWG: `jc`، `jmin`، `jmax`، `s1`، `s2`، `h1`-`h4`، `i1`-`i5`، `j1`-`j3`، `itime`. |
| `mtu` | integer | MTU تونل. |
| `keepalive` | integer | keepalive دائمی به ثانیه؛ `0` یعنی خاموش. |
| `allowedIPs` | string[] | CIDRهایی که از تونل می‌روند. |

## پیش‌بررسی اینباند

<Endpoint method="POST" path="/api/instances/preflight" perm="inbounds.manage" :token="true" />

طرح را پیش از ساخت بررسی می‌کند. بدنه همان بدنهٔ ساخت به‌همراه `nodeIds` و `ports` هر نود است؛ `nodeId` نادیده گرفته می‌شود. پاسخ برای هر نود یک یافته دارد، با `error` خالی وقتی نود آماده است.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances/preflight" \
  -d '{"kind":"openvpn","name":"udp1194","proto":"udp","port":1194,"network":"10.128.0.0/16","nodeIds":[0,4]}'
```

```json
{
  "items": [
    { "nodeId": 0, "error": "" },
    { "nodeId": 4, "error": "port udp/1194 is already used by udp1194" }
  ]
}
```

`400` یعنی خود طرح معتبر نیست.

## خواندن پیش‌فرض‌ها

<Endpoint method="GET" path="/api/instances/defaults" perm="inbounds.manage" :token="true" />

تنظیمات پیش‌فرض اینباند تازه را برمی‌گرداند. برای OpenConnect وضعیت نصب نود را هم می‌دهد.

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `kind` | query | string | `openvpn`، `ocserv` یا `wireguard`. پیش‌فرض `openvpn`. |
| `nodeId` | query | integer | نودی که پیش‌فرض‌ها برایش است. `-1` (پیش‌فرض) یعنی اینباند تخصیص‌نیافته. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/instances/defaults?kind=openvpn&nodeId=0"
```

```json
{
  "authMode": "cert",
  "tlsMode": "tls-crypt",
  "dataCiphers": ["AES-256-GCM", "CHACHA20-POLY1305"],
  "fallbackCipher": "",
  "authDigest": "SHA256",
  "tlsMinVersion": "1.2",
  "dns": ["1.1.1.1"],
  "redirectGateway": false,
  "blockOutsideDns": false,
  "pushRoutes": [],
  "ipv6": false,
  "network6": "",
  "clientToClient": false,
  "maxClients": 0,
  "keepaliveInterval": 10,
  "keepaliveTimeout": 60,
  "tunMtu": 0,
  "mssFix": 0,
  "fragment": 0,
  "sndRcvBuf": 0,
  "compression": "off",
  "renegSec": 0,
  "portShare": "",
  "exitNotify": false,
  "multihome": false,
  "remotes": [],
  "remote": "",
  "verb": 3,
  "nat": true,
  "serverCustom": "",
  "clientCustom": "",
  "description": ""
}
```

برای `kind=ocserv` پاسخ شیئی با `settings` و همچنین `supported`، `installed`، `version`، `installing`، `installError`، `camouflageMin`، `camouflageOk`، `certSource`، `panelCert` و `acme` است.

## خواندن دسترسی اینباند

<Endpoint method="GET" path="/api/instances/access" perm="inbounds.manage" :token="true" />

گروه‌هایی که می‌توانند از هر اینباند استفاده کنند و تعداد کاربرانی که فهرست اینباند خودشان را دارند، نه گروه، را برمی‌گرداند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/access"
```

```json
{
  "groups": [
    { "id": 3, "name": "Iran", "instances": [12, 21], "clients": 42 }
  ],
  "ownListClients": 7
}
```

## نصب OpenConnect روی این سرور

<Endpoint method="POST" path="/api/ocserv/install" perm="inbounds.manage" :token="true" />

نصب `ocserv` روی میزبان پنل را شروع می‌کند. پاسخ `202` است؛ نتیجهٔ همین سرور را از `GET instances/defaults?kind=ocserv&nodeId=0` بخوانید.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X POST "$BASE/ocserv/install"
```

`400` یعنی نصب روی این میزبان ممکن نیست.

## خواندن یک اینباند

<Endpoint method="GET" path="/api/instances/{id}" perm="inbounds.view" :token="true" />

اینباند، فایل تنظیمات رندرشده، محل فایل، استقرارها و بازنویسی‌ها را برمی‌گرداند. حساب باید `inbounds.view` برای همهٔ اینباندها داشته باشد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/12"
```

```json
{
  "instance": {
    "id": 12,
    "kind": "openvpn",
    "nodeId": 0,
    "name": "udp1194",
    "enabled": true,
    "proto": "udp",
    "port": 1194,
    "network": "10.128.0.0/16",
    "active": true,
    "state": "active",
    "clients": 42,
    "settings": { "authMode": "cert", "tlsMode": "tls-crypt" }
  },
  "config": "port 1194\nproto udp\n...",
  "path": "/etc/ovira/instances/udp1194/server.conf",
  "shared": { "name": "udp1194", "port": 1194 },
  "overrides": {},
  "deployments": []
}
```

## تغییر اینباند

<Endpoint method="PUT" path="/api/instances/{id}" perm="inbounds.manage" :token="true" />

همان فیلدهای ساخت را می‌فرستد، بدون `accessGroups`، `nodeIds` و `ports`. پاسخ اینباند تغییرکرده با `warning` است وقتی بخشی از تغییر اعمال نشود.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X PUT "$BASE/instances/12" \
  -d '{"name":"udp1194","enabled":true,"proto":"udp","port":1194,"network":"10.128.0.0/16","settings":{"authMode":"cert+pass","tlsMode":"tls-crypt"}}'
```

```json
{
  "instance": {
    "id": 12,
    "name": "udp1194",
    "enabled": true,
    "port": 1194,
    "settings": { "authMode": "cert+pass", "tlsMode": "tls-crypt" }
  }
}
```

`400` فیلد اشتباه را می‌گوید. تغییر پورت یا شبکه اینباند را دوباره راه می‌اندازد و کاربرانش را قطع می‌کند.

## حذف اینباند

<Endpoint method="DELETE" path="/api/instances/{id}" perm="inbounds.manage" :token="true" />

اینباند و سرویسش را حذف می‌کند. کاربرانی که از آن استفاده می‌کردند آن پروفایل را از دست می‌دهند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/instances/12"
```

```json
{ "ok": true }
```

## فهرست استقرارها

<Endpoint method="GET" path="/api/instances/{id}/deployments" perm="inbounds.view" :token="true" />

برای هر نودی که اینباند رویش مستقر است یک ورودی با کار استقرار برمی‌گرداند. حساب باید `inbounds.view` برای همهٔ اینباندها داشته باشد.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" "$BASE/instances/12/deployments"
```

```json
{
  "items": [
    {
      "nodeId": 4,
      "node": "de-fra-1",
      "instance": { "id": 27, "parentId": 12, "nodeId": 4, "name": "udp1194" },
      "job": {
        "serviceId": 12,
        "nodeId": 4,
        "instanceId": 27,
        "status": "done",
        "stage": "running",
        "logs": [],
        "updatedAt": 1795919000
      }
    }
  ]
}
```

## استقرار اینباند

<Endpoint method="POST" path="/api/instances/{id}/deployments" perm="inbounds.manage" :token="true" />

استقرار روی یک یا چند نود را در صف می‌گذارد.

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `nodeIds` | integer[] | بله | ۱ تا ۱۰۰ نود برای استقرار. |
| `ports` | object | خیر | پورت هر نود، با کلید شناسهٔ نود. |

`?check=1` را اضافه کنید تا نودها بررسی شوند، نه مستقر: پاسخ `200` با یک یافته برای هر نود است و چیزی تغییر نمی‌کند. بدون آن پاسخ `202` است و استقرارها در صف می‌روند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$BASE/instances/12/deployments?check=1" \
  -d '{"nodeIds":[4],"ports":{"4":1194}}'
```

```json
{
  "items": [
    { "nodeId": 4, "error": "" }
  ]
}
```

`400` یعنی نودی انتخاب نشده، تعداد نودها زیاد است یا بدنه معتبر نیست.

## حذف استقرار

<Endpoint method="DELETE" path="/api/instances/{id}/deployments/{node}" perm="inbounds.manage" :token="true" />

اینباند را از یک نود حذف می‌کند. پارامترهای مسیر شناسهٔ اینباند و شناسهٔ نود هستند؛ `0` همین سرور.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -X DELETE "$BASE/instances/12/deployments/4"
```

```json
{ "ok": true }
```

`400` یعنی شناسه یا نود معتبر نیست، یا اینباند آنجا مستقر نیست.

## تغییر بازنویسی‌های یک نود

<Endpoint method="PUT" path="/api/instances/{id}/deployments/{node}/overrides" perm="inbounds.manage" :token="true" />

تعیین می‌کند یک نود برای اینباند چندنودی چه چیزی را بازنویسی کند. پاسخ `202` است و نود دوباره مستقر می‌شود.

| فیلد | نوع | معنی |
|---|---|---|
| `port` | integer | پورت این نود به‌جای پورت مشترک. |
| `network` | string | شبکهٔ تونل این نود به‌جای شبکهٔ مشترک. |
| `remotes` | object[] | آدرس کاربران این نود به‌جای آدرس‌های مشترک: `label`، `host`، `port`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" \
  -X PUT "$BASE/instances/12/deployments/4/overrides" \
  -d '{"port":443,"remotes":[{"label":"Germany","host":"de.example.com","port":443}]}'
```

```json
{ "ok": true }
```

`400` یعنی اینباند روی آن نود مستقر نیست.

<Endpoint method="DELETE" path="/api/instances/{id}/deployments/{node}/overrides" perm="inbounds.manage" :token="true" />

بازنویسی‌های آن نود را پاک و آن را دوباره مستقر می‌کند. پاسخ `202` است.

## تخصیص اینباند به نود

<Endpoint method="POST" path="/api/instances/{id}/node" perm="inbounds.manage" :token="true" />

اینباند را به یک نود منتقل می‌کند، از جمله از یک نود به نود دیگر. بدنه یک فیلد لازم دارد:

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `nodeId` | integer | بله | نودی که تخصیص می‌یابد. `0` سرور پنل است. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances/12/node" \
  -d '{"nodeId":4}'
```

پاسخ اینباند و `warning` است وقتی بخشی اعمال نشود. `400` یعنی نودی انتخاب نشده یا معتبر نیست.

<Endpoint method="DELETE" path="/api/instances/{id}/node" perm="inbounds.manage" :token="true" />

اینباند را از نودش جدا و تخصیص‌نیافته می‌کند. پروفایل‌هایش تا تخصیص دوباره از کار می‌افتند.

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" -X DELETE "$BASE/instances/12/node"
```

`400` یعنی اینباند جدا نمی‌شود.

## شروع، توقف یا راه‌اندازی دوباره

<Endpoint method="POST" path="/api/instances/{id}/control" perm="inbounds.manage" :token="true" />

| فیلد | نوع | لازم | معنی |
|---|---|---|---|
| `action` | string | بله | `start`، `stop` یا `restart`. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  -H "Content-Type: application/json" -X POST "$BASE/instances/12/control" \
  -d '{"action":"restart"}'
```

پاسخ اینباند پس از کار است. `400` یعنی کار معتبر نیست.

## خواندن گزارش اینباند

به `inbounds.view: all` نیاز دارد.

<Endpoint method="GET" path="/api/instances/{id}/logs" perm="inbounds.view" :token="true" />

| پارامتر | محل | نوع | معنی |
|---|---|---|---|
| `id` | path | integer | شناسهٔ اینباند. |
| `lines` | query | integer | چند خط، ۱۰ تا ۲۰۰۰. مقدار دیگر یعنی ۲۰۰. |

```bash
curl -sS -H "Authorization: Bearer $OVIRA_TOKEN" \
  "$BASE/instances/12/logs?lines=100"
```

```json
{
  "logs": "2026-11-02 12:00:01 TLS: Initial packet from 203.0.113.9:51820\n..."
}
```

`404` یعنی چنین اینباندی نیست.

## صفحه‌های مرتبط

- [نودها](/fa/api/reference/nodes): سرورهایی که اینباند رویشان اجرا می‌شود.
- [گروه‌ها](/fa/api/reference/groups): گروه‌هایی که از اینباند استفاده می‌کنند.
- [اینباندها](/fa/use/inbounds): صفحهٔ پنل و فیلدهایش.
- [انتخاب پروتکل](/fa/protocols/): هر نوع برای چه کاری خوب است.
