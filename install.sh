#!/bin/bash

clear
echo "===================================================="
echo "    Fortnite Telegram Bot - Automated Installer     "
echo "===================================================="
echo ""

read -s -p "Please enter your Telegram Bot Token: " BOT_TOKEN
echo ""
read -p "Please enter your Admin Chat ID (Numeric): " ADMIN_CHAT_ID
echo ""

# تنظیمات پروکسی
read -p "Do you want to use a Proxy? (y/n, default n): " USE_PROXY
if [[ "$USE_PROXY" == "y" || "$USE_PROXY" == "Y" ]]; then
    read -p "Proxy Type (http/socks5, default socks5): " PROXY_TYPE
    PROXY_TYPE=${PROXY_TYPE:-socks5}
    read -p "Proxy IP/Host: " PROXY_HOST
    read -p "Proxy Port: " PROXY_PORT
    read -p "Proxy Username (leave empty if none): " PROXY_USER
    read -s -p "Proxy Password (leave empty if none): " PROXY_PASS
    echo ""

    if [ -n "$PROXY_USER" ]; then
        PROXY_URL="${PROXY_TYPE}://${PROXY_USER}:${PROXY_PASS}@${PROXY_HOST}:${PROXY_PORT}"
    else
        PROXY_URL="${PROXY_TYPE}://${PROXY_HOST}:${PROXY_PORT}"
    fi
    echo "✅ Proxy is set to: $PROXY_URL"
else
    PROXY_URL=""
    echo "❌ No Proxy selected. Running directly."
fi
echo ""

if [ -z "$BOT_TOKEN" ] || [ -z "$ADMIN_CHAT_ID" ]; then
    echo "❌ Error: Token or Admin ID cannot be empty. Installation aborted."
    exit 1
fi

echo "[1/5] Updating system packages and installing prerequisites..."
apt update && apt install -y python3 python3-pip python3-requests python3-bs4 git

echo "[2/5] Installing required Python libraries (Telegram, Cloudscraper)..."
pip3 install requests beautifulsoup4 cloudscraper "python-telegram-bot[job-queue]" httpx[socks] --break-system-packages

echo "[3/5] Creating bot files in /root/fortnite_bot ..."
mkdir -p /root/fortnite_bot

# ----------------------------------------------------
# Creating vbucks_scraper.py
# ----------------------------------------------------
cat << 'EOF' > /root/fortnite_bot/vbucks_scraper.py
import cloudscraper
from bs4 import BeautifulSoup
import requests
import json
import re
import os

PROXY_URL = os.environ.get("PROXY_URL", "")
PROXIES = {"http": PROXY_URL, "https": PROXY_URL} if PROXY_URL else None

def get_vbucks_missions():
    url = "https://seebot.dev/missions.php"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "application/json, text/javascript, */*; q=0.01"
    }
    try:
        response = requests.get(url, headers=headers, proxies=PROXIES)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        json_data = None
        
        for script in soup.find_all('script'):
            text = script.string
            if text and "powerLevel" in text:
                if "[" in text and "]" in text:
                    start = text.find('[')
                    end = text.rfind(']') + 1
                    try:
                        json_data = json.loads(text[start:end])
                        break
                    except:
                        continue
                        
        missions_found = []
        if json_data:
            for mission in json_data:
                alert_rewards = mission.get("alertRewards", [])
                for r in alert_rewards:
                    item_type = str(r.get("itemType", "")).upper()
                    
                    if "V-BUCKS" in item_type or "VBUCKS" in item_type:
                        zone = mission.get("zone", "Unknown")
                        name = mission.get("name", "Mission")
                        pl = mission.get("powerLevel", 0)
                        qty = r.get("quantity", 50)
                        
                        name_upper = name.upper()
                        if "RIDE THE LIGHTNING" in name_upper: mission_icon = "🚚"
                        elif "CATEGORY" in name_upper or "STORM" in name_upper: mission_icon = "🌀"
                        elif "RETRIVE" in name_upper or "RETRIEVE" in name_upper: mission_icon = "🎈"
                        elif "FIGHT THE STORM" in name_upper: mission_icon = "⛈️"
                        elif "BUILD THE RADAR" in name_upper: mission_icon = "📡"
                        elif "EVACUATE THE SHELTER" in name_upper: mission_icon = "🏠"
                        elif "REPAIR THE SHELTER" in name_upper: mission_icon = "🛠️"
                        elif "DTB" in name_upper or "BOMB" in name_upper: mission_icon = "💣"
                        else: mission_icon = "🎯"
                        
                        mission_str = (
                            f"🌍 **{zone}**\n"
                            f"{mission_icon} `{name}`\n"
                            f"⚡ Power {pl}\n"
                            f"💎 {qty} V-Bucks\n"
                            f"───────────────────"
                        )
                        missions_found.append(mission_str)
                        
        final_message = "✅ **Today's V-Bucks Missions:**\n\n"
        if missions_found:
            for mission in missions_found: final_message += f"{mission}\n"
        else:
            final_message += "❌ No V-Bucks missions available today.\n"
            
        return final_message
    except Exception as e:
        return f"❌ Error fetching V-Bucks: {e}"

