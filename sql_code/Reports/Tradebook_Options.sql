use harsh_data;

Select * from TB_Opt;

--Table formation
/*create table TB_Opt(
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
ExchangeTradeTime varchar(30));*/

--Data Replace
TRUNCATE TABLE TB_Opt;
--Data Fetch
INSERT INTO TB_Opt(Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime)
SELECT Server, ManagerID, UserID, ClientID, MemberID, Exchange, StrategyID, SecurityType, SecurityID, Symbol, ExpiryDate, ReferenceText, OptionType, StrikePrice, Side, Quantity, Price, ExchangeTradeTime
FROM Options_Data;

DELETE FROM TB_Opt
WHERE ManagerID LIKE '%Mock';


