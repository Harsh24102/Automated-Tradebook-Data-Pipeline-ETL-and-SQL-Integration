use harsh_data;

select * from Tradebook_Apr;
select * from Apr_Match;

SELECT 
	[ManagerID],
	[UserID], 
	[ExchangeTradeTime], 
	[Symbol], 
	[StrategyID],
	[SecurityType],
	[Exchange],
	[ExpiryDate], 
	[OptionType], 
	[StrikePrice], 
	[Side],
	[BuyQuantity],
	[SellQuantity],
	[BuyAmount],
	[SellAmount]
--INTO New_Tradebook_Apr
FROM Tradebook_Apr

UNION ALL

SELECT 
	[ManagerID],
	[UserID],
	[TRADE_DATE1 ], 
	[Symbol], 
	[StrategyID],
	[SecurityType],
	[Exchange],
	[FormattedExpiryDate], 
	[OptionType], 
	[StrikePrice], 
	[Side], 
	[BuyQDifference] AS BuyQuantity,
	[SellQDifference] AS SellQuantity,
	[BuyADifference] AS BuyAmount,
	[SellADifference] AS SellAmount
FROM Apr_Match;

select * from New_Tradebook_Apr;

Alter Table New_TB_April
add BuyRate Float,
	SellRate Float,
	NetQuantity int,
	NetAmount Float;

UPDATE New_Tradebook_Apr
SET BuyRate = CASE 
                  WHEN Side = 'Buy' AND BuyQuantity <> 0 THEN BuyAmount / BuyQuantity
                  ELSE 0
              END,
    SellRate = CASE 
                   WHEN Side = 'Sell' AND SellQuantity <> 0 THEN SellAmount / SellQuantity
                   ELSE 0
               END;


UPDATE New_Tradebook_Apr
SET NetQuantity = BuyQuantity - SellQuantity,
	NetAmount = SellAmount - BuyAmount;

select * from New_Tradebook_Apr;

