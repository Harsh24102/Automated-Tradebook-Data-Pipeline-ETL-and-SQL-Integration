USE harsh_data;

Select * from  Tradebook_2025_EXP;

--Drop Table EXP_Open_Position_Apr_08_RS;

--To Fetch Previous Data 
select * 
into [EXP_April_7_RS] from Janvi.[dbo].[EXP_April_7_RS];

select * 
into BHAVCOPY2025_05_05 from Janvi.[dbo].[BHAVCOPY2025_05_05];

select * 
into BHAVCOPY2025_04_30 from Janvi.[dbo].[BHAVCOPY2025_04_30];


select 
ManagerID,
Reference_Text,
Exchange,
StrategyID,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice,
BuyQuantity,
SellQuantity,
BuyAmount,
SellAmount,
NetQuantity,
TradeDate
into EXP_Open_Position_Apr_08_RS
from  [EXP_April_7_RS]
where TradeDate like '2025-04-07'
     and ExpiryDate not like '2025-04-07'    ----Previous Date
      and NetQuantity<>0;


--Current Date data
SELECT *
INTO Tradebook_EXP_MAY_05_RS
FROM Tradebook_2025_EXP
WHERE TradeDate LIKE '2025-05-05'; 

----------------------------------------------------
---------------------OP-----------------------------
----------------------------------------------------

Select * from EXP_Open_Position_Apr_08_RS;

--To set Current Date
UPDATE EXP_Open_Position_Apr_08_RS
set TradeDate='2025-04-08';

--Now Update Bhavcopy
select * from EXP_Open_Position_MAY_05_RS;
select * from [dbo].[BHAVCOPY2025_04_07];
select * from [dbo].[BHAVCOPY2025_04_08];

Alter table EXP_Open_Position_Apr_08_RS
add Settle_PRICE_ FLOAT,
   Prev_Settle_PRICE_ FLOAT;

UPDATE eo
SET eo.Prev_Settle_PRICE_ = b.SttlmPric
FROM EXP_Open_Position_Apr_08_RS eo
INNER JOIN [BHAVCOPY2025_04_07] b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND COALESCE(eo.OptionType, 'XX') = COALESCE(NULLIF(b.OptnTp, ''), 'XX')
    AND COALESCE(eo.StrikePrice, -0.01) = COALESCE(TRY_CAST(NULLIF(b.StrkPric, '') AS FLOAT), -0.01);

UPDATE eo
SET eo.Settle_PRICE_ = b.SttlmPric
FROM EXP_Open_Position_Apr_08_RS eo
INNER JOIN [BHAVCOPY2025_04_08] b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND COALESCE(eo.OptionType, 'XX') = COALESCE(NULLIF(b.OptnTp, ''), 'XX')
    AND COALESCE(eo.StrikePrice, -0.01) = COALESCE(TRY_CAST(NULLIF(b.StrkPric, '') AS FLOAT), -0.01)

----------------------------------------------------
---------------------Settlement OP------------------
----------------------------------------------------

--To Update Settlement 	
Alter table EXP_Open_Position_Apr_08_RS
add Settle_minus_Strike FLOAT;

UPDATE EXP_Open_Position_Apr_08_RS
SET Settle_minus_Strike= Settle_PRICE_-StrikePrice;

UPDATE EXP_Open_Position_Apr_08_RS
SET Settle_PRICE_ = CASE
    WHEN Settle_minus_Strike > 0 THEN 
        CASE 
            WHEN OptionType = 'CE' THEN ABS(Settle_minus_Strike)
            WHEN OptionType = 'PE' THEN 0
        END
    WHEN Settle_minus_Strike < 0 THEN 
        CASE 
            WHEN OptionType = 'CE' THEN 0
            WHEN OptionType = 'PE' THEN ABS(Settle_minus_Strike)
        END
    ELSE Settle_PRICE_  -- No update if conditions aren't met
END
WHERE netQuantity <> 0
  AND ExpiryDate = TradeDate
  AND (Settle_minus_Strike > 0 OR Settle_minus_Strike < 0);

--Now We add calculations
ALTER TABLE EXP_Open_Position_Apr_08_RS
ADD 
    Carry_Position_BA FLOAT,
    Carry_Position_SA FLOAT,
    Final_BA FLOAT,
    Final_SA FLOAT,
    M2M FLOAT;

UPDATE EXP_Open_Position_Apr_08_RS
SET Carry_Position_BA = 
    CASE 
        WHEN NetQuantity < 0 THEN ABS(NetQuantity * Settle_PRICE_)
        WHEN NetQuantity > 0 THEN ABS(NetQuantity * Prev_Settle_PRICE_)
    END;

UPDATE EXP_Open_Position_Apr_08_RS
SET Carry_Position_SA = 
    CASE 
        WHEN NetQuantity < 0 THEN ABS(NetQuantity * Prev_Settle_PRICE_)
        WHEN NetQuantity > 0 THEN ABS(NetQuantity * Settle_PRICE_)
    END;

