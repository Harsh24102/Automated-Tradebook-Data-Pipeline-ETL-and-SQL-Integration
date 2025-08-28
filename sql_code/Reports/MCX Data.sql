use harsh_data;

DROP table Mcx_Data;
--Table formation
create table Mcx_Data(
[CLIENT_ID] Varchar(50),
[COMPANY_CODE] varchar(50),
[SYMBOL] varchar(80),
[BUY_QUANTITY] int,
[BUY_AMOUNT] float,
[SALE_QUANTITY] int,
[SALE_AMOUNT] float,
[NET_QUANTITY] int,
[M2M] float,
TradeDate  VARCHAR(10));

Select * from Mcx_Data;

Select * from Data_24_25_MCX
order by CLIENT_ID,TradeDate asc;

--Data Replace
TRUNCATE TABLE Mcx_Data;
--Data Fetch
INSERT INTO Mcx_Data([CLIENT_ID],[COMPANY_CODE],[SYMBOL],[BUY_QUANTITY],[BUY_AMOUNT],[SALE_QUANTITY],[SALE_AMOUNT],[NET_QUANTITY],[M2M],[TradeDate])
SELECT [CLIENT_ID],[COMPANY_CODE],[SCRIP_SYMBOL],[BUY_QUANTITY],[BUY_AMOUNT],[SALE_QUANTITY],[SALE_AMOUNT],[NET_QUANTITY],[NOT_PROFIT],[TradeDate]
FROM Data_24_25_MCX;

Select * from Mcx_Data;

UPDATE Mcx_Data
SET TradeDate = CONVERT(VARCHAR, CAST(TradeDate AS DATE), 101);

