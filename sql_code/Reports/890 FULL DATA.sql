use harsh_data;

select * from [dbo].[Data2024_NSE];
select * from Data_NSE;


DROP table Data_NSE;

--Table formation
CREATE TABLE Data_NSE(
[CLIENT_ID] Varchar(50),
[COMPANY_CODE] varchar(50),
[SYMBOL] varchar(80),
[BUY_QUANTITY] float,
[BUY_AMOUNT] float,
[SALE_QUANTITY] float,
[SALE_AMOUNT] float,
[NET_QUANTITY] float,
[M2M] float,
TradeDate  VARCHAR(10)
);

--Data Replace
TRUNCATE TABLE Data_NSE;
--Data Fetch
INSERT INTO Data_NSE([CLIENT_ID], [COMPANY_CODE], [SYMBOL], [BUY_QUANTITY], [BUY_AMOUNT], [SALE_QUANTITY], [SALE_AMOUNT], [NET_QUANTITY], [M2M], [TradeDate])
SELECT 
[CLIENT_ID],
[COMPANY_CODE],
[SCRIP_SYMBOL],
TRY_CAST([BUY_QUANTITY] AS float),  
TRY_CAST([BUY_AMOUNT] AS FLOAT),   
TRY_CAST([SALE_QUANTITY] AS float), 
TRY_CAST([SALE_AMOUNT] AS FLOAT), 
TRY_CAST([NET_QUANTITY] AS float),   
TRY_CAST([NOT_PROFIT] AS FLOAT),   
[TradeDate]
FROM [dbo].[Data2024_NSE];

UPDATE Data_NSE
SET TradeDate = CONVERT(VARCHAR, CAST(TradeDate AS DATE), 103);


Select * from Data_NSE;


-- query for daily date range 
DECLARE @StartDate VARCHAR(10) = '01/04/2024';  
DECLARE @EndDate VARCHAR(10) = '31/12/2024';   

SELECT 
    current_day.CLIENT_ID,
    current_day.COMPANY_CODE,
    current_day.SYMBOL,
    current_day.BUY_QUANTITY - COALESCE(previous_day.BUY_QUANTITY, 0) AS BUY_QUANTITY,
    current_day.BUY_AMOUNT - COALESCE(previous_day.BUY_AMOUNT, 0) AS BUY_AMOUNT,
    current_day.SALE_QUANTITY - COALESCE(previous_day.SALE_QUANTITY, 0) AS SALE_QUANTITY,
    current_day.SALE_AMOUNT - COALESCE(previous_day.SALE_AMOUNT, 0) AS SALE_AMOUNT,
    current_day.NET_QUANTITY - COALESCE(previous_day.NET_QUANTITY, 0) AS NET_QUANTITY,
    current_day.M2M - COALESCE(previous_day.M2M, 0) AS M2M,
    current_day.TradeDate AS TradeDate
FROM 
    Data_NSE AS current_day
LEFT JOIN 
    Data_NSE AS previous_day
    ON current_day.CLIENT_ID = previous_day.CLIENT_ID  
    AND current_day.COMPANY_CODE = previous_day.COMPANY_CODE
    AND current_day.SYMBOL = previous_day.SYMBOL
    AND CONVERT(DATE, previous_day.TradeDate, 103) = CONVERT(DATE, @StartDate, 103)
WHERE 
    CONVERT(DATE, current_day.TradeDate, 103) = CONVERT(DATE, @EndDate, 103);
    --AND current_day.COMPANY_CODE = 'DERIVATIVES';  


--Query for single dates daily
DECLARE @InputDate DATE = CONVERT(DATE, '21/11/2024', 103); 

SELECT 
    current_day.CLIENT_ID,
    current_day.COMPANY_CODE,
    current_day.SYMBOL,
    current_day.BUY_QUANTITY - COALESCE(previous_day.BUY_QUANTITY, 0) AS BUY_QUANTITY,
    current_day.BUY_AMOUNT - COALESCE(previous_day.BUY_AMOUNT, 0) AS BUY_AMOUNT,
    current_day.SALE_QUANTITY - COALESCE(previous_day.SALE_QUANTITY, 0) AS SALE_QUANTITY,
    current_day.SALE_AMOUNT - COALESCE(previous_day.SALE_AMOUNT, 0) AS SALE_AMOUNT,
    current_day.NET_QUANTITY - COALESCE(previous_day.NET_QUANTITY, 0) AS NET_QUANTITY,
    current_day.M2M - COALESCE(previous_day.M2M, 0) AS M2M,
    current_day.TradeDate AS CURRENT_TRADE_DATE
FROM 
    Data_NSE AS current_day
LEFT JOIN 
    Data_NSE AS previous_day
    ON current_day.CLIENT_ID = previous_day.CLIENT_ID  
    AND current_day.COMPANY_CODE = previous_day.COMPANY_CODE
    AND current_day.SYMBOL = previous_day.SYMBOL
    AND TRY_CONVERT(DATE, previous_day.TradeDate, 103) = DATEADD(DAY, -1, @InputDate)
WHERE 
    TRY_CONVERT(DATE, current_day.TradeDate, 103) = @InputDate 
    AND current_day.COMPANY_CODE = 'DERIVATIVES';






  
