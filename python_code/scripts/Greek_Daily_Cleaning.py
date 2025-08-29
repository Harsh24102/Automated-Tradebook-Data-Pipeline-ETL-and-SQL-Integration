#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import pandas as pd
import re
from datetime import datetime
import warnings

# === Configuration ===
manual_date = os.environ.get("TARGET_DATE")  # Optional: set TARGET_DATE=YYYY-MM-DD in environment
if manual_date:
    today = datetime.strptime(manual_date, "%Y-%m-%d")
    print(f"📌 Manual override date set: {manual_date}")
else:
    today = datetime.today()
file_date_str = today.strftime('%d%m%Y')

file_name = f"MergeGreek{file_date_str}"
merge_folder = r"E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_GREEK"
input_file = os.path.join(merge_folder, f"{file_name}.csv")
output_file = os.path.join(merge_folder, f"{file_name}_.csv")
log_file = os.path.join(merge_folder, f"{file_name}_CLEANING_LOG.csv")

# === Utility Functions ===

def split_symbol(value):
    if pd.isna(value) or not isinstance(value, str):
        return pd.Series([None, None, None, None])
    match = re.match(r"([A-Z]+)(\d{5})(\d{5})([A-Z]{2})", value)
    if match:
        return pd.Series(match.groups())
    elif re.match(r"^[A-Z]+$", value.strip()):
        return pd.Series([value.strip(), None, None, None])
    else:
        return pd.Series([value.strip(), None, None, None])

def clean_security_type(sec_type, source_file):
    exchange = None
    if isinstance(source_file, str):
        parts = source_file.split('_')
        if len(parts) >= 2:
            exchange = parts[1].strip()

    if pd.isna(sec_type):
        return pd.Series([exchange, None])

    sec_type_clean = sec_type.replace("L,", "").strip().upper()
    if sec_type_clean in ["OPT", "BSE OPT", "NSE OPT"]:
        return pd.Series([exchange, "OPTSTK"])
    elif sec_type_clean in ["FUT", "BSE FUT", "NSE FUT"]:
        return pd.Series([exchange, "FUTSTK"])
    elif sec_type_clean in ["OPTSTK", "FUTSTK"]:
        return pd.Series([exchange, sec_type_clean])
    else:
        return pd.Series([exchange, None])

def unify_trade_datetime_columns(df):
    trade_datetime = pd.Series([pd.NaT] * len(df))

    if 'ExchangeTradeTime' in df.columns:
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            dt_exchange = pd.to_datetime(df['ExchangeTradeTime'], errors='coerce')
        trade_datetime = trade_datetime.fillna(dt_exchange)

    if 'TradeDate1' in df.columns and 'TradeTime1' in df.columns:
        dt1 = pd.to_datetime(df['TradeDate1'].astype(str) + ' ' + df['TradeTime1'].astype(str), errors='coerce', dayfirst=True)
        trade_datetime = trade_datetime.fillna(dt1)

    if 'TradeDate2' in df.columns and 'TradeTime2' in df.columns:
        dt2 = pd.to_datetime(df['TradeDate2'].astype(str) + ' ' + df['TradeTime2'].astype(str), errors='coerce', dayfirst=True)
        trade_datetime = trade_datetime.fillna(dt2)

    if 'SourceFile' in df.columns:
        mask = trade_datetime.isna()
        fallback = df.loc[mask, 'SourceFile'].str.extract(r'(\d{2})(\d{2})(\d{4})')
        fallback_dates = pd.to_datetime(
            fallback[0] + '/' + fallback[1] + '/' + fallback[2],
            format='%d/%m/%Y', errors='coerce'
        )
        trade_datetime.loc[mask] = fallback_dates

    df['TradeDateTime'] = trade_datetime.dt.strftime('%Y-%m-%d %H:%M:%S')

    drop_cols = [
        'TradeDate1', 'TradeTime1', 'TradeDate2', 'TradeTime2',
        'ExchangeTradeTime', 'ExchangeOrderTime', 'FinalExchangeOrderTime'
    ]
    df.drop(columns=[col for col in drop_cols if col in df.columns], inplace=True)

    return df

# === Main Processing ===
if not os.path.exists(input_file):
    print(f"⚠️ File not found: {input_file}. Nothing to process today.")
else:
    print(f"Processing file: {input_file}")
    df = pd.read_csv(input_file, encoding='utf-8')
    change_log = {'File': f"{file_name}.csv"}

    # Drop unnecessary columns
    drop_cols = [col for col in df.columns if col.startswith(('Empty', 'Sample', 'Status', 'ClientCode', 'Instruction'))]
    if drop_cols:
        df.drop(columns=drop_cols, inplace=True)
        change_log['Removed Columns'] = drop_cols

    # Normalize 'Side'
    if 'Side' in df.columns:
        before = df['Side'].dropna().unique().tolist()
        df['Side'] = df['Side'].astype(str).str.upper().replace({'1': 'BUY', 'B': 'BUY', '2': 'SELL', 'S': 'SELL'})
        after = df['Side'].dropna().unique().tolist()
        change_log['Side Changed'] = before != after

    # Symbol breakdown
    if 'Symbol' in df.columns:
        df[['CleanedSymbol', 'Code', 'ParsedStrikePrice', 'ParsedOptionType']] = df['Symbol'].apply(split_symbol)
        df['Symbol'] = df['CleanedSymbol'].combine_first(df['Symbol'])

        df['ParsedStrikePrice'] = pd.to_numeric(df['ParsedStrikePrice'], errors='coerce')
        if 'StrikePrice' not in df.columns:
            df['StrikePrice'] = df['ParsedStrikePrice']
        else:
            df['StrikePrice'] = df['StrikePrice'].where(df['StrikePrice'].notna(), df['ParsedStrikePrice'])

        if 'OptionType' not in df.columns:
            df['OptionType'] = df['ParsedOptionType']
        else:
            df['OptionType'] = df['OptionType'].where(df['OptionType'].notna(), df['ParsedOptionType'])

        df.drop(['CleanedSymbol', 'ParsedStrikePrice', 'ParsedOptionType'], axis=1, inplace=True)
        change_log['Symbol Split'] = True

    # SecurityType and Exchange extraction
    if 'SourceFile' in df.columns:
        df[['Exchange', 'SecurityTypeCleaned']] = df.apply(
            lambda row: clean_security_type(row.get('SecurityType', None), row['SourceFile']), axis=1
        )
        df['SecurityType'] = df['SecurityTypeCleaned']
        df.drop(['SecurityTypeCleaned'], axis=1, inplace=True)
        change_log['SecurityType Cleaned'] = True

    # TradeDateTime consolidation
    df = unify_trade_datetime_columns(df)
    change_log['TradeDateTime Unified'] = True

    # Save everything
    df.to_csv(output_file, index=False, encoding='utf-8')
    log_df = pd.DataFrame([change_log])
    log_df.to_csv(log_file, index=False)

    print(f"✅ Cleaned data saved to: {output_file}")
    print(f"📘 Cleaning log saved to: {log_file}")


# In[ ]:




