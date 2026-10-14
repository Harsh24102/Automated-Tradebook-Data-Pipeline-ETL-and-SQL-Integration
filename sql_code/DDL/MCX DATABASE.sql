USE [2526 MCXVIVA]
GO

/*
delete from [dbo].[StoreData]
where ExchangeTradeTime like '20250127%'
delete from [dbo].[StoreData]
where ExchangeTradeTime like '20250128%'
delete from [dbo].[StoreData]
where ExchangeTradeTime like '20250129%'
*/

INSERT INTO [dbo].[StoreData]
           ([Server]
           ,[UserID]
           ,[MAINTradeID]
           ,[MAINOrderID]
           ,[OrderID]
           ,[ExchangeOrderNo]
           ,[ExchangeTradeID]
           ,[OrderTime]
           ,[ExchangeOrderTime]
           ,[ExchangeTradeTime]
           ,[Exchange]
           ,[SecurityID]
           ,[Symbol]
           ,[ExpiryDate]
           ,[SecurityType]
           ,[Side]
           ,[OrderType]
           ,[Quantity]
           ,[PendingQuantity]
           ,[Price]
           ,[StrikePrice]
           ,[ClientID]
           ,[ReferenceText]
           ,[CTCLId]
           ,[MemberID]
           ,[StrategyID]
           ,[OptionType]
           ,[OpenClose]
           ,[ProductType]
           ,[ManagerID]
           ,[Pancard]
           ,[TerminalInfo]
           ,[AlgoID]
           ,[AlgoCategory]
           ,[ParticipantID]
           ,[Multiplier])
     select
		[Server]
           ,[UserID]
           ,[MAINTradeID]
           ,[MAINOrderID]
           ,[OrderID]
           ,[ExchangeOrderNo]
           ,[ExchangeTradeID]
           ,[OrderTime]
           ,[ExchangeOrderTime]
           ,[ExchangeTradeTime]
           ,[Exchange]
           ,[SecurityID]
           ,[Symbol]
           ,[ExpiryDate]
           ,[SecurityType]
           ,[Side]
           ,[OrderType]
           ,[Quantity]
           ,[PendingQuantity]
           ,[Price]
           ,[StrikePrice]
           ,[ClientID]
           ,[ReferenceText]
           ,[CTCLId]
           ,[MemberID]
           ,[StrategyID]
           ,[OptionType]
           ,[OpenClose]
           ,[ProductType]
           ,[ManagerID]
           ,[Pancard]
           ,[TerminalInfo]
           ,[AlgoID]
           ,[AlgoCategory]
           ,[ParticipantID]
           ,[Multiplier]
		from 
[dbo].[UPLOAD]

select * from CreateToken

DELETE FROM CreateToken

INSERT INTO [dbo].[CreateToken]
           ([ManagerID]
           ,[ReferenceText]
		   ,[StrategyID]
           ,[Exchange]
           ,[SecurityType]
           ,[Symbol]
           ,[ExpiryDate]
           ,[OptionType]
           ,[StrikePrice]
           ,[BuyQuantity]
           ,[BuyAmount]
           ,[SellQuantity]
           ,[SellAmount]
		   ,[ExchangeTradeTime]
		   ,Multiplier)
SELECT 
    [ManagerID],
    [ReferenceText],
	[StrategyID],
	[Exchange],
    [SecurityType],
    [Symbol],
    CAST(UPPER(FORMAT(CONVERT(DATE, [ExpiryDate], 112), 'ddMMMyyyy')) AS VARCHAR),
    (CASE WHEN [OptionType] LIKE 'XX' THEN '' ELSE [OptionType] END) AS [OptionType],
    (CASE WHEN [StrikePrice] LIKE '-0.01' THEN '' ELSE [StrikePrice] END) AS [StrikePrice],
    SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT) ELSE 0 END) AS [BuyQuantity],
    SUM(CASE WHEN [Side] = 'Buy' THEN (CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT) ) * CAST([Price] AS FLOAT) ELSE 0 END) AS [BuyAmount],
    SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT) ELSE 0 END) AS [SellQuantity],
    SUM(CASE WHEN [Side] = 'Sell' THEN (CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT)) * CAST([Price] AS FLOAT) ELSE 0 END) AS [SellAmount],
	UPPER(FORMAT(CONVERT(DATE, SUBSTRING([ExchangeTradeTime], 1, 8), 112), 'ddMMMyyyy')),
	Multiplier
FROM 
    [dbo].[StoreData]
WHERE 
	--TRY_CONVERT(DATE, ExpiryDate, 113) >= '2025-04-01'
    TRY_CONVERT(DATE, ExpiryDate, 113) IS NOT NULL AND
    TRY_CONVERT(DATE, ExpiryDate, 113) >= CAST(GETDATE() AS DATE)
GROUP BY
    [ManagerID],
    [ReferenceText],
	[StrategyID],
	[SecurityID],
    [Exchange],
    [SecurityType],
    [Symbol],
    [ExpiryDate],
    [OptionType],
    [StrikePrice],
	[ExchangeTradeTime],
	Multiplier
ORDER BY
    [ManagerID],
	ExpiryDate,
	OptionType,
	StrikePrice;


update CreateToken
set OptionType = ''
where OptionType is null



SELECT
ManagerID,
ReferenceText,
StrategyID,
Exchange,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice,
sum(BuyQuantity) as BuyQuantity,
sum(BuyAmount) as BuyAmount,
sum(SellQuantity)as SellQuantity,
sum(SellAmount) as SellAmount,
ExchangeTradeTime,
Multiplier
FROM CreateToken
group by
ManagerID,
ReferenceText,
StrategyID,
Exchange,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice,
ExchangeTradeTime,
Multiplier
HAVING
     (SUM(BuyQuantity) - SUM(SellQuantity)) <> 0
ORDER BY
    [ManagerID],
	Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;

select * from StoreData
where ExchangeTradeTime like '20250723%'

delete from StoreData
where ExchangeTradeTime like '20250722%'