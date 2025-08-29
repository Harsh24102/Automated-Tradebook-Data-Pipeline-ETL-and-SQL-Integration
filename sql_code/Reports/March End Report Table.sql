use harsh_data;

--To drop Main Table;
Drop table Common_Report_Table;

--Create Main Table
CREATE TABLE Common_Report_Table (
	Server varchar(20),
	ManagerID varchar(20),
	CompanyCode VARCHAR(50),
	UserID varchar(20),
	ClientID Varchar(20),
	MemberID int,
    Token VARCHAR(100),
    Exchange VARCHAR(20),
    StrategyID int,
	SecurityType Varchar(20),
	SecurityID int,
    Symbol VARCHAR(50),
    ExpiryDate DATE,
    OptionType VARCHAR(20),
    StrikePrice Float,
    Side VARCHAR(10),
    Quantity INT,
    Price Float,
    TradeDate DATE,
    BuyQuantity INT,
    SellQuantity INT,
    BuyAmount Float,
    SellAmount Float,
	TRADING_QUANTITY INT,
    TRADING_AMOUNT Float,
    NetQuantity INT,
    NetAmount Float,
	NotProfit Float
    --ClosingPrice Float
);

--Delete Previous Data
TRUNCATE TABLE Common_Report_Table;

--To drop table 890
Drop table Temp_Club_890;

-- Create a temporary table for 890 file
CREATE TABLE Temp_Club_890 (
    CLIENT_ID varchar(20),
    COMPANY_CODE VARCHAR(50),
    SCRIP_SYMBOL VARCHAR(80),
    NET_QUANTITY INT,
    NET_RATE Float,
    NET_AMOUNT Float,
    CLOSING_PRICE Float,
    NOT_PROFIT Float,
    TRADING_QUANTITY INT,
    TRADING_AMOUNT Float,
    BUY_QUANTITY INT,
    BUY_RATE Float,
    BUY_AMOUNT Float,
    SALE_QUANTITY INT,
    SALE_RATE Float,
    SALE_AMOUNT Float,
    TradeDate DATE
);

-- Insert data from CSV into Temp_Club_890
BULK INSERT Temp_Club_890
FROM 'F:\DATA TEAM\Process NSE\CLUBSQL\Club24.csv'
WITH (
    FIRSTROW = 2,  
    FIELDTERMINATOR = ',',  -- Use ',' if the file is comma-separated
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);


-- Insert the data into Common_Report_Table from Club file for EXPOPT Ids
/*INSERT INTO Common_Report_Table (
    ManagerID, CompanyCode, NotProfit, TRADING_QUANTITY, TRADING_AMOUNT, TradeDate, Symbol, ExpiryDate, OptionType, StrikePrice,
    BuyQuantity, SellQuantity, BuyAmount, SellAmount
)
SELECT 
    A.CLIENT_ID, A.COMPANY_CODE, A.NOT_PROFIT, A.TRADING_QUANTITY, A.TRADING_AMOUNT, A.TradeDate, A.Symbol, A.ExpiryDate, A.Option_Type, A.Strike_Price,
    A.BUY_QUANTITY AS BuyQuantity, A.SALE_QUANTITY AS SellQuantity, A.BUY_AMOUNT AS BuyAmount, A.SALE_AMOUNT AS SellAmount
FROM Temp_Club_890 A
WHERE A.CLIENT_ID LIKE 'EXPOPT%' 
AND NOT EXISTS (
    SELECT 1 
    FROM Common_Report_Table B
    WHERE B.ManagerID = A.CLIENT_ID
    AND B.Symbol = A.Symbol
    AND B.TradeDate = A.TradeDate
    AND B.ExpiryDate = A.ExpiryDate
    AND B.OptionType = A.Option_Type
    AND B.StrikePrice = A.Strike_Price
);


--Inserting Expenses column for EXPOPT ids
INSERT INTO Common_Report_Table (
    ManagerID, CompanyCode, Symbol, NetQuantity, NetAmount, NotProfit, TRADING_QUANTITY, TRADING_AMOUNT,
    BuyQuantity, BuyAmount, SellQuantity, SellAmount, TradeDate
)
SELECT 
    CLIENT_ID AS ManagerID,
    COMPANY_CODE AS CompanyCode,
    SCRIP_SYMBOL AS Symbol,
    NET_QUANTITY AS NetQuantity,
    NET_AMOUNT AS NetAmount,
    NOT_PROFIT AS NotProfit,
    TRADING_QUANTITY,
    TRADING_AMOUNT,
    BUY_QUANTITY AS BuyQuantity,
    BUY_AMOUNT AS BuyAmount,
    SALE_QUANTITY AS SellQuantity,
    SALE_AMOUNT AS SellAmount,
    TradeDate
FROM Temp_Club_890
WHERE CLIENT_ID LIKE 'EXPOPT%'
AND COMPANY_CODE = 'EXPENSES';*/



