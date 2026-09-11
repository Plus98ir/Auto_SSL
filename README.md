# 🚀 Professional SSL Management & Telegram Bot System

A lightweight, automated, and secure SSL certificate management system designed for Linux servers. It integrates **Certbot**, **Nginx**, and a dedicated **Telegram Bot** to let you manage, renew, download, and check the status of your SSL certificates directly from your chat or a clean CLI menu.

---

## ✨ Features

- **🤖 Telegram Bot Integration:**
  - Interactive inline keyboard menus (`/start`, `/status`, `/renew`, `/newcert`, `/download`).
  - Selective domain status checking and certificate renewals.
  - Direct file delivery (`fullchain.pem` and `privkey.pem`) sent straight to your Telegram chat.
  - Automatic deployment hooks for renewal notifications.
- **🛡️ Nginx & 3X-UI Fallback Compatibility:**
  - Seamlessly works with reverse proxies and panel fallback configurations.
  - Automatically handles standard and wildcard certificates.
- **💻 Interactive CLI Menu:**
  - Quick management script (`ssl`) for local server administration.
- **🌐 Proxy Support:**
  - Built-in HTTP/HTTPS proxy support for restricted network environments.
- **⏰ Automated Renewals:**
  - Automatically sets up a cron job to check and renew certificates twice a day.

---

## 📦 Installation

Run the following command on your Linux server with `root` privileges to install the management system and set up the Telegram bot:

```bash
bash <(curl -s [https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh](https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh))
