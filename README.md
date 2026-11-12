<h1 align="center">🔐 Auto SSL — Let's Encrypt manager with a Telegram bot</h1>

<p align="center"><a href="https://hits.sh/github.com/Plus98ir/Auto_SSL/"><img src="https://hits.sh/github.com/Plus98ir/Auto_SSL.svg?style=for-the-badge&label=views&color=2563eb" alt="Views"></a> <a href="https://corenetbase.com/#support"><img src="https://img.shields.io/badge/support-buy%20me%20a%20coffee-e11d2a?style=for-the-badge&logo=buymeacoffee&logoColor=white" alt="Support"></a> <a href="https://Plus98ir.github.io"> <img src="https://img.shields.io/badge/Website-Plus98ir.github.io-blue?style=for-the-badge&logo=google-chrome" alt="Web Page"> </a></p>

<details>
<summary><b>☕ Support · حمایت</b> — USDT (TRC20) / TRX</summary>
<br>
<p align="center"><img src="https://raw.githubusercontent.com/Plus98ir/.github/main/tron-qr.png" width="200" alt="TRON address QR"></p>

```
TA53aFyGNfSAcrCaJi9QmA9x5W47nPJcf7
```

> [!WARNING]
> **TRON network only.** Sending from ERC20 / BEP20 will lose the funds.<br>
> **فقط شبکه‌ی TRON.** ارسال از ERC20 یا BEP20 پول را از بین می‌برد.

</details>

<div align="center">

