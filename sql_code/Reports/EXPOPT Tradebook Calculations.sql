use harsh_data;

--Fetch 28-March Open Position 
SELECT *
INTO EXP_Open_Position_28MAR
FROM Tradebook_2025
WHERE TradeDate = '2025-03-28'
AND ExpiryDate LIKE '2025-04%';

--Drop TradeTime column 
ALTER TABLE EXP_Open_Position_28MAR
DROP COLUMN TradeTime;

select * from EXP_Open_Position_28MAR;

--Fetch 1st April Trades
SELECT *
INTO EXP_Traded_01APR
FROM Tradebook_2025
WHERE TradeDate = '2025-04-01';

--Drop TradeTime column 
ALTER TABLE EXP_Traded_01APR
DROP COLUMN TradeTime;

select * from EXP_Traded_01APR;

--MERGE both Table EXP_Open_Position_28MAR & EXP_Traded_01APR
SELECT *
INTO TB_Merge_01Apr
FROM EXP_Open_Position_28MAR
UNION ALL
SELECT *
FROM EXP_Traded_01APR;

select * from TB_Merge_01Apr;

--Buy & Sell Calculations
Alter Table TB_Merge_01Apr
ADD BuyQuantity int,
	SellQuantity int,
	BuyAmount Float,
	SellAmount Float;

Update TB_Merge_01Apr
SET BuyQuantity = case
					When side = 'Buy' then Quantity
					else 0
				  End,
	SellQuantity = case
					When side = 'Sell' then Quantity
					else 0
				  End,
	BuyAmount = CASE 
                    WHEN Side = 'Buy' THEN Quantity * Price
                    ELSE 0
                END,
    SellAmount = CASE 
                     WHEN Side = 'Sell' THEN Quantity * Price 
                     ELSE 0
                 END;

Alter Table TB_Merge_01Apr
ADD BuyRate Float, SellRate Float;

UPDATE TB_Merge_01Apr
SET BuyRate = CASE 
                  WHEN Side = 'Buy' AND Quantity <> 0 THEN BuyAmount / Quantity
                  ELSE 0
              END,
    SellRate = CASE 
                   WHEN Side = 'Sell' AND Quantity <> 0 THEN SellAmount / Quantity
                   ELSE 0
               END;

select * from TB_Merge_01Apr;


--ADD NET calculations
ALTER Table TB_Merge_01Apr
ADD NetQuantity int, NetAmount Float, NetBR float, NetSR float;

Update TB_Merge_01Apr
set NetQuantity = BuyQuantity - SellQuantity;

Update TB_Merge_01Apr
set NetAmount = SellAmount - BuyAmount;

UPDATE TB_Merge_01Apr
SET NetBR = COALESCE((
    SELECT SUM(BuyAmount) / NULLIF(SUM(BuyQuantity), 0)
    FROM TB_Merge_01Apr AS T
    WHERE T.ManagerID = TB_Merge_01Apr.ManagerID
    AND T.Symbol = TB_Merge_01Apr.Symbol
    AND T.OptionType = TB_Merge_01Apr.OptionType
    AND T.StrikePrice = TB_Merge_01Apr.StrikePrice
    AND T.ExpiryDate = TB_Merge_01Apr.ExpiryDate
    AND T.TradeDate = TB_Merge_01Apr.TradeDate
    AND T.Side = 'Buy'
), 0)
WHERE Side = 'Buy';


UPDATE TB_Merge_01Apr
SET NetSR = COALESCE((
    SELECT SUM(SellAmount) / NULLIF(SUM(SellQuantity), 0)
    FROM TB_Merge_01Apr AS T
    WHERE T.ManagerID = TB_Merge_01Apr.ManagerID
    AND T.Symbol = TB_Merge_01Apr.Symbol
    AND T.OptionType = TB_Merge_01Apr.OptionType
    AND T.StrikePrice = TB_Merge_01Apr.StrikePrice
    AND T.ExpiryDate = TB_Merge_01Apr.ExpiryDate
    AND T.TradeDate = TB_Merge_01Apr.TradeDate
    AND T.Side = 'Sell'
), 0)
WHERE Side = 'Sell';

UPDATE TB_Merge_01Apr
SET NetBR = COALESCE(NetBR, 0),
    NetSR = COALESCE(NetSR, 0);

