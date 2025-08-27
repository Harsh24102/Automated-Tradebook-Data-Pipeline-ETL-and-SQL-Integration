#!/usr/bin/env python
# coding: utf-8

# In[ ]:


import os
import shutil
import logging
from datetime import datetime

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)

# Server paths for NFT
server_paths_nifty = {
    "NIFTY-1(GMT)": r"\\172.16.4.13\d$\LIVE RISK ADMIN\BN-SERVER\ADMIN8\CSV\AdapterSpreadBook",
    "NIFTY-2(OWN)": r"\\172.16.4.13\d$\LIVE RISK ADMIN\BEXOPT-SERVER\ADMIN3\CSV\AdapterSpreadBook"
}

# Local paths
destination_base_nifty = r"E:\DATA\2025-2026\SPREADBOOK"
merge_folder_nifty = r"E:\DATA\2025-2026\MERGE_SPREADBOOK\MERGE_NFT"

# Strategy list
strategies = [1, 54]

# Use current date
today_date = datetime.now().strftime("%Y%m%d")
logging.info(f"Using system date: {today_date}")

def check_write_permission():
    try:
        test_folder = os.path.join(destination_base_nifty, "NFTY_TEST")
        os.makedirs(test_folder, exist_ok=True)
        test_file = os.path.join(test_folder, "test.txt")
        with open(test_file, "w") as f:
            f.write("test")
        os.remove(test_file)
        os.rmdir(test_folder)
        logging.info("Write permission check: SUCCESS")
        return True
    except Exception as e:
        logging.error(f"Write permission check: FAILED - {e}")
        return False

def copy_nft_files(date):
    for exp, src_base in server_paths_nifty.items():
        for strat in strategies:
            filename = f"AdapterSpreadBook_{strat}_{date}.csv"
            source_path = os.path.join(src_base, filename)
            dest_folder = os.path.join(destination_base_nifty, exp)
            dest_path = os.path.join(dest_folder, filename)

            os.makedirs(dest_folder, exist_ok=True)

            if not os.path.exists(source_path):
                logging.warning(f"File not found: {source_path}")
                continue

            try:
                shutil.copy2(source_path, dest_path)
                logging.info(f"Copied: {source_path} -> {dest_path}")
            except PermissionError as pe:
                logging.error(f"Permission denied copying {source_path}: {pe}")
                raise
            except Exception as e:
                logging.error(f"Copy error for {source_path} -> {dest_path}: {e}")

def merge_nft_files(date):
    os.makedirs(merge_folder_nifty, exist_ok=True)
    merged_file_path = os.path.join(merge_folder_nifty, f"MergedNFT_{date}.csv")

    files_to_merge = []
    for exp in server_paths_nifty:
        for strat in strategies:
            path = os.path.join(destination_base_nifty, exp, f"AdapterSpreadBook_{strat}_{date}.csv")
            if os.path.exists(path):
                files_to_merge.append(path)
            else:
                logging.warning(f"Missing for merge: {path}")

    if not files_to_merge:
        logging.warning("No files found to merge. Merge skipped.")
        return

    try:
        with open(merged_file_path, "w") as merged:
            for i, file in enumerate(files_to_merge):
                with open(file, "r") as f:
                    if i == 0:
                        merged.write(f.read())
                    else:
                        f.readline()  # skip header
                        merged.write(f.read())
                logging.info(f"Merged file: {file}")
        logging.info(f"Merged file saved to: {merged_file_path}")
    except Exception as e:
        logging.error(f"Merge failed: {e}")

if __name__ == "__main__":
    if not check_write_permission():
        logging.error("No write access. Exiting.")
        exit(1)

    try:
        copy_nft_files(today_date)
        merge_nft_files(today_date)
    except Exception as e:
        logging.error(f"Unexpected error: {e}", exc_info=True)