UPDATE EXP_Open_Position_Apr_08_RS
SET 
    Final_BA = Carry_Position_BA,
    Final_SA = Carry_Position_SA;

UPDATE EXP_Open_Position_Apr_08_RS
SET M2M = ROUND(Final_SA - Final_BA , 2);

select * from EXP_Open_Position_Apr_08_RS;

--To get Final Output Excel File for Open Position
Select 
ManagerID,
Reference_Text,
Exchange,
StrategyID,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice,
BuyQuantity,
SellQuantity,
BuyAmount,
SellAmount,
NetQuantity,
Settle_PRICE_,
Prev_Settle_PRICE_,
Carry_Position_BA,
Carry_Position_SA,
Final_BA,
Final_SA,
M2M,
TradeDate
from EXP_Open_Position_Apr_08_RS;

----------------------------------------------------
---------------------IntraDay-----------------------
----------------------------------------------------

Select * from Tradebook_EXP_MAY_05_RS;

--To get Intraday data from Main table
SELECT 
    [ManagerID],
	Reference_Text,
    [Exchange],
	StrategyID,
    [SecurityType],
    [Symbol],
    [ExpiryDate],
    [OptionType],
    [StrikePrice],
    SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) AS [BuyQuantity],
    SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) * CAST([Price] AS FLOAT) ELSE 0 END) AS [BuyAmount],
    SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) AS [SellQuantity],
    SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) * CAST([Price] AS FLOAT) ELSE 0 END) AS [SellAmount],
    (SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) - 
     SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) ELSE 0 END)) AS NetQuantity,
    
    -- Buy Rate calculation with zero BuyQuantity handled explicitly
    CASE 
        WHEN SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) = 0
        THEN 0
        ELSE 
            SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) * CAST([Price] AS FLOAT) ELSE 0 END) / 
            SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) ELSE 0 END)
    END AS [BuyRate],
    
    -- Sell Rate calculation with zero SellQuantity handled explicitly
    CASE 
        WHEN SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) = 0
        THEN 0
        ELSE 
            SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) * CAST([Price] AS FLOAT) ELSE 0 END) / 
            SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) ELSE 0 END)
    END AS [SellRate],
    
    TradeDate
into EXP_IntraDay_MAY_05_RS
FROM 
    Tradebook_EXP_MAY_05_RS
GROUP BY
    [ManagerID],
	Reference_Text,
    [Exchange],
	StrategyID,
    [SecurityType],
    [Symbol],
    [ExpiryDate],
    [OptionType],
    [StrikePrice],
    TradeDate
ORDER BY
    [ManagerID],
	Symbol,
    [ExpiryDate],
    [OptionType],
    [StrikePrice],
    TradeDate;

Select * from EXP_IntraDay_MAY_05_RS;

--Update Intraday Bhav
Alter table EXP_IntraDay_MAY_05_RS
add Settle_PRICE_ FLOAT,
    Prev_Settle_PRICE_ FLOAT;

UPDATE eo
SET eo.Prev_Settle_PRICE_ = b.SttlmPric
FROM EXP_IntraDay_MAY_05_RS eo
INNER JOIN [BHAVCOPY2025_05_02] b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND COALESCE(eo.OptionType, 'XX') = COALESCE(NULLIF(b.OptnTp, ''), 'XX')
    AND COALESCE(eo.StrikePrice, -0.01) = COALESCE(TRY_CAST(NULLIF(b.StrkPric, '') AS FLOAT), -0.01);

UPDATE eo
SET eo.Settle_PRICE_ = b.SttlmPric
FROM EXP_IntraDay_MAY_05_RS eo
INNER JOIN BHAVCOPY2025_05_05 b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND COALESCE(eo.OptionType, 'XX') = COALESCE(NULLIF(b.OptnTp, ''), 'XX')
    AND COALESCE(eo.StrikePrice, -0.01) = COALESCE(TRY_CAST(NULLIF(b.StrkPric, '') AS FLOAT), -0.01)

----------------------------------------------------
---------------------Settlement IntraDay------------
----------------------------------------------------

--Update Settlement
Alter table EXP_IntraDay_MAY_05_RS
add Settle_minus_Strike FLOAT;

UPDATE EXP_IntraDay_MAY_05_RS
SET Settle_minus_Strike= Settle_PRICE_-StrikePrice;

UPDATE EXP_IntraDay_MAY_05_RS
SET Settle_PRICE_ = CASE
    WHEN Settle_minus_Strike > 0 THEN 
        CASE 
            WHEN OptionType = 'CE' THEN ABS(Settle_minus_Strike)
            WHEN OptionType = 'PE' THEN 0
        END
    WHEN Settle_minus_Strike < 0 THEN 
        CASE 
            WHEN OptionType = 'CE' THEN 0
            WHEN OptionType = 'PE' THEN ABS(Settle_minus_Strike)
        END
    ELSE Settle_PRICE_  -- No update if conditions aren't met
