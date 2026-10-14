use harsh_data;

--For storing Holding Trades in proper format as Actual Trades
INSERT INTO Holding_Trades(ManagerID, Symbol, StrategyID, ExchangeTradeTime, ExpiryDate, OptionType, StrikePrice, BuyQuantity, SellQuantity, NetQuantity, RemainingQuantity)
SELECT a.ManagerID, a.Symbol, a.StrategyID, a.ExchangeTradeTime, a.ExpiryDate, a.OptionType, a.StrikePrice, a.BuyQuantity, a.SellQuantity, 
       (a.BuyQuantity - a.SellQuantity) AS NetQuantity, a.RemainingQuantity
FROM April_Datewise a
WHERE NOT EXISTS (
    SELECT 1
    FROM Holding_Trades n
    WHERE n.ManagerID = a.ManagerID 
      AND n.Symbol = a.Symbol 
      AND n.StrategyID = a.StrategyID 
      AND n.ExchangeTradeTime = a.ExchangeTradeTime
);

Select * from Holding_Trades
order by [ManagerID], 
    [Symbol], 
    [ExchangeTradeTime]; 

--Date Updation
UPDATE Holding_Trades
SET ExchangeTradeTime = CONVERT(varchar(10), CAST(ExchangeTradeTime AS datetime), 23);
--Side Update
UPDATE Holding_Trades
SET Side = 'Holding'
WHERE BuyQuantity = 0 AND SellQuantity = 0;

