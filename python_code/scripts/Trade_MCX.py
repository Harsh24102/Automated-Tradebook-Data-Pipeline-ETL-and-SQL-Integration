#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import shutil
from datetime import datetime, timedelta

# Configuration
source_dir = r"\\172.16.4.13\d$\LIVE RISK ADMIN\MCX-SERVER\ADMIN1\CSV\TradeBook"
destination_dir = r"E:\DATA\2025-2026\TRADEBOOK\MCX"

# Yesterday's date
yesterday = datetime.today() - timedelta(days=1)

# Skip weekends
if yesterday.weekday() in (5, 6):  # Saturday=5, Sunday=6
    print(f"Skipped weekend: {yesterday.strftime('%Y-%m-%d')}")
else:
    file_name = f"Trade{yesterday.strftime('%Y%m%d')}.csv"
    src_file_path = os.path.join(source_dir, file_name)
    dst_file_path = os.path.join(destination_dir, file_name)

    if os.path.exists(src_file_path):
        if os.path.exists(dst_file_path):
            if os.path.getsize(dst_file_path) > 0:
                print(f"Skipped (already exists and not empty): {file_name}")
            else:
                try:
                    shutil.copy2(src_file_path, dst_file_path)
                    print(f"Replaced 0 KB file: {file_name}")
                except Exception as e:
                    print(f"Error replacing file {file_name}: {e}")
        else:
            try:
                shutil.copy2(src_file_path, dst_file_path)
                print(f"Copied: {file_name}")
            except Exception as e:
                print(f"Error copying file {file_name}: {e}")
    else:
        print(f"File not found: {file_name}")


# In[ ]:




