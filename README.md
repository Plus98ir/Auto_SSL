<p align="center">
  <a href="https://Plus98ir.github.io">
    <img src="https://img.shields.io/badge/Website-Plus98ir.github.io-blue?style=for-the-badge&logo=google-chrome" alt="Web Page">
  </a>
</p>

# 🔐 Auto SSL — Let's Encrypt manager with a Telegram bot

| **🇺🇸 English** | [🇮🇷 فارسی](README.fa.md) |
| --- | --- |

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
