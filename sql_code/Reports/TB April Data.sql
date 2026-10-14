use harsh_data;

--table formation
create table Tradebook_Apr(
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
Price Float,
ExchangeTradeTime varchar(20));

Select * from Tradebook_Apr;

Select * from Clubed;

--Data Fetch
INSERT INTO Tradebook_Apr(Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime
FROM Clubed;

Select * from Tradebook_Apr;


 