END
WHERE netQuantity <> 0
  AND ExpiryDate = TradeDate
  AND (Settle_minus_Strike > 0 OR Settle_minus_Strike < 0);


--Now Calculations 
ALTER TABLE EXP_IntraDay_MAY_05_RS
ADD 
    CloseAmount FLOAT,
    New_BA FLOAT,
    New_SA FLOAT,
    Final_BA FLOAT,
    Final_SA FLOAT,
    M2M FLOAT;

UPDATE EXP_IntraDay_MAY_05_RS
SET CloseAmount =ABS( Settle_PRICE_ * NetQuantity);

UPDATE EXP_IntraDay_MAY_05_RS
SET 
    New_SA = CASE 
                WHEN NetQuantity > 0 THEN CloseAmount + [SellAmount]
				WHEN NetQuantity < 0 THEN [SellAmount]
				WHEN NetQuantity = 0 THEN [SellAmount]  
                ELSE New_SA  
             END,
    New_BA = CASE 
                WHEN NetQuantity < 0 THEN CloseAmount + [BuyAmount]
				WHEN NetQuantity > 0 THEN [BuyAmount]
				WHEN NetQuantity = 0 THEN [BuyAmount] 
                ELSE New_BA  
             END;

UPDATE EXP_IntraDay_MAY_05_RS
SET 
    Final_BA = New_BA,
    Final_SA = New_SA;


UPDATE EXP_IntraDay_MAY_05_RS
SET M2M = Final_SA-Final_BA;

--To get Final Output Excel File for Intraday
Select 
ManagerID,
Reference_Text,
Exchange,
StrategyID,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice,
BuyQuantity,
SellQuantity,
BuyAmount,
SellAmount,
NetQuantity,
Settle_PRICE_,
Prev_Settle_PRICE_,
Final_BA,
Final_SA,
M2M,
TradeDate
from EXP_IntraDay_MAY_05_RS;

-----------------------------------------------------
--To check Merged data (OP + Intraday)
SELECT 
ManagerID,Reference_Text,Exchange,StrategyID,SecurityType,Symbol,ExpiryDate,OptionType,StrikePrice,BuyQuantity,SellQuantity,BuyAmount,SellAmount,NetQuantity,Settle_PRICE_,Prev_Settle_PRICE_,Final_BA,Final_SA,M2M,TradeDate
from EXP_Open_Position_MAY_05_RS
union all
SELECT 
ManagerID,Reference_Text,Exchange,StrategyID,SecurityType,Symbol,ExpiryDate,OptionType,StrikePrice,BuyQuantity,SellQuantity,BuyAmount,SellAmount,NetQuantity,Settle_PRICE_,Prev_Settle_PRICE_,Final_BA,Final_SA,M2M,TradeDate
from EXP_IntraDay_MAY_05_RS
order by ManagerID,SYMBOL,ExpiryDate,OptionType,StrikePrice;

----------------------------------------------------
---------------------Grouping-----------------------
----------------------------------------------------

--Final Output Excel File from Merging data (OP + Intraday)
SELECT 
    ManagerID,
    Reference_Text,
    Exchange,
    StrategyID,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice,
    SUM(BuyQuantity) AS BuyQuantity,
    SUM(SellQuantity) AS SellQuantity,
    SUM(BuyAmount) AS BuyAmount,
    SUM(SellAmount) AS SellAmount,
    SUM(NetQuantity) AS NetQuantity,
    AVG(Settle_PRICE_) AS SettlePrice,
    AVG(Prev_Settle_PRICE_) AS PrevSettlePrice,
    SUM(Final_BA) AS Final_BA,
    SUM(Final_SA) AS Final_SA,
    SUM(M2M) AS M2M,
    TradeDate
INTO EXP_MAY_05_RS
FROM (
    SELECT 
        ManagerID, Reference_Text, Exchange, StrategyID, SecurityType, Symbol, ExpiryDate, OptionType, StrikePrice,
        BuyQuantity, SellQuantity, BuyAmount, SellAmount, NetQuantity, Settle_PRICE_, Prev_Settle_PRICE_, Final_BA, Final_SA, M2M, TradeDate
    FROM EXP_Open_Position_MAY_05_RS

    UNION ALL

    SELECT 
        ManagerID, Reference_Text, Exchange, StrategyID, SecurityType, Symbol, ExpiryDate, OptionType, StrikePrice,
        BuyQuantity, SellQuantity, BuyAmount, SellAmount, NetQuantity, Settle_PRICE_, Prev_Settle_PRICE_, Final_BA, Final_SA, M2M, TradeDate
    FROM EXP_IntraDay_MAY_05_RS
) AS CombinedData
GROUP BY 
    ManagerID,
    Reference_Text,
    Exchange,
    StrategyID,
    SecurityType,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice,
    TradeDate
ORDER BY 
    ManagerID,
    Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;

select * from EXP_MAY_05_RS;