def get_160_missions():
    url = "https://seebot.dev/missions.php"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
        "Accept": "application/json, text/javascript, */*; q=0.01"
    }
    try:
        response = requests.get(url, headers=headers, proxies=PROXIES)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        json_data = None
        for script in soup.find_all('script'):
            text = script.string
            if text and "powerLevel" in text:
                if "[" in text and "]" in text:
                    start = text.find('[')
                    end = text.rfind(']') + 1
                    try:
                        json_data = json.loads(text[start:end])
                        break
                    except:
                        continue
        missions_found = []
        if json_data:
            for mission in json_data:
                try: pl = int(mission.get("powerLevel", 0))
                except: pl = 0
                if pl == 160:
                    zone = mission.get("zone", "Unknown")
                    name = mission.get("name", "Mission")
                    biome = mission.get("biome", "")
                    
                    name_upper = name.upper()
                    if "RIDE THE LIGHTNING" in name_upper: mission_icon = "🚚"
                    elif "CATEGORY" in name_upper or "STORM" in name_upper: mission_icon = "🌀"
                    elif "RETRIEVE" in name_upper: mission_icon = "🎈"
                    elif "FIGHT THE STORM" in name_upper: mission_icon = "⛈️"
                    elif "DTB" in name_upper or "BOMB" in name_upper: mission_icon = "💣"
                    else: mission_icon = "⚡"

                    rewards_list = [f"▫️ {r.get('itemType')} `x{r.get('quantity')}`" for r in mission.get("missionRewards", [])]
                    basic_str = "\n   ".join(rewards_list) if rewards_list else "None"
                    
                    alert_list = [f"▪️ {r.get('itemType')} `x{r.get('quantity')}`" for r in mission.get("alertRewards", [])]
                    alert_str = "\n   ".join(alert_list) if alert_list else "None"
                    
                    mission_info = (
                        f"🌍 **{zone}**\n"
                        f"{mission_icon} `{name}`\n"
                        f"⚡ Power {pl}\n"
                        f"🗺 Biome: `{biome}`\n"
                        f"🎁 **Alert Rewards:**\n   {alert_str}\n"
                        f"📦 **Basic Rewards:**\n   {basic_str}\n"
                        f"───────────────────"
                    )
                    missions_found.append(mission_info)
                    
        final_message = "⚡ **Today's Power 160 Missions:**\n\n"
        if missions_found: final_message += "\n".join(missions_found)
        else: final_message += "❌ No Power 160 missions available today.\n"
        return final_message
    except Exception as e:
        return f"❌ Error fetching 160 missions: {e}"

