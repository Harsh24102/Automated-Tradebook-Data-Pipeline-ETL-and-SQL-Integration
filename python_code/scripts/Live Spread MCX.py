#!/usr/bin/env python
# coding: utf-8

# In[2]:


import os
import shutil
import logging
from datetime import datetime, timedelta

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)

# Paths
server_path_mcx = r"\\172.16.4.13\d$\LIVE RISK ADMIN\MCX-SERVER\ADMIN1\CSV\AdapterSpreadBook"
destination_folder_mcx = r"E:\DATA\2025-2026\SPREADBOOK\MCX"
merge_folder_mcx = r"E:\DATA\2025-2026\MERGE_SPREADBOOK\MERGE_MCX"

# Strategy list
strategies_mcx = [1]

# Use yesterday's date
yesterday_date = (datetime.now() - timedelta(days=1)).strftime('%Y%m%d')
logging.info(f"Using yesterday's date: {yesterday_date}")

def check_write_permission():
    try:
        os.makedirs(destination_folder_mcx, exist_ok=True)
        test_file = os.path.join(destination_folder_mcx, "test_write.txt")
        with open(test_file, 'w') as f:
            f.write("test")
        os.remove(test_file)
        logging.info("Write permission check: SUCCESS")
        return True
    except Exception as e:
        logging.error(f"Write permission check: FAILED - {e}")
        return False

def copy_mcx_files(date):
    for strat in strategies_mcx:
        filename = f"AdapterSpreadBook_{strat}_{date}.csv"
        source_path = os.path.join(server_path_mcx, filename)
        dest_path = os.path.join(destination_folder_mcx, filename)

        os.makedirs(destination_folder_mcx, exist_ok=True)

        if not os.path.exists(source_path):
            logging.warning(f"File not found: {source_path}")
            continue

        try:
            shutil.copy2(source_path, dest_path)
            logging.info(f"Copied: {source_path} -> {dest_path}")
        except PermissionError as pe:
            logging.error(f"Permission error copying {source_path}: {pe}")
            raise
        except Exception as e:
            logging.error(f"Failed to copy {source_path} -> {dest_path}: {e}")

def merge_mcx_files(date):
    os.makedirs(merge_folder_mcx, exist_ok=True)
    merged_file_path = os.path.join(merge_folder_mcx, f"MergedMCX_{date}.csv")

    files_to_merge = []
    for strat in strategies_mcx:
        file_path = os.path.join(destination_folder_mcx, f"AdapterSpreadBook_{strat}_{date}.csv")
        if os.path.exists(file_path):
            files_to_merge.append(file_path)
        else:
            logging.warning(f"Missing for merge: {file_path}")

    if not files_to_merge:
        logging.warning("No files to merge. Merge skipped.")
        return

    try:
        with open(merged_file_path, 'w') as merged_file:
            for i, file in enumerate(files_to_merge):
                with open(file, 'r') as f:
                    if i == 0:
                        merged_file.write(f.read())
                    else:
                        f.readline()  # skip header
                        merged_file.write(f.read())
                logging.info(f"Merged file: {file}")
        logging.info(f"Merged file saved to: {merged_file_path}")
    except Exception as e:
        logging.error(f"Failed during merge: {e}")

if __name__ == "__main__":
    if not check_write_permission():
        logging.error("No write access to destination. Exiting.")
        exit(1)

    try:
        copy_mcx_files(yesterday_date)
        merge_mcx_files(yesterday_date)
    except Exception as e:
        logging.error(f"An unexpected error occurred: {e}", exc_info=True)


# In[ ]:




