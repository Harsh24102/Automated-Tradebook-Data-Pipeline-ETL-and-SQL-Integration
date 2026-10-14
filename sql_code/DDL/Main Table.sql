use harsh_data;

--drop table TradeBookApr;

create table TradeBookApr(
Server varchar(20),
ManagerID varchar(20),
UserID varchar(20),
ClientID Varchar(10),
MemberID int,
Exchange varchar(20),
StrategyID int,
SecurityType Varchar(20),
SecurityID int,
Symbol varchar(50),
ExpiryDate Date,
ReferenceText varchar(50),
OptionType Varchar(6),
StrikePrice Float,
Side char(10),
Quantity int,
Price Float);

Select * from TradeBookApr;

INSERT INTO TradeBookApr(Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price
FROM TM1Apr2;

Select * from TradeBookApr;
