USE harsh_data;

Select * from New_Tradebook_Apr
order by ManagerID, Symbol, ExchangeTradeTime;

ALTER TABLE New_Tradebook_Apr
ADD Day VARCHAR(20);  

UPDATE New_Tradebook_Apr
SET Day = DATENAME(WEEKDAY, ExchangeTradeTime);

--Added CloseAmount 
Alter Table New_Tradebook_Apr
--drop column CloseAmount;
add CloseAmount float;

--drop column For BA & SA
Alter Table New_Tradebook_Apr
Drop column New_BA ,
New_SA ,
NP_BA ,
NP_SA ;

--Added column For BA & SA
Alter Table New_Tradebook_Apr
ADD New_BA float,
New_SA float,
NP_BA float,
NP_SA float;

--Query for updating Holding trades occur on holiday ClosePrice and PreviousClose
SET DATEFIRST 7;
DECLARE @HolidayDates TABLE (HolidayDate DATE);
INSERT INTO @HolidayDates (HolidayDate)
VALUES ('2024-04-02'),  
       ('2024-04-09'),
       ('2024-04-11'),
       ('2024-04-16'),  
       ('2024-04-17'),
       ('2024-04-23'),
       ('2024-05-01');

UPDATE t1
SET 
    t1.ClosePrice = t2.ClosePrice,  
    t1.Prev_Close_Price = t2.Prev_Close_Price  
FROM New_Tradebook_Apr t1
INNER JOIN New_Tradebook_Apr t2
    ON t1.ManagerID = t2.ManagerID
    AND t1.Symbol = t2.Symbol
    AND t1.Side = 'Holding'
    AND t1.ExchangeTradeTime IN (SELECT HolidayDate FROM @HolidayDates) 
    AND (
        (t1.ExchangeTradeTime = '2024-04-02' AND t2.ExchangeTradeTime = '2024-04-01')
        OR (t1.ExchangeTradeTime = '2024-04-09' AND t2.ExchangeTradeTime = '2024-04-08')
        OR (t1.ExchangeTradeTime = '2024-04-11' AND t2.ExchangeTradeTime = '2024-04-10')
        OR (t1.ExchangeTradeTime = '2024-04-16' AND t2.ExchangeTradeTime = '2024-04-15')
        OR (t1.ExchangeTradeTime = '2024-04-17' AND t2.ExchangeTradeTime = '2024-04-16')
        OR (t1.ExchangeTradeTime = '2024-04-23' AND t2.ExchangeTradeTime = '2024-04-22')
        OR (t1.ExchangeTradeTime = '2024-05-01' AND t2.ExchangeTradeTime = '2024-04-30')
    )
WHERE t1.ClosePrice IS NULL
  AND t1.Prev_Close_Price IS NULL;

Update New_Tradebook_Apr
set SettlementPrice = 0
where SettlementPrice IS NULL;

--Query for updating Saturday's ClosePrice to Friday's ClosePrice
UPDATE t1
SET 
    t1.ClosePrice = t2.ClosePrice,  
    t1.Prev_Close_Price = t2.Prev_Close_Price  
FROM New_Tradebook_Apr t1
INNER JOIN New_Tradebook_Apr t2
    ON t1.ManagerID = t2.ManagerID  
    AND DATEPART(WEEKDAY, t1.ExchangeTradeTime) = 7  -- Saturday (assuming 7 = Saturday)
    AND DATEPART(WEEKDAY, t2.ExchangeTradeTime) = 6  -- Friday (assuming 6 = Friday)
	AND t1.Symbol = t2.Symbol
	And t1.Side = 'Holding'
WHERE t1.ExchangeTradeTime = DATEADD(day, 1, t2.ExchangeTradeTime); 


--Query for getting closeamount for Saturday's trade
UPDATE New_Tradebook_Apr
SET CloseAmount = 
    CASE 
        WHEN Side = 'Holding' THEN ABS(RemainingQuantity * Prev_Close_Price)
        ELSE CloseAmount  
    END
where Day = 'Saturday'
and Side = 'Holding';

--Query for Matching the Friday and Saturday trades
UPDATE t1
SET t1.CloseAmount = ABS(t1.RemainingQuantity * t1.Prev_Close_Price)
FROM New_Tradebook_Apr t1
INNER JOIN New_Tradebook_Apr t2
    ON t1.ManagerID = t2.ManagerID  
    AND DATEPART(WEEKDAY, t1.ExchangeTradeTime) = 6  
    AND DATEPART(WEEKDAY, t2.ExchangeTradeTime) = 7  
    AND t2.Side = 'holding';  

