use harsh_data;

ALTER Table TM227
add BuyQuantity int,
	SellQuantity int,
	NetQuantity int;

Update TM227
set /*BuyQuantity = case
					When side = 'Buy' then Quantity
					else 0
				  End,
	SellQuantity = case
					When side = 'Sell' then Quantity
					else 0
				  End;*/
	NetQuantity = BuyQuantity - SellQuantity;

Select * from TM227;
