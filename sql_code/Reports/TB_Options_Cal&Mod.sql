use harsh_data;

-- Update ExchangeTradeTime column to the format YYYY-MM-DD
UPDATE TB_Opt
SET ExchangeTradeTime = CONVERT(VARCHAR(10), LEFT(ExchangeTradeTime, 8), 120);  -- Converts to YYYY-MM-DD format

UPDATE TB_Opt
SET ExchangeTradeTime = STUFF(STUFF(ExchangeTradeTime, 5, 0, '-'), 8, 0, '-');

--For Token formattion
/*Alter table TB_Opt
ADD Token varchar(100);

Alter table TB_Opt
drop column Ref_Tn;*/

UPDATE TB_Opt
SET Token = CONCAT(
    ManagerID, ' ',
	StrategyID, ' ',
	Symbol, ' ',
	ExpiryDate, ' ',
    OptionType, ' ',
	StrikePrice
);

/*Alter table TB_Opt
drop column BuyQuantity,SellQuantity,BuyRate,SellRate,BuyAmount,SellAmount,NetQuantity,NetAmount; 

Alter table TB_Opt
ADD BuyQuantity int,
	SellQuantity int,
	BuyAmount Float,
    SellAmount Float;
	--BuyRate Float,
	--SellRate Float,
	--NetQuantity int,
	--NetAmount Float;*/

Update TB_Opt
SET BuyQuantity = case
					When side = 'Buy' then Quantity
					else 0
				  End,
	SellQuantity = case
					When side = 'Sell' then Quantity
					else 0
				  End,
	BuyAmount = CASE 
                    WHEN Side = 'Buy' THEN Quantity * Price
                    ELSE 0
                END,
    SellAmount = CASE 
                     WHEN Side = 'Sell' THEN Quantity * Price 
                     ELSE 0
                 END;
	/*BuyRate = CASE 
                  WHEN Side = 'Buy' AND Quantity <> 0 THEN BuyAmount / Quantity
                  ELSE 0
              END,
    SellRate = CASE 
                   WHEN Side = 'Sell' AND Quantity <> 0 THEN SellAmount / Quantity
                   ELSE 0
               END,
	NetQuantity = BuyQuantity - SellQuantity,
	NetAmount = SellAmount - BuyAmount;*/

DELETE FROM TB_Opt
WHERE ExchangeTradeTime = '2025-02-19';  -- Replace with the date you want to remove
