USE harsh_data;

WITH CalculatedData AS (
    SELECT
        ManagerID,
        Symbol,
        Exchange,
        ExchangeTradeTime,
        OptionType,  
        StrikePrice,
        ExpiryDate, 
        Side,
        BuyQuantity,
        BuyAmount,
        SellQuantity,
        SellAmount
    FROM BackupApr
),
AggregatedData AS (
    SELECT
        ManagerID,
        Symbol,
        Exchange,
        ExchangeTradeTime,
        OptionType,  
        StrikePrice,
        ExpiryDate,  
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
        END AS SellRate
    FROM CalculatedData
    GROUP BY ManagerID, Symbol, OptionType, StrikePrice, ExpiryDate, Exchange, ExchangeTradeTime
),
RankedTrades AS (
    SELECT 
        ManagerID,
        Symbol,
        Side,
        ExchangeTradeTime,
        ExpiryDate,
        OptionType,
        StrikePrice,
        BuyQuantity,
        SellQuantity,
        ROW_NUMBER() OVER (PARTITION BY ManagerID, Symbol ORDER BY ExchangeTradeTime) AS TradeOrder
    FROM 
        BackupApr
),
RemainingQuantities AS (
    SELECT 
        *,
        SUM(CASE WHEN Side = 'Buy' THEN BuyQuantity ELSE -SellQuantity END) 
            OVER (PARTITION BY ManagerID, Symbol ORDER BY ExchangeTradeTime ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Holdings
    FROM 
        RankedTrades
)
SELECT 
    a.ManagerID,
    a.Symbol,
    a.Exchange,
    a.ExchangeTradeTime,
    a.OptionType, 
    a.StrikePrice,
    a.ExpiryDate,  
    a.BuyQuantity,
    ROUND(a.BuyRate, 2) AS BuyRate,
    a.BuyAmount,
    a.SellQuantity,
    ROUND(a.SellRate, 2) AS SellRate,
    a.SellAmount,
    a.NetQuantity,
    a.NetAmount,
    CASE 
        WHEN r.Holdings = 0 THEN '0'
        ELSE ' - ' 
    END AS NetQuantity,
    r.Holdings AS RemainingQuantity,
    TRY_CAST(b.ClsPric AS float) AS ClosePrice
FROM AggregatedData a
LEFT JOIN Bhavcopy_April b
    ON a.Symbol = b.TckrSymb
    AND a.ExchangeTradeTime = b.TradDt
    AND TRY_CAST(a.StrikePrice AS decimal(18, 2)) = COALESCE(TRY_CAST(b.StrkPric AS decimal(18, 2)), -0.01)
    AND a.ExpiryDate = TRY_CAST(b.XpryDt AS DATE)
    AND a.OptionType = COALESCE(NULLIF(b.OptnTp, ''), 'XX')
LEFT JOIN RemainingQuantities r
    ON a.ManagerID = r.ManagerID AND a.Symbol = r.Symbol AND a.ExchangeTradeTime = r.ExchangeTradeTime
ORDER BY 
    a.ManagerID, 
    a.Symbol, 
    a.ExchangeTradeTime;



