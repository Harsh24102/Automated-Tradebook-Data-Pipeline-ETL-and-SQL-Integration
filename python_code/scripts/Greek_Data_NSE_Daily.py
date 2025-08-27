#!/usr/bin/env python
# coding: utf-8

# ### NSE CODE for Daily

# In[6]:


import os
import pandas as pd
from datetime import datetime

def log(message):
    print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {message}")

def is_weekend(date_obj):
    return date_obj.weekday() >= 5  # 5 = Saturday, 6 = Sunday

def parse_date_from_filename(filename):
    try:
        date_part = filename[:4]  # MMDD
        current_year = datetime.now().year
        date_obj = datetime.strptime(date_part + str(current_year), "%m%d%Y")
        return date_obj
    except Exception:
        return None

def read_and_fix_file(path, headers, file_type, silent=False):
    if not os.path.exists(path) or os.path.getsize(path) == 0:
        if not silent:
            log(f"⚠️ Skipping zero size or missing {file_type} file: {os.path.basename(path)}")
        return None, None
    try:
        df = pd.read_csv(path, header=None, names=headers)
        file_date = parse_date_from_filename(os.path.basename(path))
        if not silent:
            log(f"📂 Reading {file_type} file: {os.path.basename(path)}")
            if file_date:
                log(f"✅ Parsed date from {file_type} file: {file_date.strftime('%Y-%m-%d')}")
        return df, file_date
    except Exception as e:
        if not silent:
            log(f"❌ Error reading {file_type} file {os.path.basename(path)}: {e}")
        return None, None

def process_segment(segment, paths, output_folder, target_date):
    log(f"--- Processing Segment: {segment} ---")

    target_date_obj = datetime.strptime(target_date, "%Y-%m-%d")

    if is_weekend(target_date_obj):
        log(f"🟡 Skipping all files processing for weekend date: {target_date}")
        log(f"--- Completed processing for segment: {segment} ---")
        return

    fo_files = sorted(os.listdir(paths.get("FO", ""))) if os.path.exists(paths.get("FO", "")) else []
    eq_files = sorted(os.listdir(paths.get("EQ", ""))) if os.path.exists(paths.get("EQ", "")) else []
    currency_files = sorted(os.listdir(paths.get("CURRENCY", ""))) if os.path.exists(paths.get("CURRENCY", "")) else []

    # === Headers ===
    fo_headers = [
        "ExchangeTradeID", "Sample1", "Symbol", "SecurityType", "ExpiryDate",
        "StrikePrice", "OptionType", "SecurityName", "Sample2", "Sample3", "ManagerID",
        "Sample4", "Side", "Quantity", "Price", "Sample5", "ClientID", "MemberID",
        "Sample6", "ExchangeTradeTime", "ExchangeOrderTime", "ExchangeOrderNo",
        "ExchangeOrderStatus", "FinalExchangeOrderTime"
    ]

    eq_headers = [
        "ExchangeTradeID", "Sample1", "Symbol", "SecurityType", "SecurityName",
        "Sample2", "Sample3", "Sample4", "ManagerID", "Sample5", "Side", "Quantity",
        "Price", "Sample6", "ClientID", "MemberID", "Sample7", "Sample8", "Sample9",
        "ExchangeTradeTime", "ExchangeOrderTime", "ExchangeOrderNo",
        "ExchangeOrderStatus", "FinalExchangeOrderTime"
    ]

    currency_headers = [
        "ExchangeTradeID", "Sample1", "Symbol", "SecurityType", "SecurityName",
        "Sample2", "Quantity", "Price", "ExchangeTradeTime", "ExchangeOrderTime",
        "ExchangeOrderNo", "ExchangeOrderStatus"
    ]

    file_date_str = target_date_obj.strftime("%d%m%Y")
    processed_any = False

    # === Process FO ===
    processed_fo = False
    for fo_file in fo_files:
        fo_date = parse_date_from_filename(fo_file)
        if fo_date != target_date_obj:
            continue
        fo_path = os.path.join(paths["FO"], fo_file)
        if not os.path.exists(fo_path) or os.path.getsize(fo_path) == 0:
            log(f"⚠️ Skipping zero size or missing FO file: {fo_file}")
            continue
        df_fo, _ = read_and_fix_file(fo_path, fo_headers, "FO", silent=True)
        if df_fo is not None:
            log(f"✅ Processing FO file: {fo_file} -> {target_date}")
            fo_out = os.path.join(output_folder, f"FO_NSE_{file_date_str}.csv")
            df_fo.to_csv(fo_out, index=False, encoding='utf-8')
            log(f"✅ FO output saved: {fo_out}")
            processed_fo = True
            processed_any = True
            break
    if not processed_fo:
        log(f"⚠️ No FO file found for date {target_date}")

    # === Process EQ ===
    processed_eq = False
    for eq_file in eq_files:
        eq_date = parse_date_from_filename(eq_file)
        if eq_date != target_date_obj:
            continue
        eq_path = os.path.join(paths["EQ"], eq_file)
        if not os.path.exists(eq_path) or os.path.getsize(eq_path) == 0:
            log(f"⚠️ Skipping zero size or missing EQ file: {eq_file}")
            continue
        log(f"✅ Found matching EQ file: {eq_file}")
        df_eq, _ = read_and_fix_file(eq_path, eq_headers, "EQ", silent=True)
        if df_eq is not None:
            eq_out = os.path.join(output_folder, f"EQ_NSE_{file_date_str}.csv")
            df_eq.to_csv(eq_out, index=False, encoding='utf-8')
            log(f"✅ EQ output saved: {eq_out}")
            processed_eq = True
            processed_any = True
            break
    if not processed_eq:
        log(f"⚠️ No EQ file found for date {target_date}")

    # === Process Currency ===
    processed_currency = False
    for cur_file in currency_files:
        cur_date = parse_date_from_filename(cur_file)
        if cur_date != target_date_obj:
            continue
        cur_path = os.path.join(paths["CURRENCY"], cur_file)
        if not os.path.exists(cur_path) or os.path.getsize(cur_path) == 0:
            log(f"⚠️ Skipping zero size or missing Currency file: {cur_file}")
            continue
        df_cur, _ = read_and_fix_file(cur_path, currency_headers, "CURRENCY", silent=True)
        if df_cur is not None:
            cur_out = os.path.join(output_folder, f"CU_NSE_{file_date_str}.csv")
            df_cur.to_csv(cur_out, index=False, encoding='utf-8')
            log(f"✅ Currency output saved: {cur_out}")
            processed_currency = True
            processed_any = True
            break
    if not processed_currency:
        log(f"⚠️ No Currency file found for date {target_date}")

    if processed_any:
        log(f"✅ Processed date: {target_date}")
    else:
        log(f"⚠️ No files found for date {target_date}")

    log(f"--- Completed processing for segment: {segment} ---")


# ==== CONFIGURATION ====
paths = {
    "FO": r"\\172.16.5.33\greek_admin_backup\AutoOnlineBackup\NSE\FO",
    "EQ": r"\\172.16.5.33\greek_admin_backup\AutoOnlineBackup\NSE\EQ",
    "CURRENCY": r"\\172.16.5.33\greek_admin_backup\AutoOnlineBackup\NSE\Currency"
}

output_folder = r"E:\DATA\2025-2026\GREEK TRADEBOOK"

# === Use today's date automatically ===
target_date = datetime.now().strftime("%Y-%m-%d")

# ==== RUN ====
log("======= NSE GREEK AUTO BACKUP PROCESS STARTED =======")
process_segment("NSE", paths, output_folder, target_date)
log("======= NSE PROCESS COMPLETED =======")

