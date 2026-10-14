use harsh_data;

drop table NFT_DATA_2025;

--Table formation
CREATE TABLE NFT_DATA_2025 (
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
	[Quantity] varchar(10) ,
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
);

--Data Replace
TRUNCATE TABLE NFT_DATA_2025;

--Data Fetch
INSERT INTO NFT_DATA_2025([Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime],
[Exchange], [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText],
[CTCLID], [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [Multiplier])
SELECT [Server], [UserID], [MAINTradeID], [MAINOrderID], [OrderID], [ExchangeOrderNo], [ExchangeTradeID], [OrderTime], [ExchangeOrderTime], [ExchangeTradeTime],
[Exchange], [SecurityID], [Symbol], [ExpiryDate], [SecurityType], [Side], [OrderType], [Quantity], [PendingQuantity], [Price], [StrikePrice], [ClientID], [ReferenceText],
[CTCLID], [MemberID], [StrategyID], [OptionType], [OpenClose], [ProductType], [ManagerID], [Pancard], [TerminalInfo], [AlgoID], [AlgoCategory], [Multiplier]
FROM [2526 GNFTOPT].[dbo].[IFSC-NFT];  

select * from NFT_DATA_2025;


-- Clean the MemberID column to remove decimal part and convert it to INT
UPDATE NFT_DATA_2025
SET MemberID = CAST(FLOOR(CAST(MemberID AS FLOAT)) AS INT)
WHERE ISNUMERIC(MemberID) = 1;

-- Clean the SecurityID column to remove decimal part and convert it to INT
UPDATE NFT_DATA_2025
SET SecurityID = CAST(FLOOR(CAST(SecurityID AS FLOAT)) AS INT)
WHERE ISNUMERIC(SecurityID) = 1;

-- Clean the CTCLID column to remove decimal part and convert it to INT
UPDATE NFT_DATA_2025
SET CTCLID = CAST(FLOOR(CAST(CTCLID AS FLOAT)) AS INT)
WHERE ISNUMERIC(CTCLID) = 1;

-- Clean the StrategyID column to remove decimal part and convert it to INT
UPDATE NFT_DATA_2025
SET StrategyID = CAST(FLOOR(CAST(StrategyID AS FLOAT)) AS INT)
WHERE ISNUMERIC(StrategyID) = 1;

-- Clean the Quantity column to remove decimal part and convert it to INT
UPDATE NFT_DATA_2025
SET Quantity = CAST(FLOOR(CAST(Quantity AS FLOAT)) AS INT)
WHERE ISNUMERIC(Quantity) = 1;