--To fetch bhavcopy into my table 
--Update Option Type = 'XX' & Strikeprice = '-0.01'
Update [dbo].[BHAVCOPY2025_03_28]
set OptnTp = 'XX', StrkPric = '-0.01'
where OptnTp = ''
and StrkPric = '';

Update TB_Merge_01Apr
set Symbol = 'BANKEX'
where Symbol = 'BKX';

ALTER TABLE TB_Merge_01Apr
ADD CLOSE_PRICE_ float, PREV_CLOSE_ float, SETTLE_PRICE_ float;

--1 APRIL
UPDATE eo
SET 
    eo.CLOSE_PRICE_ = b.ClsPric,
    eo.PREV_CLOSE_ = b.PrvsClsgPric,
    eo.SETTLE_PRICE_ = b.SttlmPric
FROM TB_Merge_01Apr eo
INNER JOIN [dbo].[BHAVCOPY2025_04_01] b  
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric
WHERE eo.CLOSE_PRICE_ IS NULL
AND eo.PREV_CLOSE_ IS NULL
AND eo.SETTLE_PRICE_ IS NULL
AND eo.TradeDate = '2025-04-01';

--28 March
UPDATE eo
SET 
    eo.CLOSE_PRICE_ = b.ClsPric,
    eo.PREV_CLOSE_ = b.PrvsClsgPric,
    eo.SETTLE_PRICE_ = b.SttlmPric
FROM TB_Merge_01Apr eo
INNER JOIN [dbo].[BHAVCOPY2025_03_28] b  
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric
WHERE eo.CLOSE_PRICE_ IS NULL
AND eo.PREV_CLOSE_ IS NULL
AND eo.SETTLE_PRICE_ IS NULL
AND eo.TradeDate = '2025-03-28';

Select * from TB_Merge_01Apr;

select 
	ManagerID,
	Symbol,
	ExpiryDate,
	OptionType,
	StrikePrice,
	TradeDate,
	BuyQuantity,
	SellQuantity,
	NetQuantity
INTO Demo_TB
from TB_Merge_01Apr;


SELECT * FROM Demo_TB;

Alter Table Demo_TB
ADD Token Varchar(80);

UPDATE Demo_TB
SET Token = CONCAT(
    ManagerID, ' ',
	Symbol, ' ',
	ExpiryDate, ' ',
    OptionType, ' ',
	StrikePrice
);

ALTER Table Demo_TB
--DROP COLUMN Open_Position;
add Open_Position int;


SELECT 
    rt.Token,
    rt.BuyQuantity,
    rt.SellQuantity,
    rt.TradeDate,
    CASE 
        WHEN rt.BuyQuantity > 0 THEN 
            ABS(SUM(rt.BuyQuantity - rt.SellQuantity) OVER (
                PARTITION BY rt.Token 
                ORDER BY rt.TradeDate 
                ROWS UNBOUNDED PRECEDING
            ))
        ELSE 
            SUM(rt.BuyQuantity - rt.SellQuantity) OVER (
                PARTITION BY rt.Token 
                ORDER BY rt.TradeDate 
                ROWS UNBOUNDED PRECEDING
            )
    END AS Open_Position_
--into TB
FROM Demo_TB rt
ORDER BY rt.Token, rt.TradeDate;

--Checking demo table update
UPDATE Demo_TB
SET Open_Position = (
    SELECT SUM(rt2.BuyQuantity) - SUM(rt2.SellQuantity)
    FROM TB rt2
    WHERE rt2.Token = Demo_TB.Token
    AND rt2.TradeDate <= Demo_TB.TradeDate
)
FROM Demo_TB
WHERE EXISTS (
    SELECT 1
    FROM TB rt2
    WHERE rt2.Token = Demo_TB.Token
    AND rt2.TradeDate = Demo_TB.TradeDate
);

--Updating Main Table
Alter table TB_Merge_01Apr
add Open_Position int;