-- Insert the data into Common_Report_Table from Club file for ALLOPT & NFTOPT IDs & EXPOPT IDs
INSERT INTO Common_Report_Table (
    ManagerID, CompanyCode, NotProfit, TRADING_QUANTITY, TRADING_AMOUNT, TradeDate, Symbol, ExpiryDate, OptionType, StrikePrice,
    BuyQuantity, SellQuantity, BuyAmount, SellAmount)
SELECT 
    A.CLIENT_ID, A.COMPANY_CODE, A.NOT_PROFIT, A.TRADING_QUANTITY, A.TRADING_AMOUNT, A.TradeDate, A.Symbol, A.ExpiryDate, A.Option_Type, A.Strike_Price,
	A.BUY_QUANTITY AS BuyQuantity, A.SALE_QUANTITY AS SellQuantity, A.BUY_AMOUNT AS BuyAmount, A.SALE_AMOUNT AS SellAmount
FROM Temp_Club_890 A
WHERE (A.CLIENT_ID LIKE 'ALLOPT%' OR A.CLIENT_ID LIKE 'NFTOPT%' OR A.CLIENT_ID LIKE 'EXPOPT%') 
AND NOT EXISTS (
        SELECT 1 
        FROM Common_Report_Table B
        WHERE B.ManagerID = A.CLIENT_ID
        AND B.Symbol = A.Symbol
        AND B.TradeDate = A.TradeDate
        AND B.ExpiryDate = A.ExpiryDate
        AND B.OptionType = A.Option_Type
        AND B.StrikePrice = A.Strike_Price
);

--Replacing null values
--EXPOPT
UPDATE CRT
SET 
    CRT.UserID = ATB.UserID,
    CRT.ClientID = ATB.ClientID,
    CRT.MemberID = ATB.MemberID,
    CRT.Exchange = ATB.Exchange,
    CRT.StrategyID = ATB.StrategyID,
    CRT.SecurityType = ATB.SecurityType,
    CRT.SecurityID = ATB.SecurityID,
    CRT.Side = ATB.Side,
    CRT.Quantity = ATB.Quantity,
    CRT.Price = ATB.Price
FROM Common_Report_Table CRT
JOIN EXPOPT_TB ATB
ON CRT.ManagerID = ATB.ManagerID
AND CRT.Symbol = ATB.Symbol
AND CRT.ExpiryDate = ATB.ExpiryDate
AND CRT.OptionType = ATB.OptionType
AND CRT.StrikePrice = ATB.StrikePrice
AND CRT.TradeDate = ATB.ExchangeTradeTime
WHERE 
    CRT.UserID IS NULL 
    OR CRT.ClientID IS NULL 
    OR CRT.MemberID IS NULL 
    OR CRT.Exchange IS NULL
    OR CRT.StrategyID IS NULL
    OR CRT.SecurityType IS NULL
    OR CRT.SecurityID IS NULL
    OR CRT.Side IS NULL
    OR CRT.Quantity IS NULL
    OR CRT.Price IS NULL;


