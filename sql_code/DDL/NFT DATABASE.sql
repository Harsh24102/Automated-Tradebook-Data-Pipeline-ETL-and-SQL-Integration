USE [2526 GNFTOPT]
GO
/*
delete from [dbo].[IFSC-NFT]
where ExchangeTradeTime like '20250520%'
delete from [dbo].[IFSC-NFT]
where ExchangeTradeTime like '20250519%'
*/


INSERT INTO [dbo].[IFSC-NFT]
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
    CAST([ExpiryDate] AS VARCHAR),
    (CASE WHEN [OptionType] LIKE 'XX' THEN '' ELSE [OptionType] END) AS [OptionType],
    (CASE WHEN [StrikePrice] LIKE '-0.01' THEN '' ELSE [StrikePrice] END) AS [StrikePrice],
    SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT) ELSE 0 END) AS [BuyQuantity],
    SUM(CASE WHEN [Side] = 'Buy' THEN (CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT) ) * CAST([Price] AS FLOAT) ELSE 0 END) AS [BuyAmount],
    SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT) ELSE 0 END) AS [SellQuantity],
    SUM(CASE WHEN [Side] = 'Sell' THEN (CAST([Quantity] AS FLOAT) * CAST([Multiplier] AS FLOAT)) * CAST([Price] AS FLOAT) ELSE 0 END) AS [SellAmount],
	UPPER(FORMAT(CONVERT(DATE, SUBSTRING([ExchangeTradeTime], 1, 8), 112), 'ddMMMyyyy')),
	Multiplier
FROM [dbo].[IFSC-NFT]
    
WHERE 
    CONVERT(DATE, [ExpiryDate], 106) > (GETDATE()-1) -- Filter for future expiry dates
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
set StrikePrice = ''
where StrikePrice like '0'
update CreateToken
set ReferenceText = '0'
where ReferenceText like ''
update CreateToken
set StrikePrice = ''
where SecurityType like 'FUTIDX'




------------------------------------------------------

SELECT
ManagerID,
ReferenceText,
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
CAST(Multiplier AS FLOAT) AS Multiplier
FROM CreateToken
group by
ManagerID,
ReferenceText,
Exchange,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice,
CAST(Multiplier AS FLOAT)
HAVING
     (SUM(BuyQuantity) - SUM(SellQuantity)) <> 0
ORDER BY
    [ManagerID],
	Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;


