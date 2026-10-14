# 📈 Automated Tradebook Data Pipeline — ETL & SQL Server Integration

![Python](https://img.shields.io/badge/ETL-Python%20%7C%20Pandas-3776AB?logo=python&logoColor=white)
![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC2927?logo=microsoftsqlserver&logoColor=white)
![Power BI](https://img.shields.io/badge/Visualization-Power%20BI-F2C811?logo=powerbi&logoColor=black)

An automated pipeline that takes **1M+ raw, inconsistent tradebook records**, cleans and standardises
them with Python, loads them into **SQL Server**, and feeds **Power BI** dashboards for daily P&L,
trader performance and anomaly checks. Batch-file automation runs the steps without manual work.

## Why it matters

Trade files arrived from several sources in different shapes, with duplicates and missing values.
This pipeline gave the team one clean, indexed table set to report from, so daily P&L and anomaly
checks no longer depended on manual spreadsheet work.

## How it works

```
Raw tradebook files ──► Python (Pandas/NumPy) ──► SQL Server (SSMS) ──► Power BI (DAX)
                        clean · merge · validate   optimised procedures   P&L, trader KPIs,
                        dedupe · standardise       indexed tables          anomaly views
```

- **Extract & transform** — Pandas scripts read the raw files, fix types and formats, remove
  duplicates, handle missing values and validate fields before loading.
- **Load** — SQL procedures load the cleaned data into an indexed schema built for large queries.
- **Report** — Power BI connects to the tables; DAX measures cover trade performance, P&L trends and
  strategy effectiveness.

## Repository structure

| Folder | Contents |
|---|---|
| `python_code/scripts/` | Production ETL scripts (bhavcopy fetch, Greek data, live spreads, MCX trades, SQL loads) |
| `python_code/notebooks/` | Notebooks used to develop and test each step |
| `sql_code/DDL/` | Table definitions |
| `sql_code/DML/` | Net buy/sell, remaining-quantity and adjustment queries |
| `sql_code/Procedures/` | Automated upload and expense procedures |
| `sql_code/Reports/` | M2M, open position, tradebook and month-end reports |
| `sql_code/Utilities/` | Bhavcopy price matching and helper queries |

## Run it

1. Create the database and tables in SQL Server using the scripts in `sql_code/DDL`.
2. Install Python dependencies: `pip install pandas numpy pyodbc sqlalchemy openpyxl`
3. Set your SQL Server details as environment variables (see `.env.example`). The scripts read
   `SQL_SERVER`, `SQL_USERNAME` and `SQL_PASSWORD`; the values written in the code
   (`DEMO-SQL-01`, `demo_user`, `Example@123`) are only examples.
4. Change the file-share paths at the top of each script to your own folders (the `192.0.2.x`
   addresses are example addresses), then run the scripts in `python_code/scripts`.
5. Point Power BI at the SQL Server tables.

## Tech stack

Python (Pandas, NumPy) · SQL Server / SSMS · Power BI (DAX) · Windows batch automation

---
*Built from my work as a Data Analyst at Arya Fin-Trade Services. Server names, network addresses, credentials and client IDs in this repository are made-up examples; no client or trading data is included.*
