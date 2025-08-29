#!/usr/bin/env python
# coding: utf-8

# In[3]:


import os
import shutil
from datetime import datetime, timedelta

# Configuration
source_dir = r"\\172.16.4.13\d$\LIVE RISK ADMIN\PAIR-SERVER\TEST-SERVER\CSV\TradeBook"
destination_dir = r"E:\DATA\2025-2026\TEST SERVER TRADEBOOK"

# Simple logging function (prints only)
def log(message):
    print(message)

# Date range
start_date = datetime(2025, 6, 18)
end_date = datetime.today()

# Loop through dates and copy files
current_date = start_date
while current_date <= end_date:
    # Skip weekends
    if current_date.weekday() in (5, 6):
        log(f"Skipped weekend: {current_date.strftime('%Y-%m-%d')}")
        current_date += timedelta(days=1)
        continue

    file_name = f"Trade{current_date.strftime('%Y%m%d')}.csv"
    src_file_path = os.path.join(source_dir, file_name)
    dst_file_path = os.path.join(destination_dir, file_name)

    if os.path.exists(src_file_path):
        if os.path.exists(dst_file_path):
            if os.path.getsize(dst_file_path) > 0:
                log(f"Skipped (already exists and not empty): {file_name}")
            else:
                try:
                    shutil.copy2(src_file_path, dst_file_path)
                    log(f"Replaced 0 KB file: {file_name}")
                except Exception as e:
                    log(f"Error replacing file {file_name}: {e}")
        else:
            try:
                shutil.copy2(src_file_path, dst_file_path)
                log(f"Copied: {file_name}")
            except Exception as e:
                log(f"Error copying file {file_name}: {e}")
    else:
        log(f"File not found: {file_name}")

    current_date += timedelta(days=1)


# In[ ]:




