USE [2526 GREEK];

-- Drop existing tables (optional, for clean reload)
DROP TABLE IF EXISTS Upload_Staging;
DROP TABLE IF EXISTS Upload;
DROP TABLE IF EXISTS StoreData;

-- Upload staging table: raw ingest (as text)
CREATE TABLE Upload_Staging (
    SourceFile VARCHAR(100),
    ExchangeTradeID VARCHAR(50),
    Symbol VARCHAR(50),
    SecurityType VARCHAR(20),
    ExpiryDate VARCHAR(20),
    StrikePrice VARCHAR(50),
    OptionType VARCHAR(10),
    SecurityName VARCHAR(100),
    ManagerID VARCHAR(50),
    Side VARCHAR(10),
    Quantity VARCHAR(20),
    Price VARCHAR(50),
    ClientID VARCHAR(50),
    MemberID VARCHAR(50),
    ExchangeOrderNo VARCHAR(50),
    ExchangeOrderStatus VARCHAR(20),
    Code VARCHAR(50),
    Exchange VARCHAR(10),
    TradeDateTime VARCHAR(50)  
);

-- Cleaned Upload table (intermediate)
CREATE TABLE Upload (
    SourceFile VARCHAR(100),
    ExchangeTradeID BIGINT,
    Symbol VARCHAR(50),
    Side VARCHAR(10),
    Quantity INT,
    Price FLOAT,
    ManagerID VARCHAR(50),
    ExchangeOrderNo VARCHAR(50), 
    SecurityType VARCHAR(20),
    ExpiryDate VARCHAR(20),
    StrikePrice FLOAT,
    OptionType VARCHAR(10),
    SecurityName VARCHAR(100),
    ClientID INT,
    MemberID INT,
    ExchangeOrderStatus VARCHAR(20),
    Code VARCHAR(50),
    Exchange VARCHAR(10),
    TradeDate DATETIME
);

-- Final destination
CREATE TABLE dbo.StoreData (
    SourceFile VARCHAR(100),
    ExchangeTradeID BIGINT,
    Symbol VARCHAR(50),
    Side VARCHAR(10),
    Quantity INT,
    Price FLOAT,
    ManagerID VARCHAR(50),
    ExchangeOrderNo VARCHAR(50), 
    SecurityType VARCHAR(20),
    ExpiryDate DATE,
    StrikePrice FLOAT,
    OptionType VARCHAR(10),
    SecurityName VARCHAR(100),
    ClientID VARCHAR(20),
    MemberID VARCHAR(20),
    ExchangeOrderStatus VARCHAR(20),
    Code VARCHAR(50),
    Exchange VARCHAR(10),
    TradeDate DATE,
    TradeTime TIME(0)
);

-- Clean data before insert
Truncate Table StoreData;
Truncate Table Upload;
Truncate Table Upload_Staging;

--Length Update
Alter Table StoreData
alter column [ExchangeOrderStatus] VARCHAR(50);

-- Load CSV into staging
BULK INSERT Upload_Staging
FROM 'E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_GREEK\MergeGreek18062025_.csv'
WITH (
    FORMAT = 'CSV',
    FIELDQUOTE = '"',
    FIRSTROW = 2
);


select * from Upload_Staging

-- Clean load from staging to Upload
INSERT INTO Upload (
    SourceFile, ExchangeTradeID, Symbol, Side, Quantity, Price, ManagerID, ExchangeOrderNo, 
    SecurityType, ExpiryDate, StrikePrice, OptionType, SecurityName, ClientID, MemberID,
    ExchangeOrderStatus, Code, Exchange, TradeDate
)
SELECT
    SourceFile,
    TRY_CAST(LTRIM(RTRIM(ExchangeTradeID)) AS BIGINT),
    LTRIM(RTRIM(Symbol)),
    LTRIM(RTRIM(Side)),
    TRY_CAST(REPLACE(LTRIM(RTRIM(Quantity)), ',', '') AS INT),
    TRY_CAST(REPLACE(LTRIM(RTRIM(Price)), ',', '') AS FLOAT),
    LTRIM(RTRIM(ManagerID)),
    LTRIM(RTRIM(ExchangeOrderNo)),
    NULL, -- Cleaned later
    LTRIM(RTRIM(ExpiryDate)),
    TRY_CAST(REPLACE(LTRIM(RTRIM(StrikePrice)), ',', '') AS FLOAT),
    LTRIM(RTRIM(OptionType)),
    ISNULL(NULLIF(LTRIM(RTRIM(SecurityName)), ''), '-') AS SecurityName,
    TRY_CAST(LTRIM(RTRIM(ClientID)) AS INT),
    TRY_CAST(LTRIM(RTRIM(MemberID)) AS INT),
    ISNULL(NULLIF(LTRIM(RTRIM(ExchangeOrderStatus)), ''), 'Nil'),
    ISNULL(NULLIF(LTRIM(RTRIM(Code)), ''), '-') AS Code,
    LTRIM(RTRIM(Exchange)),
    TRY_CAST(LTRIM(RTRIM(TradeDateTime)) AS DATETIME)
