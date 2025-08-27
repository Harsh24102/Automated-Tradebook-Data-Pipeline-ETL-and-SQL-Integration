#!/usr/bin/env python
# coding: utf-8

# In[1]:


import os
import pandas as pd
from sqlalchemy import create_engine
import urllib

# ---------- SQL Server connection details ----------
server = 'AG-SERVER-043'
database = 'harsh_data'
username = 'data05'
password = 'sai@123'

# ---------- Create the SQLAlchemy engine ----------
params = urllib.parse.quote_plus(
    f"DRIVER={{ODBC Driver 17 for SQL Server}};"
    f"SERVER={server};"
    f"DATABASE={database};"
    f"UID={username};PWD={password}"
)

engine = create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# ---------- Folder path to start looking for CSV files ----------
root_folder = r"E:\Back-Up Files\Data Team\BSE - NSE\Bhavcopy_CM(MERGED)\FEB_2025_CM - Copy"

# ---------- Loop through folders and process CSV files ----------
for dirpath, _, filenames in os.walk(root_folder):
    for file in filenames:
        if file.lower().endswith('.csv'):
            file_path = os.path.join(dirpath, file)
            table_name = os.path.splitext(file)[0].replace(' ', '_').replace('-', '_')

            print(f"\n📥 Importing: {file_path} → Table: {table_name}")

            try:
                # Read the CSV file
                df = pd.read_csv(file_path, low_memory=False)


                # Upload to SQL Server (replace table if it exists)
                df.to_sql(name=table_name, con=engine, if_exists='replace', index=False)
                print(f"✅ Successfully imported into table: {table_name}")
            except Exception as e:
                print(f"❌ Failed to import {file}: {e}")


# In[ ]:




