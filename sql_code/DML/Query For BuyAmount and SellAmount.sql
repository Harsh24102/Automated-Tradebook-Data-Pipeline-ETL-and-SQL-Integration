use harsh_data;

ALTER TABLE TM227 ----BuyAmount and SellAmount
ADD BuyAmount Float,      
    SellAmount Float, 
	NetAmount Float;

UPDATE TM227
SET /*BuyAmount = CASE 
                    WHEN Side = 'Buy' THEN Quantity * Price
                    ELSE 0
                END,
    SellAmount = CASE 
                     WHEN Side = 'Sell' THEN Quantity * Price  -- Assuming you use the same Price for SellAmount; adjust if different
                     ELSE 0
                 END;*/
	NetAmount = SellAmount - BuyAmount;
   
Select * from TM227;
