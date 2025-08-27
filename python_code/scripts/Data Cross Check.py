#!/usr/bin/env python
# coding: utf-8

# ## DATA CROSS CHECK 

# In[1]:


import os
import pandas as pd
from datetime import datetime

# --- Configurations ---
DATA_PATHS = {
    'EXP': r'E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_EXP',
    'ALL': r'E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_SENSEX',
    'NFT': r'E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_IFSC_NIFTY',
    'MCX': r'E:\DATA\2025-2026\TRADEBOOK\MCX'
}

FILENAME_PATTERNS = {
    'EXP': 'MergedTrade{date}.csv',
    'ALL': 'MergedTrade{date}.csv',
    'NFT': 'MergedTrade{date}.csv',
    'MCX': 'Trade{date}.csv'
}

def validate_manager_id_for_date(date_str):
    print(f"\nChecking data quality for: {date_str}")

    for segment, folder in DATA_PATHS.items():
        filename = FILENAME_PATTERNS[segment].format(date=date_str)
        file_path = os.path.join(folder, filename)

        print(f"\nSegment: {segment}")
        if not os.path.exists(file_path):
            print(f"  ❌ File not found: {file_path}")
            continue

        try:
            df = pd.read_csv(file_path, dtype=str)
        except Exception as e:
            print(f"  ❌ Failed to read {file_path}: {e}")
            continue

        if 'ManagerID' not in df.columns:
            print(f"  ❌ 'ManagerID' column is missing in {filename}")
            continue

        # Check for missing or blank ManagerID
        missing = df['ManagerID'].isna() | (df['ManagerID'].str.strip() == '')

        if missing.any():
            print(f"  ⚠️  Found {missing.sum()} rows with missing ManagerID in {filename}")
            print(df.loc[missing, ['UserID', 'OrderID', 'ManagerID']])
        else:
            print(f"  ✅ No missing ManagerID in {filename}")

if __name__ == "__main__":
    # Default to today's date or use a specific one (format: YYYYMMDD)
    today_str = datetime.now().strftime('%Y%m%d')

    # Or override with specific date like:
    # today_str = '20250714'

    validate_manager_id_for_date(today_str)


# In[ ]:




