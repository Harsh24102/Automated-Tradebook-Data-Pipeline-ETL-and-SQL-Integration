#!/usr/bin/env python
# coding: utf-8

# In[5]:


import os
import pandas as pd
from sqlalchemy import create_engine, text
import urllib
from datetime import datetime
import re

# === SQL Server connection details ===
server = 'AG-SERVER-043'
database = '2526 GREEK'
username = 'data05'
password = 'sai@123'

# Build SQLAlchemy engine
params = urllib.parse.quote_plus(
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};PWD={password}"
)
engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# === Folder where CSV files are stored ===
csv_folder = r"E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_GREEK"

# === Automatically set today's date ===
today = datetime.today()
today_date_only = today.replace(hour=0, minute=0, second=0, microsecond=0)

# === Extract date from filename (format: MergeGreekDDMMYYYY.csv) ===
def extract_date_from_filename(filename):
    match = re.search(r'MergeGreek(\d{8})', filename)
    if match:
        date_str = match.group(1)
        try:
            return datetime.strptime(date_str, "%d%m%Y")
        except Exception as e:
            print(f"⚠️ Date parse error in filename {filename}: {e}")
            return None
    return None

# === Expected columns in the CSV files ===
expected_cols = [
    'SourceFile', 'ExchangeTradeID', 'Symbol', 'SecurityType', 'ExpiryDate', 'StrikePrice',
    'OptionType', 'SecurityName', 'ManagerID', 'Side', 'Quantity', 'Price', 'ClientID',
    'MemberID', 'ExchangeOrderNo', 'ExchangeOrderStatus', 'Code', 'Exchange', 'TradeDateTime'
]

# === Find all CSVs matching today's date, excluding files with '_CLEANING_LOG' in name ===
files_to_process = []
for file in os.listdir(csv_folder):
    if file.lower().endswith('.csv') and '_cleaning_log' not in file.lower():
        file_date = extract_date_from_filename(file)
        if file_date is not None and file_date.date() == today_date_only.date():
            files_to_process.append(file)

if files_to_process:
    # Truncate table only if files exist to process
    with engine.begin() as connection:
        connection.execute(text("TRUNCATE TABLE Upload_Staging;"))
        count = connection.execute(text("SELECT COUNT(*) FROM Upload_Staging;")).scalar()
        print(f"Upload_Staging table truncated (cleared). Rows now: {count}")

    # Loop through and process each file
    for file in files_to_process:
        file_path = os.path.join(csv_folder, file)
        print(f"\n📥 Processing file: {file_path}")
        try:
            df = pd.read_csv(file_path, quotechar='"', dtype=str)
            df['SourceFile'] = file

            # Clean column headers
            df.columns = [col.strip() for col in df.columns]

            # Check for missing columns
            missing_cols = [col for col in expected_cols if col not in df.columns]
            if missing_cols:
                print(f"⚠️ Skipping {file} — missing columns: {missing_cols}")
                continue

            # Reorder columns to match expected order
            df = df[expected_cols]

            # Upload to SQL staging table
            df.to_sql(name='Upload_Staging', con=engine, if_exists='append', index=False)
            print(f"✅ Successfully appended data from {file} into Upload_Staging "
                  f"({len(df)} rows)")

        except Exception as e:
            print(f"❌ Failed to process {file}: {e}")
else:
    print("📭 No file found for today; skipping truncation and loading.")


# In[ ]:




