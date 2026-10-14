use [BI Report]

SELECT
ManagerID,
Reference_Text,
Exchange,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice,
sum(BuyQuantity) as BuyQuantity,
sum(BuyAmount) as BuyAmount,
sum(SellQuantity)as SellQuantity,
sum(SellAmount) as SellAmount
FROM [dbo].[CLUB__EXPOPT]
group by
ManagerID,
Reference_Text,
Exchange,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice
HAVING
     (SUM(BuyQuantity) - SUM(SellQuantity)) <> 0
ORDER BY
    [ManagerID],
	Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;

Insert Into [dbo].[CLUB__EXPOPT]([ManagerID],[Reference_Text],[Exchange],[SecurityType],[Symbol],[ExpiryDate],[OptionType],[StrikePrice],[BuyQuantity],[BuyAmount],[SellQuantity],[SellAmount])
select [ManagerID],[Reference_Text],[Exchange],[SecurityType],[Symbol],[ExpiryDate],[OptionType],[StrikePrice],[BuyQuantity],[BuyAmount],[SellQuantity],[SellAmount] from [STG_CLUB__EXPOPT]

select * from janvi.[dbo].[EXP_Open_Position_June_16_RS]

Select * from [CLUB__EXPOPT]
where TradeDate = '2025-06-16'
and Symbol = 'BAJFINANCE'


SELECT
    ManagerID,
    Reference_Text,
    Exchange,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice,
    SUM(BuyQuantity) AS BuyQuantity,
    SUM(BuyAmount) AS BuyAmount,
    SUM(SellQuantity) AS SellQuantity,
    SUM(SellAmount) AS SellAmount
FROM [dbo].[CLUB__EXPOPT]
WHERE ExpiryDate >= CAST(GETDATE() AS DATE) 
GROUP BY
    ManagerID,
    Reference_Text,
    Exchange,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice
HAVING
    (SUM(BuyQuantity) - SUM(SellQuantity)) <> 0
ORDER BY
    ManagerID,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;

-- 1. Create staging table (once)
CREATE TABLE [dbo].[RAW_MERGE_EXP]
(
    Server VARCHAR(50),UserID VARCHAR(50),MAINTradeID INT,MAINOrderID INT,OrderID INT,ExchangeOrderNo VARCHAR(50),ExchangeTradeID VARCHAR(50),OrderTime VARCHAR(50),ExchangeOrderTime VARCHAR(50),
	ExchangeTradeTime VARCHAR(50),Exchange VARCHAR(50),SecurityID INT,Symbol VARCHAR(50),ExpiryDate DATE,SecurityType VARCHAR(50),Side VARCHAR(10),OrderType VARCHAR(20),Quantity INT,
    PendingQuantity INT,Price DECIMAL(18, 2),StrikePrice DECIMAL(18, 2),ClientID VARCHAR(50),ReferenceText VARCHAR(255),CTCLID VARCHAR(50),MemberID VARCHAR(50),StrategyID VARCHAR(50),OptionType VARCHAR(10),
    OpenClose VARCHAR(10),ProductType VARCHAR(20),ManagerID VARCHAR(50),Pancard VARCHAR(20),TerminalInfo VARCHAR(50),AlgoID VARCHAR(50),AlgoCategory VARCHAR(50),ParticipantID VARCHAR(50),
    Multiplier INT
);

CREATE TABLE [dbo].[STG_CLUB__EXPOPT]
(
    ManagerID VARCHAR(50),
    Reference_Text VARCHAR(255),
    Exchange VARCHAR(50),
    SecurityType VARCHAR(50),
    Symbol VARCHAR(50),
    ExpiryDate DATE,
    OptionType VARCHAR(10),
    StrikePrice DECIMAL(18,2),
    BuyQuantity INT,
    BuyAmount DECIMAL(18,2),
    SellQuantity INT,
    SellAmount DECIMAL(18,2)
);

ALTER TABLE [dbo].[RAW_MERGE_EXP]
ALTER COLUMN Multiplier VARCHAR(50);


-- 2. Load the CSV to staging
TRUNCATE TABLE [dbo].[RAW_MERGE_EXP];

BULK INSERT [dbo].[RAW_MERGE_EXP]
FROM 'E:\DATA\2025-2026\MERGE_TRADEBOOK\MERGE_EXP\MergedTrade20250617.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK,
    CODEPAGE = 'ACP'
);

TRUNCATE TABLE [dbo].[STG_CLUB__EXPOPT];

INSERT INTO [dbo].[STG_CLUB__EXPOPT]
SELECT
    ManagerID,
    ReferenceText,
    Exchange,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice,
    SUM(CASE WHEN Side = 'Buy' THEN Quantity ELSE 0 END) AS BuyQuantity,
    SUM(CASE WHEN Side = 'Buy' THEN Quantity * Price ELSE 0 END) AS BuyAmount,
    SUM(CASE WHEN Side = 'Sell' THEN Quantity ELSE 0 END) AS SellQuantity,
    SUM(CASE WHEN Side = 'Sell' THEN Quantity * Price ELSE 0 END) AS SellAmount
FROM [dbo].[RAW_MERGE_EXP]
GROUP BY
    ManagerID,
    ReferenceText,
    Exchange,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;

-- 3. Merge into final table, if needed
INSERT INTO [dbo].[CLUB__EXPOPT]
SELECT s.*
FROM [dbo].[STG_CLUB__EXPOPT] s
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[CLUB__EXPOPT] t
    WHERE
        t.ManagerID = s.ManagerID AND
        t.Reference_Text = s.Reference_Text AND
        t.Exchange = s.Exchange AND
        t.SecurityType = s.SecurityType AND
        t.Symbol = s.Symbol AND
        t.ExpiryDate = s.ExpiryDate AND
        t.OptionType = s.OptionType AND
        t.StrikePrice = s.StrikePrice
);


INSERT INTO [dbo].[CLUB__EXPOPT]
(
    ManagerID,
    Reference_Text,
    Exchange,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice,
    BuyQuantity,
    BuyAmount,
    SellQuantity,
    SellAmount
)
SELECT *
FROM (
    SELECT
        ManagerID,
        ReferenceText,
        Exchange,
        SecurityType,
        Symbol,
        ExpiryDate,
        OptionType,
        StrikePrice,
        SUM(CASE WHEN Side = 'Buy' THEN Quantity ELSE 0 END) AS BuyQuantity,
        SUM(CASE WHEN Side = 'Buy' THEN Quantity * Price ELSE 0 END) AS BuyAmount,
        SUM(CASE WHEN Side = 'Sell' THEN Quantity ELSE 0 END) AS SellQuantity,
        SUM(CASE WHEN Side = 'Sell' THEN Quantity * Price ELSE 0 END) AS SellAmount
    FROM [dbo].[RAW_MERGE_EXP]
    WHERE CAST(ExpiryDate AS DATE) >= CAST(GETDATE() AS DATE)
    GROUP BY
        ManagerID,
        ReferenceText,
        Exchange,
        SecurityType,
        Symbol,
        ExpiryDate,
        OptionType,
        StrikePrice
    HAVING
        (SUM(CASE WHEN Side = 'Buy' THEN Quantity ELSE 0 END) -
         SUM(CASE WHEN Side = 'Sell' THEN Quantity ELSE 0 END)) <> 0
) AS FilteredData
WHERE NOT EXISTS (
    SELECT 1 FROM [dbo].[CLUB__EXPOPT] t
    WHERE
        t.ManagerID = FilteredData.ManagerID AND
        t.Reference_Text = FilteredData.ReferenceText AND
        t.Exchange = FilteredData.Exchange AND
        t.SecurityType = FilteredData.SecurityType AND
        t.Symbol = FilteredData.Symbol AND
        t.ExpiryDate = FilteredData.ExpiryDate AND
        t.OptionType = FilteredData.OptionType AND
        t.StrikePrice = FilteredData.StrikePrice
);