--Query for Matching Monday and Saturday trades
UPDATE t1
SET t1.CloseAmount = ABS(t1.RemainingQuantity * t1.Prev_Close_Price)
FROM New_Tradebook_Apr t1
INNER JOIN New_Tradebook_Apr t2
    ON t1.ManagerID = t2.ManagerID  
    AND DATEPART(WEEKDAY, t1.ExchangeTradeTime) = 2  
    AND DATEPART(WEEKDAY, t2.ExchangeTradeTime) = 7  
    AND t2.Side = 'holding'  
	AND t1.Symbol = t2.Symbol
WHERE t1.ExchangeTradeTime = DATEADD(day, 2, t2.ExchangeTradeTime)
AND DATEPART(WEEKDAY, t1.ExchangeTradeTime) = 2;  

--Query for Updating Closeamount for Holding trades from Monday to Friday
UPDATE t1
SET t1.CloseAmount = ABS(t1.RemainingQuantity * t1.Prev_Close_Price)
FROM New_Tradebook_Apr t1
INNER JOIN New_Tradebook_Apr t2
    ON t1.Symbol = t2.Symbol  
	AND t1.ManagerID = t2.ManagerID
    AND t1.Side IN ('Buy', 'Sell')  
    AND t2.Side = 'Holding'  
    AND CAST(t1.ExchangeTradeTime AS DATE) = DATEADD(DAY, 1, CAST(t2.ExchangeTradeTime AS DATE))  
WHERE DATENAME(WEEKDAY, t1.ExchangeTradeTime) NOT IN ('Saturday', 'Sunday')  
    AND DATENAME(WEEKDAY, t2.ExchangeTradeTime) NOT IN ('Saturday', 'Sunday')  
    AND t1.CloseAmount = ABS(t1.RemainingQuantity * t1.ClosePrice)  
    AND t1.ClosePrice IS NOT NULL  
    AND t1.RemainingQuantity != 0;  

--For CloseAmount
--Actual Trade
UPDATE New_Tradebook_Apr
SET CloseAmount = 
    CASE 
        WHEN Side IN ('Buy', 'Sell') THEN ABS(RemainingQuantity * ClosePrice)
        ELSE CloseAmount  
    END
where CloseAmount IS NULL;
--Holding Trades
UPDATE New_Tradebook_Apr
SET CloseAmount = 
    CASE 
        WHEN Side = 'Holding' THEN ABS(RemainingQuantity * ClosePrice)
        ELSE CloseAmount  
    END
where CloseAmount IS NULL;

--Updated New BuyAmount and SellAmount 
UPDATE New_Tradebook_Apr
SET 
    New_BA = 
        CASE 
            WHEN (NetQuantity < 0) AND (Side IN ('buy', 'sell')) THEN CloseAmount + BuyAmount
            ELSE BuyAmount
        END,
    New_SA = 
        CASE 
            WHEN (NetQuantity > 0) AND (Side IN ('buy', 'sell')) THEN CloseAmount + SellAmount
            ELSE SellAmount
        END;

--Updated NetPosition Buy and Sell
UPDATE New_Tradebook_Apr
SET 
    NP_BA = CASE 
                WHEN Side = 'holding' THEN RemainingQuantity * Prev_Close_Price 
                ELSE NP_BA -- Keep existing value if not 'holding'
             END,
    NP_SA = CASE 
                WHEN Side = 'holding' THEN RemainingQuantity * ClosePrice
                ELSE NP_SA -- Keep existing value if not 'holding'
             END;

UPDATE New_Tradebook_Apr
SET NP_BA = 0, NP_SA = 0 
WHERE Side = 'buy' OR Side = 'Sell'
and NP_BA is null
and NP_SA is null;

--Drop column Final and M2M
Alter Table New_Tradebook_Apr
drop column Final_BA ,
Final_SA ,
M2M ;

--Add column Final and M2M
Alter Table New_Tradebook_Apr
add Final_BA float,
Final_SA float,
M2M float;

--Final BuyAmount and SellAmount
Update New_Tradebook_Apr
SET Final_BA = New_BA + NP_BA,
	Final_SA = New_SA + NP_SA;

--M2M Calculation
Update New_Tradebook_Apr
SET M2M = Final_SA - Final_BA;












