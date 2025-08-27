#!/usr/bin/env python
# coding: utf-8

# ### BSE CODE for Daily

# In[2]:


import os
import pandas as pd
from datetime import datetime

# === Logging Function ===
def log(msg):
    timestamp = datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    full_msg = f"{timestamp} {msg}"
    print(full_msg)

# === Configs ===
manual_date = os.environ.get("TARGET_DATE")

if manual_date:
    try:
        target_date_obj = datetime.strptime(manual_date, "%Y-%m-%d")
        log(f"📌 Manual override date set: {manual_date}")
    except ValueError:
        log(f"❌ Invalid TARGET_DATE format: {manual_date}. Use YYYY-MM-DD.")
        exit(1)
else:
    now = datetime.now()
    target_date_obj = datetime.strptime(now.strftime("%Y-%m-%d"), "%Y-%m-%d")
    if now.hour < 18:
        log("📅 Using today's date (before 6 PM)")
    else:
        log("📅 Using today's date (after 6 PM)")

target_date = target_date_obj.strftime("%Y-%m-%d")
target_date_str_file = target_date_obj.strftime("%d%m%Y")

# === Paths ===
output_folder = r"E:\DATA\2025-2026\GREEK TRADEBOOK"
fo_input_folder = r"\\172.16.5.33\greek_admin_backup\AutoOnlineBackup\BSE\FO"
eq_input_folder = r"\\172.16.5.33\greek_admin_backup\AutoOnlineBackup\BSE\EQ"
cu_input_folder = r"\\172.16.5.33\greek_admin_backup\AutoOnlineBackup\BSE\CURRENCY"

# === Column Headers ===
fo_columns = [
    "Empty1", "Empty2", "Empty3", "Empty4", "ExchangeTradeID", "Symbol", "Side", "Quantity", "Price",
    "ManagerID", "Status", "Empty5", "TradeDate1", "TradeTime1", "TradeDate2", "TradeTime2", "ExchangeOrderNo",
    "SecurityType", "Empty6", "ClientCode", "Instruction"
]

eq_columns = [
    "ExchangeTradeID", "ManagerID", "SecurityCode", "Symbol", "Sample1", "Val1", "Val2", "Val3",
    "ExchangeTradeTime", "ExchangeTradeDate", "ClientCode", "ExchangeOrderNo", "PositionType", "Side",
    "OrderID", "Ownership", "ISIN", "Flag1", "Flag2", "TradeTime2", "Extra"
]

cu_columns = [
    "Col1", "Col2", "Col3", "Col4", "Col5", "Col6", "Col7", "Col8",
    "Col9", "Col10", "Col11", "Col12", "Col13", "Col14", "Col15",
    "Col16", "Col17", "Col18", "Col19", "Col20"
]

# === Helpers ===
def is_weekend(date_obj):
    return date_obj.weekday() >= 5

def parse_date_from_filename(filename):
    try:
        mmdd = filename[:4]
        file_date = datetime.strptime(mmdd + str(target_date_obj.year), "%m%d%Y")
        return file_date
    except Exception:
        return None

def read_file(filepath, headers, label):
    try:
        if not os.path.exists(filepath) or os.path.getsize(filepath) == 0:
            log(f"⚠️ Skipping empty {label} file: {os.path.basename(filepath)}")
            return None
        df = pd.read_csv(filepath, header=None, names=headers, sep="|", encoding="utf-8", engine="python")
        df = df.apply(lambda col: col.str.strip() if col.dtype == "object" else col)
        return df
    except Exception as e:
        log(f"❌ Failed to read {label} file {os.path.basename(filepath)}: {e}")
        return None

# === Main ===
def process_bse_data():
    log("======= BSE GREEK AUTO BACKUP PROCESS STARTED =======")
    log(f"--- Processing Segment: BSE for date: {target_date} ---")

    if is_weekend(target_date_obj):
        log(f"🟡 Skipping all files processing for weekend date: {target_date}")
        log("======= BSE PROCESS COMPLETED =======")
        return

    fo_files = sorted([f for f in os.listdir(fo_input_folder) if f.lower().endswith((".csv", ".txt"))])
    eq_files = sorted([f for f in os.listdir(eq_input_folder) if f.lower().endswith((".csv", ".txt"))])
    cu_files = sorted([f for f in os.listdir(cu_input_folder) if f.lower().endswith((".csv", ".txt"))])

    processed_any = False
    cu_found = False

    # --- FO Files ---
    for file in fo_files:
        file_date = parse_date_from_filename(file)
        if file_date and file_date.date() == target_date_obj.date():
            log(f"✅ Parsed date from FO file: {file} -> {file_date.strftime('%Y-%m-%d')}")
            df = read_file(os.path.join(fo_input_folder, file), fo_columns, "FO")
            if df is not None:
                out_path = os.path.join(output_folder, f"FO_BSE_{target_date_str_file}.csv")
                df.to_csv(out_path, index=False, encoding="utf-8")
                log(f"✅ FO output saved: {out_path}")
                processed_any = True
                break

    # --- EQ Files ---
    for file in eq_files:
        file_date = parse_date_from_filename(file)
        if file_date and file_date.date() == target_date_obj.date():
            log(f"✅ Parsed date from EQ file: {file} -> {file_date.strftime('%Y-%m-%d')}")
            df = read_file(os.path.join(eq_input_folder, file), eq_columns, "EQ")
            if df is not None:
                out_path = os.path.join(output_folder, f"EQ_BSE_{target_date_str_file}.csv")
                df.to_csv(out_path, index=False, encoding="utf-8")
                log(f"✅ EQ output saved: {out_path}")
                processed_any = True
                break

    # --- CU Files ---
    for file in cu_files:
        file_date = parse_date_from_filename(file)
        if file_date and file_date.date() == target_date_obj.date():
            df = read_file(os.path.join(cu_input_folder, file), cu_columns, "Currency")
            if df is not None:
                out_path = os.path.join(output_folder, f"CU_BSE_{target_date_str_file}.csv")
                df.to_csv(out_path, index=False, encoding="utf-8")
                log(f"✅ CU output saved: {out_path}")
                processed_any = True
                cu_found = True
                break

    if not cu_found:
        log(f"⚠️ No Currency file found for date {target_date}")

    if processed_any:
        log(f"✅ Processed date: {target_date}")
    else:
        log(f"⚠️ No files found for date {target_date}")

    log("======= BSE PROCESS COMPLETED =======")

# === Run ===
if __name__ == "__main__":
    process_bse_data()


# In[ ]:




