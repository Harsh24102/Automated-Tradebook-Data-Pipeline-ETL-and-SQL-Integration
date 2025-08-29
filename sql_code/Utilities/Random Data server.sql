use harsh_data;

select * from [dbo].[Server_Data];

Select * from Random_Data;

create table Random_Data(
Server varchar(20),
ManagerID varchar(20),
UserID varchar(20),
ClientID Varchar(20),
MemberID int,
Exchange varchar(20),
StrategyID int,
SecurityType Varchar(20),
SecurityID int,
Symbol varchar(80),
ExpiryDate Date,
ReferenceText varchar(80),
OptionType Varchar(6),
StrikePrice Float,
Side char(10),
Quantity int,
Price Float,
ExchangeTradeTime varchar(30));

--Data Replace
TRUNCATE TABLE Random_Data;
--Data Fetch
INSERT INTO Random_Data(Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime
FROM Options_Data;

--DELETE FROM Random_Data
--WHERE ManagerID LIKE '%Mock';

--Inserting Server Details
UPDATE rd
SET rd.Server = sd.ServerName
FROM Random_Data rd
JOIN Server_Data sd ON rd.ManagerID = sd.ManagerID
WHERE rd.Server = 'Default' 
AND sd.ServerName IS NOT NULL 
AND sd.ServerName <> '';


--Active Ids Trades Today
WITH RankedData AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY ManagerID ORDER BY ExchangeTradeTime ASC) AS rn
    FROM random_data  
    WHERE 
        CONVERT(DATE, LEFT(ExchangeTradeTime, 8), 112) = CAST(GETDATE() AS DATE)
        AND CAST(SUBSTRING(ExchangeTradeTime, 10, 2) AS INT) >= 9
)
SELECT * 
FROM RankedData 
WHERE rn = 1
ORDER BY ManagerID;

--For EXPOPT IDs only
WITH RankedData AS (
    SELECT Server, ManagerID, ClientID, UserID, 
           ROW_NUMBER() OVER (PARTITION BY ManagerID ORDER BY ExchangeTradeTime ASC) AS rn
    FROM random_data  
    WHERE 
        CONVERT(DATE, LEFT(ExchangeTradeTime, 8), 112) = CAST(GETDATE() AS DATE)
        AND CAST(SUBSTRING(ExchangeTradeTime, 10, 2) AS INT) >= 9
        AND ManagerID LIKE 'EXPOPT%'  -- Ensures only EXPOPT IDs
        AND TRY_CAST(SUBSTRING(ManagerID, 7, LEN(ManagerID)) AS INT) BETWEEN 1 AND 100
)
SELECT Server, ManagerID, ClientID, UserID
FROM RankedData 
WHERE rn = 1
ORDER BY ManagerID;