[🇬🇧 English](#english) | [🇮🇷 فارسی](#persian)

</div>

---

<a name="english"></a>

## 🇬🇧 English

One installer that sets up Let's Encrypt certificates on a Debian or Ubuntu
server, renews them on its own, and lets you manage everything from a terminal
menu or a private Telegram bot.

---

## 📋 Features

| | |
| --- | --- |
| ➕ **New certificates** | Standard (with `www` added only when it resolves) or wildcard. Picks nginx or standalone mode on its own. |
| 🔎 **Checks before issuing** | Confirms the domain points to this server and port 80 is free, so failed attempts don't burn your Let's Encrypt quota. |
| 🔁 **Automatic renewal** | Uses certbot's own timer, or cron when a proxy is set. Nothing is scheduled twice. |
| 🪝 **After every renewal** | Reloads nginx, optionally copies the files to a folder, runs your own command and notifies Telegram. |
| 🔔 **Expiry report** | Daily check that messages you when a certificate has 20 days or fewer left. |
| 🌐 **Wildcard that renews** | Cloudflare API mode renews wildcards unattended. Manual TXT mode is still there, with a warning. |
| 🤖 **Telegram bot** | Status, renew, new certificate, download and backup from your phone. Supports several admins. |
| 📦 **Export** | `.crt`, `.key` and optionally `.pfx` for panels like x-ui and Marzban. |
| 💾 **Backup and restore** | Archives all of `/etc/letsencrypt` in one file and restores it just as easily. |
| 🧪 **Dry run** | Test issuing or renewing on the staging server without using real quota. |
| 🧹 **Clean uninstall** | Removes the bot, schedules and scripts. Certificates stay where they are. |

---

## ⚙️ Step 1 — Create the bot (optional)

Skip this if you only want the terminal menu.

1. Open Telegram and message **@BotFather**.
2. Send `/newbot` and choose a display name.
3. Choose a username ending in `bot` (for example `MySSLManagerBot`).
4. Copy the HTTP API token.

You also need the **numeric ID** of every admin — send `/start` to
[@userinfobot](https://t.me/userinfobot) to get it.

> ⚠️ **Keep the token private.** If it leaks, revoke it with `/revoke` in
> BotFather and run the installer again.

---

## 🚀 Step 2 — Install

On a Debian or Ubuntu server, as root:

```bash
bash <(curl -fsSL https://github.com/Plus98ir/Auto_SSL/releases/latest/download/install-ssl-manager.sh)
```

The installer asks for:

- an HTTP proxy — only if the server can't reach Let's Encrypt and Telegram directly;
- the bot token and admin IDs (comma separated) — press `Enter` to skip the bot;
- whether the bot may send private keys — default is **no**;
- an email address for Let's Encrypt notices.

It then installs the packages, writes the config, the renewal hook, the daily
expiry check and the bot service, and opens the menu.

> 🔄 **Upgrading from v1?** Run `systemctl disable --now ssl-bot` first so two
> listeners never poll the same token.

---

## 🖥 Terminal menu

Type `ssl` at any time.

| Option | What it does |
| --- | --- |
| `1` New certificate | Standard or wildcard, with an optional dry run first. |
| `2` Renew one | Pick a domain from the list and force-renew it. |
| `3` Renew all | Renews everything that's due, or tests it with a dry run. |
| `4` Status of all | Full certbot output plus days left for each domain. |
| `5` Status of one | Details for a single certificate. |
| `6` Delete or revoke | Deletes locally, or revokes at Let's Encrypt too. Removes the matching nginx vhost. |
| `7` Export | Writes `.crt` / `.key` / `.pfx` to `/root/ssl-exports/`. |
| `8` Backup or restore | Archives to `/root/ssl-backups/`, or restores from an archive. |
| `9` Settings | Post-renew command, copy-to folder, Telegram test message. |
| `10` Uninstall | Removes SSL Manager. Certificates are kept. |

---

## 🤖 Telegram bot

Only the admin IDs you entered get a reply; everyone else is ignored.

| Command | What it does |
| --- | --- |
| `/start` | Opens the button menu. |
| `/status` | Pick a domain to see its details and days left. |
| `/renew` | Pick a domain to renew now. |
| `/newcert example.com` | Checks DNS and port 80, issues the certificate and sends the files. |
| `/download` | Pick a domain to receive its certificate files. |
| `/backup` | Creates a backup on the server, and sends it if key sending is on. |

> 🔒 With `SEND_KEYS="no"` the bot sends only `fullchain.pem` and tells you
> where the private key is on the server. Anything sent through Telegram stays
> on Telegram's servers.

---

## 🔁 How renewal works

- **No proxy:** certbot's own `certbot.timer` handles renewals.
- **With a proxy:** the timer is turned off and a cron job runs
  `certbot renew` twice a day with the proxy set.
- After every successful renewal, the hook in
  `/etc/letsencrypt/renewal-hooks/deploy/` reloads nginx, copies the files if
  you set a folder, runs your command and messages the admins.
- Every day at 09:30 server time, the expiry check reports anything close to
  expiring.
- Manual-mode wildcards **can't** renew on their own. Use Cloudflare mode, or
  repeat the manual step every 90 days.

---

## 🔧 Configuration

Everything lives in `/etc/ssl-manager/config` (mode `600`). Menu option `9`
edits the common settings for you.

| Setting | Default | Meaning |
| --- | --- | --- |
| `EMAIL` | — | Address for Let's Encrypt notices. |
| `PROXY_URL` | empty | e.g. `http://user:pass@1.2.3.4:8080`. Leave empty for a direct connection. |
| `BOT_TOKEN` | — | Token from BotFather. |
| `ADMIN_IDS` | — | Numeric IDs, comma separated. |
| `SEND_KEYS` | `no` | Whether the bot may send private keys and backups. |
| `POST_RENEW_CMD` | empty | Runs after each renewal, e.g. `systemctl restart xray`. |
| `COPY_TO_DIR` | empty | Copy `fullchain.pem` and `privkey.pem` here after each renewal. |
| `EXPIRY_WARN_DAYS` | `20` | Report certificates with this many days or fewer left. |

---

## 🗂 Files

| Path | Purpose |
| --- | --- |
| `/etc/ssl-manager/config` | Settings and secrets. |
| `/usr/local/bin/ssl` | Terminal menu. |
| `/usr/local/bin/ssl-bot.sh` | Telegram bot, run by the `ssl-bot` service. |
| `/usr/local/bin/ssl-lib.sh` | Shared helpers. |
| `/usr/local/bin/ssl-expiry-check.sh` | Daily expiry report. |
| `/etc/letsencrypt/renewal-hooks/deploy/00-ssl-manager.sh` | Runs after every renewal. |
| `/var/log/ssl-manager.log` | Issues, renewals and warnings. |
| `/root/ssl-backups/` | Backup archives. |
| `/root/ssl-exports/` | Exported certificate files. |

---

## 🔒 Security

- The config file and the Cloudflare token are readable by root only (`600`).
- The bot token is read from the config, never written into scripts; bot
  scripts are `700`.
- The proxy password is typed hidden and URL-encoded, so `@`, `:` or `#` work.
- Admin checks use the sender's ID, not the chat ID.
- Private keys are never sent over Telegram unless you turn it on.
- After a restart the bot skips old messages, so a command sent earlier never
  runs twice.

### If you fork this repo

Add a `.gitignore` so real data is never committed:

```gitignore
config
cloudflare.ini
*.pem
*.tar.gz
```

---

## 🌐 Proxy — do you need one?

Only if the server can't reach `acme-v02.api.letsencrypt.org` or
`api.telegram.org` directly, which in practice means a server inside Iran.
Servers abroad should leave `PROXY_URL` empty.

The proxy must be reachable **from the server itself**. `127.0.0.1` means that
machine, not your own computer. Check with:

```bash
ss -ltnp | grep <port>
curl -x http://127.0.0.1:<port> -I https://api.telegram.org
```

---

## ❓ Troubleshooting

| Symptom | Cause and fix |
| --- | --- |
| The bot doesn't answer | Check `systemctl status ssl-bot` and `journalctl -u ssl-bot -f`. Make sure an old v1 listener isn't using the same token and your ID is in `ADMIN_IDS`. |
| Domain does not resolve | The A record is missing or hasn't propagated. Fix DNS and retry. |
| Port 80 is busy | Another service (Apache, HAProxy, Xray) holds port 80. Stop it while issuing, or put nginx in front. |
| `Too many failed authorizations` | Let's Encrypt rate limit. Wait an hour and use a dry run until it passes. |
| Wildcard didn't renew | It was issued in manual mode. Reissue it in Cloudflare mode. |
| Renewed, but the site shows the old certificate | The service using it wasn't restarted. Set `POST_RENEW_CMD`. |
| No renewal messages on Telegram | Send a test from menu option `9`. If it fails, check the token and proxy. |

---

## 📎 Notes

- Certificates are issued by [Let's Encrypt](https://letsencrypt.org) through certbot.
- This project is not affiliated with Let's Encrypt or the EFF.

---

<a name="persian"></a>

## 🇮🇷 فارسی

<div align="center">

[🇬🇧 English](#english) | [🇮🇷 فارسی](#persian)

</div>

**🔐 Auto SSL — مدیریت گواهی Let's Encrypt با ربات تلگرام**

<div style="direction: rtl; text-align: right;">

یک نصب‌کننده که گواهی Let's Encrypt را روی سرور دبیان یا اوبونتو راه می‌اندازد،
خودکار تمدیدش می‌کند و مدیریت همه چیز را از منوی ترمینال یا یک ربات خصوصی
تلگرام ممکن می‌کند.

---

## 📋 امکانات

| | |
| --- | --- |
| ➕ **گواهی جدید** | معمولی (`www` فقط اگر رزولو شود اضافه می‌شود) یا وایلدکارت. حالت nginx یا standalone را خودش انتخاب می‌کند. |
| 🔎 **بررسی قبل از صدور** | چک می‌کند دامنه به همین سرور اشاره کند و پورت ۸۰ آزاد باشد، تا تلاش‌های ناموفق سهمیه Let's Encrypt را هدر ندهند. |
| 🔁 **تمدید خودکار** | از تایمر خود certbot استفاده می‌کند، یا اگر پروکسی تنظیم شده باشد از کران. هیچ‌چیز دو بار زمان‌بندی نمی‌شود. |
| 🪝 **بعد از هر تمدید** | nginx را ریلود می‌کند، در صورت تمایل فایل‌ها را به پوشه دلخواه کپی می‌کند، دستور خودتان را اجرا می‌کند و در تلگرام خبر می‌دهد. |
| 🔔 **گزارش انقضا** | بررسی روزانه که اگر گواهی‌ای ۲۰ روز یا کمتر وقت داشته باشد پیام می‌دهد. |
| 🌐 **وایلدکارتِ قابل تمدید** | حالت Cloudflare API وایلدکارت را بدون دخالت شما تمدید می‌کند. حالت TXT دستی هم با هشدار باقی است. |
| 🤖 **ربات تلگرام** | وضعیت، تمدید، گواهی جدید، دانلود و بکاپ از روی گوشی. چند ادمین را پشتیبانی می‌کند. |
| 📦 **خروجی** | فایل `.crt` و `.key` و در صورت نیاز `.pfx` برای پنل‌هایی مثل x-ui و مرزبان. |
| 💾 **بکاپ و بازگردانی** | کل `/etc/letsencrypt` را در یک فایل آرشیو می‌کند و به همین راحتی برش می‌گرداند. |
| 🧪 **تست آزمایشی** | صدور یا تمدید را روی سرور staging تست کنید، بدون مصرف سهمیه واقعی. |
| 🧹 **حذف تمیز** | ربات، زمان‌بندی‌ها و اسکریپت‌ها را حذف می‌کند. گواهی‌ها سر جایشان می‌مانند. |

---

## ⚙️ مرحله ۱ — ساخت ربات (اختیاری)

اگر فقط منوی ترمینال را می‌خواهید، از این مرحله رد شوید.

۱. تلگرام را باز کنید و به **@BotFather** پیام بدهید.
۲. دستور `/newbot` را بفرستید و یک نام نمایشی انتخاب کنید.
۳. یک نام کاربری که به `bot` ختم شود انتخاب کنید (مثلاً `MySSLManagerBot`).
۴. توکن HTTP API را کپی کنید.

همچنین به **آیدی عددی** هر ادمین نیاز دارید — به
[@userinfobot](https://t.me/userinfobot) پیام `/start` بدهید تا آن را بگیرید.

> ⚠️ **توکن را محرمانه نگه دارید.** اگر لو رفت، با `/revoke` در BotFather
> باطلش کنید و نصب‌کننده را دوباره اجرا کنید.

---

## 🚀 مرحله ۲ — نصب

روی سرور دبیان یا اوبونتو، با کاربر روت:

```bash
bash <(curl -fsSL https://github.com/Plus98ir/Auto_SSL/releases/latest/download/install-ssl-manager.sh)
```

نصب‌کننده این‌ها را می‌پرسد:

- پروکسی HTTP — فقط اگر سرور نتواند مستقیم به Let's Encrypt و تلگرام وصل شود؛
- توکن ربات و آیدی ادمین‌ها (جداشده با کاما) — برای رد شدن از ربات `Enter` بزنید؛
- اینکه ربات اجازه ارسال کلید خصوصی داشته باشد یا نه — پیش‌فرض **نه**؛
- یک ایمیل برای اطلاعیه‌های Let's Encrypt.

بعد پکیج‌ها را نصب می‌کند، کانفیگ، هوک تمدید، بررسی روزانه انقضا و سرویس ربات
را می‌سازد و منو را باز می‌کند.

> 🔄 **از نسخه ۱ ارتقا می‌دهید؟** اول `systemctl disable --now ssl-bot` را بزنید
> تا دو لیسنر هم‌زمان روی یک توکن کار نکنند.

---

## 🖥 منوی ترمینال

هر وقت خواستید `ssl` را تایپ کنید.

| گزینه | کارکرد |
| --- | --- |
| `1` گواهی جدید | معمولی یا وایلدکارت، با امکان تست آزمایشی قبل از صدور. |
| `2` تمدید یک دامنه | دامنه را از لیست انتخاب کنید تا فوراً تمدید شود. |
| `3` تمدید همه | هر چه موعدش رسیده را تمدید می‌کند، یا با dry-run تستش می‌کند. |
| `4` وضعیت همه | خروجی کامل certbot به همراه روزهای باقی‌مانده هر دامنه. |
| `5` وضعیت یک دامنه | جزئیات یک گواهی. |
| `6` حذف یا ابطال | حذف محلی، یا ابطال در Let's Encrypt. vhost مربوط در nginx هم پاک می‌شود. |
| `7` خروجی | ساخت `.crt` / `.key` / `.pfx` در `/root/ssl-exports/`. |
| `8` بکاپ یا بازگردانی | آرشیو در `/root/ssl-backups/`، یا بازگردانی از آرشیو. |
| `9` تنظیمات | دستور بعد از تمدید، پوشه کپی و پیام آزمایشی تلگرام. |
| `10` حذف برنامه | SSL Manager را حذف می‌کند. گواهی‌ها باقی می‌مانند. |

---

## 🤖 ربات تلگرام

فقط آیدی‌های ادمینی که وارد کرده‌اید جواب می‌گیرند؛ بقیه نادیده گرفته می‌شوند.

| دستور | کارکرد |
| --- | --- |
| `/start` | منوی دکمه‌ای را باز می‌کند. |
| `/status` | یک دامنه انتخاب کنید تا جزئیات و روزهای باقی‌مانده را ببینید. |
| `/renew` | یک دامنه انتخاب کنید تا همین حالا تمدید شود. |
| `/newcert example.com` | DNS و پورت ۸۰ را چک می‌کند، گواهی صادر می‌کند و فایل‌ها را می‌فرستد. |
| `/download` | یک دامنه انتخاب کنید تا فایل‌های گواهی‌اش را بگیرید. |
| `/backup` | روی سرور بکاپ می‌گیرد و اگر ارسال کلید روشن باشد آن را می‌فرستد. |

> 🔒 با `SEND_KEYS="no"` ربات فقط `fullchain.pem` را می‌فرستد و مسیر کلید خصوصی
> روی سرور را می‌گوید. هر چیزی که از تلگرام رد شود روی سرورهای تلگرام باقی می‌ماند.

---

## 🔁 تمدید چطور کار می‌کند

- **بدون پروکسی:** تایمر خود certbot یعنی `certbot.timer` تمدیدها را انجام می‌دهد.
- **با پروکسی:** تایمر خاموش می‌شود و یک کران‌جاب روزی دو بار `certbot renew`
  را با پروکسی اجرا می‌کند.
- بعد از هر تمدید موفق، هوک داخل `/etc/letsencrypt/renewal-hooks/deploy/`
  nginx را ریلود می‌کند، اگر پوشه تعیین کرده باشید فایل‌ها را کپی می‌کند،
  دستور شما را اجرا می‌کند و به ادمین‌ها پیام می‌دهد.
- هر روز ساعت ۰۹:۳۰ به وقت سرور، گواهی‌های نزدیک به انقضا گزارش می‌شوند.
- وایلدکارتِ حالت دستی **خودکار تمدید نمی‌شود**. از حالت Cloudflare استفاده کنید
  یا هر ۹۰ روز مرحله دستی را تکرار کنید.

---

## 🔧 پیکربندی

همه چیز در `/etc/ssl-manager/config` است (پرمیشن `600`). گزینه `9` منو
تنظیمات رایج را برایتان ویرایش می‌کند.

| تنظیم | پیش‌فرض | توضیح |
| --- | --- | --- |
| `EMAIL` | — | ایمیل برای اطلاعیه‌های Let's Encrypt. |
| `PROXY_URL` | خالی | مثل `http://user:pass@1.2.3.4:8080`. برای اتصال مستقیم خالی بگذارید. |
| `BOT_TOKEN` | — | توکن BotFather. |
| `ADMIN_IDS` | — | آیدی‌های عددی، جداشده با کاما. |
| `SEND_KEYS` | `no` | اینکه ربات اجازه ارسال کلید خصوصی و بکاپ را دارد یا نه. |
| `POST_RENEW_CMD` | خالی | بعد از هر تمدید اجرا می‌شود، مثلاً `systemctl restart xray`. |
| `COPY_TO_DIR` | خالی | بعد از هر تمدید، `fullchain.pem` و `privkey.pem` اینجا کپی می‌شوند. |
| `EXPIRY_WARN_DAYS` | `20` | گواهی‌هایی که این تعداد روز یا کمتر وقت دارند گزارش می‌شوند. |

---

## 🗂 فایل‌ها

| مسیر | کاربرد |
| --- | --- |
| `/etc/ssl-manager/config` | تنظیمات و اطلاعات محرمانه. |
| `/usr/local/bin/ssl` | منوی ترمینال. |
| `/usr/local/bin/ssl-bot.sh` | ربات تلگرام، اجراشده توسط سرویس `ssl-bot`. |
| `/usr/local/bin/ssl-lib.sh` | توابع مشترک. |
| `/usr/local/bin/ssl-expiry-check.sh` | گزارش روزانه انقضا. |
| `/etc/letsencrypt/renewal-hooks/deploy/00-ssl-manager.sh` | بعد از هر تمدید اجرا می‌شود. |
| `/var/log/ssl-manager.log` | صدورها، تمدیدها و هشدارها. |
| `/root/ssl-backups/` | آرشیوهای بکاپ. |
| `/root/ssl-exports/` | فایل‌های خروجی گرفته‌شده. |

---

## 🔒 امنیت

- فایل کانفیگ و توکن Cloudflare فقط برای روت قابل خواندن هستند (`600`).
- توکن ربات از کانفیگ خوانده می‌شود و هیچ‌وقت داخل اسکریپت‌ها نوشته نمی‌شود؛
  اسکریپت‌های ربات `700` هستند.
- پسورد پروکسی مخفی تایپ و URL-encode می‌شود، پس `@` یا `:` یا `#` مشکلی ایجاد نمی‌کنند.
- بررسی ادمین با آیدی فرستنده انجام می‌شود، نه آیدی چت.
- کلید خصوصی هیچ‌وقت از تلگرام فرستاده نمی‌شود مگر اینکه خودتان فعالش کنید.
- بعد از ری‌استارت، ربات پیام‌های قدیمی را رد می‌کند تا دستوری که قبلاً فرستاده‌اید
  دوباره اجرا نشود.

### اگر این ریپو را فورک کردید

یک `.gitignore` بگذارید تا هیچ‌وقت داده واقعی کامیت نشود:

```gitignore
config
cloudflare.ini
*.pem
*.tar.gz
```

---

## 🌐 پروکسی — اصلاً لازم است؟

فقط اگر سرورتان نتواند مستقیم به `acme-v02.api.letsencrypt.org` یا
`api.telegram.org` برسد، که عملاً یعنی سرور داخل ایران. سرورهای خارج باید
`PROXY_URL` را خالی بگذارند.

پروکسی باید **از خود سرور** قابل دسترس باشد. `127.0.0.1` یعنی همان ماشین، نه
کامپیوتر شخصی شما. با این دستورها چک کنید:

```bash
ss -ltnp | grep <port>
curl -x http://127.0.0.1:<port> -I https://api.telegram.org
```

---

## ❓ رفع اشکال

| نشانه | علت و راه‌حل |
| --- | --- |
| ربات جواب نمی‌دهد | `systemctl status ssl-bot` و `journalctl -u ssl-bot -f` را چک کنید. مطمئن شوید لیسنر قدیمی نسخه ۱ روی همان توکن فعال نیست و آیدی شما در `ADMIN_IDS` هست. |
| دامنه رزولو نمی‌شود | رکورد A وجود ندارد یا هنوز پخش نشده. DNS را درست کنید و دوباره امتحان کنید. |
| پورت ۸۰ اشغال است | سرویس دیگری (Apache، HAProxy، Xray) پورت ۸۰ را گرفته. موقع صدور متوقفش کنید یا nginx را جلویش بگذارید. |
| `Too many failed authorizations` | محدودیت نرخ Let's Encrypt. یک ساعت صبر کنید و تا موفق نشده از dry-run استفاده کنید. |
| وایلدکارت تمدید نشد | در حالت دستی صادر شده. دوباره با حالت Cloudflare صادرش کنید. |
| تمدید شد ولی سایت گواهی قدیمی را نشان می‌دهد | سرویسی که از آن استفاده می‌کند ری‌استارت نشده. `POST_RENEW_CMD` را تنظیم کنید. |
| پیام تمدید در تلگرام نمی‌آید | با گزینه `9` منو پیام آزمایشی بفرستید. اگر نرسید، توکن و پروکسی را چک کنید. |

---

## 📎 نکات

- گواهی‌ها توسط [Let's Encrypt](https://letsencrypt.org) و از طریق certbot صادر می‌شوند.
- این پروژه هیچ وابستگی به Let's Encrypt یا EFF ندارد.

</div>