def get_weekly_superchargers():
    url = "https://fortnitedb.com/"
    scraper = cloudscraper.create_scraper()
    if PROXIES:
        scraper.proxies.update(PROXIES)
    
    try:
        response = scraper.get(url, timeout=15)
        response.raise_for_status()
        soup = BeautifulSoup(response.text, 'html.parser')
        
        weekly_reward = None
        target_nodes = soup.find_all(string=re.compile(r'Complete 10|160\+|Weekly', re.IGNORECASE))
        
        for node in target_nodes:
            parent = node.find_parent('div') or node.find_parent('tr') or node.find_parent('td')
            if parent:
                text_content = parent.get_text(separator=" ", strip=True).upper()
                if "SUPERCHARGER" in text_content or "CORE RE-PERK" in text_content or "REPERK" in text_content:
                    if "WEAPON" in text_content: weekly_reward = "Weapon Supercharger"
                    elif "HERO" in text_content: weekly_reward = "Hero Supercharger"
                    elif "SURVIVOR" in text_content: weekly_reward = "Survivor Supercharger"
                    elif "TRAP" in text_content: weekly_reward = "Trap Supercharger"
                    elif "DEFENDER" in text_content: weekly_reward = "Defender Supercharger"
                    elif "CORE" in text_content or "RE-PERK" in text_content: weekly_reward = "Core Re-PERK"
                    
                    if weekly_reward: break  
        
        if not weekly_reward:
            for img in soup.find_all('img'):
                alt_title = str(img.get('alt', '')).upper() + " " + str(img.get('title', '')).upper()
                if "SUPERCHARGER" in alt_title or "CORE RE-PERK" in alt_title:
                    if "WEAPON" in alt_title: weekly_reward = "Weapon Supercharger"
                    elif "HERO" in alt_title: weekly_reward = "Hero Supercharger"
                    elif "SURVIVOR" in alt_title: weekly_reward = "Survivor Supercharger"
                    elif "TRAP" in alt_title: weekly_reward = "Trap Supercharger"
                    elif "DEFENDER" in alt_title: weekly_reward = "Defender Supercharger"
                    elif "CORE" in alt_title: weekly_reward = "Core Re-PERK"
                    
                    if weekly_reward: break
        
        if not weekly_reward:
            return "❌ **Error:** Could not determine this week's reward on FortniteDB."

        item_icon = "🚀"
        if "HERO" in weekly_reward.upper(): item_icon = "🦸‍♂️"
        elif "WEAPON" in weekly_reward.upper(): item_icon = "⚔️"
        elif "TRAP" in weekly_reward.upper(): item_icon = "🧩"
        elif "SURVIVOR" in weekly_reward.upper(): item_icon = "👥"
        elif "DEFENDER" in weekly_reward.upper(): item_icon = "🛡️"
        elif "CORE" in weekly_reward.upper(): item_icon = "🛠️"
        
        return f"🛠 **This Week's Reward:**\n\n{item_icon} **{weekly_reward}**"

    except Exception as e:
        return f"❌ Error fetching FortniteDB Weekly: {e}"
EOF

# ----------------------------------------------------
# Creating vbucks_bot.py
# ----------------------------------------------------
cat << 'EOF' > /root/fortnite_bot/vbucks_bot.py
import logging
import json
import os
import datetime
import requests
import re
from datetime import time, datetime as dt, timezone
from telegram import Update, ReplyKeyboardMarkup, KeyboardButton, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    ApplicationBuilder, 
    ContextTypes, 
    CommandHandler, 
    MessageHandler, 
    CallbackQueryHandler, 
    filters, 
    Defaults
)
from telegram.request import HTTPXRequest

from vbucks_scraper import get_vbucks_missions, get_160_missions, get_weekly_superchargers

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)

USERS_FILE = "/root/fortnite_bot/users.json"
MAX_USERS = 200

# ====================================================
# تنظیمات ادمین
# ====================================================
ADMIN_ID = "YOUR_ADMIN_ID_PLACEHOLDER"
PROXY_URL = os.environ.get("PROXY_URL", "")

# ====================================================
# دیکشنری زبان‌ها (Localization)
# ====================================================
TEXTS = {
    "en": {
        "welcome": "Welcome! Your chat ID is saved.\nUse the menu below to get Fortnite STW updates:",
        "lang_selected": "🇬🇧 English language selected!",
        "btn_vbucks": "💎 V-Bucks Missions",
        "btn_160": "⚡ Power 160 Missions",
        "btn_weekly": "🛠 Weekly Reward",
        "btn_timer": "⏱ Season Timers",
        "btn_lang": "🌐 Language (زبان)",
        "fetching": "Fetching data, please wait...",
        "timer_prompt": "⏱ Select a season to view the remaining time:",
        "timer_bp": "🏆 Battle Pass",
        "timer_venture": "⚡ Venture",
        "timer_updated": "Timer updated 🔄",
        "season_ended": "⚠️ The **{}** has ended!",
        "timer_format": "🌐 **Fortnite {} ({})**\n\n📊 Progress: **{:.1f}%**\n{}\n⏳ Remaining: **{}** Days\n\n⏱ **{}**\n\n🗓 **End Date:** {}\n🚀 **Next Season:** {}",
        "daily_title": "🔔 **Fortnite Daily Reset Update!** 🛒\n-----------------------------------\n\n",
        "weekly_title": "🚨 **Fortnite Weekly Reset & Superchargers!** 🛠\n-----------------------------------\n\n",
        "admin_stat": "📊 **Admin Panel Stats**\n\nTotal registered users: `{}`",
        "admin_new_start": "👤 **New user started the bot!**\n\nName: {}\nUsername: {}\nID: `{}`",
        "admin_new_msg": "👤 **New user sent a message!**\n\nName: {}\nUsername: {}\nID: `{}`",
        "no_username": "None"
    },
    "fa": {
        "welcome": "خوش آمدید! آیدی شما ذخیره شد.\nاز منوی زیر برای دریافت اطلاعات فورتنایت استفاده کنید:",
        "lang_selected": "🇮🇷 زبان فارسی انتخاب شد!",
        "btn_vbucks": "💎 ماموریت‌های ویباکس",
        "btn_160": "⚡ ماموریت‌های پاور 160",
        "btn_weekly": "🛠 جوایز هفتگی",
        "btn_timer": "⏱ تایمر سیزن‌ها",
        "btn_lang": "🌐 Language (زبان)",
        "fetching": "در حال دریافت اطلاعات...",
        "timer_prompt": "⏱ یکی از سیزن‌ها را جهت مشاهده زمان باقی‌مانده انتخاب کنید:",
        "timer_bp": "🏆 بتل پس",
        "timer_venture": "⚡ ونچر",
        "timer_updated": "تایمر به‌روزرسانی شد 🔄",
        "season_ended": "⚠️ زمان **{}** به پایان رسیده است!",
        "timer_format": "🌐 **Fortnite {} ({})**\n\n📊 پیشرفت سیزن: **{:.1f}%**\n{}\n⏳ زمان باقی‌مانده: **{}** روز\n\n⏱ **{}**\n\n🗓 **تاریخ پایان:** {}\n🚀 **سیزن بعدی:** {}",
        "daily_title": "🔔 **آپدیت روزانه ماموریت‌های فورتنایت!** 🛒\n-----------------------------------\n\n",
        "weekly_title": "🚨 **ریست هفتگی و سوپرچارجرهای فورتنایت!** 🛠\n-----------------------------------\n\n",
        "admin_stat": "📊 **آمار پنل مدیریت**\n\nتعداد کل کاربرانی که در ربات ثبت شده‌اند: `{}` نفر",
        "admin_new_start": "👤 **یک کاربر جدید ربات را استارت کرد!**\n\nاسم: {}\nیوزرنیم: {}\nآیدی: `{}`",
        "admin_new_msg": "👤 **یک کاربر جدید به ربات پیام داد!**\n\nاسم: {}\nیوزرنیم: {}\nآیدی: `{}`",
        "no_username": "ندارد"
    }
}

def load_users():
    if os.path.exists(USERS_FILE):
        with open(USERS_FILE, "r") as f:
            data = json.load(f)
            if isinstance(data, list):
                return {str(uid): "en" for uid in data}
            return data
    return {}

def save_user(chat_id, lang=None):
    users = load_users()
    chat_id_str = str(chat_id)
    if chat_id_str not in users or lang is not None:
        if chat_id_str not in users and len(users) >= MAX_USERS:
            return
        users[chat_id_str] = lang if lang else users.get(chat_id_str, "en")
        with open(USERS_FILE, "w") as f:
            json.dump(users, f)

def get_user_lang(chat_id):
    users = load_users()
    return users.get(str(chat_id), "en")

