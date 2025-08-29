use harsh_data;
--To check trades that are not OFF Set
select * from New_Tradebook_Apr
where NetQuantity != 0;

select * from New_Tradebook_Apr
where NetQuantity = 0;

select * from New_Tradebook_Apr
order by ManagerID, ExchangeTradeTime, Symbol;

--This code will differentiate quanity datewise on NQ and store holding data in RQ
WITH RankedTrades AS (
    SELECT 
        [ManagerID],
        [Symbol],
        [StrategyID],
        [ExchangeTradeTime],
        [ExpiryDate],
        [OptionType],
        [StrikePrice],
        [Side],
        BuyQuantity,
        SellQuantity,
        ROW_NUMBER() OVER (PARTITION BY [ManagerID], [Symbol], [StrategyID] ORDER BY [ExchangeTradeTime]) AS TradeOrder
    FROM 
        New_Tradebook_Apr
),
RemainingQuantities AS (
    SELECT 
        *,
        SUM(CASE WHEN Side = 'Buy' THEN BuyQuantity ELSE -SellQuantity END) 
            OVER (PARTITION BY [ManagerID], [Symbol], [StrategyID] ORDER BY [ExchangeTradeTime] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Holdings
    FROM 
        RankedTrades
)
SELECT 
    [ManagerID],
    [Symbol],
    [StrategyID],
    [ExchangeTradeTime],
    [ExpiryDate],
    [OptionType],
    [StrikePrice],
    [Side],
    BuyQuantity,
    SellQuantity,
    CASE 
        WHEN Holdings = 0 THEN '0'
        ELSE ' - ' 
    END AS NetQuantity,
    Holdings AS RemainingQuantity
--into Holding_Trades
FROM 
    RemainingQuantities
ORDER BY 
    [ManagerID], 
    [Symbol], 
    [ExchangeTradeTime], 
    TradeOrder;

Select * from Holding_Trades;

Select * from Holding_Trades
order by [ManagerID], 
    [Symbol], 
    [ExchangeTradeTime]; 















