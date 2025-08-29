#!/usr/bin/env python
# coding: utf-8

# In[2]:


import os
import shutil
import logging
import csv
from datetime import datetime

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)

# Server paths per EXP
server_paths = {
    # "EXP-5": r"\\172.16.4.13\d$\LIVE RISK ADMIN\NIFTY-SERVER\ADMIN8\CSV\AdapterSpreadBook",
    "EXP-6": r"\\172.16.4.13\d$\LIVE RISK ADMIN\BN-SERVER\ADMIN10\CSV\AdapterSpreadBook",
    "EXP-7": r"\\172.16.4.13\d$\LIVE RISK ADMIN\BN-SERVER\EXPSERVER7\CSV\AdapterSpreadBook",
    "EXP-8": r"\\172.16.4.13\d$\LIVE RISK ADMIN\BN-SERVER\EXPSERVER8\CSV\AdapterSpreadBook",
    "EXP BACKUP": r"\\172.16.4.13\d$\LIVE RISK ADMIN\ALL BACKUP SERVER\EXP-BACKUP\CSV\AdapterSpreadBook",
}

# Local paths
destination_base = r"E:\DATA\2025-2026\SPREADBOOK"
merge_output_dir = r"E:\DATA\2025-2026\MERGE_SPREADBOOK\MERGE_EXP"

# Strategies
strategies = [1, 54]

# Use today's date in YYYYMMDD format
today_date = datetime.now().strftime('%Y%m%d')
logging.info(f"Using current date: {today_date}")

def check_write_permission():
    try:
        test_path = os.path.join(destination_base, "test_exp_write.txt")
        with open(test_path, 'w') as f:
            f.write("test")
        os.remove(test_path)
        logging.info("Write permission check: SUCCESS")
        return True
    except Exception as e:
        logging.error(f"Write permission check: FAILED - {e}")
        return False

def copy_spread_files(date):
    copied_files = []
    for exp, src_base in server_paths.items():
        for strat in strategies:
            filename = f"AdapterSpreadBook_{strat}_{date}.csv"
            source_path = os.path.join(src_base, filename)
            dest_folder = os.path.join(destination_base, exp)
            dest_path = os.path.join(dest_folder, filename)

            os.makedirs(dest_folder, exist_ok=True)

            logging.info(f"Checking file: {source_path}")
            if not os.path.exists(source_path):
                logging.warning(f"Source file NOT found: {source_path}")
                continue

            try:
                shutil.copy2(source_path, dest_path)
                logging.info(f"Copied: {source_path} -> {dest_path}")
                copied_files.append(dest_path)
            except PermissionError as pe:
                logging.error(f"Permission denied copying {source_path}: {pe}")
                raise
            except Exception as e:
                logging.error(f"Failed to copy {source_path} -> {dest_path}: {e}")

    return copied_files

def merge_csvs(copied_files, date):
    merge_output_path = os.path.join(merge_output_dir, f"MergedEXP_{date}.csv")
    os.makedirs(merge_output_dir, exist_ok=True)

    try:
        with open(merge_output_path, mode='w', newline='', encoding='utf-8') as outfile:
            writer = None
            for file_path in copied_files:
                if not os.path.exists(file_path):
                    logging.warning(f"Skipping missing file: {file_path}")
                    continue
                try:
                    with open(file_path, mode='r', newline='', encoding='utf-8') as infile:
                        reader = csv.reader(infile)
                        headers = next(reader, None)
                        if writer is None:
                            writer = csv.writer(outfile)
                            writer.writerow(headers)
                        for row in reader:
                            writer.writerow(row)
                    logging.info(f"Merged file: {file_path}")
                except Exception as e:
                    logging.error(f"Error merging file {file_path}: {e}")
        logging.info(f"Merged file saved to: {merge_output_path}")
    except Exception as e:
        logging.error(f"Failed to create merged file: {e}")

if __name__ == "__main__":
    if not check_write_permission():
        logging.error("No write access to destination. Exiting.")
        exit(1)
    try:
        copied_files = copy_spread_files(today_date)
        if copied_files:
            merge_csvs(copied_files, today_date)
        else:
            logging.warning("No files copied. Merge skipped.")
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}", exc_info=True)


# In[ ]:




