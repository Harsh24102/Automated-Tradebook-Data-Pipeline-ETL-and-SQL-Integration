use harsh_data;

--To Fetch Previous Data 
/*select * 
into [NFT_April_8_RS] from Janvi.[dbo].[NFT_April_8_RS];*/

--To fetch bhavcopy
/*select * 
into [BHAVCOPY2025_04_09] from Janvi.[dbo].[BHAVCOPY2025_04_09];

select * 
into [G_T_Bhavcopy_FO_080425] from Janvi.[dbo].[G_T_Bhavcopy_FO_080425];*/

Select * from Tradebook_2025_NFT;

Drop Table NFT_Open_Position_April_17_RS;

--Previous Day open position inserted 
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
into NFT_Open_Position_April_17_RS
from NFT_April_16_RS
where TradeDate like '2025-04-16'         --Previous Date 
  and ExpiryDate not like '2025-04-16'     --Previous Date 
      and NetQuantity<>0;

--Current Date data
SELECT *
INTO Tradebook_NFT_APRIL_17_RS
FROM Tradebook_2025_NFT
WHERE TradeDate LIKE '2025-04-17';

----------------------------------------------------
---------------------OP-----------------------------
----------------------------------------------------

Select * from NFT_Open_Position_April_17_RS;

--To set Current Date
UPDATE NFT_Open_Position_April_17_RS
set TradeDate='2025-04-17';

ALTER TABLE NFT_Open_Position_April_17_RS
ADD TokenforIFSC VARCHAR(30),
    Settle_PRICE_ FLOAT,
    Prev_Settle_PRICE_ FLOAT;  

UPDATE NFT_Open_Position_April_17_RS
SET TokenforIFSC = CONCAT(SecurityType, Symbol, UPPER(FORMAT(expiryDate, 'dd-MMM-yyyy')));

--Now Update Bhavcopy
select * from NFT_Open_Position_April_17_RS;
select * from BHAVCOPY2025_04_17;
select * from [G_T_Bhavcopy_FO_170425];
select * from [BHAVCOPY2025_04_16];
select * from [G_T_Bhavcopy_FO_160425];

UPDATE eo
SET eo.Prev_Settle_PRICE_ = b.SttlmPric
FROM NFT_Open_Position_April_17_RS eo
INNER JOIN BHAVCOPY2025_04_16 b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric;

UPDATE eo
SET eo.Prev_Settle_PRICE_ = g.SETTLEMENT
FROM NFT_Open_Position_April_17_RS eo
INNER JOIN [G_T_Bhavcopy_FO_160425] g
    ON eo.TokenforIFSC = g.CONTRACT_D;  

UPDATE eo
SET eo.Settle_PRICE_ = b.SttlmPric
FROM NFT_Open_Position_April_17_RS eo
INNER JOIN [BHAVCOPY2025_04_17] b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric;

UPDATE eo
SET eo.Settle_PRICE_ = g.SETTLEMENT
FROM NFT_Open_Position_April_17_RS eo
INNER JOIN [G_T_Bhavcopy_FO_170425] g
    ON eo.TokenforIFSC = g.CONTRACT_D; 
	
----------------------------------------------------
---------------------Settlement OP------------------
----------------------------------------------------

--To Update Settlement
Alter table NFT_Open_Position_April_17_RS
add Settle_minus_Strike FLOAT;

UPDATE NFT_Open_Position_April_17_RS
SET Settle_minus_Strike= Settle_PRICE_-StrikePrice;

UPDATE NFT_Open_Position_April_17_RS
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
ALTER TABLE NFT_Open_Position_April_17_RS
ADD 
    Carry_Position_BA FLOAT,
    Carry_Position_SA FLOAT,
    Final_BA FLOAT,
    Final_SA FLOAT,
    M2M FLOAT;

UPDATE NFT_Open_Position_April_17_RS
SET Carry_Position_BA = 
    CASE 
        WHEN NetQuantity < 0 THEN ABS(NetQuantity * Settle_PRICE_)
        WHEN NetQuantity > 0 THEN ABS(NetQuantity * Prev_Settle_PRICE_)
    END;

UPDATE NFT_Open_Position_April_17_RS
SET Carry_Position_SA = 
    CASE 
        WHEN NetQuantity < 0 THEN ABS(NetQuantity * Prev_Settle_PRICE_)
        WHEN NetQuantity > 0 THEN ABS(NetQuantity * Settle_PRICE_)
    END;

UPDATE NFT_Open_Position_April_17_RS
SET 
    Final_BA = Carry_Position_BA,
    Final_SA = Carry_Position_SA;

UPDATE NFT_Open_Position_April_17_RS
SET M2M = ROUND(Final_SA - Final_BA , 2);

select * from NFT_Open_Position_April_17_RS;

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
Final_BA,
Final_SA,
M2M,
TradeDate
from NFT_Open_Position_April_17_RS;

----------------------------------------------------
---------------------IntraDay-----------------------
----------------------------------------------------

