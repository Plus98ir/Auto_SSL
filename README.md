 <p align="center">
  <a href="https://Plus98ir.github.io">
    <img src="https://img.shields.io/badge/Website-Plus98ir.github.io-blue?style=for-the-badge&logo=google-chrome" alt="Web Page">
  </a>
</p>

---

[🇮🇷 فارسی](README_Fa.md) | **🇺🇸 us English**

---

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
bash <(curl -fsSL https://github.com/Plus98ir/Auto_ssl-telegram_bot/releases/latest/download/install.sh)
```

During installation, the script will ask you for:

Optional HTTP/HTTPS Proxy (if needed).

Telegram Bot Token & Admin Chat ID (optional, can be skipped).

Your email address for Certbot registration and notices.

🛠️ Usage
1. Telegram Bot Commands
Once the bot service is running and configured, send /start to your Telegram bot to open the control panel:

📊 Status: View expiration dates and paths for individual domains via interactive buttons.

🔄 Renew: Choose and renew specific certificates on demand.

➕ New Cert: Issue a new certificate for a domain (e.g., /newcert example.com).

⬇️ Download: Select a domain and receive its certificate files directly in chat.

2. Command Line Interface (CLI)
You can access the interactive management menu anytime on your server by typing:

```txt
ssl
```

⚙️ Configuration & Nginx Fallback Example
If you are using this alongside a panel like 3X-UI with a fallback mechanism pointing to a local Nginx instance (e.g., serving a gaming/decoy HTML page on port 8040), use a clean Nginx configuration block like this:

Nginx
server {
    listen 127.0.0.1:8040;
    server_name yourdomain.com [www.yourdomain.com](https://www.yourdomain.com);
    
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri$uri/ =404;
      }
    }

---
📝 License
This project is open-source and available under the MIT License.

```txt
<Elicitations message="Would you like me to help you customize anything else in this README or adjust the script configuration?">
  <Elicitation label="Customize README badges" query="Can you add status badges or custom sections to this README?"/>
  <Elicitation label="Review script features" query="Let's review the script features to make sure everything is optimized."/>
</Elicitations>
```
