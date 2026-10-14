use harsh_data; 

select * from Bhav_Match
where SettlementPrice is null;

Select * from Bhavcopy_April
where FinInstrmTp = 'IDO'
and OptnTp = 'CE'
AND StrkPric >= SettlementP;

Select * from Bhavcopy_April;
select * from New_Tradebook_Apr;

--Creating and Updating SettlementPrice where ExpiryDate similar to TradeDate
Select * from Bhavcopy_April
where TradDt = XpryDt
and OptnTp like '%PE%'
AND FinInstrmTp = 'IDO'
AND TckrSymb = 'FINNIFTY';

ALTER TABLE Bhavcopy_April
--Drop column [SettlementP];
ADD SettlementP FLOAT; 

UPDATE Bhavcopy_April
SET SettlementP = CASE 
    WHEN [FinInstrmTp] = 'IDO' AND TradDt = XpryDt THEN
        CASE 
            WHEN [OptnTp] = 'CE' AND TRY_CAST([StrkPric] AS FLOAT) < TRY_CAST(SttlmPric AS FLOAT) THEN TRY_CAST(SttlmPric AS FLOAT) - TRY_CAST([StrkPric] AS FLOAT)
            WHEN [OptnTp] = 'CE' AND TRY_CAST([StrkPric] AS FLOAT) >= TRY_CAST(SttlmPric AS FLOAT) THEN 0
            WHEN [OptnTp] = 'PE' AND TRY_CAST([StrkPric] AS FLOAT) > TRY_CAST(SttlmPric AS FLOAT) THEN TRY_CAST([StrkPric] AS FLOAT) - TRY_CAST(SttlmPric AS FLOAT)
            WHEN [OptnTp] = 'PE' AND TRY_CAST([StrkPric] AS FLOAT) <= TRY_CAST(SttlmPric AS FLOAT) THEN 0
            ELSE 0  
        END
    ELSE SttlmPric  
END
WHERE [FinInstrmTp] = 'IDO' AND TradDt = XpryDt;  


UPDATE Bhavcopy_April
SET SettlementP = SttlmPric
WHERE SettlementP IS NULL;

--Updating Exchange portion
UPDATE Bhavcopy_April
SET Sgmt = 'FO'
WHERE Src = 'BSE';

ALTER TABLE Bhavcopy_April
ADD Exchange VARCHAR(20);

UPDATE Bhavcopy_April
SET Exchange = Src + Sgmt;

--Fetching ClosePrice and SettlementPrice from Bhavcopy to my table 
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
    FROM New_Tradebook_Apr
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
    a.BuyRate,
    a.BuyAmount,
    a.SellQuantity,
    a.SellRate,
    a.SellAmount,
    a.NetQuantity,
    a.NetAmount,
    TRY_CAST(b.ClsPric AS float) AS ClosePrice,
    TRY_CAST(b.SettlementP AS float) AS SettlementPrice, 
	TRY_CAST(b.[PrvsClsgPric] AS float) AS PrevClosePrice
--into Bhav_Match
FROM AggregatedData a
LEFT JOIN Bhavcopy_April b
    ON a.Symbol = b.TckrSymb
    AND a.ExchangeTradeTime = b.TradDt
    AND TRY_CAST(a.StrikePrice AS decimal(18, 2)) = COALESCE(TRY_CAST(b.StrkPric AS decimal(18, 2)), -0.01)
    AND a.ExpiryDate = TRY_CAST(b.XpryDt AS DATE)
    AND a.OptionType = COALESCE(NULLIF(b.OptnTp, ''), 'XX');

Select * from Bhav_Match
order by ManagerID,Symbol,ExchangeTradeTime;

Select * from Bhav_Match
where ManagerID = 'EXPOPT01'
AND Symbol = 'SBILIFE'
order by ManagerID,ExchangeTradeTime;