Select * from Tradebook_NFT_APRIL_17_RS;

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
into NFT_IntraDay_April_17_RS
FROM 
    Tradebook_NFT_APRIL_17_RS
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

Select * from NFT_IntraDay_April_17_RS;

--Update Intraday Bhav
ALTER TABLE NFT_IntraDay_April_17_RS
ADD TokenforIFSC VARCHAR(30),
    Settle_PRICE_ FLOAT,
    Prev_Settle_PRICE_ FLOAT;  

UPDATE NFT_IntraDay_April_17_RS
SET TokenforIFSC = CONCAT(SecurityType, Symbol, UPPER(FORMAT(expiryDate, 'dd-MMM-yyyy')));

UPDATE eo
SET eo.Prev_Settle_PRICE_ = b.SttlmPric
FROM NFT_IntraDay_April_17_RS eo
INNER JOIN BHAVCOPY2025_04_16 b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric;

UPDATE eo
SET eo.Prev_Settle_PRICE_ = g.SETTLEMENT
FROM NFT_IntraDay_April_17_RS eo
INNER JOIN [G_T_Bhavcopy_FO_160425] g
    ON eo.TokenforIFSC = g.CONTRACT_D;  

UPDATE eo
SET eo.Settle_PRICE_ = b.SttlmPric
FROM NFT_IntraDay_April_17_RS eo
INNER JOIN [BHAVCOPY2025_04_17] b 
    ON eo.Symbol = b.TckrSymb
    AND eo.ExpiryDate = b.XpryDt
    AND eo.OptionType = b.OptnTp
    AND eo.StrikePrice = b.StrkPric;

UPDATE eo
SET eo.Settle_PRICE_ = g.SETTLEMENT
FROM NFT_IntraDay_April_17_RS eo
INNER JOIN [G_T_Bhavcopy_FO_170425] g
    ON eo.TokenforIFSC = g.CONTRACT_D;  
	
----------------------------------------------------
---------------------Settlement IntraDay------------
----------------------------------------------------

--Update Settlement
Alter table NFT_IntraDay_April_17_RS
add Settle_minus_Strike FLOAT;

UPDATE NFT_IntraDay_April_17_RS
SET Settle_minus_Strike= Settle_PRICE_-StrikePrice;

UPDATE NFT_IntraDay_April_17_RS
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
ALTER TABLE NFT_IntraDay_April_17_RS
ADD 
    CloseAmount FLOAT,
    New_BA FLOAT,
    New_SA FLOAT,
    Final_BA FLOAT,
    Final_SA FLOAT,
    M2M FLOAT;

UPDATE NFT_IntraDay_April_17_RS
SET CloseAmount =ABS( Settle_PRICE_ * NetQuantity);

UPDATE NFT_IntraDay_April_17_RS
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

UPDATE NFT_IntraDay_April_17_RS
SET 
    Final_BA = New_BA,
    Final_SA = New_SA;


UPDATE NFT_IntraDay_April_17_RS
SET M2M = ROUND(Final_SA - Final_BA , 2);

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
from NFT_IntraDay_April_17_RS;

-----------------------------------------------------
--To check Merged data (OP + Intraday)
SELECT 
ManagerID,Reference_Text,Exchange,StrategyID,SecurityType,Symbol,ExpiryDate,OptionType,StrikePrice,BuyQuantity,SellQuantity,BuyAmount,SellAmount,NetQuantity,Settle_PRICE_,Prev_Settle_PRICE_,Final_BA,Final_SA,M2M,TradeDate
from NFT_Open_Position_April_17_RS
union all
SELECT 
ManagerID,Reference_Text,Exchange,StrategyID,SecurityType,Symbol,ExpiryDate,OptionType,StrikePrice,BuyQuantity,SellQuantity,BuyAmount,SellAmount,NetQuantity,Settle_PRICE_,Prev_Settle_PRICE_,Final_BA,Final_SA,M2M,TradeDate
from NFT_IntraDay_April_17_RS
order by ManagerID,Symbol,ExpiryDate,OptionType,StrikePrice;

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
INTO NFT_April_17_RS
FROM (
    SELECT 
        ManagerID, Reference_Text, Exchange, StrategyID, SecurityType, Symbol, ExpiryDate, OptionType, StrikePrice,
        BuyQuantity, SellQuantity, BuyAmount, SellAmount, NetQuantity, Settle_PRICE_, Prev_Settle_PRICE_, Final_BA, Final_SA, M2M, TradeDate
    FROM NFT_Open_Position_April_17_RS

    UNION ALL

    SELECT 
        ManagerID, Reference_Text, Exchange, StrategyID, SecurityType, Symbol, ExpiryDate, OptionType, StrikePrice,
        BuyQuantity, SellQuantity, BuyAmount, SellAmount, NetQuantity, Settle_PRICE_, Prev_Settle_PRICE_, Final_BA, Final_SA, M2M, TradeDate
    FROM NFT_IntraDay_April_17_RS
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

select * from NFT_April_17_RS;
