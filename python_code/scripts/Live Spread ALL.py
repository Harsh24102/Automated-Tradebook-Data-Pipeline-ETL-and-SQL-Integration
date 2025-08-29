#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import os
import shutil
import logging
from datetime import datetime

# Setup logging with console output only (no log file)
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)

# Server paths for ALL segment
server_paths_all = {
    "PAIR": r"\\172.16.4.13\d$\LIVE RISK ADMIN\PAIR-SERVER\ADMIN4\CSV\AdapterSpreadBook",
    "SENSEX-1": r"\\172.16.4.13\d$\LIVE RISK ADMIN\PAIR-SERVER\SENSEX-1\CSV\AdapterSpreadBook",
    "SENSEX-2": r"\\172.16.4.13\d$\LIVE RISK ADMIN\PAIR-SERVER\SENSEX-2\CSV\AdapterSpreadBook",
    "SENSEX-BACKUP": r"\\172.16.4.13\d$\LIVE RISK ADMIN\ALL BACKUP SERVER\SENX-BACKUP\CSV\AdapterSpreadBook"
}

# Local destination base for ALL segment
destination_base_all = r"E:\DATA\2025-2026\SPREADBOOK"

# Strategies for ALL segment
strategies = [1, 47, 54, 237]

def check_write_permission():
    test_path = os.path.join(destination_base_all, "test_write.txt")
    try:
        with open(test_path, 'w') as f:
            f.write("test")
        os.remove(test_path)
        logging.info(f"Write permission check: SUCCESS at {destination_base_all}")
        return True
    except Exception as e:
        logging.error(f"Write permission check: FAILED at {destination_base_all} - {e}")
        return False

def copy_all_files(date):
    for exp, src_base in server_paths_all.items():
        for strat in strategies:
            filename = f"AdapterSpreadBook_{strat}_{date}.csv"
            source_path = os.path.join(src_base, filename)
            dest_folder = os.path.join(destination_base_all, exp)
            dest_path = os.path.join(dest_folder, filename)

            os.makedirs(dest_folder, exist_ok=True)

            logging.info(f"Checking existence of source file: {source_path}")
            if not os.path.exists(source_path):
                logging.warning(f"Source file NOT found: {source_path}")
                continue  # skip copying missing file

            try:
                shutil.copy2(source_path, dest_path)
                logging.info(f"Copied: {source_path} -> {dest_path}")
            except PermissionError as pe:
                logging.error(f"Permission error copying {source_path} -> {dest_path}: {pe}")
                raise
            except Exception as e:
                logging.error(f"Failed to copy {source_path} -> {dest_path}: {e}")

def merge_all_files(date):
    merge_folder = r"E:\DATA\2025-2026\MERGE_SPREADBOOK\MERGE_ALL"
    os.makedirs(merge_folder, exist_ok=True)

    merged_file_path = os.path.join(merge_folder, f"MergedALL_{date}.csv")

    all_files = []
    for exp in server_paths_all.keys():
        for strat in strategies:
            file_path = os.path.join(destination_base_all, exp, f"AdapterSpreadBook_{strat}_{date}.csv")
            if os.path.exists(file_path):
                all_files.append(file_path)
            else:
                logging.warning(f"File to merge not found: {file_path}")

    if not all_files:
        logging.error("No files found to merge. Aborting merge step.")
        return

    try:
        with open(merged_file_path, 'w') as merged_file:
            for file in all_files:
                with open(file, 'r') as f:
                    merged_file.write(f.read())
                logging.info(f"Merged file: {file}")
        logging.info(f"Merged file saved to: {merged_file_path}")
    except Exception as e:
        logging.error(f"Failed to merge files into {merged_file_path}: {e}")

if __name__ == "__main__":
    # Get current date in YYYYMMDD format automatically
    today_date = datetime.now().strftime('%Y%m%d')
    logging.info(f"Using current date: {today_date}")

    if not check_write_permission():
        logging.error("Insufficient write permissions on the destination folder. Exiting.")
        exit(1)

    try:
        copy_all_files(today_date)
        merge_all_files(today_date)
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}", exc_info=True)