def get_auto_bp_data():
    PROXIES = {"http": PROXY_URL, "https": PROXY_URL} if PROXY_URL else None
    try:
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'}
        res = requests.get("https://fortnite.gg/season-countdown", headers=headers, proxies=PROXIES, timeout=10)
        date_match = re.search(r'ends on [A-Za-z]+, ([A-Za-z]+ \d+, \d{4})', res.text)
        end_date = datetime.datetime(2026, 11, 1, 7, 30, 0, tzinfo=timezone.utc)
        
        if date_match:
            date_str = date_match.group(1)
            end_date = datetime.datetime.strptime(date_str, "%B %d, %Y").replace(hour=7, minute=30, second=0, tzinfo=timezone.utc)
            
        start_date = datetime.datetime(2026, 8, 20, 7, 30, 0, tzinfo=timezone.utc)
        now = datetime.datetime.now(timezone.utc)
        total = (end_date - start_date).total_seconds()
        elapsed = (now - start_date).total_seconds()
        percent = max(0, min(100, (elapsed / total) * 100))
        return end_date, percent
    except Exception:
        end_date = datetime.datetime(2026, 11, 1, 7, 30, 0, tzinfo=timezone.utc)
        start_date = datetime.datetime(2026, 8, 20, 7, 30, 0, tzinfo=timezone.utc)
        now = datetime.datetime.now(timezone.utc)
        percent = max(0, min(100, ((now - start_date).total_seconds() / (end_date - start_date).total_seconds()) * 100))
        return end_date, percent

VENTURE_CYCLES = [
    {"name": "Mild Meadows 🌸", "start": (1, 24), "end": (4, 5)},
    {"name": "Scurvy Shoals 🏴‍☠️", "start": (4, 5), "end": (6, 20)},
    {"name": "Blasted Badlands 🏜", "start": (6, 20), "end": (9, 3)},
    {"name": "Hexsylvania 🎃", "start": (9, 3), "end": (11, 20)},
    {"name": "Frostnite ❄️", "start": (11, 20), "end": (1, 24)}
]

def get_venture_data():
    now = datetime.datetime.now(timezone.utc)
    year = now.year
    for i, v in enumerate(VENTURE_CYCLES):
        sm, sd = v["start"]
        em, ed = v["end"]
        if sm > em: 
            start_dt = datetime.datetime(year if now.month >= sm else year - 1, sm, sd, 0, 0, 0, tzinfo=timezone.utc)
            end_dt = datetime.datetime(year + 1 if now.month >= sm else year, em, ed, 0, 0, 0, tzinfo=timezone.utc)
        else:
            start_dt = datetime.datetime(year, sm, sd, 0, 0, 0, tzinfo=timezone.utc)
            end_dt = datetime.datetime(year, em, ed, 0, 0, 0, tzinfo=timezone.utc)
        if start_dt <= now < end_dt:
            next_season = VENTURE_CYCLES[(i + 1) % len(VENTURE_CYCLES)]["name"]
            return v["name"], start_dt, end_dt, next_season
    return None, None, None, None

def generate_progress_bar(percent, length=10):
    filled = max(0, min(length, int(round(length * percent / 100))))
    return "🟦" * filled + "⬛" * (length - filled)

