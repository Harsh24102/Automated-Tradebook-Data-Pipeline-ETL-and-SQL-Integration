# 📈 Automated Tradebook Data Pipeline: ETL & SQL Integration

![Status: Complete](https://img.shields.io/badge/Status-Complete-green.svg)
[![Tech Stack](https://img.shields.io/badge/Database-SQL%20Server-red.svg)](https://www.microsoft.com/en-us/sql-server/)
[![Tech Stack](https://img.shields.io/badge/ETL-Python%20%7C%20Pandas-blue.svg)](https://www.python.org/)
[![Tech Stack](https://img.shields.io/badge/Visualization-Power%20BI-yellow.svg)]

## 1. Project Goal & Business Impact

This project established a robust and automated **ETL (Extract, Transform, Load) data pipeline** to manage and analyze over **1 million messy tradebook records** from various sources (as per professional experience). The primary goal was to transform raw trading data into a clean, structured format, integrate it into a centralized **SQL Server** database, and provide real-time insights via Power BI.

* **Business Impact:** Enabled accurate daily P\&L (Profit & Loss) analysis, anomaly detection, and supported data-driven strategic decisions for management, directly addressing data inconsistency issues.

## 2. Pipeline Architecture & Key Features

The pipeline is designed for scalability and data integrity:

* **Data Extraction & Transformation (ET):** Utilized **Python (Pandas and NumPy)** to extract raw, inconsistent data files. Automated scripts perform complex data cleaning, merging, validation, and standardization, handling duplicates and missing values across the 1M+ records.
* **Data Loading (L) & Optimization:** Optimized SQL procedures were created in **SQL Server Management Studio (SSMS)** to efficiently load the cleaned data. The database schema was designed with optimized indexing to ensure fast query performance for large datasets.
* **Visualization Layer:** Connected the standardized SQL tables to **Power BI** to create dynamic dashboards, using **DAX** to calculate key metrics like trade performance, P\&L trends, and strategy effectiveness.

## 3. Technology Stack

| Category | Tools and Libraries |
| :--- | :--- |
| **ETL/Scripting** | **Python** (Pandas, NumPy) |
| **Database** | **SQL Server (SSMS)** |
| **Visualization** | **Power BI (DAX)** |
| **Concepts** | ETL, Data Modeling, Data Cleaning, Indexing |

## 4. Getting Started

1.  **Setup SQL Server:** Install and configure SQL Server, ensuring the database structure (schema and tables) is created to match the pipeline's output.
2.  **Configure Environment:** Install Python and required libraries (`pandas`, `pyodbc` or similar SQL connectors).
3.  **Run ETL Scripts:** Execute the main Python scripts to automate the cleaning, transformation, and loading of the source tradebook files into the SQL Server database.

---

