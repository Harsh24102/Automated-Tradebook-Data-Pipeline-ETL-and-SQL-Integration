use harsh_data;

--RQ column added in main Tradebook
ALTER TABLE New_Tradebook_Apr
ADD  RemainingQuantity INT;

--Query for Adding HoldingTrades into main Tradebook
INSERT INTO New_Tradebook_Apr 
(
    ManagerID,
    UserID,  
    ExchangeTradeTime,
    Symbol,
    StrategyID,
    SecurityType, 
    Exchange,      
    ExpiryDate,
    OptionType,
    StrikePrice,
    Side,
    BuyQuantity,
    SellQuantity,
    BuyAmount,  
    SellAmount,
    BuyRate,    
    SellRate,   
    NetQuantity,
    NetAmount, 
    RemainingQuantity
)
SELECT 
    ManagerID,
    NULL AS UserID,  
    ExchangeTradeTime,
    Symbol,
    StrategyID,
    NULL AS SecurityType,  
    NULL AS Exchange,      
    ExpiryDate,
    OptionType,
    StrikePrice,
    Side,
    BuyQuantity,
    SellQuantity,
    0 AS BuyAmount, 
    0 AS SellAmount, 
    0 AS BuyRate,    
    0 AS SellRate,   
    NetQuantity,
    0 AS NetAmount,  
    RemainingQuantity
FROM Holding_Trades
WHERE Side = 'holding';

select * from New_Tradebook_Apr
order by ManagerID,  Symbol, ExchangeTradeTime;

--Updating NQ and RQ
UPDATE New_Tradebook_Apr
SET RemainingQuantity = CASE
    WHEN Side IN ('buy', 'sell') THEN NetQuantity
    ELSE RemainingQuantity  
END
WHERE Side IN ('buy', 'sell');  

Alter table [dbo].[New_Tradebook_Apr]
--Drop column Token;
ADD Token varchar(100);


UPDATE New_Tradebook_Apr
SET Token = CONCAT(
    ManagerID, ' ',
	OptionType, ' ',
	Symbol, ' ',
    ExpiryDate, ' ',
	StrikePrice
);

SELECT * FROM New_Tradebook_Apr
WHERE UserID IS NULL
AND Side = 'Holding';

--Updating columns Strategyid, Userid, Exchange, Securityid
--For Indexes(Options) only
UPDATE New_Tradebook_Apr
SET 
    [UserID] = CASE 
        WHEN Token LIKE '%NIFTY%' THEN 'ADNSE'
        WHEN Token LIKE '%MIDCPNIFTY%' THEN 'ADMID'
        WHEN Token LIKE '%FINNIFTY%' THEN 'ADFIN'
        WHEN Token LIKE '%BANKNIFTY%' THEN 'ADFIN'
        WHEN Token LIKE '%BANKEX%' THEN 'ADBSE'
        WHEN Token LIKE '%SENSEX%' THEN 'ADBSE'
        ELSE [UserID] -- Keep original if no match
    END,
    [StrategyID] = CASE 
        WHEN Token LIKE '%NIFTY%' THEN '71'
        WHEN Token LIKE '%MIDCPNIFTY%' THEN '282'
        WHEN Token LIKE '%FINNIFTY%' THEN '76'
        WHEN Token LIKE '%BANKNIFTY%' THEN '44'
        WHEN Token LIKE '%BANKEX%' THEN '310'
        WHEN Token LIKE '%SENSEX%' THEN '286'
        ELSE [StrategyID] -- Keep original if no match
    END,
    [Exchange] = CASE 
        WHEN Token LIKE '%BANKEX%' OR Token LIKE '%SENSEX%' THEN 'BSEFO'
        ELSE 'NSEFO' -- Use NSEFO for other tokens
    END,
    [SecurityType] = 'OPTIDX'  
WHERE 
    ([UserID] IS NULL OR [Exchange] IS NULL OR [SecurityType] IS NULL)
    AND Side = 'holding';


--For each stocks optionwise
-- NIFTY
UPDATE New_Tradebook_Apr 
SET 
    [UserID] = 'ADNSE' 
WHERE 
    [UserID] IS NULL AND [StrategyID] = '71';

-- BankNifty
UPDATE New_Tradebook_Apr 
SET 
    [UserID] = 'ADFIN'
WHERE 
    [UserID] IS NULL AND [StrategyID] = '44';

-- FINNIFTY
UPDATE New_Tradebook_Apr 
SET 
    [UserID] = 'ADFIN' 
WHERE 
    [UserID] IS NULL AND [StrategyID] = '76';

-- MIDCPNIFTY
UPDATE New_Tradebook_Apr
SET 
    [UserID] = 'ADMID'
WHERE 
    [UserID] IS NULL AND [StrategyID] = '282';

-- BANKEX
UPDATE New_Tradebook_Apr
SET 
    [UserID] = 'ADBSE',
    [Exchange] = 'BSEFO'  
WHERE 
    [UserID] IS NULL AND [StrategyID] = '286';

-- SENSEX
UPDATE New_Tradebook_Apr
SET 
    [UserID] = 'ADBSE',
    [Exchange] = 'BSEFO'  
WHERE 
    [UserID] IS NULL AND [StrategyID] = '310';

-- Replace NULL values in UserID and StrategyID with '0'
UPDATE New_Tradebook_Apr
SET 
    [UserID] = '0',
    [StrategyID] = '0'
WHERE 
    [UserID] IS NULL OR [StrategyID] IS NULL;

SELECT * FROM New_Tradebook_Apr
WHERE StrategyID = 0;
--AND side = 'holding';

Select * from New_Tradebook_Apr
order by [ManagerID], 
    [Symbol], 
    [ExchangeTradeTime]; 