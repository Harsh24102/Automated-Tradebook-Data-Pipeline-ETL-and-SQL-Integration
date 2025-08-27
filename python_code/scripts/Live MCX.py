#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import shutil
import time
from datetime import datetime, timedelta

# Configuration
source_dir = r"\\172.16.4.13\d$\LIVE RISK ADMIN\MCX-SERVER\ADMIN1\CSV\TradeBook"
destination_dir = r"E:\DATA\2025-2026\TRADEBOOK\MCX"
check_interval = 300  # seconds between checks (5 minutes)

def is_market_open():
    now = datetime.now()

    # Skip weekends: 5 = Saturday, 6 = Sunday
    if now.weekday() >= 5:
        return False

    # Market starts at 9:00 AM
    market_start = now.replace(hour=9, minute=0, second=0, microsecond=0)

    # Determine seasonal closing times
    # Summer: April (4) to September (9) - closes at 11:30 PM
    # Winter: October (10) to March (3) - closes at 12:00 AM (midnight)
    if now.month in [4, 5, 6, 7, 8, 9]:
        market_end = now.replace(hour=23, minute=59, second=55, microsecond=0)
    else:
        # Midnight of the next day
        market_end = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)

    return market_start <= now <= market_end

def get_today_file_paths():
    # Use the correct date for the filename based on time
    if datetime.now().hour < 9:
        file_date = datetime.now() - timedelta(days=1)
    else:
        file_date = datetime.now()

    file_name = f"Trade{file_date.strftime('%Y%m%d')}.csv"
    return (
        os.path.join(source_dir, file_name),
        os.path.join(destination_dir, file_name),
        file_name
    )

# Track previous file size
previous_size = -1
print(f"[{datetime.now().strftime('%H:%M:%S')}] Starting file monitor...")

while True:
    if not is_market_open():
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Market is closed or it's a weekend. Exiting monitor.")
        break

    src_file, dst_file, file_name = get_today_file_paths()

    if not os.path.exists(src_file):
        print(f"[{datetime.now().strftime('%H:%M:%S')}] Source file not found: {file_name}. Stopping monitor.")
        break

    current_size = os.path.getsize(src_file)

    if current_size != previous_size:
        try:
            shutil.copy2(src_file, dst_file)
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Copied/Updated: {file_name} (Size: {current_size} bytes)")
            previous_size = current_size
        except Exception as e:
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Error copying file: {e}")
    else:
        print(f"[{datetime.now().strftime('%H:%M:%S')}] No change in file: {file_name}")

    time.sleep(check_interval)


# In[ ]:




