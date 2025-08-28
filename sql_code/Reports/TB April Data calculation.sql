use harsh_data;

Select * from Tradebook_Apr;

--Formula for finding NetQuantity & NetAmount
Alter table Tradebook_Apr
ADD BuyAmount Float,      
    SellAmount Float, 
	NetAmount Float,
	BuyQuantity int,
	SellQuantity int,
	NetQuantity int,
	BuyRate Float, 
    SellRate Float; 

Update Tradebook_Apr
SET /*BuyAmount = CASE 
                    WHEN Side = 'Buy' THEN Quantity * Price
                    ELSE 0
                END,
    SellAmount = CASE 
                     WHEN Side = 'Sell' THEN Quantity * Price 
                     ELSE 0
                 END;*/
	NetAmount = SellAmount - BuyAmount;
	/*BuyQuantity = case
					When side = 'Buy' then Quantity
					else 0
				  End,
	SellQuantity = case
					When side = 'Sell' then Quantity
					else 0
				  End;*/
	--NetQuantity = BuyQuantity - SellQuantity;
	/*BuyRate = CASE 
                  WHEN Side = 'Buy' AND Quantity <> 0 THEN BuyAmount / Quantity
                  ELSE 0
              END,
    SellRate = CASE 
                   WHEN Side = 'Sell' AND Quantity <> 0 THEN SellAmount / Quantity
                   ELSE 0
               END;*/
Select * from Tradebook_Apr;