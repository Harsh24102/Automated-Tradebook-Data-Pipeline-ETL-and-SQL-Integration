use harsh_data;

DROP TABLE CheckRMS;

create table CheckRMS (
ManagerID Varchar(20),
Symbol Varchar(50),
ExpiryDate Date,
OptionType varchar(6),
Side char(10),
Quantity int,
Price Float,
StrikePrice Float,
BuyAmount Float,
SellAmount Float,
BuyQuantity int,
SellQuantity int,
NetQuantity int,
NetAmount Float,
BuyRate Float,
SellRate Float);

select * from CheckRMS;

INSERT INTO CheckRMS (ManagerID, Symbol, OptionType, ExpiryDate, Side, Quantity, Price, StrikePrice, BuyAmount, SellAmount, BuyQuantity, BuyRate, SellRate, SellQuantity, NetQuantity, NetAmount) 
SELECT ManagerID,Symbol,OptionType,ExpiryDate,Side,Quantity,Price,StrikePrice,BuyAmount,SellAmount,BuyQuantity,BuyRate,SellRate,SellQuantity,NetQuantity,NetAmount
FROM TradeBookApr;


Update CheckRMS
Set Symbol = 'BANKEX'
Where Symbol = 'BKX';

Update CheckRMS
Set Symbol = 'SENSEX'
Where Symbol = 'BSX';



