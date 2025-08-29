use [2526 ALLOPT]
go

/*
DELETE FROM StoreData
WHERE ExchangeTradeTime LIKE '%20250401%'

DELETE FROM StoreData
WHERE ExchangeTradeTime LIKE '%20250527%'
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
           ,[CTCLID]
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
           ,[CTCLID]
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
		  
		from [dbo].[UPLOAD]

GO



delete from CreateToken

--------------- insert data "EXPOPT"
INSERT INTO [dbo].[CreateToken]
           ([ManagerID]
           ,[ReferenceText]
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
		   ,[ExchangeTradeTime])
SELECT 
    [ManagerID],
    [ReferenceText],
    [Exchange],
    [SecurityType],
    [Symbol],
    [ExpiryDate],
    (CASE WHEN [OptionType] LIKE 'XX' THEN '' ELSE [OptionType] END) AS [OptionType],
    [StrikePrice],
    SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) AS [BuyQuantity],
    SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) * CAST([Price] AS FLOAT) ELSE 0 END) AS [BuyAmount],
    SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) AS [SellQuantity],
    SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) * CAST([Price] AS FLOAT) ELSE 0 END) AS [SellAmount],
	UPPER(FORMAT(CONVERT(DATE, SUBSTRING([ExchangeTradeTime], 1, 8), 112), 'ddMMMyyyy'))
FROM 
    [dbo].[StoreData]
WHERE 
    ExpiryDate LIKE '%2025'
    AND TRY_CAST(ExpiryDate AS DATE) IS NOT NULL
    AND TRY_CAST(ExpiryDate AS DATE) > (GETDATE() - 1)
GROUP BY
    [ManagerID],
    [ReferenceText],
    [Exchange],
    [SecurityType],
    [Symbol],
    [ExpiryDate],
    [OptionType],
    [StrikePrice],
	UPPER(FORMAT(CONVERT(DATE, SUBSTRING([ExchangeTradeTime], 1, 8), 112), 'ddMMMyyyy'))
HAVING
     SUM(CASE WHEN [Side] = 'Sell' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) 
    - SUM(CASE WHEN [Side] = 'Buy' THEN CAST([Quantity] AS FLOAT) ELSE 0 END) <> 0
ORDER BY
    [ManagerID],
	ExpiryDate,
	OptionType,
	StrikePrice;





update CreateToken
set ReferenceText = '0'
where ReferenceText like ''
update CreateToken
set StrikePrice = ''
where SecurityType like 'FUT%'


delete from CreateToken
where ExpiryDate like 'EQ'

--------------------------------------------------------------


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
sum(SellAmount) as SellAmount
FROM CreateToken
group by
ManagerID,
ReferenceText,
Exchange,
SecurityType,
Symbol,
ExpiryDate,
OptionType,
StrikePrice
HAVING
     (SUM(BuyQuantity) - SUM(SellQuantity)) <> 0
ORDER BY
    [ManagerID],
	Symbol,
    ExpiryDate,
    OptionType,
    StrikePrice;