--NFTOPT
UPDATE CRT
SET 
    CRT.UserID = ATB.UserID,
    CRT.ClientID = ATB.ClientID,
    CRT.MemberID = ATB.MemberID,
    CRT.Exchange = ATB.Exchange,
    CRT.StrategyID = ATB.StrategyID,
    CRT.SecurityType = ATB.SecurityType,
    CRT.SecurityID = ATB.SecurityID,
    CRT.Side = ATB.Side,
    CRT.Quantity = ATB.Quantity,
    CRT.Price = ATB.Price
FROM Common_Report_Table CRT
JOIN NFTOPT_TB ATB
ON CRT.ManagerID = ATB.ManagerID
AND CRT.Symbol = ATB.Symbol
AND CRT.ExpiryDate = ATB.ExpiryDate
AND CRT.OptionType = ATB.OptionType
AND CRT.StrikePrice = ATB.StrikePrice
AND CRT.TradeDate = ATB.TradeDate
WHERE 
    CRT.UserID IS NULL 
    OR CRT.ClientID IS NULL 
    OR CRT.MemberID IS NULL 
    OR CRT.Exchange IS NULL
    OR CRT.StrategyID IS NULL
    OR CRT.SecurityType IS NULL
    OR CRT.SecurityID IS NULL
    OR CRT.Side IS NULL
    OR CRT.Quantity IS NULL
    OR CRT.Price IS NULL;

--ALLOPT
UPDATE CRT
SET 
    CRT.UserID = ATB.UserID,
    CRT.ClientID = ATB.ClientID,
    CRT.MemberID = ATB.MemberID,
    CRT.Exchange = ATB.Exchange,
    CRT.StrategyID = ATB.StrategyID,
    CRT.SecurityType = ATB.SecurityType,
    CRT.SecurityID = ATB.SecurityID,
    CRT.Side = ATB.Side,
    CRT.Quantity = ATB.Quantity,
    CRT.Price = ATB.Price
FROM Common_Report_Table CRT
JOIN ALLOPT_TB ATB
ON CRT.ManagerID = ATB.ManagerID
AND CRT.Symbol = ATB.Symbol
AND CRT.ExpiryDate = ATB.ExpiryDate
AND CRT.OptionType = ATB.OptionType
AND CRT.StrikePrice = ATB.StrikePrice
AND CRT.TradeDate = ATB.TradeDate
WHERE 
    CRT.UserID IS NULL 
    OR CRT.ClientID IS NULL 
    OR CRT.MemberID IS NULL 
    OR CRT.Exchange IS NULL
    OR CRT.StrategyID IS NULL
    OR CRT.SecurityType IS NULL
    OR CRT.SecurityID IS NULL
    OR CRT.Side IS NULL
    OR CRT.Quantity IS NULL
    OR CRT.Price IS NULL;

--Drop or View Main Table
Drop Table March_Report_2024_25;
select * from March_Report_2024_25;

--Enter Data into new table March_Report_2024_25
SELECT 
    [Server],
    [ManagerID],
    [CompanyCode],
    [UserID],
    [ClientID],
    [MemberID],
    [Exchange],
    [StrategyID],
    [SecurityType],
    [SecurityID],
    [Symbol],
    [ExpiryDate],
    [TradeDate],
    [OptionType],
    [StrikePrice],
	Quantity,
	Price,
	Side,
    BuyQuantity,
    SellQuantity,
    BuyAmount,
    SellAmount,
    TRADING_QUANTITY,
    TRADING_AMOUNT,
    NetQuantity,
    NetAmount,
    NotProfit
INTO March_Report_2024_25
FROM 
    Common_Report_Table;

--Code for storing data into another table for EXPOPT ids only
SELECT 
    Server, 
    ManagerID, 
    UserID, 
    ClientID, 
    MemberID, 
    Exchange, 
    StrategyID, 
    SecurityType, 
    SecurityID, 
    Symbol, 
    ExpiryDate, 
    ReferenceText, 
    OptionType, 
    StrikePrice, 
    Side, 
    Quantity, 
    Price, 
    ExchangeTradeTime,
    Token,
    BuyQuantity,
    BuyAmount,
    SellQuantity,
    SellAmount
--INTO EXPOPT_TB
FROM TB_Opt;
