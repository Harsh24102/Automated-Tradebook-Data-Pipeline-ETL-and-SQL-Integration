use harsh_data;

--Table formation
create table Aug_Cross_Check(
Server varchar(20),
ManagerID varchar(20),
UserID varchar(20),
ClientID Varchar(20),
MemberID int,
Exchange varchar(20),
StrategyID int,
SecurityType Varchar(20),
SecurityID int,
Symbol varchar(80),
ExpiryDate Date,
ReferenceText varchar(80),
OptionType Varchar(6),
StrikePrice Float,
Side char(10),
Quantity int,
Price Float,
ExchangeTradeTime varchar(30));

Select * from Aug_Cross_Check;

Select * from Aug_Update;

--Data Replace
TRUNCATE TABLE Aug_Cross_Check;
--Data Fetch
INSERT INTO Aug_Cross_Check(Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime
FROM Aug_Update;

Select * from Aug_Cross_Check;

-- Update ExchangeTradeTime column to the format YYYY-MM-DD
UPDATE Aug_Cross_Check
SET ExchangeTradeTime = CONVERT(VARCHAR(10), LEFT(ExchangeTradeTime, 8), 120);  -- Converts to YYYY-MM-DD format

UPDATE Aug_Cross_Check
SET ExchangeTradeTime = STUFF(STUFF(ExchangeTradeTime, 5, 0, '-'), 8, 0, '-');

--For Token formattion
Alter table Aug_Cross_Check
ADD Token varchar(100);

Alter table Aug_Cross_Check
drop column ReferenceText;

UPDATE Aug_Cross_Check
SET Token = CONCAT(
    ManagerID, ' ',
	StrategyID, ' ',
	Symbol, ' ',
	ExpiryDate, ' ',
    OptionType, ' ',
	StrikePrice
);

Alter table Aug_Cross_Check
drop column BuyQuantity,SellQuantity,BuyRate,SellRate,BuyAmount,SellAmount,NetQuantity,NetAmount;   

Alter table Aug_Cross_Check
ADD BuyQuantity int,
	SellQuantity int,
	BuyAmount Float,
    SellAmount Float;
	--BuyRate Float,
	--SellRate Float,
	--NetQuantity int,
	--NetAmount Float;

Update Aug_Cross_Check
SET /*BuyQuantity = case
					When side = 'Buy' then Quantity
					else 0
				  End,
	SellQuantity = case
					When side = 'Sell' then Quantity
					else 0
				  End;*/
	BuyAmount = CASE 
                    WHEN Side = 'Buy' THEN Quantity * Price
                    ELSE 0
                END,
    SellAmount = CASE 
                     WHEN Side = 'Sell' THEN Quantity * Price 
                     ELSE 0
                 END;
	--NetQuantity = BuyQuantity - SellQuantity;
	--NetAmount = SellAmount - BuyAmount;
	/*BuyRate = CASE 
                  WHEN Side = 'Buy' AND Quantity <> 0 THEN BuyAmount / Quantity
                  ELSE 0
              END,
    SellRate = CASE 
                   WHEN Side = 'Sell' AND Quantity <> 0 THEN SellAmount / Quantity
                   ELSE 0
               END;*/

--Options TradeDatewise
SELECT 
    ManagerID,
    Symbol,
    Exchange,
    SecurityType,
    Token,
    MAX(ExchangeTradeTime) AS ExchangeTradeTime,  
    SUM(BuyQuantity) AS TotalBuyQuantity,
    SUM(SellQuantity) AS TotalSellQuantity,
    SUM(BuyAmount) AS TotalBuyAmount,
    SUM(SellAmount) AS TotalSellAmount
--INTO Options_Strategy_wise
FROM 
    Aug_Cross_Check
WHERE 
    SecurityType LIKE 'OPTIDX'
GROUP BY 
    ManagerID, Symbol, Exchange, Token, SecurityType,ExchangeTradeTime  -- Group by TradeDate
ORDER BY 
    ManagerID, Symbol, ExchangeTradeTime, Token;  -- Sort by TradeDate