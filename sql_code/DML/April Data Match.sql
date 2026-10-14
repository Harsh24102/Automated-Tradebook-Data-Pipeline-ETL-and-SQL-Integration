Use harsh_data;

---Cumulative Tradebook DATA STORED IN Cumulative_April TABLE
WITH CalculatedData AS (
    SELECT
        Token,
		ExchangeTradeTime,
        Side,
        Quantity,
        Price,
		BuyAmount,  
		BuyQuantity,
		SellAmount,
		SellQuantity,
		NetAmount ,
		NetQuantity ,
		BuyRate,
		SellRate
	FROM Tradebook_Apr b
)
SELECT
    Token,
	ExchangeTradeTime,
    SUM(BuyQuantity) AS BuyQuantity,
    SUM(BuyAmount) AS BuyAmount,
    SUM(SellQuantity) AS SellQuantity,
    SUM(SellAmount) AS SellAmount,
    SUM(BuyQuantity -SellQuantity) AS NetQuantity,
    SUM(SellAmount) - SUM(BuyAmount) AS NetAmount
--INTO Cumulative_April 
FROM CalculatedData
GROUP BY Token,ExchangeTradeTime;

select * from Cumulative_April;


---cumulative DATA from 227 STORE IN TABLE 227
WITH CalculatedData AS (
    SELECT
        Token,
        [TRADE_DATE1 ],
        CAST([BUY_AMOUNT ] AS float) AS [BUY_AMOUNT],
        CAST([BUY_QUANTITY ] AS int) AS [BUY_QUANTITY],
        CAST([SALE_AMOUNT ] AS float) AS [SALE_AMOUNT],
        CAST([SALE_QUANTITY ] AS int) AS [SALE_QUANTITY],
        CAST([NET_AMOUNT ] AS float) AS [NET_AMOUNT],
        CAST([NET_QUANTITY ] AS int) AS [NET_QUANTITY]
    FROM Data_227
)
SELECT
    Token,
    [TRADE_DATE1 ],
    SUM([BUY_QUANTITY]) AS BuyQuantity_227,
    SUM([BUY_AMOUNT]) AS BuyAmount_227,
    SUM([SALE_QUANTITY]) AS SellQuantity_227,
    SUM([SALE_AMOUNT]) AS SellAmount_227,
    SUM([BUY_QUANTITY] - [SALE_QUANTITY]) AS NetQuantity_227,
    SUM([SALE_AMOUNT]) - SUM([BUY_AMOUNT]) AS NetAmount_227
--INTO Table_227 
FROM CalculatedData
GROUP BY Token, [TRADE_DATE1 ];

select * from Table_227;


--Join Query for Matching Data 
SELECT 
		d.Token,
		d.[TRADE_DATE1 ],
		d.[BUY_QUANTITY ],
		a.BuyQuantity,
		d.[SALE_QUANTITY ],
		a.SellQuantity,
		d.[BUY_AMOUNT ],
		a.BuyAmount,
		d.[SALE_AMOUNT ],
		a.SellAmount
From Data_227 d
LEFT JOIN Cumulative_April a
	on CAST(d.[TRADE_DATE1 ] AS Date) = CAST(a.ExchangeTradeTime AS DATE)
	AND d.Token = a.Token
ORDER BY
	d.Token,
	d.[TRADE_DATE1 ];


---Query for Unmatch rows from matching data

SELECT 
		d.Token,
		d.[TRADE_DATE1 ],
		d.[BuyQuantity_227],
		a.BuyQuantity,
		d.[SellQuantity_227],
		a.SellQuantity,
		(d.[BuyQuantity_227] - a.BuyQuantity) AS BuyQDifference,
		(d.[SellQuantity_227] - a.SellQuantity) AS SellQDifference,
		d.[BuyAmount_227],
		a.BuyAmount,
		d.[SellAmount_227],
		a.SellAmount,
		(d.[BuyAmount_227] - a.BuyAmount) AS BuyADifference,
		(d.[SellAmount_227]  - a.SellAmount) AS SellADifference
From Table_227 d
LEFT JOIN Cumulative_April a
on CAST(d.[TRADE_DATE1 ] AS Date) = CAST(a.ExchangeTradeTime AS DATE)
	AND d.Token = a.Token
ORDER BY
	d.Token,
	d.[TRADE_DATE1 ];


----USING CTE TO FIND Misiing Trades and store in Apr_Match Table
WITH JoinedData AS (
    SELECT 
        d.Token,
        d.[TRADE_DATE1 ],
        d.[BuyQuantity_227],
        COALESCE(a.BuyQuantity, 0) AS BuyQuantity,
        d.[SellQuantity_227],
        COALESCE(a.SellQuantity, 0) AS SellQuantity,
        d.[BuyAmount_227],
        COALESCE(a.BuyAmount, 0) AS BuyAmount,
        d.[SellAmount_227],
        COALESCE(a.SellAmount, 0) AS SellAmount
    FROM Table_227 d
    LEFT JOIN Cumulative_April a
        ON CAST(d.[TRADE_DATE1 ] AS DATE) = CAST(a.ExchangeTradeTime AS DATE)
        AND d.Token = a.Token
),
Quantity_Difference AS (
    SELECT 
        Token,
        [TRADE_DATE1 ],
        BuyQuantity_227,
        BuyQuantity,
        SellQuantity_227,
        SellQuantity,
        (BuyQuantity_227 - BuyQuantity) AS BuyQDifference,
        (SellQuantity_227 - SellQuantity) AS SellQDifference,
        BuyAmount_227,
        BuyAmount,
        SellAmount_227,
        SellAmount,
        ROUND([BuyAmount_227] - BuyAmount, 2) AS BuyADifference,
        ROUND([SellAmount_227] - SellAmount, 2) AS SellADifference,
        ROUND(COALESCE(NULLIF(([BuyAmount_227] - BuyAmount) / NULLIF(([BuyQuantity_227] - BuyQuantity), 0), 0), 0), 2) AS BuyRate,
        ROUND(COALESCE(NULLIF(([SellAmount_227] - SellAmount) / NULLIF(([SellQuantity_227] - SellQuantity), 0), 0), 0), 2) AS SellRate
    FROM JoinedData
)
SELECT *
--INTO Apr_Match
FROM Quantity_Difference
WHERE (BuyQDifference <> 0 OR SellQDifference <> 0)
ORDER BY 
    [TRADE_DATE1],
	Token;

select * from Apr_Match;






