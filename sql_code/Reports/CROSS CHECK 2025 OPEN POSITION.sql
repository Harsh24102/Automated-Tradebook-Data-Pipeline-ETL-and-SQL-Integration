use harsh_data;

select * from Tradebook_2025
where TradeDate like '2025-04%';

SELECT * FROM Tradebook_2025
WHERE --ExpiryDate LIKE '2025-04%' AND 
TradeDate NOT LIKE '2025-03%';

SELECT * 
--INTO EXP_OPEN_03_28
FROM Tradebook_2025
WHERE ExpiryDate LIKE '2025-04%' 
AND TradeDate NOT LIKE '2025-04%';

select * from EXP_OPEN_28;

Select * from [dbo].[EXP_OPEN_01_04]
order by ManagerID;

alter table [EXP_OPEN_01_04]
add [CLOSE_PRICE_] float;

select * from EXP_OPEN_COMBINED
order by ManagerID;


SELECT * INTO [EXP_OPEN_COMBINED]
FROM (
    SELECT * FROM [EXP_OPEN_01_04]
    UNION ALL
    SELECT * FROM [EXP_OPEN_28]
) AS CombinedData;

select * from EXP_OPEN_COMBINED;

Update [EXP_OPEN_COMBINED]
set OptionType = '', StrikePrice = ''
where OptionType = 'XX'
and StrikePrice = '-0.01';

UPDATE eo
SET eo.CLOSE_PRICE_ = b.ClsPric
FROM [EXP_OPEN_COMBINED] eo
INNER JOIN [BHAVCOPY2025_04_01] b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric
	and CLOSE_PRICE_ IS NULL;

UPDATE [EXP_OPEN_COMBINED]
SET CLOSE_PRICE_ = CASE 
    WHEN SecurityType = 'OPTIDX' AND TradeDate = ExpiryDate THEN
        CASE 
            WHEN OptionType = 'CE' AND TRY_CAST(StrikePrice AS FLOAT) < TRY_CAST(CLOSE_PRICE_ AS FLOAT) THEN TRY_CAST(CLOSE_PRICE_ AS FLOAT) - TRY_CAST(CLOSE_PRICE_ AS FLOAT)
            WHEN OptionType = 'CE' AND TRY_CAST(StrikePrice AS FLOAT) >= TRY_CAST(CLOSE_PRICE_ AS FLOAT) THEN 0
            WHEN OptionType = 'PE' AND TRY_CAST(StrikePrice AS FLOAT) > TRY_CAST(CLOSE_PRICE_ AS FLOAT) THEN TRY_CAST(CLOSE_PRICE_ AS FLOAT) - TRY_CAST(CLOSE_PRICE_ AS FLOAT)
            WHEN OptionType = 'PE' AND TRY_CAST(StrikePrice AS FLOAT) <= TRY_CAST(CLOSE_PRICE_ AS FLOAT) THEN 0
            ELSE 0  
        END
    ELSE CLOSE_PRICE_  
END
WHERE SecurityType = 'OPTIDX' AND TradeDate = ExpiryDate;

select * from EXP_OPEN_COMBINED;

--Added column for M2M Calculations
Alter Table EXP_OPEN_COMBINED
ADD [CLOSE_PRICE_] float;

UPDATE eo
SET eo.[CLOSE_PRICE_] = b.ClsPric
FROM [EXP_OPEN_COMBINED] eo
INNER JOIN [dbo].[BHAVCOPY2025_03_28] b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric
	and CLOSE_PRICE_ IS NULL
	and TradeDate LIKE '2025-03%';


Alter Table EXP_OPEN_COMBINED
ADD Close_Amount float,
	New_BA float,
	New_SA float,
	NP_BA float,
	NP_SA float,
	M2M float;

Alter Table EXP_OPEN_COMBINED
drop column CLOSE_PRICE_, Pre_Close_Price;--Close_Amount, New_BA, New_SA, NP_BA, NP_SA, M2M;

update EXP_OPEN_COMBINED
set Close_Amount = NetQuantity * CLOSE_PRICE_;
	
--Updated New BuyAmount and SellAmount 
UPDATE EXP_OPEN_COMBINED
SET 
    New_BA = 
        CASE 
            WHEN (NetQuantity < 0) AND (Side IN ('buy', 'sell')) THEN Close_Amount + BuyAmount
            ELSE BuyAmount
        END,
    New_SA = 
        CASE 
            WHEN (NetQuantity > 0) AND (Side IN ('buy', 'sell')) THEN Close_Amount + SellAmount
            ELSE SellAmount
        END
WHERE TradeDate LIKE '2025-04%';


--Updated NetPosition Buy and Sell
UPDATE EXP_OPEN_COMBINED
SET 
    NP_BA = CASE 
                WHEN Side = 'Buy' THEN NetQuantity * CLOSE_PRICE_
                ELSE 0 
             END,
    NP_SA = CASE 
                WHEN Side = 'Sell' THEN NetQuantity * CLOSE_PRICE_
                ELSE 0 
             END
WHERE TradeDate LIKE '2025-03%';

UPDATE EXP_OPEN_COMBINED
SET 
    NP_BA = COALESCE(NP_BA, 0), 
    NP_SA = COALESCE(NP_SA, 0), 
    New_BA = COALESCE(New_BA, 0), 
    New_SA = COALESCE(New_SA, 0)
WHERE 
    NP_BA IS NULL 
    OR NP_SA IS NULL 
    OR New_BA IS NULL 
    OR New_SA IS NULL;


--Add column Final and M2M
Alter Table EXP_OPEN_COMBINED
add Final_BA float,
Final_SA float,
M2M float;

--Final BuyAmount and SellAmount
Update EXP_OPEN_COMBINED
SET Final_BA = New_BA + NP_BA,
	Final_SA = New_SA + NP_SA;

--M2M Calculation
Update EXP_OPEN_COMBINED
SET M2M = Final_SA - Final_BA;

SELECT 
ManagerID,
Symbol,
Exchange,
StrategyID,
SecurityType,
ExpiryDate,
TradeDate,
OptionType,
StrikePrice,
Price,
SUM(BuyQuantity) AS BuyQuantity,
        SUM(BuyAmount) AS BuyAmount,
        SUM(SellQuantity) AS SellQuantity,
        SUM(SellAmount) AS SellAmount,
        SUM(BuyQuantity - SellQuantity) AS NetQuantity,
        SUM(SellAmount) - SUM(BuyAmount) AS NetAmount,
        CASE
            WHEN SUM(BuyQuantity) > 0 THEN SUM(BuyAmount) / NULLIF(SUM(BuyQuantity), 0)
            ELSE 0
        END AS BuyRate,
        CASE
            WHEN SUM(SellQuantity) > 0 THEN SUM(SellAmount) / NULLIF(SUM(SellQuantity), 0)
            ELSE 0
        END AS SellRate,
CLOSE_PRICE_
into Cumulative_EXP_
from EXP_OPEN_COMBINED
GROUP BY ManagerID,Symbol,Exchange,StrategyID,SecurityType,ExpiryDate,TradeDate,OptionType,StrikePrice,Price,CLOSE_PRICE_