def get_season_status(season_type, lang):
    t = TEXTS[lang]
    now = datetime.datetime.now(timezone.utc)
    
    if season_type == "timer_bp":
        name = "Current Season"
        end, percent = get_auto_bp_data()
        next_season = "TBA"
        prefix = "Battle Pass" if lang == "en" else "بتل‌پس"
        remaining_diff = end - now
        if remaining_diff.total_seconds() <= 0: return t["season_ended"].format(prefix)
        progress_bar = generate_progress_bar(percent)
    else:
        name, start, end, next_season = get_venture_data()
        prefix = "Venture" if lang == "en" else "ونچر"
        if not name: return "⚠️ Error calculating Venture cycle." if lang == "en" else "⚠️ خطا در محاسبه چرخه‌ی ونچر."
        remaining_diff = end - now
        if remaining_diff.total_seconds() <= 0: return t["season_ended"].format(prefix)
        total_seconds = (end - start).total_seconds()
        elapsed_seconds = (now - start).total_seconds()
        percent = max(0, min(100, (elapsed_seconds / total_seconds) * 100))
        progress_bar = generate_progress_bar(percent)

    days = remaining_diff.days
    hours, remainder = divmod(remaining_diff.seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    timer_str = f"`{days:02d} : {hours:02d} : {minutes:02d} : {seconds:02d}`"

    return t["timer_format"].format(prefix, name, percent, progress_bar, days, timer_str, end.strftime('%Y-%m-%d'), next_season)

def get_main_keyboard(lang, chat_id):
    t = TEXTS[lang]
    keyboard = [
        [KeyboardButton(t["btn_vbucks"]), KeyboardButton(t["btn_160"])],
        [KeyboardButton(t["btn_weekly"]), KeyboardButton(t["btn_timer"])],
        [KeyboardButton(t["btn_lang"])]
    ]
    if str(chat_id) == str(ADMIN_ID):
        keyboard.append([KeyboardButton("👑 Admin Panel")])
        
    return ReplyKeyboardMarkup(keyboard, resize_keyboard=True)

def get_timer_inline_keyboard(lang):
    t = TEXTS[lang]
    inline_keyboard = [
        [InlineKeyboardButton(t["timer_bp"], callback_data="timer_bp"), InlineKeyboardButton(t["timer_venture"], callback_data="timer_venture")]
    ]
    return InlineKeyboardMarkup(inline_keyboard)

def get_lang_keyboard():
    return InlineKeyboardMarkup([
        [InlineKeyboardButton("🇬🇧 English", callback_data="setlang_en"), InlineKeyboardButton("🇮🇷 فارسی", callback_data="setlang_fa")]
    ])

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = update.effective_chat.id
    user = update.effective_user
    users = load_users()
    
    if str(chat_id) not in users and str(chat_id) != str(ADMIN_ID):
        admin_lang = get_user_lang(ADMIN_ID)
        username_str = f"@{user.username}" if user.username else TEXTS[admin_lang]["no_username"]
        try:
            admin_text = TEXTS[admin_lang]["admin_new_start"].format(user.first_name, username_str, user.id)
            await context.bot.send_message(chat_id=ADMIN_ID, text=admin_text, parse_mode="Markdown")
        except: pass
    
    lang = get_user_lang(chat_id)
    save_user(chat_id, lang)
    await update.message.reply_text(TEXTS[lang]["welcome"], reply_markup=get_main_keyboard(lang, chat_id))

async def message_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    chat_id = update.effective_chat.id
    user = update.effective_user
    users = load_users()
    
    if str(chat_id) not in users and str(chat_id) != str(ADMIN_ID):
        admin_lang = get_user_lang(ADMIN_ID)
        username_str = f"@{user.username}" if user.username else TEXTS[admin_lang]["no_username"]
        try:
            admin_text = TEXTS[admin_lang]["admin_new_msg"].format(user.first_name, username_str, user.id)
            await context.bot.send_message(chat_id=ADMIN_ID, text=admin_text, parse_mode="Markdown")
        except: pass
    
    lang = get_user_lang(chat_id)
    text = update.message.text
    t = TEXTS[lang]
    save_user(chat_id, lang)
    
    if text == "👑 Admin Panel" and str(chat_id) == str(ADMIN_ID):
        total_users = len(users)
        await update.message.reply_text(t["admin_stat"].format(total_users), parse_mode="Markdown")
    elif text in [TEXTS["en"]["btn_vbucks"], TEXTS["fa"]["btn_vbucks"]]:
        await update.message.reply_text(t["fetching"])
        await update.message.reply_text(get_vbucks_missions(), parse_mode="Markdown")
    elif text in [TEXTS["en"]["btn_160"], TEXTS["fa"]["btn_160"]]:
        await update.message.reply_text(t["fetching"])
        await update.message.reply_text(get_160_missions(), parse_mode="Markdown")
    elif text in [TEXTS["en"]["btn_weekly"], TEXTS["fa"]["btn_weekly"]]:
        await update.message.reply_text(t["fetching"])
        await update.message.reply_text(get_weekly_superchargers(), parse_mode="Markdown")
    elif text in [TEXTS["en"]["btn_timer"], TEXTS["fa"]["btn_timer"]]:
        await update.message.reply_text(t["timer_prompt"], reply_markup=get_timer_inline_keyboard(lang))
    elif text in [TEXTS["en"]["btn_lang"], TEXTS["fa"]["btn_lang"]]:
        await update.message.reply_text("Select your language / زبان خود را انتخاب کنید:", reply_markup=get_lang_keyboard())

async def callback_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    chat_id = query.message.chat.id
    data = query.data

    if data.startswith("setlang_"):
        new_lang = data.split("_")[1]
        save_user(chat_id, new_lang)
        await query.answer()
        await query.message.reply_text(TEXTS[new_lang]["lang_selected"], reply_markup=get_main_keyboard(new_lang, chat_id))
    elif data in ["timer_bp", "timer_venture"]:
        lang = get_user_lang(chat_id)
        await query.answer(TEXTS[lang]["timer_updated"])
        try: await query.edit_message_text(get_season_status(data, lang), parse_mode="Markdown", reply_markup=get_timer_inline_keyboard(lang))
        except: pass

async def daily_reset_notification(context: ContextTypes.DEFAULT_TYPE):
    users = load_users()
    if not users: return
    try:
        vbucks_data = get_vbucks_missions()
        missions_160_data = get_160_missions()
        for chat_id, lang in users.items():
            try: await context.bot.send_message(chat_id=chat_id, text=TEXTS[lang]["daily_title"] + f"{vbucks_data}\n\n{missions_160_data}", parse_mode="Markdown")
            except: pass
    except: pass

async def weekly_reset_notification(context: ContextTypes.DEFAULT_TYPE):
    users = load_users()
    if not users: return
    try:
        weekly_data = get_weekly_superchargers()
        for chat_id, lang in users.items():
            try: await context.bot.send_message(chat_id=chat_id, text=TEXTS[lang]["weekly_title"] + f"{weekly_data}", parse_mode="Markdown")
            except: pass
    except: pass

if __name__ == '__main__':
    TOKEN = os.environ.get("BOT_TOKEN", "YOUR_TOKEN_PLACEHOLDER")
    defaults = Defaults(tzinfo=timezone.utc)
    
    app_builder = ApplicationBuilder().token(TOKEN).defaults(defaults)
    
    if PROXY_URL:
        t_request = HTTPXRequest(proxy_url=PROXY_URL)
        app_builder = app_builder.request(t_request).get_updates_request(t_request)
        print(f"📡 Using Proxy: {PROXY_URL}")
        
    application = app_builder.build()
    job_queue = application.job_queue

    job_queue.run_daily(daily_reset_notification, time=time(hour=0, minute=1, tzinfo=timezone.utc))
    job_queue.run_daily(weekly_reset_notification, time=time(hour=0, minute=2, tzinfo=timezone.utc), days=(4,))

    application.add_handler(CommandHandler("start", start))
    application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, message_handler))
    application.add_handler(CallbackQueryHandler(callback_handler))

    print("🤖 Telegram Bot is running in Bilingual Mode with Multi-Lang Admin Panel...")
    application.run_polling()
EOF

# ----------------------------------------------------
# جایگذاری اتوماتیک مقادیر توکن و آیدی ادمین در فایل پایتون
# ----------------------------------------------------
sed -i "s/YOUR_TOKEN_PLACEHOLDER/$BOT_TOKEN/g" /root/fortnite_bot/vbucks_bot.py
sed -i "s/YOUR_ADMIN_ID_PLACEHOLDER/$ADMIN_CHAT_ID/g" /root/fortnite_bot/vbucks_bot.py

echo "[4/5] Setting up Systemd service for permanent execution..."
cat << EOF > /etc/systemd/system/vbucksbot.service
[Unit]
Description=Fortnite Monitoring Telegram Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/fortnite_bot
Environment="PROXY_URL=$PROXY_URL"
ExecStart=/usr/bin/python3 /root/fortnite_bot/vbucks_bot.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[5/5] Enabling and starting the service..."
systemctl daemon-reload
systemctl enable vbucksbot.service
systemctl restart vbucksbot.service

echo ""
echo "===================================================="
echo " ✅ Bot installed and running successfully!"
echo " Check status with: systemctl status vbucksbot.service"
echo "===================================================="
