use harsh_data;

--This code will give holding datewise trade merged with actual trades
WITH RankedTrades AS (
    SELECT 
        [ManagerID],
        [Symbol],
        [StrategyID],
        [ExchangeTradeTime],
        [ExpiryDate],
        [OptionType],
        [StrikePrice],
        SUM(BuyQuantity) AS BuyQuantity,
        SUM(SellQuantity) AS SellQuantity
    FROM 
        New_Tradebook_Apr
    GROUP BY 
        [ManagerID], 
        [Symbol], 
        [StrategyID], 
        [ExchangeTradeTime], 
        [ExpiryDate], 
        [OptionType], 
        [StrikePrice]
),
RemainingQuantities AS (
    SELECT 
        *,
        SUM(BuyQuantity - SellQuantity) 
        OVER (PARTITION BY [ManagerID], [Symbol], [OptionType], [StrikePrice], [ExpiryDate]  ORDER BY [ExchangeTradeTime] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RemainingQuantity
    FROM 
        RankedTrades
),
ActualTrades AS (
    SELECT 
        [ManagerID],
        [Symbol],
        [StrategyID],
        ExchangeTradeTime,
        ExpiryDate,
        OptionType,
        StrikePrice,
        0 AS BuyQuantity,
        0 AS SellQuantity,
        RemainingQuantity
    FROM 
        RemainingQuantities
    WHERE 
        RemainingQuantity <> 0
),
HoldingTrades AS (
    SELECT 
        [ManagerID],
        [Symbol],
        [StrategyID],
        DATEADD(DAY, 1, ExchangeTradeTime) AS ExchangeTradeTime,
        ExpiryDate,
        OptionType,
        StrikePrice,
        0 AS BuyQuantity,
        0 AS SellQuantity,
        RemainingQuantity
    FROM 
        RemainingQuantities
    WHERE 
        RemainingQuantity <> 0 
        AND ExchangeTradeTime IN (
            SELECT DISTINCT 
                ExchangeTradeTime 
            FROM 
                RemainingQuantities 
            WHERE 
                RemainingQuantity <> 0
        )
)

SELECT 
    [ManagerID],
    [Symbol],
    [StrategyID],
    ExchangeTradeTime,
    ExpiryDate,
    OptionType,
    StrikePrice,
    BuyQuantity,
    SellQuantity,
    RemainingQuantity
--into April_Datewise
FROM 
    RemainingQuantities

UNION ALL

SELECT 
    [ManagerID],
    [Symbol],
    [StrategyID],
    ExchangeTradeTime,
    ExpiryDate,
    OptionType,
    StrikePrice,
    BuyQuantity,
    SellQuantity,
    RemainingQuantity
FROM 
    HoldingTrades


ORDER BY 
    [ManagerID], 
    [Symbol], 
    ExchangeTradeTime;


Select * from April_Datewise
order by ManagerID, Symbol, ExchangeTradeTime;























































