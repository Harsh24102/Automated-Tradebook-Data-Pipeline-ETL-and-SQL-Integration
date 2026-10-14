#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import pandas as pd
from datetime import datetime

# === Config ===
source_folder = r"E:\DATA\2025-2026\GREEK TRADEBOOK"
output_folder = r"E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_GREEK"

segments = ["FO", "EQ", "CU"]
exchanges = ["BSE", "NSE"]

# === Get today's date in DDMMYYYY format ===
today_str = datetime.today().strftime("%d%m%Y")
dfs = []

print(f"\n📆 Processing files for today's date: {today_str}")

# === Loop through each segment-exchange combination ===
for segment in segments:
    for exchange in exchanges:
        filename = f"{segment}_{exchange}_{today_str}.csv"
        file_path = os.path.join(source_folder, filename)
        if os.path.exists(file_path):
            try:
                df = pd.read_csv(file_path, encoding="utf-8")
                df.insert(0, "SourceFile", filename)  # Optional: track source file
                dfs.append(df)
                print(f"✅ Included: {filename}")
            except Exception as e:
                print(f"❌ Error reading {filename}: {e}")
        else:
            print(f"⚠️ File not found: {filename}")

# === Merge and save output if any files were read ===
if dfs:
    try:
        combined_df = pd.concat(dfs, ignore_index=True)
        output_filename = f"MergeGreek{today_str}.csv"
        output_path = os.path.join(output_folder, output_filename)
        os.makedirs(output_folder, exist_ok=True)
        combined_df.to_csv(output_path, index=False, encoding="utf-8")
        print(f"📁 Merged file saved ({len(dfs)} file(s) merged): {output_filename}")
    except Exception as e:
        print(f"❌ Error while merging or saving: {e}")
else:
    print(f"⛔ No valid files found to merge for today ({today_str})")


# In[ ]:




