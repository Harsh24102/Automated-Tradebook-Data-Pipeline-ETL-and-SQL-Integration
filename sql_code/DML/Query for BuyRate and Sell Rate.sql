use harsh_data;

ALTER TABLE TM227
ADD BuyRate Float,  --Buy Rate
    SellRate Float; --Sell Rate

UPDATE TM227
SET BuyRate = CASE 
                  WHEN Side = 'Buy' AND Quantity <> 0 THEN BuyAmount / Quantity
                  ELSE 0
              END,
    SellRate = CASE 
                   WHEN Side = 'Sell' AND Quantity <> 0 THEN SellAmount / Quantity
                   ELSE 0
               END;

Select * from TM227;