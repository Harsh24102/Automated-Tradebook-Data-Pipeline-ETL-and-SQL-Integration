use harsh_data;

drop table GREEK_TradeBook;

--Table Formation
CREATE TABLE GREEK_TradeBook(
	ManagerID Varchar(20),
	ClientID Int,
	Exchange Varchar(10),
	SecurityType Varchar(20),
	Symbol Varchar(50),
	ExpiryDate Date,
	StrikePrice Float,
	OptionType Char(10),
	Side Char(10),
	Quantity int,
	Price Float,
	TradeDate Date,
	TradeTime Time);

--Data Replace
TRUNCATE TABLE GREEK_TradeBook;

--Data Fetch
INSERT INTO GREEK_TradeBook(ManagerID, ClientID, Exchange, SecurityType, Symbol, ExpiryDate,OptionType, StrikePrice, Side, Quantity, Price, TradeDate, TradeTime)
SELECT ManagerID, ClientID, Exchange, SecurityType, Symbol, ExpiryDate, OptionType, StrikePrice, Side, Quantity, Price, TradeDate, TradeTime
FROM [2526 GREEK].dbo.StoreData;

Select * from GREEK_TradeBook

Alter Table GREEK_TradeBook
ADD BuyQuantity int,
	SellQuantity int,
	BuyAmount Float,
    SellAmount Float,
	BuyRate Float,
	SellRate Float,
	NetQuantity int,
	NetAmount Float;

Update GREEK_TradeBook
SET BuyQuantity = case
					When side = 'Buy' then Quantity
					else 0
				  End,
	SellQuantity = case
					When side = 'Sell' then Quantity
					else 0
				  End;

Update GREEK_TradeBook
SET BuyAmount = CASE 
                    WHEN Side = 'Buy' THEN Quantity * Price
                    ELSE 0
                END,
    SellAmount = CASE 
                     WHEN Side = 'Sell' THEN Quantity * Price 
                     ELSE 0
                 END;

Update GREEK_TradeBook
SET BuyRate = CASE 
                  WHEN Side = 'Buy' AND Quantity <> 0 THEN BuyAmount / Quantity
                  ELSE 0
              END,
    SellRate = CASE 
                   WHEN Side = 'Sell' AND Quantity <> 0 THEN SellAmount / Quantity
                   ELSE 0
               END;

Update GREEK_TradeBook
SET	NetQuantity = BuyQuantity - SellQuantity,
	NetAmount = SellAmount - BuyAmount;