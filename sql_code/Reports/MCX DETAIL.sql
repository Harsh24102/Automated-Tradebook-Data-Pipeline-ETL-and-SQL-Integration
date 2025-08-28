use harsh_data;

Select * from Mcx_Data;

-- query for daily date range 
--DECLARE @StartDate VARCHAR(10) = '01/07/2024';  
--DECLARE @EndDate VARCHAR(10) = '02/07/2024';   

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
    Mcx_Data AS current_day
LEFT JOIN 
    Mcx_Data AS previous_day
    ON current_day.CLIENT_ID = previous_day.CLIENT_ID  
    AND current_day.COMPANY_CODE = previous_day.COMPANY_CODE
    AND current_day.SYMBOL = previous_day.SYMBOL
    AND CONVERT(DATE, previous_day.TradeDate, 103) = CONVERT(DATE, @StartDate, 103)
WHERE 
    CONVERT(DATE, current_day.TradeDate, 103) = CONVERT(DATE, @EndDate, 103);
	--AND current_day.COMPANY_CODE = 'COMMODITY'
    --AND current_day.COMPANY_CODE = 'EXPENSES';  


--Query for single dates daily
--DECLARE @InputDate DATE = CONVERT(DATE, '02/07/2024', 103); 

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
    Mcx_Data AS current_day
LEFT JOIN 
    Mcx_Data AS previous_day
    ON current_day.CLIENT_ID = previous_day.CLIENT_ID  
    AND current_day.COMPANY_CODE = previous_day.COMPANY_CODE
    AND current_day.SYMBOL = previous_day.SYMBOL
    AND TRY_CONVERT(DATE, previous_day.TradeDate, 103) = DATEADD(DAY, -1, @InputDate)
WHERE 
    TRY_CONVERT(DATE, current_day.TradeDate, 103) = @InputDate; 
    --AND current_day.COMPANY_CODE = 'COMMODITY';




--DECLARE @InputDate VARCHAR(10) = '02/07/2024';  -- Input date in dd/mm/yyyy format

-- Convert input date string to DATE type
DECLARE @ConvertedDate DATE = CONVERT(DATE, @InputDate, 103);  -- 103 style corresponds to dd/mm/yyyy

SELECT 
    current_day.CLIENT_ID,
    current_day.COMPANY_CODE,
    current_day.SYMBOL,
    current_day.BUY_QUANTITY,
    current_day.BUY_AMOUNT,
    current_day.SALE_QUANTITY,
    current_day.SALE_AMOUNT,
    current_day.NET_QUANTITY,
    current_day.M2M AS M2M_Today,  -- M2M for 2nd July
    previous_day.M2M AS M2M_Previous,  -- M2M for 1st July
    (current_day.M2M - COALESCE(previous_day.M2M, 0)) AS M2M_Difference, 
    current_day.TradeDate AS CURRENT_TRADE_DATE
FROM 
    Mcx_Data AS current_day
LEFT JOIN 
    Mcx_Data AS previous_day
    ON current_day.CLIENT_ID = previous_day.CLIENT_ID  
    AND current_day.COMPANY_CODE = previous_day.COMPANY_CODE
    AND current_day.SYMBOL = previous_day.SYMBOL
    AND CAST(TRY_CONVERT(DATETIME, previous_day.TradeDate, 103) AS DATE) = DATEADD(DAY, -1, @ConvertedDate)
WHERE 
    CAST(TRY_CONVERT(DATETIME, current_day.TradeDate, 103) AS DATE) = @ConvertedDate
	AND current_day.COMPANY_CODE = 'COMMODITY';


DECLARE @InputDate VARCHAR(10) = '02/07/2024';  -- Input date in dd/mm/yyyy format

-- Convert input date string to DATE type
DECLARE @ConvertedDate DATE = CONVERT(DATE, @InputDate, 103);  -- 103 style corresponds to dd/mm/yyyy

SELECT 
    current_day.CLIENT_ID,
    current_day.COMPANY_CODE,
    current_day.SYMBOL,
    current_day.BUY_QUANTITY,
    previous_day.BUY_QUANTITY,
    current_day.SALE_QUANTITY,
    previous_day.SALE_QUANTITY,
    current_day.NET_QUANTITY AS NET_QUANTITY_TODAY,  -- NET_QUANTITY for 2nd July
    (current_day.BUY_QUANTITY - current_day.SALE_QUANTITY) AS NET_QUANTITY,  
    previous_day.NET_QUANTITY AS NET_QUANTITY_PREVIOUS,  -- NET_QUANTITY for 1st July
    (previous_day.BUY_QUANTITY - previous_day.SALE_QUANTITY) AS NET_QUANTITY,  
    current_day.M2M AS M2M_TODAY,  -- M2M for 2nd July
    ISNULL(previous_day.M2M, 0) AS M2M_PREVIOUS,  
    (current_day.M2M - ISNULL(previous_day.M2M, 0)) AS M2M_Difference,  
    current_day.TradeDate AS CURRENT_TRADE_DATE
FROM 
    Mcx_Data AS current_day
LEFT JOIN 
    Mcx_Data AS previous_day
    ON current_day.CLIENT_ID = previous_day.CLIENT_ID  
    AND current_day.COMPANY_CODE = previous_day.COMPANY_CODE
    AND current_day.SYMBOL = previous_day.SYMBOL
    AND CAST(TRY_CONVERT(DATETIME, previous_day.TradeDate, 103) AS DATE) = DATEADD(DAY, -1, @ConvertedDate)
WHERE 
    CAST(TRY_CONVERT(DATETIME, current_day.TradeDate, 103) AS DATE) = @ConvertedDate;
