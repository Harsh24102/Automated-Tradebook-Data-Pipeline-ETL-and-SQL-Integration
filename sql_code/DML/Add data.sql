use harsh_data;

select * from Options_Data;

SELECT * FROM Options_Data
WHERE ExchangeTradeTime like '20240418%'; 

SELECT COUNT(*) FROM Options_Data
WHERE ExchangeTradeTime like '20240418%';  

-- To check for specific date
DECLARE @SpecificDate DATE = '2024-04-30';  

-- Query to check if data exists or not
SELECT COUNT(*) AS DateExistCount
FROM options_data
WHERE CONVERT(DATE, LEFT(ExchangeTradeTime, 8), 112) = @SpecificDate;


BEGIN TRANSACTION;

-- Delete data for that date
DELETE FROM Options_Data
WHERE ExchangeTradeTime = @SpecificDate;

-- Re-insert the data for that date (Modify as needed)
INSERT INTO Options_Data([Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime],
[Exchange], [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText],
[CTCLID], [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [Multiplier])
SELECT [Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime],
[Exchange], [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText],
[CTCLID], [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [Multiplier]
FROM source_table
WHERE ExchangeTradeTime = @SpecificDate;

COMMIT;