FROM Upload_Staging;

-- Insert into final StoreData
INSERT INTO StoreData (
    SourceFile, ExchangeTradeID, Symbol, Side, Quantity, Price, ManagerID, ExchangeOrderNo, 
    SecurityType, ExpiryDate, StrikePrice, OptionType, SecurityName, ClientID, MemberID,
    ExchangeOrderStatus, Code, Exchange, TradeDate, TradeTime
)
SELECT 
    SourceFile,
    ExchangeTradeID,
    Symbol,
    Side,
    Quantity,
    Price,
    ManagerID,
    ExchangeOrderNo,
    NULL AS SecurityType,  
    TRY_CAST(ExpiryDate AS DATE),
    StrikePrice,
    CASE 
        WHEN OptionType IN ('CE', 'PE') THEN OptionType
        ELSE 'XX'
    END,
    ISNULL(NULLIF(SecurityName, ''), '-') AS SecurityName,
    ISNULL(NULLIF(CAST(ClientID AS VARCHAR(20)), ''), '-') AS ClientID,
    ISNULL(NULLIF(CAST(MemberID AS VARCHAR(20)), ''), '-') AS MemberID,
    ISNULL(NULLIF(ExchangeOrderStatus, ''), 'Nil'),
    ISNULL(NULLIF(Code, ''), '-') AS Code,
    Exchange,
    CAST(TradeDate AS DATE),
    CAST(TradeDate AS TIME(0))
FROM Upload;

--UPDATE QUERIES
UPDATE StoreData
SET ExpiryDate = TRY_CAST(
    SUBSTRING(SourceFile, 15, 4) + '-' +  -- Year
    SUBSTRING(SourceFile, 13, 2) + '-' +  -- Month
    SUBSTRING(SourceFile, 11, 2)          -- Day
AS DATE)
WHERE ExpiryDate IS NULL
  AND SourceFile LIKE 'MergeGreek%.csv'
  AND Code IS NOT NULL
  AND Code <> '-';

UPDATE StoreData
SET ExpiryDate = NULL
WHERE ExpiryDate = '1900-01-01';

UPDATE StoreData
SET SecurityType = 'OPTSTK'
WHERE StrikePrice > 0 AND OptionType IN ('CE', 'PE');

UPDATE StoreData
SET SecurityType = 'FUTSTK'
WHERE StrikePrice = 0 or StrikePrice is Null AND (OptionType IN ('0', 'XX') OR OptionType IS NULL);

UPDATE StoreData
SET StrikePrice = -0.01, OptionType = 'XX'
WHERE SecurityType = 'FUTSTK';

Update StoreData
set ExpiryDate = '-'
where SourceFile LIKE 'EQ%'
AND ExpiryDate = '1900-01-01'

UPDATE StoreData
SET ExpiryDate = CAST(
    '20' + LEFT(Code, 2) + '-' +       -- Year: '25' → '2025'
    SUBSTRING(Code, 3, 1) + '-' +      -- Month: '6'
    RIGHT(Code, 2)                     -- Day: '10'
    AS DATE
)
WHERE LEN(Code) = 5 AND Code <> '-';

Update StoreData
set ExpiryDate = '1900-01-01'
where ExpiryDate is null

--TO CHECK DATA
SELECT *,
    Code,
    CAST(
        '20' + LEFT(Code, 2) + '-' +
        SUBSTRING(Code, 3, 1) + '-' +
        RIGHT(Code, 2)
        AS DATE
    ) AS ComputedExpiryDate
FROM StoreData
WHERE LEN(Code) = 5 AND Code <> '-';

SELECT * FROM StoreData
where SourceFile LIKE 'EQ%'
AND ExpiryDate = '1900-01-01'

SELECT * FROM [Upload_Staging]
order by TradeDateTime;

SELECT * FROM StoreData
where TradeDate = '2025-07-23';   --TO CHECK PARTICULAR DATE

SELECT * FROM StoreData
where TradeDate like '2025-07%';  --TO CHECK CUMULATIVE DATA

SELECT * FROM StoreData
order by TradeDate DESC;     --TO CHECK OVERALL DATA

delete from StoreData
where TradeDate = '2025-07-07';