UPDATE TB_Merge_01Apr
SET Open_Position = d.Open_Position
FROM Demo_TB d
WHERE TB_Merge_01Apr.ManagerID = d.ManagerID
  AND TB_Merge_01Apr.TradeDate = d.TradeDate
  AND TB_Merge_01Apr.ExpiryDate = d.ExpiryDate
  AND TB_Merge_01Apr.Symbol = d.Symbol
  AND TB_Merge_01Apr.OptionType = d.OptionType
  AND TB_Merge_01Apr.StrikePrice = d.StrikePrice;

Select * from TB_Merge_01Apr;

--Tradedate = ExpiryDate
UPDATE TB_Merge_01Apr
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

Select * from TB_Merge_01Apr;

--Closeamount calculations
Alter table TB_Merge_01Apr
add Closeamount float;

UPDATE TB_Merge_01Apr
SET CloseAmount =ABS( CLOSE_PRICE_ * NetQuantity);

--Calculations for NEW BA & SA
Alter table TB_Merge_01Apr
add New_BA float,
	New_SA float,
	Carry_Position_BA FLOAT,
	Carry_Position_SA FLOAT;

-- Update New_SA and New_BA
UPDATE TB_Merge_01Apr
SET 
    New_SA = CASE 
                WHEN TradeDate = '2025-03-28' AND Open_Position != 0 THEN 0
				WHEN TradeDate = '2025-03-28' AND Open_Position = 0 THEN 0
                WHEN TradeDate = '2025-04-01' AND NetQuantity > 0 THEN CloseAmount + [SellAmount]
                WHEN TradeDate = '2025-04-01' AND NetQuantity < 0 THEN [SellAmount]
                WHEN TradeDate NOT IN ('2025-03-28', '2025-04-01') AND NetQuantity > 0 THEN CloseAmount + [SellAmount]
                WHEN TradeDate NOT IN ('2025-03-28', '2025-04-01') AND NetQuantity < 0 THEN [SellAmount]
                ELSE New_SA  
             END,
    New_BA = CASE 
                WHEN TradeDate = '2025-03-28' AND Open_Position != 0 THEN 0
				WHEN TradeDate = '2025-03-28' AND Open_Position = 0 THEN 0
                WHEN TradeDate = '2025-04-01' AND NetQuantity < 0 THEN CloseAmount + [BuyAmount]
                WHEN TradeDate = '2025-04-01' AND NetQuantity > 0 THEN [BuyAmount]
                WHEN TradeDate NOT IN ('2025-03-28', '2025-04-01') AND NetQuantity < 0 THEN CloseAmount + [BuyAmount]
                WHEN TradeDate NOT IN ('2025-03-28', '2025-04-01') AND NetQuantity > 0 THEN [BuyAmount]
                ELSE New_BA  
             END;

-- Carry calculations for 28 March (only when Open_Position ≠ 0)
UPDATE TB_Merge_01Apr
SET Carry_Position_BA = 
    CASE 
        WHEN Open_Position = 0 THEN 0
        WHEN Open_Position < 0 THEN ABS(Open_Position * CLOSE_PRICE_)
        WHEN Open_Position > 0 THEN ABS(Open_Position * PREV_CLOSE_)
    END,
    Carry_Position_SA = 
    CASE 
        WHEN Open_Position = 0 THEN 0
        WHEN Open_Position < 0 THEN ABS(Open_Position * PREV_CLOSE_)
        WHEN Open_Position > 0 THEN ABS(Open_Position * CLOSE_PRICE_)
    END
WHERE TradeDate = '2025-03-28';

-- Carry calculations for 1 April (set both to 0 if Open_Position ≠ 0)
UPDATE TB_Merge_01Apr
SET Carry_Position_BA = 0,
    Carry_Position_SA = 0
WHERE --TradeDate = '2025-04-01' AND Open_Position != 0
 TradeDate = '2025-04-01' AND Open_Position = 0;



Select * from TB_Merge_01Apr;


--Calculations for Final BA & SA
Alter table TB_Merge_01Apr
add Final_BA float,
	Final_SA float,
	M2M FLOAT;

UPDATE TB_Merge_01Apr
SET Final_BA =Carry_Position_BA + New_BA;

UPDATE TB_Merge_01Apr
SET Final_SA = Carry_Position_SA + New_SA;

--Final M2M
UPDATE TB_Merge_01Apr
SET M2M = Final_SA - Final_BA;


Select * from TB_Merge_01Apr;