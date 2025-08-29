use harsh_data;

--drop table Options_Data;

--Table formation
/*CREATE TABLE Options_Data (
    [Server] varchar(50),
	[UserID] varchar(50),
	[MAINTradeID] varchar(50),
	[MAINOrderID] varchar(50),
	[OrderID] varchar(50),
	[ExchangeOrderNo] varchar(50),
	[ExchangeTradeID] varchar(50),
	[OrderTime] varchar(50),
	[ExchangeOrderTime] varchar(50),
	[ExchangeTradeTime] varchar(50),
	[Exchange] varchar(50),
	[SecurityID] varchar(50),
	[Symbol] varchar(50),
	[ExpiryDate] varchar(50),
	[SecurityType] varchar(50),
	[Side] varchar(50),
	[OrderType] varchar(50),
	[Quantity] bigint,
	[PendingQuantity] varchar(50),
	[Price] float,
	[StrikePrice] float,
	[ClientID] varchar(50),
	[ReferenceText] varchar(50),
	[CTCLID] varchar(50),
	[MemberID] varchar(50),
	[StrategyID] varchar(50),
	[OptionType] varchar(50),
	[OpenClose] varchar(50),
	[ProductType] varchar(50),
	[ManagerID] varchar(50),
	[Pancard] varchar(50),
	[TerminalInfo] varchar(50),
	[AlgoID] varchar(50),
	[AlgoCategory] varchar(50),
	[Multiplier] float
);*/

--Data Replace
TRUNCATE TABLE Options_Data;
--Data Fetch
INSERT INTO Options_Data([Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime],
[Exchange], [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText],
[CTCLID], [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [Multiplier])
SELECT [Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime],
[Exchange], [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText],
[CTCLID], [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [Multiplier]
FROM [Reporting].[dbo].[StroedData];  

select * from Options_Data;


SELECT * 
FROM Options_Data
WHERE CAST(STUFF(ExchangeTradeTime, 9, 1, ' ') AS DATETIME) >= CAST(GETDATE() AS DATE);
